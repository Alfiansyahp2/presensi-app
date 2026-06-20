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
     * Menggantikan migration lama yang tidak sesuai dengan struktur aktual
     *
     * ⚠️ WARNING: Migration lama (2014_10_12_000000_create_users_table.php)
     *            tidak sesuai dengan database dan harus dihapus/diabaikan
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id()->comment('Primary Key');
            $table->string('fullname', 255)->comment('Nama lengkap siswa');
            $table->string('nisn', 255)->unique()->comment('Nomor Induk Siswa Nasional - Unique');
            $table->string('kelas', 255)->comment('Kelas siswa');
            $table->string('email', 255)->unique()->comment('Email login - Unique');
            $table->string('password')->comment('Password terenkripsi (bcrypt)');
            $table->rememberToken()->comment('Token untuk "remember me" login');
            $table->timestamps(); // created_at & updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
