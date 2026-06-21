<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Absensi extends Model
{
    use HasFactory;

    protected $table = 'absens'; // Explicit table name to match actual database

    /**
     * The attributes that are mass assignable.
     *
     * SECURITY CRITICAL: user_id and school_id are NOT fillable
     * - user_id must be derived from auth()->id()
     * - school_id must be derived from user's school relationship
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'status',
        'jam_masuk',
        'jam_pulang',
        'latitude',
        'longitude',
        'jarak_meter',
        'alasan',
        'foto_absen_masuk',
        'foto_absen_pulang',
        // SECURITY: 'user_id' and 'school_id' are NOT fillable
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'jam_masuk' => 'datetime:H:i:s',
        'jam_pulang' => 'datetime:H:i:s',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Status constants
     */
    public const STATUS_HADIR = 'HADIR';
    public const STATUS_TERLAMBAT = 'TERLAMBAT';
    public const STATUS_IZIN = 'IZIN';
    public const STATUS_SAKIT = 'SAKIT';
    public const STATUS_ALPHA = 'ALPHA';

    /**
     * All available statuses
     */
    public static function getAllStatuses(): array
    {
        return [
            self::STATUS_HADIR,
            self::STATUS_TERLAMBAT,
            self::STATUS_IZIN,
            self::STATUS_SAKIT,
            self::STATUS_ALPHA,
        ];
    }

    /**
     * SECURITY: Prevent user_id modification through mass assignment
     */
    protected function setUserIdAttribute($value)
    {
        // Only allow setting user_id if no authenticated user (for seeding/admin operations)
        // or if the current user is setting their own user_id
        if (app()->bound('auth') && auth()->check() && auth()->id() != $value) {
            throw new \Exception('Cannot set user_id for another user');
        }

        $this->attributes['user_id'] = $value;
    }

    /**
     * SECURITY: Prevent school_id modification through mass assignment
     * school_id must always be derived from user's relationship
     */
    protected function setSchoolIdAttribute($value)
    {
        // school_id should be automatically derived from the user
        // Throw exception if someone tries to set it manually
        if (app()->bound('auth') && auth()->check()) {
            $expectedSchoolId = auth()->user()->school_id;
            if ($value != $expectedSchoolId) {
                throw new \Exception('school_id must match user\'s school_id');
            }
        }

        $this->attributes['school_id'] = $value;
    }

    /**
     * RELATIONSHIPS
     */

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
     * SCOPES FOR MULTI-TENANT ISOLATION
     */

    /**
     * Scope: filter absensi hari ini
     */
    public function scopeToday($query)
    {
        return $query->whereDate('created_at', today());
    }

    /**
     * Scope: filter by school (multi-tenant isolation)
     * CRITICAL: All admin attendance queries must use this
     */
    public function scopeFromSchool($query, int $schoolId)
    {
        return $query->where('school_id', $schoolId);
    }

    /**
     * Scope: filter by user
     */
    public function scopeFromUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope: filter by status
     */
    public function scopeWithStatus($query, string $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope: only present/late attendances
     */
    public function scopePresent($query)
    {
        return $query->whereIn('status', [self::STATUS_HADIR, self::STATUS_TERLAMBAT]);
    }

    /**
     * Scope: only absent (izin/sakit)
     */
    public function scopeAbsent($query)
    {
        return $query->whereIn('status', [self::STATUS_IZIN, self::STATUS_SAKIT]);
    }

    /**
     * Scope: date range
     */
    public function scopeDateRange($query, string $startDate, string $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }

    /**
     * Scope: this month
     */
    public function scopeThisMonth($query)
    {
        return $query->whereYear('created_at', now()->year)
            ->whereMonth('created_at', now()->month);
    }

    /**
     * HELPER METHODS
     */

    /**
     * Helper: ambil absensi hari ini untuk user tertentu
     * OPTIMIZED: Now includes school_id for multi-tenant safety
     */
    public static function getTodayAttendance(int $userId, ?int $schoolId = null): ?self
    {
        $query = self::where('user_id', $userId)->today();

        if ($schoolId !== null) {
            $query->where('school_id', $schoolId);
        }

        return $query->first();
    }

    /**
     * Check if student has checked in today
     */
    public function hasCheckedIn(): bool
    {
        return !is_null($this->jam_masuk);
    }

    /**
     * Check if student has checked out today
     */
    public function hasCheckedOut(): bool
    {
        return !is_null($this->jam_pulang);
    }

    /**
     * Check if attendance is complete (both check-in and check-out)
     */
    public function isComplete(): bool
    {
        return $this->hasCheckedIn() && $this->hasCheckedOut();
    }

    /**
     * Check if attendance requires approval (izin/sakit)
     */
    public function requiresApproval(): bool
    {
        return in_array($this->status, [self::STATUS_IZIN, self::STATUS_SAKIT]);
    }

    /**
     * Check if attendance is late
     */
    public function isLate(): bool
    {
        return $this->status === self::STATUS_TERLAMBAT;
    }

    /**
     * Calculate total hours at school
     */
    public function calculateHours(): float
    {
        if (!$this->isComplete()) {
            return 0;
        }

        $checkIn = \Carbon\Carbon::createFromFormat('H:i:s', $this->jam_masuk);
        $checkOut = \Carbon\Carbon::createFromFormat('H:i:s', $this->jam_pulang);

        return $checkOut->diffInHours($checkIn);
    }

    /**
     * SECURITY: Validate attendance belongs to authenticated user's school
     * Used in policies to prevent cross-tenant access
     */
    public function belongsToUserSchool(?User $user = null): bool
    {
        if ($user === null) {
            $user = auth()->user();
        }

        if ($user === null) {
            return false;
        }

        // SUPER_ADMIN can access all schools
        if ($user->isSuperAdmin()) {
            return true;
        }

        // Check if attendance belongs to user's school
        return $this->school_id === $user->school_id;
    }

    /**
     * SECURITY: Validate attendance belongs to specific user
     * Used to ensure students can only access their own attendance
     */
    public function belongsToUser(int $userId): bool
    {
        return $this->user_id === $userId;
    }

    /**
     * SECURITY: Validate attendance can be accessed by user
     * - Students can only see their own attendance
     * - Teachers/School Admins can see attendance from their school
     * - Super Admins can see all attendance
     */
    public function canBeAccessedBy(?User $user = null): bool
    {
        if ($user === null) {
            $user = auth()->user();
        }

        if ($user === null) {
            return false;
        }

        // SUPER_ADMIN can access all attendance
        if ($user->isSuperAdmin()) {
            return true;
        }

        // STUDENT can only access their own attendance
        if ($user->isStudent()) {
            return $this->user_id === $user->id;
        }

        // TEACHER and SCHOOL_ADMIN can access attendance from their school
        if ($user->isTeacher() || $user->isSchoolAdmin()) {
            return $this->school_id === $user->school_id;
        }

        return false;
    }

    /**
     * SECURITY: Validate attendance can be modified by user
     * Only teachers and admins can approve/modify attendance
     */
    public function canBeModifiedBy(?User $user = null): bool
    {
        if ($user === null) {
            $user = auth()->user();
        }

        if ($user === null) {
            return false;
        }

        // SUPER_ADMIN can modify all attendance
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can modify attendance in their school
        if ($user->isSchoolAdmin()) {
            return $this->school_id === $user->school_id;
        }

        // TEACHER can modify attendance in their school
        if ($user->isTeacher()) {
            return $this->school_id === $user->school_id;
        }

        // STUDENT cannot modify attendance (only create)
        return false;
    }
}
