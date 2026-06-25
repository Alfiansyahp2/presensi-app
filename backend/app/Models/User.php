<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * SECURITY: Remove school_id from fillable to prevent tenant switching
     * SECURITY: role and status are NOT fillable - only admins can change these
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'nisn',
        'kelas',
        'email',
        'password',
        // 'school_id', // REMOVED: Must be assigned by admin only
        // 'role',      // NEVER fillable - system-assigned only
        // 'status',    // NEVER fillable - admin-controlled only
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * SECURITY: Hide password hash from API responses
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'role' => 'string',
        'status' => 'string',
    ];

    /**
     * Role constants
     */
    public const ROLE_SUPER_ADMIN = 'SUPER_ADMIN';
    public const ROLE_SCHOOL_ADMIN = 'SCHOOL_ADMIN';
    public const ROLE_TEACHER = 'TEACHER';
    public const ROLE_STUDENT = 'STUDENT';

    /**
     * Status constants
     */
    public const STATUS_PENDING = 'PENDING';
    public const STATUS_ACTIVE = 'ACTIVE';
    public const STATUS_SUSPENDED = 'SUSPENDED';

    /**
     * All available roles
     */
    public static function getAllRoles(): array
    {
        return [
            self::ROLE_SUPER_ADMIN,
            self::ROLE_SCHOOL_ADMIN,
            self::ROLE_TEACHER,
            self::ROLE_STUDENT,
        ];
    }

    /**
     * All available statuses
     */
    public static function getAllStatuses(): array
    {
        return [
            self::STATUS_PENDING,
            self::STATUS_ACTIVE,
            self::STATUS_SUSPENDED,
        ];
    }

    /**
     * Check if user is SUPER_ADMIN
     */
    public function isSuperAdmin(): bool
    {
        return $this->role === self::ROLE_SUPER_ADMIN;
    }

    /**
     * Check if user is SCHOOL_ADMIN
     */
    public function isSchoolAdmin(): bool
    {
        return $this->role === self::ROLE_SCHOOL_ADMIN;
    }

    /**
     * Check if user is TEACHER
     */
    public function isTeacher(): bool
    {
        return $this->role === self::ROLE_TEACHER;
    }

    /**
     * Check if user is STUDENT
     */
    public function isStudent(): bool
    {
        return $this->role === self::ROLE_STUDENT;
    }

    /**
     * Check if user has any admin role
     */
    public function isAdmin(): bool
    {
        return in_array($this->role, [
            self::ROLE_SUPER_ADMIN,
            self::ROLE_SCHOOL_ADMIN,
        ]);
    }

    /**
     * Check if user account is active
     */
    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }

    /**
     * Check if user is suspended
     */
    public function isSuspended(): bool
    {
        return $this->status === self::STATUS_SUSPENDED;
    }

    /**
     * Check if user is pending approval
     */
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    /**
     * Check if user can manage the given school
     * SUPER_ADMIN can manage any school
     * SCHOOL_ADMIN can only manage their own school
     */
    public function canManageSchool(int $schoolId): bool
    {
        if ($this->isSuperAdmin()) {
            return true;
        }

        if ($this->isSchoolAdmin()) {
            return $this->school_id === $schoolId;
        }

        return false;
    }

    /**
     * Check if user belongs to the given school
     */
    public function belongsToSchool(int $schoolId): bool
    {
        return $this->school_id === $schoolId;
    }

    /**
     * Check if user has specific permission
     */
    public function hasPermission(string $permission): bool
    {
        // SUPER_ADMIN has all permissions
        if ($this->isSuperAdmin()) {
            return true;
        }

        // Check role_permissions table
        return \DB::table('role_permissions')
            ->where('role', $this->role)
            ->whereExists(function ($query) use ($permission) {
                $query->select(\DB::raw(1))
                    ->from('permissions')
                    ->whereColumn('permission_id', 'permissions.id')
                    ->where('name', $permission);
            })
            ->exists();
    }

    /**
     * Get all permissions for this user
     */
    public function permissions(): array
    {
        if ($this->isSuperAdmin()) {
            return \DB::table('permissions')->pluck('name')->toArray();
        }

        return \DB::table('role_permissions')
            ->where('role', $this->role)
            ->join('permissions', 'role_permissions.permission_id', '=', 'permissions.id')
            ->pluck('permissions.name')
            ->toArray();
    }

    /**
     * Scope query to only include users from a specific school
     * Use for multi-tenant isolation
     */
    public function scopeFromSchool($query, int $schoolId)
    {
        return $query->where('school_id', $schoolId);
    }

    /**
     * Scope query to only include active users
     */
    public function scopeActive($query)
    {
        return $query->where('status', self::STATUS_ACTIVE);
    }

    /**
     * Scope query to only include users with a specific role
     */
    public function scopeWithRole($query, string $role)
    {
        return $query->where('role', $role);
    }

    /**
     * Relasi ke sekolah
     */
    public function school()
    {
        return $this->belongsTo(School::class);
    }

    /**
     * Relasi ke absensi
     */
    public function attendances()
    {
        return $this->hasMany(Absensi::class, 'user_id');
    }

    /**
     * Relasi ke absensi hari ini
     */
    public function todayAttendance()
    {
        return $this->hasOne(Absensi::class, 'user_id')
            ->whereDate('created_at', today());
    }

    /**
     * SECURITY: Prevent role modification through mass assignment
     */
    protected function setRoleAttribute($value)
    {
        // Only allow setting role if current user is SUPER_ADMIN
        // This is enforced at controller level, but add defense here too
        if (app()->bound('auth') && auth()->check() && !auth()->user()->isSuperAdmin()) {
            throw new \Exception('Only SUPER_ADMIN can set role');
        }

        $this->attributes['role'] = $value;
    }

    /**
     * SECURITY: Prevent status modification through mass assignment
     */
    protected function setStatusAttribute($value)
    {
        // Only admins can set status
        if (app()->bound('auth') && auth()->check() && !auth()->user()->isAdmin()) {
            throw new \Exception('Only admins can set status');
        }

        $this->attributes['status'] = $value;
    }

    /**
     * SECURITY: Prevent school_id modification through mass assignment
     */
    protected function setSchoolIdAttribute($value)
    {
        // Only admins can set school_id
        if (app()->bound('auth') && auth()->check() && !auth()->user()->isAdmin()) {
            throw new \Exception('Only admins can set school_id');
        }

        $this->attributes['school_id'] = $value;
    }
}
