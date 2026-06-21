<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Seed role permissions mapping
     */
    public function up(): void
    {
        // SUPER_ADMIN has all permissions
        $superAdminPermissionIds = DB::table('permissions')->pluck('id');
        $superAdminData = [];
        foreach ($superAdminPermissionIds as $permissionId) {
            $superAdminData[] = [
                'role' => 'SUPER_ADMIN',
                'permission_id' => $permissionId,
            ];
        }
        DB::table('role_permissions')->insert($superAdminData);

        // SCHOOL_ADMIN permissions
        $schoolAdminPermissions = [
            'teacher.create', 'teacher.view', 'teacher.update', 'teacher.delete',
            'student.create', 'student.view', 'student.update', 'student.delete', 'student.approve',
            'attendance.view', 'attendance.approve', 'attendance.validate',
            'report.view', 'report.export',
            'settings.view', 'settings.update',
            'user.suspend', 'user.activate', 'user.view_all',
            'school.view', 'school.update',
        ];
        $this->assignPermissionsToRole('SCHOOL_ADMIN', $schoolAdminPermissions);

        // TEACHER permissions
        $teacherPermissions = [
            'student.view',
            'attendance.view', 'attendance.approve', 'attendance.validate',
            'report.view', 'report.export',
            'school.view',
        ];
        $this->assignPermissionsToRole('TEACHER', $teacherPermissions);

        // STUDENT permissions
        $studentPermissions = [
            'attendance.create', 'attendance.view_own',
            'report.view_own',
            'school.view',
        ];
        $this->assignPermissionsToRole('STUDENT', $studentPermissions);
    }

    private function assignPermissionsToRole(string $role, array $permissionNames): void
    {
        $permissionIds = DB::table('permissions')
            ->whereIn('name', $permissionNames)
            ->pluck('id');

        $data = [];
        foreach ($permissionIds as $permissionId) {
            $data[] = [
                'role' => $role,
                'permission_id' => $permissionId,
            ];
        }

        DB::table('role_permissions')->insert($data);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('role_permissions')->truncate();
    }
};
