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
        // Step 1: Update school_id = 0 jadi NULL (data existing)
        DB::statement("UPDATE absens SET school_id = NULL WHERE school_id = 0");

        // Step 2: Pastikan school_id nullable
        Schema::table('absens', function (Blueprint $table) {
            $table->unsignedBigInteger('school_id')->nullable()->change();
        });

        // Step 3: Tambah foreign key constraint
        Schema::table('absens', function (Blueprint $table) {
            $table->foreign('school_id')
                  ->references('id')
                  ->on('schools')
                  ->nullOnDelete();
        });

        // Step 4: Update status enum
        DB::statement("ALTER TABLE absens MODIFY COLUMN status ENUM('BELUM_ABSEN', 'HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'PULANG') DEFAULT 'BELUM_ABSEN'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Reverse foreign key
        Schema::table('absens', function (Blueprint $table) {
            $table->dropForeign(['school_id']);
        });

        // Revert school_id to NOT NULL
        Schema::table('absens', function (Blueprint $table) {
            $table->unsignedBigInteger('school_id')->nullable(false)->change();
        });

        // Revert status enum
        DB::statement("ALTER TABLE absens MODIFY COLUMN status ENUM('hadir', 'izin', 'sakit') DEFAULT 'hadir'");
    }
};
