<?php

namespace App\Providers;

use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\DB;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use App\Models\School;
use App\Models\User;
use App\Models\Absensi;
use App\Policies\SchoolPolicy;
use App\Policies\UserPolicy;
use App\Policies\AbsensiPolicy;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        School::class => SchoolPolicy::class,
        User::class => UserPolicy::class,
        Absensi::class => AbsensiPolicy::class,
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        $this->registerPolicies();

        // Implicit permission checking based on role
        Gate::before(function (User $user, $_ability) {
            // SUPER_ADMIN has all permissions
            if ($user->isSuperAdmin()) {
                return true;
            }
            return null; // Let other authorization checks proceed
        });

        // Define permission gates based on role_permissions table
        // Only try to query if permissions table exists
        try {
            $permissions = \DB::table('permissions')->pluck('name');

            foreach ($permissions as $permission) {
                Gate::define($permission, function (User $user) use ($permission) {
                    // SUPER_ADMIN already handled by 'before' callback
                    // Check if user's role has this permission
                    return $user->hasPermission($permission);
                });
            }
        } catch (\Exception $e) {
            // Silently fail if permissions table doesn't exist yet
            // This happens during initial setup before migrations run
            // Log::warning('Permissions table does not exist yet');
        }
    }
}
