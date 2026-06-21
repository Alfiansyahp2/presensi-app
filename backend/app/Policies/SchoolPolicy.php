<?php

namespace App\Policies;

use App\Models\User;
use App\Models\School;
use Illuminate\Auth\Access\HandlesAuthorization;

/**
 * School Policy
 *
 * Defines authorization rules for school management operations
 * Enforces multi-tenant isolation and role-based access control
 */
class SchoolPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view any schools
     *
     * SUPER_ADMIN: Can view all schools
     * SCHOOL_ADMIN: Can only view their own school
     * TEACHER: Can only view their own school
     * STUDENT: Can only view their own school (limited info)
     */
    public function viewAny(User $user): bool
    {
        // All authenticated users can view schools
        // Controllers should apply tenant scoping for non-super-admins
        return true;
    }

    /**
     * Determine whether the user can view a specific school
     *
     * SUPER_ADMIN: Can view any school
     * SCHOOL_ADMIN: Can only view their own school
     * TEACHER: Can only view their own school
     * STUDENT: Can only view their own school (limited info)
     */
    public function view(User $user, School $school): bool
    {
        // SUPER_ADMIN can view any school
        if ($user->isSuperAdmin()) {
            return true;
        }

        // Other roles can only view their own school
        if ($user->school_id === $school->id) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can create schools
     *
     * Only SUPER_ADMIN can create new schools (tenants)
     */
    public function create(User $user): bool
    {
        return $user->isSuperAdmin();
    }

    /**
     * Determine whether the user can update a school
     *
     * SUPER_ADMIN: Can update any school
     * SCHOOL_ADMIN: Can only update their own school
     * TEACHER: Cannot update school settings
     * STUDENT: Cannot update school settings
     */
    public function update(User $user, School $school): bool
    {
        // SUPER_ADMIN can update any school
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can update their own school
        if ($user->isSchoolAdmin() && $user->school_id === $school->id) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can delete a school
     *
     * Only SUPER_ADMIN can delete schools
     * This is a destructive operation affecting all tenants
     */
    public function delete(User $user, School $school): bool
    {
        return $user->isSuperAdmin();
    }

    /**
     * Determine whether the user can restore a soft-deleted school
     *
     * Only SUPER_ADMIN can restore deleted schools
     */
    public function restore(User $user, School $school): bool
    {
        return $user->isSuperAdmin();
    }

    /**
     * Determine whether the user can force delete a school
     *
     * Only SUPER_ADMIN can permanently delete schools
     */
    public function forceDelete(User $user, School $school): bool
    {
        return $user->isSuperAdmin();
    }

    /**
     * Determine whether the user can view school statistics
     *
     * SUPER_ADMIN: Can view any school's statistics
     * SCHOOL_ADMIN: Can view their own school's statistics
     * TEACHER: Can view their own school's statistics
     * STUDENT: Cannot view school statistics
     */
    public function viewStatistics(User $user, School $school): bool
    {
        // SUPER_ADMIN can view any school's statistics
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN and TEACHER can view their own school's statistics
        if (($user->isSchoolAdmin() || $user->isTeacher()) && $user->school_id === $school->id) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can suspend/activate a school
     *
     * Only SUPER_ADMIN can suspend or activate schools
     */
    public function toggleStatus(User $user, School $school): bool
    {
        return $user->isSuperAdmin();
    }

    /**
     * Determine whether the user can view school users
     *
     * SUPER_ADMIN: Can view any school's users
     * SCHOOL_ADMIN: Can view their own school's users
     * TEACHER: Can view their own school's users (students only)
     * STUDENT: Cannot view school users list
     */
    public function viewUsers(User $user, School $school): bool
    {
        // SUPER_ADMIN can view any school's users
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can view their own school's users
        if ($user->isSchoolAdmin() && $user->school_id === $school->id) {
            return true;
        }

        // TEACHER can view their own school's students
        if ($user->isTeacher() && $user->school_id === $school->id) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can view school attendance
     *
     * SUPER_ADMIN: Can view any school's attendance
     * SCHOOL_ADMIN: Can view their own school's attendance
     * TEACHER: Can view their own school's attendance
     * STUDENT: Cannot view school-wide attendance
     */
    public function viewAttendance(User $user, School $school): bool
    {
        // SUPER_ADMIN can view any school's attendance
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN and TEACHER can view their own school's attendance
        if (($user->isSchoolAdmin() || $user->isTeacher()) && $user->school_id === $school->id) {
            return true;
        }

        return false;
    }
}
