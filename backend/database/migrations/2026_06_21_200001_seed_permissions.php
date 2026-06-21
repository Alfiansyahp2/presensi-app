<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Seed permissions data
     */
    public function up(): void
    {
        // School permissions
        $schoolPermissions = [
            ['name' => 'school.create', 'description' => 'Create new school/tenant', 'category' => 'school'],
            ['name' => 'school.view', 'description' => 'View school information', 'category' => 'school'],
            ['name' => 'school.update', 'description' => 'Update school settings', 'category' => 'school'],
            ['name' => 'school.delete', 'description' => 'Delete school/tenant', 'category' => 'school'],
            ['name' => 'school.suspend', 'description' => 'Suspend school account', 'category' => 'school'],
        ];

        // Teacher permissions
        $teacherPermissions = [
            ['name' => 'teacher.create', 'description' => 'Create teacher account', 'category' => 'teacher'],
            ['name' => 'teacher.view', 'description' => 'View teacher information', 'category' => 'teacher'],
            ['name' => 'teacher.update', 'description' => 'Update teacher information', 'category' => 'teacher'],
            ['name' => 'teacher.delete', 'description' => 'Delete teacher account', 'category' => 'teacher'],
        ];

        // Student permissions
        $studentPermissions = [
            ['name' => 'student.create', 'description' => 'Create student account', 'category' => 'student'],
            ['name' => 'student.view', 'description' => 'View student information', 'category' => 'student'],
            ['name' => 'student.update', 'description' => 'Update student information', 'category' => 'student'],
            ['name' => 'student.delete', 'description' => 'Delete student account', 'category' => 'student'],
            ['name' => 'student.approve', 'description' => 'Approve pending student registration', 'category' => 'student'],
        ];

        // Attendance permissions
        $attendancePermissions = [
            ['name' => 'attendance.create', 'description' => 'Create attendance record', 'category' => 'attendance'],
            ['name' => 'attendance.view', 'description' => 'View attendance records', 'category' => 'attendance'],
            ['name' => 'attendance.view_own', 'description' => 'View own attendance records', 'category' => 'attendance'],
            ['name' => 'attendance.approve', 'description' => 'Approve/reject attendance requests', 'category' => 'attendance'],
            ['name' => 'attendance.validate', 'description' => 'Validate sick/permission requests', 'category' => 'attendance'],
        ];

        // Report permissions
        $reportPermissions = [
            ['name' => 'report.view', 'description' => 'View attendance reports', 'category' => 'report'],
            ['name' => 'report.view_own', 'description' => 'View own attendance reports', 'category' => 'report'],
            ['name' => 'report.export', 'description' => 'Export attendance reports', 'category' => 'report'],
        ];

        // Settings permissions
        $settingsPermissions = [
            ['name' => 'settings.view', 'description' => 'View school settings', 'category' => 'settings'],
            ['name' => 'settings.update', 'description' => 'Update school settings', 'category' => 'settings'],
        ];

        // User management permissions
        $userPermissions = [
            ['name' => 'user.suspend', 'description' => 'Suspend user account', 'category' => 'user'],
            ['name' => 'user.activate', 'description' => 'Activate user account', 'category' => 'user'],
            ['name' => 'user.view_all', 'description' => 'View all users in school', 'category' => 'user'],
        ];

        $allPermissions = array_merge(
            $schoolPermissions,
            $teacherPermissions,
            $studentPermissions,
            $attendancePermissions,
            $reportPermissions,
            $settingsPermissions,
            $userPermissions
        );

        DB::table('permissions')->insert($allPermissions);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('permissions')->truncate();
    }
};
