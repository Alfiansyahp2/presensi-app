<?php

namespace Database\Seeders;

use App\Models\Absensi;
use App\Models\User;
use Illuminate\Database\Seeder;

class AbsensiSeeder extends Seeder
{
    /**
     * Seeder untuk data absensi siswa
     *
     * Berdasarkan data aktual dari presensis (2).sql
     * Koordinat: Area MA-2, Medokan Asri Tengah, Surabaya
     *
     * Note: Data ini merepresentasikan testing berulang dalam rentang waktu singkat
     */
    public function run(): void
    {
        // Get user arlen (user_id = 1)
        $user = User::where('email', 'arlen@gmail.com')->first();

        if (!$user) {
            $this->command->warn('User arlen@gmail.com not found. Skipping AbsensiSeeder.');
            return;
        }

        // Data absensi dari SQL dump (5 records)
        $absensiData = [
            [
                'user_id' => $user->id,
                'status' => 'hadir',
                'latitude' => '-7.3280711',
                'longitude' => '112.7943562',
                'waktu_absen' => '2026-05-12 04:02:43',
                'created_at' => '2026-05-11 21:02:43',
                'updated_at' => '2026-05-11 21:02:43',
            ],
            [
                'user_id' => $user->id,
                'status' => 'hadir',
                'latitude' => '-7.3280711',
                'longitude' => '112.7943562',
                'waktu_absen' => '2026-05-12 04:02:54',
                'created_at' => '2026-05-11 21:02:54',
                'updated_at' => '2026-05-11 21:02:54',
            ],
            [
                'user_id' => $user->id,
                'status' => 'hadir',
                'latitude' => '-7.3280711',
                'longitude' => '112.7943562',
                'waktu_absen' => '2026-05-12 04:06:25',
                'created_at' => '2026-05-11 21:06:25',
                'updated_at' => '2026-05-11 21:06:25',
            ],
            [
                'user_id' => $user->id,
                'status' => 'hadir',
                'latitude' => '-7.3280715',
                'longitude' => '112.7943504',
                'waktu_absen' => '2026-05-12 04:06:44',
                'created_at' => '2026-05-11 21:06:44',
                'updated_at' => '2026-05-11 21:06:44',
            ],
            [
                'user_id' => $user->id,
                'status' => 'hadir',
                'latitude' => '-7.3280644',
                'longitude' => '112.7943521',
                'waktu_absen' => '2026-05-12 04:23:13',
                'created_at' => '2026-05-11 21:23:13',
                'updated_at' => '2026-05-11 21:23:13',
            ],
        ];

        foreach ($absensiData as $data) {
            Absensi::updateOrCreate(
                [
                    'user_id' => $data['user_id'],
                    'waktu_absen' => $data['waktu_absen'],
                ],
                $data
            );
        }

        // Optional: Tambah data absensi contoh untuk development
        if (app()->environment() === 'local') {
            $testUser = User::where('email', 'siswa1@test.com')->first();

            if ($testUser) {
                // Tambah beberapa absensi test
                $testAbsensi = [
                    [
                        'user_id' => $testUser->id,
                        'status' => 'hadir',
                        'latitude' => '-7.3278000',
                        'longitude' => '112.7942000',
                        'waktu_absen' => now()->subDays(5)->setHour(7)->setMinute(0)->format('Y-m-d H:i:s'),
                    ],
                    [
                        'user_id' => $testUser->id,
                        'status' => 'izin',
                        'latitude' => '-7.3278000',
                        'longitude' => '112.7942000',
                        'waktu_absen' => now()->subDays(4)->setHour(7)->setMinute(0)->format('Y-m-d H:i:s'),
                    ],
                    [
                        'user_id' => $testUser->id,
                        'status' => 'sakit',
                        'latitude' => '-7.3278000',
                        'longitude' => '112.7942000',
                        'waktu_absen' => now()->subDays(3)->setHour(7)->setMinute(0)->format('Y-m-d H:i:s'),
                    ],
                ];

                foreach ($testAbsensi as $data) {
                    Absensi::create($data);
                }
            }
        }
    }
}
