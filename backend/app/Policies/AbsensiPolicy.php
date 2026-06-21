<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Absensi;
use Illuminate\Auth\Access\HandlesAuthorization;

/**
 * Absensi Policy
 *
 * Defines authorization rules for attendance management operations
 * Enforces multi-tenant isolation and role-based access control
 */
class AbsensiPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view any attendance records
     *
     * SUPER_ADMIN: Can view all attendance across all schools
     * SCHOOL_ADMIN: Can view attendance in their school
     * TEACHER: Can view attendance in their school
     * STUDENT: Can view only their own attendance
     */
    public function viewAny(User $user): bool
    {
        // All authenticated users can view attendance
        // Controllers should apply tenant scoping
        return true;
    }

    /**
     * Determine whether the user can view a specific attendance record
     *
     * SUPER_ADMIN: Can view any attendance
     * SCHOOL_ADMIN: Can view attendance in their school
     * TEACHER: Can view attendance in their school
     * STUDENT: Can view only their own attendance
     */
    public function view(User $user, Absensi $absensi): bool
    {
        // Use the model's security check method
        return $absensi->canBeAccessedBy($user);
    }

    /**
     * Determine whether the user can create attendance records
     *
     * SUPER_ADMIN: Can create attendance (but shouldn't need to)
     * SCHOOL_ADMIN: Should not create attendance directly
     * TEACHER: Should not create attendance directly
     * STUDENT: Can create their own attendance (check-in/check-out)
     */
    public function create(User $user): bool
    {
        // Only students can create attendance (for themselves)
        // SUPER_ADMIN technically can but shouldn't
        return $user->isStudent();
    }

    /**
     * Determine whether the user can create attendance for another user
     *
     * This should never be allowed - attendance must be created by the student
     * Admins/teachers can only approve existing attendance
     */
    public function createForOther(User $user, User $targetUser): bool
    {
        // Attendance can never be created for another user
        return false;
    }

    /**
     * Determine whether the user can update an attendance record
     *
     * SUPER_ADMIN: Can update any attendance
     * SCHOOL_ADMIN: Can update attendance in their school
     * TEACHER: Can update attendance in their school (approve/reject)
     * STUDENT: Cannot update attendance (only create)
     */
    public function update(User $user, Absensi $absensi): bool
    {
        // Use the model's security check method
        return $absensi->canBeModifiedBy($user);
    }

    /**
     * Determine whether the user can delete an attendance record
     *
     * SUPER_ADMIN: Can delete any attendance
     * SCHOOL_ADMIN: Can delete attendance in their school
     * TEACHER: Cannot delete attendance
     * STUDENT: Cannot delete attendance
     */
    public function delete(User $user, Absensi $absensi): bool
    {
        // SUPER_ADMIN can delete any attendance
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can delete attendance in their school
        if ($user->isSchoolAdmin() &&
            $absensi->school_id === $user->school_id) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can approve/reject attendance
     *
     * SUPER_ADMIN: Can approve any attendance
     * SCHOOL_ADMIN: Can approve attendance in their school
     * TEACHER: Can approve attendance in their school
     * STUDENT: Cannot approve attendance
     */
    public function approve(User $user, Absensi $absensi): bool
    {
        // SUPER_ADMIN can approve any attendance
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can approve attendance in their school
        if ($user->isSchoolAdmin() &&
            $absensi->school_id === $user->school_id) {
            return true;
        }

        // TEACHER can approve attendance in their school
        if ($user->isTeacher() &&
            $absensi->school_id === $user->school_id) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can validate sick/permission requests
     *
     * SUPER_ADMIN: Can validate any request
     * SCHOOL_ADMIN: Can validate requests in their school
     * TEACHER: Can validate requests in their school
     * STUDENT: Cannot validate requests
     */
    public function validate(User $user, Absensi $absensi): bool
    {
        // Only attendance that requires validation (izin/sakit)
        if (!$absensi->requiresApproval()) {
            return false;
        }

        // SUPER_ADMIN can validate any request
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can validate requests in their school
        if ($user->isSchoolAdmin() &&
            $absensi->school_id === $user->school_id) {
            return true;
        }

        // TEACHER can validate requests in their school
        if ($user->isTeacher() &&
            $absensi->school_id === $user->school_id) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can view attendance reports
     *
     * SUPER_ADMIN: Can view reports for any school
     * SCHOOL_ADMIN: Can view reports for their school
     * TEACHER: Can view reports for their school (limited)
     * STUDENT: Can view only their own reports
     */
    public function viewReports(User $user, ?Absensi $absensi = null): bool
    {
        // SUPER_ADMIN can view any reports
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can view reports for their school
        if ($user->isSchoolAdmin()) {
            return $user->school_id !== null;
        }

        // TEACHER can view reports for their school
        if ($user->isTeacher()) {
            return $user->school_id !== null;
        }

        // STUDENT can view only their own reports
        if ($user->isStudent()) {
            return true; // Controller will scope to their own data
        }

        return false;
    }

    /**
     * Determine whether the user can export attendance reports
     *
     * SUPER_ADMIN: Can export any reports
     * SCHOOL_ADMIN: Can export reports for their school
     * TEACHER: Can export reports for their class/school
     * STUDENT: Cannot export reports
     */
    public function exportReports(User $user): bool
    {
        // SUPER_ADMIN can export any reports
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can export reports for their school
        if ($user->isSchoolAdmin()) {
            return $user->school_id !== null;
        }

        // TEACHER can export reports for their school
        if ($user->isTeacher()) {
            return $user->school_id !== null;
        }

        return false;
    }

    /**
     * Determine whether the user can modify attendance location/time
     *
     * This is a sensitive operation - only SUPER_ADMIN should be able to do this
     * Used for correcting mistakes, not regular operations
     */
    public function override(User $user, Absensi $absensi): bool
    {
        // Only SUPER_ADMIN can override attendance records
        return $user->isSuperAdmin();
    }
}
