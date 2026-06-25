<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    /**
     * Smart Seeder Coordinator - Multi-tenant System
     *
     * Execution Order (CRITICAL for dependencies):
     * 1. SchoolSeederLocal - Create schools first
     * 2. UserSeederLocal - Create users with school references
     * 3. AbsensiSeederLocal - Create attendance with user references
     *
     * Priority:
     * 1. *.local.php files (Your personal data - NOT in Git)
     * 2. *.example.php files (Template data - in Git)
     * 3. *.php files (Standard seeders)
     */
    public function run(): void
    {
        $this->command->info('=====================================');
        $this->command->info('  🌱 Multi-Tenant Database Seeder');
        $this->command->info('=====================================');
        $this->command->newLine();

        // =====================================================================
        // Step 1: Seed Schools (Foundation for multi-tenant)
        // =====================================================================
        $schoolSeeder = $this->getAvailableSeeder('SchoolSeeder');
        $this->command->info("🏫 School Seeder: $schoolSeeder");
        $this->command->newLine();

        $this->executeSeeder($schoolSeeder);
        $this->command->newLine();

        // =====================================================================
        // Step 2: Seed Users (Depend on schools)
        // =====================================================================
        $userSeeder = $this->getAvailableSeeder('UserSeeder');
        $this->command->info("👥 User Seeder: $userSeeder");
        $this->command->newLine();

        $this->executeSeeder($userSeeder);
        $this->command->newLine();

        // =====================================================================
        // Step 3: Seed Attendance (Depend on users & schools)
        // =====================================================================
        $absensiSeeder = $this->getAvailableSeeder('AbsensiSeeder');
        $this->command->info("📝 Attendance Seeder: $absensiSeeder");
        $this->command->newLine();

        $this->executeSeeder($absensiSeeder);
        $this->command->newLine();

        // =====================================================================
        // Summary
        // =====================================================================
        $this->command->info('=====================================');
        $this->command->info('  ✅ Multi-Tenant Seeding Complete!');
        $this->command->info('=====================================');
        $this->command->newLine();

        // Show final stats
        $this->displayStats();

        // Show info if using example data
        if (str_contains($schoolSeeder, 'Example') ||
            str_contains($userSeeder, 'Example') ||
            str_contains($absensiSeeder, 'Example')) {
            $this->command->newLine();
            $this->command->warn('⚠️  NOTE: You are using EXAMPLE data');
            $this->command->warn('⚠️  To use your personal data:');
            $this->command->warn('    1. Copy *.example.php to *.local.php');
            $this->command->warn('    2. Edit with your real data');
            $this->command->warn('    3. Run: php artisan db:seed');
        }

        $this->command->newLine();
    }

    /**
     * Determine which seeder file to use and execute it
     *
     * Priority: .local.php > .example.php > .php
     * Uses manual include to bypass autoloader issues with .local files
     */
    private function getAvailableSeeder($baseName): string
    {
        $localPath = database_path("seeders/{$baseName}.local.php");
        $examplePath = database_path("seeders/{$baseName}.example.php");
        $standardPath = database_path("seeders/{$baseName}.php");

        $seederFile = null;
        $className = null;

        // Check if .local.php exists (highest priority)
        if (file_exists($localPath)) {
            $seederFile = $localPath;
            $className = "{$baseName}Local";
        }
        // Check if .example.php exists
        elseif (file_exists($examplePath)) {
            $seederFile = $examplePath;
            $className = "{$baseName}Example";
        }
        // Check if standard .php exists
        elseif (file_exists($standardPath)) {
            $seederFile = $standardPath;
            $className = $baseName;
        }

        // If file found, include it manually and return class name
        if ($seederFile && file_exists($seederFile)) {
            require_once $seederFile;
            return $className;
        }

        // Fallback
        $this->command->warn("⚠️  No seeder found for {$baseName}, using Example");
        return "{$baseName}Example";
    }

    /**
     * Execute a seeder class manually
     * This bypasses Laravel's container resolution for .local files
     */
    private function executeSeeder($seederClass): void
    {
        $fullClassName = "Database\\Seeders\\{$seederClass}";

        if (class_exists($fullClassName)) {
            $seeder = new $fullClassName();
            $seeder->setCommand($this->command);
            $seeder->run();
        } else {
            $this->command->error("❌ Seeder class not found: {$fullClassName}");
        }
    }

    /**
     * Display database statistics after seeding
     */
    private function displayStats(): void
    {
        $this->command->info('📊 Database Statistics:');
        $this->command->newLine();

        // Count schools
        $schoolsCount = DB::table('schools')->count();
        $this->command->info("  🏫 Schools: {$schoolsCount}");

        // Count users by role
        $roles = ['SUPER_ADMIN', 'SCHOOL_ADMIN', 'TEACHER', 'STUDENT'];
        foreach ($roles as $role) {
            $count = DB::table('users')->where('role', $role)->count();
            $this->command->info("  👥 {$role}: {$count}");
        }

        // Count pending users
        $pendingCount = DB::table('users')->where('status', 'PENDING')->count();
        $this->command->info("  ⏳ Pending Users: {$pendingCount}");

        // Count attendance
        $attendanceCount = DB::table('absens')->count();
        $this->command->info("  📝 Attendance Records: {$attendanceCount}");

        // Count permissions
        $permissionsCount = DB::table('permissions')->count();
        $this->command->info("  🔐 Permissions: {$permissionsCount}");

        $this->command->newLine();
    }
}
