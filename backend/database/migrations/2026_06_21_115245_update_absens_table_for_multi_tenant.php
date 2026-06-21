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
        Schema::table('absens', function (Blueprint $table) {
            // Foreign key ke schools - NULLABLE dulu untuk data existing
            $table->foreignId('school_id')
                  ->nullable()
                  ->after('id')
                  ->constrained('schools')
                  ->nullOnDelete();

            // Jam masuk & pulang
            $table->time('jam_masuk')->nullable()->after('status');
            $table->time('jam_pulang')->nullable()->after('jam_masuk');

            // Foto absensi
            $table->string('foto_absen_masuk')->nullable()->after('jam_pulang');
            $table->string('foto_absen_pulang')->nullable()->after('foto_absen_masuk');

            // Jarak & alasan
            $table->integer('jarak_meter')->nullable()->after('longitude');
            $table->text('alasan')->nullable()->after('jarak_meter');
        });

        // Update status enum - perlu raw SQL karena modify column enum
        DB::statement("ALTER TABLE absens MODIFY COLUMN status ENUM('BELUM_ABSEN', 'HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'PULANG') DEFAULT 'BELUM_ABSEN'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('absens', function (Blueprint $table) {
            $table->dropForeign(['school_id']);
            $table->dropColumn([
                'school_id',
                'jam_masuk',
                'jam_pulang',
                'foto_absen_masuk',
                'foto_absen_pulang',
                'jarak_meter',
                'alasan',
            ]);
        });

        // Revert status enum
        DB::statement("ALTER TABLE absens MODIFY COLUMN status ENUM('hadir', 'izin', 'sakit') DEFAULT 'hadir'");
    }
};
