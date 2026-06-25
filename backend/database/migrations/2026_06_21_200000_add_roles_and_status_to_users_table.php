<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Step 1: Modify existing role column enum (using raw SQL)
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('SUPER_ADMIN', 'SCHOOL_ADMIN', 'TEACHER', 'STUDENT') DEFAULT 'STUDENT'");

        // Step 2: Add status column for account management
        Schema::table('users', function (Blueprint $table) {
            $table->enum('status', ['PENDING', 'ACTIVE', 'SUSPENDED'])
                ->default('PENDING')
                ->after('role');

            // Add indexes for performance
            $table->index('role');
            $table->index('status');
            $table->index(['school_id', 'role']);
            $table->index(['school_id', 'status']);
        });

        // Create permissions table
        Schema::create('permissions', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->string('description')->nullable();
            $table->string('category')->nullable(); // For grouping: school, teacher, student, etc.
            $table->timestamps();

            $table->index('category');
        });

        // Create role_permissions pivot table
        Schema::create('role_permissions', function (Blueprint $table) {
            $table->id();

            $table->enum('role', ['SUPER_ADMIN', 'SCHOOL_ADMIN', 'TEACHER', 'STUDENT']);
            // Note: No foreign key to users.role because it's an enum and causes circular dependency
            // The enum values are validated at application level in User model

            $table->unsignedBigInteger('permission_id');
            $table->foreign('permission_id')->references('id')->on('permissions')->onDelete('cascade');

            $table->timestamps();

            $table->unique(['role', 'permission_id']);
            $table->index('role');
            $table->index('permission_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('role_permissions');
        Schema::dropIfExists('permissions');

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['school_id', 'role']);
            $table->dropIndex(['school_id', 'status']);
            $table->dropIndex('role');
            $table->dropIndex('status');

            $table->dropColumn(['role', 'status']);
        });
    }
};
