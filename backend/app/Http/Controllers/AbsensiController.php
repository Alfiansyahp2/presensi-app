<?php

namespace App\Http\Controllers;

use App\Models\Absensi;
use App\Services\AttendanceService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AbsensiController extends Controller
{
    protected $attendanceService;

    public function __construct(AttendanceService $attendanceService)
    {
        $this->attendanceService = $attendanceService;
    }

    /**
     * Absen masuk (check-in)
     * POST /api/absensi/checkin
     */
    public function checkIn(Request $request)
    {
        $validated = $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'foto' => 'required|image|max:2048', // max 2MB
            'alasan' => 'nullable|string|max:500',
        ]);

        try {
            $user = auth()->user();

            // Cek apakah sudah absen hari ini
            $existing = Absensi::getTodayAttendance($user->id);
            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'Sudah absen hari ini',
                    'data' => $existing,
                ], 400);
            }

            // Upload foto absen masuk
            $fotoPath = null;
            if ($request->hasFile('foto')) {
                $fotoPath = $request->file('foto')
                                    ->store('absensi-masuk', 'public');
                $validated['foto'] = $fotoPath;
            }

            // Proses absen masuk
            $attendance = $this->attendanceService->checkIn($user, [
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'foto' => $fotoPath,
                'alasan' => $validated['alasan'] ?? null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Absen masuk berhasil',
                'data' => $attendance,
                'status_info' => [
                    'status' => $attendance->status,
                    'jam_masuk' => $attendance->jam_masuk,
                    'jam_pulang' => $attendance->jam_pulang,
                    'jarak_meter' => $attendance->jarak_meter . 'm',
                    'sekolah' => $user->school->nama_sekolah,
                ],
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Absen pulang (check-out)
     * POST /api/absensi/checkout
     */
    public function checkOut(Request $request)
    {
        $validated = $request->validate([
            'foto' => 'required|image|max:2048',
        ]);

        try {
            $user = auth()->user();

            // Upload foto absen pulang
            $fotoPath = null;
            if ($request->hasFile('foto')) {
                $fotoPath = $request->file('foto')
                                    ->store('absensi-pulang', 'public');
            }

            // Proses absen pulang
            $attendance = $this->attendanceService->checkOut($user, [
                'foto' => $fotoPath,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Absen pulang berhasil',
                'data' => $attendance,
                'status_info' => [
                    'status' => $attendance->status,
                    'jam_masuk' => $attendance->jam_masuk,
                    'jam_pulang' => $attendance->jam_pulang,
                    'durasi_kerja' => $this->calculateDuration($attendance->jam_masuk, $attendance->jam_pulang),
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Cek status hari ini
     * GET /api/absensi/today
     *
     * Response membantu frontend memutuskan tombol mana yang ditampilkan:
     * - BELUM_ABSEN → Tampilkan tombol "ABSEN MASUK" saja
     * - HADIR/TERLAMBAT → Tampilkan tombol "ABSEN PULANG" saja
     * - PULANG → Tidak ada tombol aktif (sudah selesai)
     */
    public function getTodayStatus(Request $request)
    {
        $user = auth()->user();
        $statusInfo = $this->attendanceService->getTodayStatus($user->id);
        $attendance = $statusInfo['data'];
        $status = $statusInfo['status'];

        // Tentukan tombol yang aktif
        $canCheckIn = ($status === 'BELUM_ABSEN');
        $canCheckOut = in_array($status, ['HADIR', 'TERLAMBAT']);
        $activeButton = null;
        $message = '';

        switch ($status) {
            case 'BELUM_ABSEN':
                $activeButton = 'checkin';
                $message = 'Silakan absen masuk';
                break;
            case 'HADIR':
                $activeButton = 'checkout';
                $message = 'Anda sudah Hadir. Silakan absen pulang setelah jam pulang.';
                break;
            case 'TERLAMBAT':
                $activeButton = 'checkout';
                $message = 'Anda terlambat. Silakan absen pulang setelah jam pulang.';
                break;
            case 'PULANG':
                $activeButton = 'none';
                $message = 'Anda sudah absen pulang hari ini.';
                break;
            default:
                $activeButton = 'none';
                $message = 'Status tidak dikenali';
        }

        $response = [
            'success' => true,
            'data' => [
                'status' => $status,
                'active_button' => $activeButton,
                'can_checkin' => $canCheckIn,
                'can_checkout' => $canCheckOut,
                'message' => $message,
                'attendance' => $attendance,
                'school' => $user->school ? [
                    'nama_sekolah' => $user->school->nama_sekolah,
                    'jam_masuk' => $user->school->jam_masuk,
                    'jam_pulang' => $user->school->jam_pulang,
                    'radius_presensi' => $user->school->radius_presensi,
                ] : null,
            ],
        ];

        return response()->json($response);
    }

    /**
     * Riwayat absensi user
     * GET /api/absensi/history
     */
    public function history(Request $request)
    {
        $absenList = Absensi::where('user_id', $request->user()->id)
            ->with('school')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $absenList
        ]);
    }

    /**
     * Helper: hitung durasi kerja (format: X jam Y menit)
     */
    private function calculateDuration($jamMasuk, $jamPulang): string
    {
        if (!$jamMasuk || !$jamPulang) {
            return '-';
        }

        $masuk = \Carbon\Carbon::parse($jamMasuk);
        $pulang = \Carbon\Carbon::parse($jamPulang);
        $diff = $masuk->diff($pulang);

        $hours = $diff->h + ($diff->days * 24);
        $minutes = $diff->i;

        return "{$hours} jam {$minutes} menit";
    }
}
