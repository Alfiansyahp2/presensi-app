<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\School;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Public user registration (STUDENT only)
     * POST /api/register
     *
     * SECURITY:
     * - Only creates STUDENT role (role cannot be specified)
     * - Requires valid school code to ensure multi-tenant isolation
     * - Sets school_id from validated school code
     * - Status defaults to PENDING for admin approval
     * - User cannot specify role, school_id, or status
     *
     * FLOW:
     * 1. User provides school code
     * 2. Backend validates school code and retrieves school_id
     * 3. System assigns role = STUDENT, status = PENDING
     * 4. User awaits admin approval (or set as ACTIVE based on config)
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'fullname' => 'required|string|max:255',
            'nisn' => 'required|string|max:50|unique:users,nisn',
            'kelas' => 'required|string|max:50',
            'kode_sekolah' => 'required|string|exists:schools,kode_sekolah',
            'email' => 'required|email|regex:/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/|unique:users,email',
            'password' => 'required|string|min:8|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/',
        ], [
            'email.regex' => 'Email format is invalid',
            'password.regex' => 'Password must contain at least one uppercase letter, one lowercase letter, and one number',
            'kode_sekolah.exists' => 'Invalid school code. Please check with your school administration.',
        ]);

        DB::beginTransaction();
        try {
            // Find school by code
            $school = School::where('kode_sekolah', $validated['kode_sekolah'])->first();

            if (!$school) {
                throw ValidationException::withMessages([
                    'kode_sekolah' => ['Invalid school code'],
                ]);
            }

            // Check if school is active
            if (!$school->status_aktif) {
                return response()->json([
                    'success' => false,
                    'message' => 'The selected school is currently not accepting new registrations. Please contact administration.',
                ], 400);
            }

            // SECURITY: Role is always STUDENT for public registration
            // User cannot specify role, school_id, or status
            $user = User::create([
                'fullname' => $validated['fullname'],
                'nisn' => $validated['nisn'],
                'kelas' => $validated['kelas'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'school_id' => $school->id,  // Set from validated school code
                'role' => User::ROLE_STUDENT,  // Always STUDENT
                'status' => User::STATUS_PENDING,  // Requires approval
            ]);

            // Log registration for audit
            // In production: implement proper audit logging

            DB::commit();

            // Don't return token immediately - user needs approval
            return response()->json([
                'success' => true,
                'message' => 'Registration successful. Your account is pending approval from school administration.',
                'data' => [
                    'user_id' => $user->id,
                    'fullname' => $user->fullname,
                    'email' => $user->email,
                    'school_name' => $school->nama_sekolah,
                    'status' => $user->status,
                    'role' => $user->role,
                ],
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            if ($e instanceof ValidationException) {
                throw $e;
            }

            return response()->json([
                'success' => false,
                'message' => 'Registration failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * User login
     * POST /api/login
     *
     * SECURITY:
     * - Validates credentials
     * - Checks account status (ACTIVE only)
     * - Checks school status (if applicable)
     * - Returns token only for active accounts
     */
    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $validated['email'])->first();

        // Check if user exists and password is correct
        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
            ], 401);
        }

        // Check account status
        if ($user->isSuspended()) {
            return response()->json([
                'success' => false,
                'message' => 'Your account has been suspended. Please contact administrator.',
                'status' => 'SUSPENDED',
            ], 403);
        }

        if ($user->isPending()) {
            return response()->json([
                'success' => false,
                'message' => 'Your account is pending approval. Please wait for administrator approval.',
                'status' => 'PENDING',
            ], 403);
        }

        if (!$user->isActive()) {
            return response()->json([
                'success' => false,
                'message' => 'Your account is not active. Please contact administrator.',
                'status' => $user->status,
            ], 403);
        }

        // Check if user's school is active (for non-super-admins)
        if (!$user->isSuperAdmin() && $user->school_id) {
            $school = $user->school;
            if (!$school || !$school->status_aktif) {
                return response()->json([
                    'success' => false,
                    'message' => 'Your school is currently inactive. Please contact administrator.',
                    'school_status' => 'INACTIVE',
                ], 403);
            }
        }

        // Delete existing tokens to prevent token bloat
        $user->tokens()->delete();

        // Create new token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'token' => $token,
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'fullname' => $user->fullname,
                    'email' => $user->email,
                    'role' => $user->role,
                    'status' => $user->status,
                    'school_id' => $user->school_id,
                ],
            ],
        ], 200);
    }

    /**
     * Get user profile
     * GET /api/profile
     *
     * SECURITY: Returns user without sensitive data
     */
    public function profile(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'fullname' => $user->fullname,
                'email' => $user->email,
                'nisn' => $user->nisn,
                'kelas' => $user->kelas,
                'role' => $user->role,
                'status' => $user->status,
                'school_id' => $user->school_id,
                'school' => $user->school ? [
                    'id' => $user->school->id,
                    'nama_sekolah' => $user->school->nama_sekolah,
                    'alamat' => $user->school->alamat,
                    'status_aktif' => $user->school->status_aktif,
                ] : null,
                'permissions' => $user->permissions(),
                'created_at' => $user->created_at,
            ],
        ]);
    }

    /**
     * Update user profile (limited fields)
     * PUT /api/profile
     *
     * SECURITY: Users can only update their own limited profile data
     * Cannot update: role, status, school_id, email (email requires separate verification)
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'fullname' => 'sometimes|string|max:255',
            'kelas' => 'sometimes|string|max:50',
            'password' => 'sometimes|string|min:8|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/',
        ], [
            'password.regex' => 'Password must contain at least one uppercase letter, one lowercase letter, and one number',
        ]);

        // SECURITY: Only allow updating specific fields
        $allowedFields = ['fullname', 'kelas', 'password'];
        $updateData = [];

        foreach ($allowedFields as $field) {
            if (isset($validated[$field])) {
                if ($field === 'password') {
                    $updateData['password'] = Hash::make($validated[$field]);
                } else {
                    $updateData[$field] = $validated[$field];
                }
            }
        }

        if (empty($updateData)) {
            return response()->json([
                'success' => false,
                'message' => 'No valid fields to update',
            ], 400);
        }

        $user->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'id' => $user->id,
                'fullname' => $user->fullname,
                'email' => $user->email,
                'role' => $user->role,
            ],
        ]);
    }

    /**
     * User logout
     * POST /api/logout
     *
     * SECURITY: Deletes current access token
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout successful',
        ]);
    }

    /**
     * Refresh token
     * POST /api/refresh-token
     *
     * SECURITY: Issues a new token and invalidates the old one
     */
    public function refreshToken(Request $request)
    {
        $user = $request->user();

        // Delete current token
        $request->user()->currentAccessToken()->delete();

        // Create new token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Token refreshed successfully',
            'token' => $token,
        ]);
    }

    /**
     * Verify token
     * GET /api/verify-token
     *
     * SECURITY: Returns user information for valid token
     */
    public function verifyToken(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'valid' => true,
            'data' => [
                'user_id' => $user->id,
                'email' => $user->email,
                'role' => $user->role,
                'status' => $user->status,
                'school_id' => $user->school_id,
            ],
        ]);
    }
}
