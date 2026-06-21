<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('schools', function (Blueprint $table) {
            $table->id();
            $table->string('nama_sekolah');
            $table->string('kode_sekolah')->unique();
            $table->text('alamat')->nullable();
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->integer('radius_presensi')->default(50); // meter
            $table->time('jam_masuk')->default('07:00:00');
            $table->time('jam_pulang')->default('15:00:00');
            $table->integer('toleransi_terlambat')->default(10); // menit
            $table->boolean('status_aktif')->default(true);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('schools');
    }
};
