<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class School extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * SECURITY: All fields are fillable but controller-level authorization
     * will restrict who can modify school settings
     *
     * @var array<int, string>
     */
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

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'status_aktif' => 'boolean',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
        'radius_presensi' => 'integer',
        'toleransi_terlambat' => 'integer',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * SECURITY: Sensitive data should not be exposed in API responses
     * unless specifically requested by authorized users
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'deleted_at',
    ];

    /**
     * Scope query to only include active schools
     */
    public function scopeActive($query)
    {
        return $query->where('status_aktif', true);
    }

    /**
     * Scope query to only include inactive schools
     */
    public function scopeInactive($query)
    {
        return $query->where('status_aktif', false);
    }

    /**
     * Find school by code
     * Used during student registration
     */
    public static function findByCode(string $code): ?self
    {
        return static::where('kode_sekolah', $code)->first();
    }

    /**
     * Check if school is currently active
     */
    public function isActive(): bool
    {
        return $this->status_aktif === true;
    }

    /**
     * Check if current time is within attendance hours
     */
    public function isAttendanceTime(): bool
    {
        $now = now()->format('H:i:s');
        return $now >= $this->jam_masuk && $now <= $this->jam_pulang;
    }

    /**
     * Check if user is late for check-in
     */
    public function isLateForCheckIn(string $checkInTime): bool
    {
        return $checkInTime > $this->jam_masuk;
    }

    /**
     * Calculate lateness duration in minutes
     */
    public function calculateLateness(string $checkInTime): int
    {
        $checkIn = \Carbon\Carbon::createFromFormat('H:i:s', $checkInTime);
        $expectedTime = \Carbon\Carbon::createFromFormat('H:i:s', $this->jam_masuk);

        $difference = $checkIn->diffInMinutes($expectedTime);

        // If check-in is after expected time, return positive difference
        return $checkIn->gt($expectedTime) ? $difference : 0;
    }

    /**
     * RELATIONSHIPS
     */

    /**
     * Relasi ke users (students, teachers, school admins)
     */
    public function users()
    {
        return $this->hasMany(User::class);
    }

    /**
     * Relasi ke students only
     */
    public function students()
    {
        return $this->hasMany(User::class)->where('role', User::ROLE_STUDENT);
    }

    /**
     * Relasi ke teachers only
     */
    public function teachers()
    {
        return $this->hasMany(User::class)->where('role', User::ROLE_TEACHER);
    }

    /**
     * Relasi ke school admins
     */
    public function schoolAdmins()
    {
        return $this->hasMany(User::class)->where('role', User::ROLE_SCHOOL_ADMIN);
    }

    /**
     * Relasi ke active users only
     */
    public function activeUsers()
    {
        return $this->hasMany(User::class)->where('status', User::STATUS_ACTIVE);
    }

    /**
     * Relasi ke attendances (absens)
     */
    public function attendances()
    {
        return $this->hasMany(Absensi::class, 'school_id');
    }

    /**
     * Relasi ke attendances hari ini
     */
    public function todayAttendances()
    {
        return $this->hasMany(Absensi::class, 'school_id')
            ->whereDate('created_at', today());
    }

    /**
     * Get attendance statistics
     */
    public function getAttendanceStats(?string $date = null): array
    {
        $date = $date ?? today()->toDateString();

        $attendances = $this->attendances()
            ->whereDate('created_at', $date)
            ->get();

        $totalUsers = $this->activeUsers()->where('role', User::ROLE_STUDENT)->count();

        return [
            'total_users' => $totalUsers,
            'present' => $attendances->where('status', 'HADIR')->count(),
            'late' => $attendances->where('status', 'TERLAMBAT')->count(),
            'permission' => $attendances->where('status', 'IZIN')->count(),
            'sick' => $attendances->where('status', 'SAKIT')->count(),
            'absent' => $totalUsers - $attendances->count(),
            'attendance_rate' => $totalUsers > 0
                ? round(($attendances->count() / $totalUsers) * 100, 2)
                : 0,
        ];
    }

    /**
     * SECURITY: Validate geofence coordinates
     */
    public function isValidGeofence(): bool
    {
        return $this->latitude >= -90 && $this->latitude <= 90
            && $this->longitude >= -180 && $this->longitude <= 180
            && $this->radius_presensi > 0;
    }

    /**
     * SECURITY: Check if location is within school radius
     */
    public function isWithinRadius(float $userLat, float $userLong, ?int $distanceInMeters = null): bool
    {
        if (!$this->isValidGeofence()) {
            return false;
        }

        // If distance is pre-calculated, use it
        if ($distanceInMeters !== null) {
            return $distanceInMeters <= $this->radius_presensi;
        }

        // Calculate distance using Haversine formula
        $distance = $this->calculateDistance($userLat, $userLong);

        return $distance <= $this->radius_presensi;
    }

    /**
     * Calculate distance between two coordinates in meters
     * Uses Haversine formula
     */
    public function calculateDistance(float $lat1, float $lon1): float
    {
        $lat2 = $this->latitude;
        $lon2 = $this->longitude;

        $earthRadius = 6371000; // Earth's radius in meters

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }
}
