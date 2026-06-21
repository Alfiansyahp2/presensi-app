<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Add role column with enum
            $table->enum('role', ['SUPER_ADMIN', 'SCHOOL_ADMIN', 'TEACHER', 'STUDENT'])
                ->default('STUDENT')
                ->after('email');

            // Add status column for account management
            $table->enum('status', ['PENDING', 'ACTIVE', 'SUSPENDED'])
                ->default('PENDING')
                ->after('role');

            // Make school_id NOT NULL for proper tenant isolation
            // Existing NULL records will need to be handled in data migration
            $table->unsignedBigInteger('school_id')
                ->nullable()
                ->change();

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
            $table->foreign('role')->references('role')->on('users')->onDelete('cascade');

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
