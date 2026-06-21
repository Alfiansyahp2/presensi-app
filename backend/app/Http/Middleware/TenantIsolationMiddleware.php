<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Tenant Isolation Middleware
 *
 * Ensures multi-tenant query scoping is properly applied
 * This middleware should be used on all admin/management endpoints
 *
 * It adds tenant scoping helpers to the request that controllers can use
 * SUPER_ADMIN bypasses tenant isolation (can access all schools)
 *
 * Usage in routes:
 * ->middleware('tenant.isolation')
 */
class TenantIsolationMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated. Please login.',
            ], 401);
        }

        // Add tenant scoping information to request
        // Controllers can use this to scope their queries
        $request->attributes->set('tenant_isolation', [
            'is_super_admin' => $user->isSuperAdmin(),
            'user_role' => $user->role,
            'school_id' => $user->school_id,
            'must_scope_to_school' => !$user->isSuperAdmin() && $user->school_id !== null,
        ]);

        // For non-super-admin users with school_id, verify they have a school
        if (!$user->isSuperAdmin() && $user->school_id === null) {
            return response()->json([
                'success' => false,
                'message' => 'You are not assigned to any school. Please contact administrator.',
            ], 403);
        }

        return $next($request);
    }
}
