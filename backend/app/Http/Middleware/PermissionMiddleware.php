<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Permission Middleware
 *
 * Checks if authenticated user has the required permission
 * SUPER_ADMIN bypasses all permission checks
 *
 * Usage in routes:
 * ->middleware('permission:school.create')
 * ->middleware('permission:student.update,student.delete') // Must have BOTH permissions
 */
class PermissionMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, string ...$permissions): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated. Please login.',
            ], 401);
        }

        // SUPER_ADMIN has all permissions
        if ($user->isSuperAdmin()) {
            return $next($request);
        }

        // Check if user has ALL required permissions
        $hasAllPermissions = true;
        $missingPermissions = [];

        foreach ($permissions as $permission) {
            if (!$user->hasPermission($permission)) {
                $hasAllPermissions = false;
                $missingPermissions[] = $permission;
            }
        }

        if (!$hasAllPermissions) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden. You do not have the required permissions.',
                'required_permissions' => $permissions,
                'missing_permissions' => $missingPermissions,
            ], 403);
        }

        return $next($request);
    }
}
