<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Role Middleware
 *
 * Checks if authenticated user has one of the required roles
 *
 * Usage in routes:
 * ->middleware('role:SUPER_ADMIN')
 * ->middleware('role:SCHOOL_ADMIN,TEACHER') // Multiple roles allowed
 */
class RoleMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated. Please login.',
            ], 401);
        }

        // Check if user has at least one of the required roles
        $hasRole = in_array($user->role, $roles);

        if (!$hasRole) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden. You do not have the required role.',
                'required_roles' => $roles,
                'your_role' => $user->role,
            ], 403);
        }

        return $next($request);
    }
}
