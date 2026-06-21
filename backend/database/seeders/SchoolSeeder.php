<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\School;

class SchoolSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $schools = [
            [
                // Sekolah A - MA-2 Surabaya (Existing School)
                'nama_sekolah' => 'MA-2 Surabaya',
                'kode_sekolah' => 'MA02-SBY',
                'alamat' => 'Jl. Tunjungan No. 1, Surabaya, Jawa Timur',
                'latitude' => -7.3278726,
                'longitude' => 112.7942679,
                'radius_presensi' => 50, // meter
                'jam_masuk' => '07:00:00',
                'jam_pulang' => '15:00:00',
                'toleransi_terlambat' => 10, // menit
                'status_aktif' => true,
            ],
            [
                // Sekolah B - SMA Negeri 1 Jakarta
                'nama_sekolah' => 'SMA Negeri 1 Jakarta',
                'kode_sekolah' => 'SMAN1-JKT',
                'alamat' => 'Jl. Budi Utomo, Jakarta Pusat, DKI Jakarta',
                'latitude' => -6.2088,
                'longitude' => 106.8456,
                'radius_presensi' => 100, // meter
                'jam_masuk' => '06:30:00',
                'jam_pulang' => '14:00:00',
                'toleransi_terlambat' => 15, // menit
                'status_aktif' => true,
            ],
            [
                // Sekolah C - SMA Negeri 1 Bandung
                'nama_sekolah' => 'SMA Negeri 1 Bandung',
                'kode_sekolah' => 'SMAN1-BDG',
                'alamat' => 'Jl. Ir. H. Juanda, Bandung, Jawa Barat',
                'latitude' => -6.9215,
                'longitude' => 107.6108,
                'radius_presensi' => 75, // meter
                'jam_masuk' => '07:30:00',
                'jam_pulang' => '16:00:00',
                'toleransi_terlambat' => 5, // menit
                'status_aktif' => true,
            ],
        ];

        foreach ($schools as $school) {
            School::create($school);
        }

        $this->command->info('✅ Successfully seeded ' . count($schools) . ' schools.');
    }
}
