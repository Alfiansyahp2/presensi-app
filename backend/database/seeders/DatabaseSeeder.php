<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Smart Seeder Coordinator - Uses local files if available
     *
     * Priority:
     * 1. UserSeeder.local.php (Your personal data - NOT in Git)
     * 2. UserSeeder.example.php (Template data - in Git)
     *
     * Same for AbsensiSeeder
     */
    public function run(): void
    {
        $this->command->info('=================================');
        $this->command->info('  Database Seeder Starting...');
        $this->command->info('=================================');
        $this->command->newLine();

        // Determine which seeder to use
        $userSeeder = $this->getAvailableSeeder('UserSeeder');
        $absensiSeeder = $this->getAvailableSeeder('AbsensiSeeder');

        $this->command->info("📋 User Seeder: $userSeeder");
        $this->command->info("📋 Absensi Seeder: $absensiSeeder");
        $this->command->newLine();

        // Seed users first (absensi requires users)
        $this->call([$userSeeder]);

        // Seed absensi (depends on users)
        $this->call([$absensiSeeder]);

        $this->command->newLine();
        $this->command->info('=================================');
        $this->command->info('  ✅ Database Seeding Complete!');
        $this->command->info('=================================');

        // Show info if using example data
        if (str_contains($userSeeder, 'Example') || str_contains($absensiSeeder, 'Example')) {
            $this->command->newLine();
            $this->command->warn('⚠️  NOTE: You are using EXAMPLE data');
            $this->command->warn('⚠️  To use your personal data:');
            $this->command->warn('    1. Copy UserSeeder.example.php to UserSeeder.local.php');
            $this->command->warn('    2. Edit with your real data');
            $this->command->warn('    3. Run: php artisan db:seed');
        }
    }

    /**
     * Determine which seeder file to use
     *
     * Priority: .local.php > .example.php
     */
    private function getAvailableSeeder($baseName): string
    {
        $localPath = database_path("seeders/{$baseName}.local.php");
        $examplePath = database_path("seeders/{$baseName}.example.php");
        $standardPath = database_path("seeders/{$baseName}.php");

        // Check if .local.php exists (highest priority)
        if (file_exists($localPath)) {
            return "{$baseName}Local";
        }

        // Check if .example.php exists
        if (file_exists($examplePath)) {
            return "{$baseName}Example";
        }

        // Check if standard .php exists
        if (file_exists($standardPath)) {
            return $baseName;
        }

        // Fallback to example if nothing exists
        $this->command->warn("⚠️  No seeder found for {$baseName}, using Example");
        return "{$baseName}Example";
    }
}
