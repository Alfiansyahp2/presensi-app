<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Check User Status Middleware
 *
 * Ensures user account is active before allowing access
 * Suspended users cannot access the system
 * Pending users can only access limited endpoints
 *
 * Usage in routes:
 * ->middleware('auth.status')
 */
class CheckUserStatus
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

        // Check if user is suspended
        if ($user->isSuspended()) {
            return response()->json([
                'success' => false,
                'message' => 'Your account has been suspended. Please contact administrator.',
                'status' => 'SUSPENDED',
            ], 403);
        }

        // Check if user is pending approval
        if ($user->isPending()) {
            return response()->json([
                'success' => false,
                'message' => 'Your account is pending approval. Please wait for administrator approval.',
                'status' => 'PENDING',
            ], 403);
        }

        // Check if user is active
        if (!$user->isActive()) {
            return response()->json([
                'success' => false,
                'message' => 'Your account is not active. Please contact administrator.',
                'status' => $user->status,
            ], 403);
        }

        // Additional check: Verify user's school is active
        if ($user->school_id && !$user->isSuperAdmin()) {
            $school = $user->school;

            if (!$school || !$school->status_aktif) {
                return response()->json([
                    'success' => false,
                    'message' => 'Your school is currently inactive. Please contact administrator.',
                    'school_status' => 'INACTIVE',
                ], 403);
            }
        }

        return $next($request);
    }
}
