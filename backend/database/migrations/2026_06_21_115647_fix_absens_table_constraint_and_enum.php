<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Step 1: Update status enum saja (foreign key sudah ada di migration sebelumnya)
        DB::statement("ALTER TABLE absens MODIFY COLUMN status ENUM('BELUM_ABSEN', 'HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'PULANG') DEFAULT 'BELUM_ABSEN'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert status enum
        DB::statement("ALTER TABLE absens MODIFY COLUMN status ENUM('hadir', 'izin', 'sakit') DEFAULT 'hadir'");
    }
};
