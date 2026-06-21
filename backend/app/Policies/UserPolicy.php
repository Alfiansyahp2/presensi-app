<?php

namespace App\Policies;

use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

/**
 * User Policy
 *
 * Defines authorization rules for user management operations
 * Enforces multi-tenant isolation and role-based access control
 */
class UserPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view any users
     *
     * SUPER_ADMIN: Can view all users across all schools
     * SCHOOL_ADMIN: Can view users in their school only
     * TEACHER: Can view students in their school only
     * STUDENT: Cannot view user list
     */
    public function viewAny(User $user): bool
    {
        // SUPER_ADMIN can view all users
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN and TEACHER can view users in their school
        if ($user->isAdmin() || $user->isTeacher()) {
            return $user->school_id !== null;
        }

        return false;
    }

    /**
     * Determine whether the user can view a specific user
     *
     * SUPER_ADMIN: Can view any user
     * SCHOOL_ADMIN: Can view users in their school
     * TEACHER: Can view students in their school
     * STUDENT: Can only view their own profile
     */
    public function view(User $user, User $targetUser): bool
    {
        // SUPER_ADMIN can view any user
        if ($user->isSuperAdmin()) {
            return true;
        }

        // Users can always view themselves
        if ($user->id === $targetUser->id) {
            return true;
        }

        // SCHOOL_ADMIN can view users in their school
        if ($user->isSchoolAdmin() && $user->school_id === $targetUser->school_id) {
            return true;
        }

        // TEACHER can view students in their school
        if ($user->isTeacher() &&
            $user->school_id === $targetUser->school_id &&
            $targetUser->isStudent()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can create users
     *
     * SUPER_ADMIN: Can create any user in any school
     * SCHOOL_ADMIN: Can create teachers and students in their school
     * TEACHER: Cannot create users
     * STUDENT: Cannot create users
     */
    public function create(User $user): bool
    {
        // SUPER_ADMIN can create any user
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can create teachers and students
        if ($user->isSchoolAdmin()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can create a specific role
     *
     * SUPER_ADMIN: Can create any role
     * SCHOOL_ADMIN: Can create TEACHER and STUDENT only
     * Others: Cannot create users
     */
    public function createRole(User $user, string $role): bool
    {
        // SUPER_ADMIN can create any role
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can create teachers and students
        if ($user->isSchoolAdmin()) {
            return in_array($role, [User::ROLE_TEACHER, User::ROLE_STUDENT]);
        }

        return false;
    }

    /**
     * Determine whether the user can update a specific user
     *
     * SUPER_ADMIN: Can update any user
     * SCHOOL_ADMIN: Can update users in their school (except other admins)
     * TEACHER: Cannot update users
     * STUDENT: Can only update their own limited profile
     */
    public function update(User $user, User $targetUser): bool
    {
        // SUPER_ADMIN can update any user
        if ($user->isSuperAdmin()) {
            return true;
        }

        // Users can always update themselves (limited fields only, enforced at controller level)
        if ($user->id === $targetUser->id) {
            return true;
        }

        // SCHOOL_ADMIN can update non-admin users in their school
        if ($user->isSchoolAdmin() &&
            $user->school_id === $targetUser->school_id &&
            !$targetUser->isAdmin()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can update sensitive fields (role, status, school_id)
     *
     * SUPER_ADMIN: Can update any field
     * SCHOOL_ADMIN: Can update status only (not role or school_id)
     * Others: Cannot update sensitive fields
     */
    public function updateSensitiveFields(User $user, User $targetUser): bool
    {
        // SUPER_ADMIN can update any sensitive field
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can update status of non-admin users in their school
        if ($user->isSchoolAdmin() &&
            $user->school_id === $targetUser->school_id &&
            !$targetUser->isAdmin()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can delete a user
     *
     * SUPER_ADMIN: Can delete any user
     * SCHOOL_ADMIN: Can delete non-admin users in their school
     * TEACHER: Cannot delete users
     * STUDENT: Cannot delete users
     */
    public function delete(User $user, User $targetUser): bool
    {
        // Prevent self-deletion
        if ($user->id === $targetUser->id) {
            return false;
        }

        // SUPER_ADMIN can delete any user
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can delete non-admin users in their school
        if ($user->isSchoolAdmin() &&
            $user->school_id === $targetUser->school_id &&
            !$targetUser->isAdmin()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can suspend/activate a user
     *
     * SUPER_ADMIN: Can suspend/activate any user
     * SCHOOL_ADMIN: Can suspend/activate non-admin users in their school
     * TEACHER: Cannot suspend/activate users
     * STUDENT: Cannot suspend/activate users
     */
    public function toggleStatus(User $user, User $targetUser): bool
    {
        // Prevent self-suspension
        if ($user->id === $targetUser->id) {
            return false;
        }

        // SUPER_ADMIN can suspend/activate any user
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can suspend/activate non-admin users in their school
        if ($user->isSchoolAdmin() &&
            $user->school_id === $targetUser->school_id &&
            !$targetUser->isAdmin()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can assign a school to a user
     *
     * SUPER_ADMIN: Can assign any school
     * SCHOOL_ADMIN: Can assign their school only (during user creation)
     * Others: Cannot assign schools
     */
    public function assignSchool(User $user, ?int $schoolId): bool
    {
        // SUPER_ADMIN can assign any school
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can assign users to their own school only
        if ($user->isSchoolAdmin() && $schoolId === $user->school_id) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the user can approve pending registrations
     *
     * SUPER_ADMIN: Can approve any registration
     * SCHOOL_ADMIN: Can approve registrations in their school
     * Others: Cannot approve registrations
     */
    public function approve(User $user, User $targetUser): bool
    {
        // Only approve pending users
        if (!$targetUser->isPending()) {
            return false;
        }

        // SUPER_ADMIN can approve any registration
        if ($user->isSuperAdmin()) {
            return true;
        }

        // SCHOOL_ADMIN can approve registrations in their school
        if ($user->isSchoolAdmin() &&
            $user->school_id === $targetUser->school_id &&
            $targetUser->school_id !== null) {
            return true;
        }

        return false;
    }
}
