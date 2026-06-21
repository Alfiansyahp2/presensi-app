<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Absensi extends Model
{
    use HasFactory;

    protected $table = 'absens'; // Explicit table name to match actual database

    protected $fillable = [
        'school_id',
        'user_id',
        'status',
        'jam_masuk',
        'jam_pulang',
        'latitude',
        'longitude',
        'jarak_meter',
        'alasan',
        'foto_absen_masuk',
        'foto_absen_pulang',
    ];

    protected $casts = [
        'jam_masuk' => 'datetime:H:i:s',
        'jam_pulang' => 'datetime:H:i:s',
    ];

    /**
     * Relasi ke sekolah
     */
    public function school()
    {
        return $this->belongsTo(School::class);
    }

    /**
     * Relasi ke user
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope: filter absensi hari ini
     */
    public function scopeToday($query)
    {
        return $query->whereDate('created_at', today());
    }

    /**
     * Helper: ambil absensi hari ini untuk user tertentu
     */
    public static function getTodayAttendance($userId)
    {
        return self::where('user_id', $userId)
                   ->today()
                   ->first();
    }
}
