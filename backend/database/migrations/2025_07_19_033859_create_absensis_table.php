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
        Schema::create('absensis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('status', ['hadir', 'tidak_hadir', 'izin']);
            $table->text('keterangan')->nullable();
            $table->date('tanggal');
            $table->time('jam')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();   // Tambah kolom latitude
            $table->decimal('longitude', 11, 8)->nullable();  // Tambah kolom longitude
            $table->timestamps(); // created_at & updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('absensis');
    }
};
