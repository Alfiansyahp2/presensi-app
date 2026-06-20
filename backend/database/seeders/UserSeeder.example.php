<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeederExample extends Seeder
{
    /**
     * Example Seeder untuk User - DATA GENERIK
     *
     * Ini adalah TEMPLATE untuk developer lain.
     * Untuk data asli, gunakan UserSeeder.local.php
     *
     * Password default: 'password123' (atau dari env SEEDER_PASSWORD)
     */
    public function run(): void
    {
        // Default password dari env atau gunakan 'password123'
        $defaultPassword = env('SEEDER_PASSWORD', 'password123');

        // User siswa contoh (GANTI dengan data asli di UserSeeder.local.php)
        User::updateOrCreate(
            ['email' => 'siswa@example.com'],
            [
                'fullname' => 'Siswa Contoh',
                'nisn' => '1234567890',
                'kelas' => '12',
                'email' => 'siswa@example.com',
                'password' => Hash::make($defaultPassword),
            ]
        );

        // Optional: Tambah user admin
        User::updateOrCreate(
            ['email' => 'admin@sekolah.sch.id'],
            [
                'fullname' => 'Administrator',
                'nisn' => 'ADMIN001',
                'kelas' => 'ADMIN',
                'email' => 'admin@sekolah.sch.id',
                'password' => Hash::make(env('ADMIN_PASSWORD', 'admin123')),
            ]
        );

        // Optional: Tambah beberapa user test untuk development
        if (app()->environment() === 'local') {
            $testUsers = [
                [
                    'fullname' => 'Siswa Test 1',
                    'nisn' => '1234567891',
                    'kelas' => '10',
                    'email' => 'siswa1@test.local',
                ],
                [
                    'fullname' => 'Siswa Test 2',
                    'nisn' => '1234567892',
                    'kelas' => '11',
                    'email' => 'siswa2@test.local',
                ],
                [
                    'fullname' => 'Siswa Test 3',
                    'nisn' => '1234567893',
                    'kelas' => '12',
                    'email' => 'siswa3@test.local',
                ],
            ];

            foreach ($testUsers as $userData) {
                User::updateOrCreate(
                    ['email' => $userData['email']],
                    array_merge($userData, [
                        'password' => Hash::make($defaultPassword),
                    ])
                );
            }
        }

        $this->command->info('✅ Example users seeded successfully.');
        $this->command->warn('⚠️  This is example data only!');
        $this->command->warn('⚠️  For real data, create UserSeeder.local.php');
    }
}
