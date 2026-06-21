<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class School extends Model
{
    use HasFactory;

    protected $fillable = [
        'nama_sekolah',
        'kode_sekolah',
        'alamat',
        'latitude',
        'longitude',
        'radius_presensi',
        'jam_masuk',
        'jam_pulang',
        'toleransi_terlambat',
        'status_aktif',
    ];

    protected $casts = [
        'status_aktif' => 'boolean',
        // jam_masuk & jam_pulang: Biarkan apa adanya dari database (format TIME)
        // Backend akan mengirim "07:00:00" bukan "2026-06-21T07:00:00"
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
    ];

    /**
     * Relasi ke users
     */
    public function users()
    {
        return $this->hasMany(User::class);
    }

    /**
     * Relasi ke attendances (absens)
     */
    public function attendances()
    {
        return $this->hasMany(Absensi::class, 'school_id');
    }
}
