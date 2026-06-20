<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Migration yang mencerminkan struktur database aktual presensis
     *
     * Berdasarkan SQL dump: presensis (2).sql - Jun 20, 2026
     * Menggantikan migration lama (2025_07_19_033859_create_absensis_table.php)
     * yang nama tabelnya salah ('absensis' vs 'absens') dan struktur kolom tidak sesuai
     *
     * PERUBAHAN UTAMA:
     * - Nama tabel: 'absens' (bukan 'absensis')
     * - Kolom status: enum('hadir', 'izin', 'sakit') (bukan 'tidak_hadir')
     * - Kolom waktu_absen: timestamp (bukan 'tanggal' + 'jam')
     * - Latitude/Longitude: decimal(10,7) untuk presisi GPS
     */
    public function up(): void
    {
        Schema::create('absens', function (Blueprint $table) {
            $table->id()->comment('Primary Key');
            $table->foreignId('user_id')
                  ->constrained('users')
                  ->onDelete('cascade')
                  ->comment('Foreign key ke users - Cascade delete');

            $table->enum('status', ['hadir', 'izin', 'sakit'])
                  ->default('hadir')
                  ->comment('Status kehadiran: hadir/izin/sakit');

            $table->decimal('latitude', 10, 7)->comment('Koordinat GPS latitude (presisi ~1cm)');
            $table->decimal('longitude', 10, 7)->comment('Koordinat GPS longitude (presisi ~1cm)');

            $table->timestamp('waktu_absen')
                  ->useCurrent()
                  ->comment('Waktu absensi - Auto set ke current timestamp');

            $table->timestamps(); // created_at & updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('absens');
    }
};
