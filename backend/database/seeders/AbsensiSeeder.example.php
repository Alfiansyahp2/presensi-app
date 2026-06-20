<?php

namespace Database\Seeders;

use App\Models\Absensi;
use App\Models\User;
use Illuminate\Database\Seeder;

class AbsensiSeederExample extends Seeder
{
    /**
     * Example Seeder untuk Absensi - DATA GENERIK
     *
     * Ini adalah TEMPLATE untuk developer lain.
     * Untuk data asli, gunakan AbsensiSeeder.local.php
     */
    public function run(): void
    {
        // Get user siswa (contoh)
        $user = User::where('email', 'siswa@example.com')->first();

        if (!$user) {
            $this->command->warn('User siswa@example.com not found. Skipping AbsensiSeeder.');
            $this->command->info('Run UserSeeder first or check UserSeeder.local.php');
            return;
        }

        // Data absensi contoh (GANTI dengan data asli di AbsensiSeeder.local.php)
        $exampleAbsensi = [
            [
                'user_id' => $user->id,
                'status' => 'hadir',
                'latitude' => '-7.3278000',
                'longitude' => '112.7942000',
                'waktu_absen' => now()->setHour(7)->setMinute(0)->format('Y-m-d H:i:s'),
                'created_at' => now()->setHour(7)->setMinute(0),
                'updated_at' => now()->setHour(7)->setMinute(0),
            ],
            [
                'user_id' => $user->id,
                'status' => 'izin',
                'latitude' => '-7.3278000',
                'longitude' => '112.7942000',
                'waktu_absen' => now()->subDay()->setHour(7)->setMinute(0)->format('Y-m-d H:i:s'),
                'created_at' => now()->subDay()->setHour(7)->setMinute(0),
                'updated_at' => now()->subDay()->setHour(7)->setMinute(0),
            ],
            [
                'user_id' => $user->id,
                'status' => 'sakit',
                'latitude' => '-7.3278000',
                'longitude' => '112.7942000',
                'waktu_absen' => now()->subDays(2)->setHour(7)->setMinute(0)->format('Y-m-d H:i:s'),
                'created_at' => now()->subDays(2)->setHour(7)->setMinute(0),
                'updated_at' => now()->subDays(2)->setHour(7)->setMinute(0),
            ],
        ];

        foreach ($exampleAbsensi as $data) {
            Absensi::updateOrCreate(
                [
                    'user_id' => $data['user_id'],
                    'waktu_absen' => $data['waktu_absen'],
                ],
                $data
            );
        }

        $this->command->info('✅ Example attendance data seeded successfully.');
        $this->command->warn('⚠️  This is example data only!');
        $this->command->warn('⚠️  For real data, create AbsensiSeeder.local.php');

        // Optional: Add test data for development
        if (app()->environment() === 'local') {
            $testUser = User::where('email', 'siswa1@test.local')->first();

            if ($testUser) {
                Absensi::create([
                    'user_id' => $testUser->id,
                    'status' => 'hadir',
                    'latitude' => '-7.3278000',
                    'longitude' => '112.7942000',
                    'waktu_absen' => now()->subDays(5)->setHour(7)->setMinute(0),
                ]);
            }
        }
    }
}
