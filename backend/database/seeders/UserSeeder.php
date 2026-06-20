<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Seeder untuk data user siswa
     *
     * Berdasarkan data aktual dari presensis (2).sql
     *
     * Password default: 'password123' (atau dari env SEEDER_PASSWORD)
     */
    public function run(): void
    {
        // Default password dari env atau gunakan 'password123'
        $defaultPassword = env('SEEDER_PASSWORD', 'password123');

        User::updateOrCreate(
            ['email' => 'arlen@gmail.com'],
            [
                'fullname' => 'arlen',
                'nisn' => '1234567890',
                'kelas' => '12',
                'email' => 'arlen@gmail.com',
                'password' => Hash::make($defaultPassword),
            ]
        );

        // Optional: Tambah user admin
        User::updateOrCreate(
            ['email' => 'admin@presensi.sch.id'],
            [
                'fullname' => 'Administrator',
                'nisn' => 'ADMIN001',
                'kelas' => 'ADMIN',
                'email' => 'admin@presensi.sch.id',
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
                    'email' => 'siswa1@test.com',
                ],
                [
                    'fullname' => 'Siswa Test 2',
                    'nisn' => '1234567892',
                    'kelas' => '11',
                    'email' => 'siswa2@test.com',
                ],
                [
                    'fullname' => 'Siswa Test 3',
                    'nisn' => '1234567893',
                    'kelas' => '12',
                    'email' => 'siswa3@test.com',
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
    }
}
