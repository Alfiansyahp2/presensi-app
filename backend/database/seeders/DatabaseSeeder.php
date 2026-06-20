<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * Seeder ini akan mengisi database dengan data user dan absensi
     * sesuai dengan struktur database aktual dari presensis (2).sql
     */
    public function run(): void
    {
        // Seed users terlebihulu (absensi membutuhkan user)
        $this->call([
            UserSeeder::class,
            AbsensiSeeder::class,
        ]);
    }
}
