<?php

namespace App\Services;

use App\Models\User;
use App\Models\Absensi;
use App\Models\School;
use Carbon\Carbon;

class AttendanceService
{
    /**
     * Hitung jarak menggunakan Haversine formula (dalam meter)
     */
    public function calculateDistance($lat1, $lon1, $lat2, $lon2): float
    {
        $earthRadius = 6371; // km

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * asin(sqrt($a));
        $distance = $earthRadius * $c; // km

        return $distance * 1000; // meter
    }

    /**
     * Tentukan status berdasarkan waktu & toleransi sekolah
     *
     * @param Carbon $waktuAbsen
     * @param School $school
     * @return string 'HADIR' atau 'TERLAMBAT'
     */
    public function determineStatus(Carbon $waktuAbsen, School $school): string
    {
        $jamMasuk = Carbon::parse($school->jam_masuk);
        $toleransi = $school->toleransi_terlambat; // menit
        $batasTerlambat = $jamMasuk->copy()->addMinutes($toleransi);

        if ($waktuAbsen->lte($batasTerlambat)) {
            return 'HADIR';
        } else {
            return 'TERLAMBAT';
        }
    }

    /**
     * Validasi apakah user dalam radius presensi sekolah
     *
     * @param float $userLat
     * @param float $userLon
     * @param School $school
     * @return array ['valid' => bool, 'distance' => float, 'radius' => int]
     */
    public function validateLocation($userLat, $userLon, School $school): array
    {
        $distance = $this->calculateDistance(
            $userLat,
            $userLon,
            $school->latitude,
            $school->longitude
        );

        $isValid = $distance <= $school->radius_presensi;

        return [
            'valid' => $isValid,
            'distance' => round($distance, 2),
            'radius' => $school->radius_presensi,
        ];
    }

    /**
     * Proses absen masuk (check-in)
     *
     * @param User $user
     * @param array $data ['latitude', 'longitude', 'foto', 'alasan']
     * @return Absensi
     * @throws \Exception
     */
    public function checkIn(User $user, array $data): Absensi
    {
        $school = $user->school;
        $waktuAbsen = now();

        // Validasi: user harus punya school
        if (!$school) {
            throw new \Exception("User tidak terhubung ke sekolah manapun");
        }

        // Validasi lokasi
        $location = $this->validateLocation(
            $data['latitude'],
            $data['longitude'],
            $school
        );

        if (!$location['valid']) {
            throw new \Exception(
                "Di luar radius presensi. Jarak: {$location['distance']}m (Max: {$location['radius']}m)"
            );
        }

        // Tentukan status otomatis (HADIR atau TERLAMBAT)
        $status = $this->determineStatus($waktuAbsen, $school);

        // Simpan absen masuk
        $absensi = Absensi::create([
            'school_id' => $school->id,
            'user_id' => $user->id,
            'status' => $status,
            'jam_masuk' => $waktuAbsen->format('H:i:s'),
            'latitude' => $data['latitude'],
            'longitude' => $data['longitude'],
            'jarak_meter' => $location['distance'],
            'foto_absen_masuk' => $data['foto'] ?? null,
            'alasan' => $data['alasan'] ?? null,
        ]);

        return $absensi;
    }

    /**
     * Proses absen pulang (check-out)
     *
     * @param User $user
     * @param array $data ['foto']
     * @return Absensi
     * @throws \Exception
     */
    public function checkOut(User $user, array $data): Absensi
    {
        $attendance = Absensi::getTodayAttendance($user->id);

        // Validasi: harus sudah absen masuk dulu
        if (!$attendance) {
            throw new \Exception("Belum absen masuk hari ini");
        }

        // Validasi: status harus HADIR atau TERLAMBAT
        if (!in_array($attendance->status, ['HADIR', 'TERLAMBAT'])) {
            throw new \Exception("Status tidak valid untuk absen pulang. Status saat ini: {$attendance->status}");
        }

        // Validasi: sudah absen pulang belum
        if ($attendance->jam_pulang) {
            throw new \Exception("Sudah absen pulang hari ini");
        }

        // Validasi jam pulang
        $school = $user->school;
        $jamPulang = Carbon::parse($school->jam_pulang);
        $waktuSekarang = now();

        if ($waktuSekarang->lt($jamPulang)) {
            throw new \Exception(
                "Belum waktunya absen pulang. Jam pulang: {$school->jam_pulang}, Sekarang: {$waktuSekarang->format('H:i:s')}"
            );
        }

        // Update absen jadi PULANG
        $attendance->update([
            'status' => 'PULANG',
            'jam_pulang' => $waktuSekarang->format('H:i:s'),
            'foto_absen_pulang' => $data['foto'] ?? null,
        ]);

        return $attendance->fresh();
    }

    /**
     * Cek status absensi hari ini user
     *
     * @param int $userId
     * @return array ['status' => string, 'data' => Absensi|null]
     */
    public function getTodayStatus($userId): array
    {
        $attendance = Absensi::getTodayAttendance($userId);

        if (!$attendance) {
            return [
                'status' => 'BELUM_ABSEN',
                'data' => null,
            ];
        }

        return [
            'status' => $attendance->status,
            'data' => $attendance,
        ];
    }
}
