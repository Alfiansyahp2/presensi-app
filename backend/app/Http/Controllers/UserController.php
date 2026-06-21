<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * Display a listing of users.
     * GET /api/users
     *
     * SECURITY: Multi-tenant scoped based on user role
     */
    public function index(Request $request)
    {
        $user = $request->user();

        // Authorization check
        $this->authorize('viewAny', User::class);

        $validated = $request->validate([
            'role' => 'sometimes|in:SUPER_ADMIN,SCHOOL_ADMIN,TEACHER,STUDENT',
            'status' => 'sometimes|in:PENDING,ACTIVE,SUSPENDED',
            'school_id' => 'sometimes|integer|exists:schools,id',
        ]);

        $query = User::query();

        // SUPER_ADMIN can filter by school
        if ($user->isSuperAdmin() && isset($validated['school_id'])) {
            $query->where('school_id', $validated['school_id']);
        }
        // Other roles are scoped to their school
        elseif ($user->school_id) {
            $query->where('school_id', $user->school_id);
        }

        // Filter by role
        if (isset($validated['role'])) {
            // STUDENT can only see other students (limited view)
            if ($user->isStudent()) {
                $query->where('id', $user->id);
            } else {
                $query->where('role', $validated['role']);
            }
        }

        // Filter by status
        if (isset($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        $users = $query->with('school:id,nama_sekolah')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Display the specified user.
     * GET /api/users/{id}
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();

        $targetUser = User::with('school')->find($id);

        if (!$targetUser) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('view', $targetUser);

        // Hide sensitive data from non-admins
        if (!$user->isAdmin()) {
            unset($targetUser->nisn);
        }

        return response()->json([
            'success' => true,
            'data' => $targetUser,
        ]);
    }

    /**
     * Store a newly created user.
     * POST /api/users
     *
     * SECURITY: Admins can create users with specific roles
     */
    public function store(Request $request)
    {
        $user = $request->user();

        // Authorization check
        $this->authorize('create', User::class);

        $validated = $request->validate([
            'fullname' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'role' => 'required|in:TEACHER,STUDENT',
            'school_id' => 'required|integer|exists:schools,id',
            'nisn' => 'nullable|string|max:50|unique:users,nisn',
            'kelas' => 'nullable|string|max:50',
        ]);

        // Additional authorization for role creation
        $this->authorize('createRole', User::class, $validated['role']);

        // Additional authorization for school assignment
        $this->authorize('assignSchool', User::class, $validated['school_id']);

        DB::beginTransaction();
        try {
            $newUser = User::create([
                'fullname' => $validated['fullname'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role' => $validated['role'],
                'school_id' => $validated['school_id'],
                'nisn' => $validated['nisn'] ?? null,
                'kelas' => $validated['kelas'] ?? null,
                'status' => User::STATUS_ACTIVE, // Admin-created users are active by default
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'User created successfully',
                'data' => $newUser,
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to create user: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create a teacher.
     * POST /api/users/teacher
     *
     * SECURITY: SCHOOL_ADMIN and SUPER_ADMIN can create teachers
     */
    public function createTeacher(Request $request)
    {
        $user = $request->user();

        // Authorization check
        $this->authorize('create', User::class);
        $this->authorize('createRole', User::class, User::ROLE_TEACHER);

        $validated = $request->validate([
            'fullname' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'school_id' => 'required|integer|exists:schools,id',
        ]);

        // Additional authorization for school assignment
        $this->authorize('assignSchool', User::class, $validated['school_id']);

        DB::beginTransaction();
        try {
            $teacher = User::create([
                'fullname' => $validated['fullname'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role' => User::ROLE_TEACHER,
                'school_id' => $validated['school_id'],
                'status' => User::STATUS_ACTIVE,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Teacher created successfully',
                'data' => $teacher,
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to create teacher: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update the specified user.
     * PUT /api/users/{id}
     */
    public function update(Request $request, $id)
    {
        $targetUser = User::find($id);

        if (!$targetUser) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        $user = $request->user();

        // Authorization check
        $this->authorize('update', $targetUser);

        // Determine if updating sensitive fields
        $updatingSensitive = $request->hasAny(['role', 'status', 'school_id']);

        if ($updatingSensitive) {
            $this->authorize('updateSensitiveFields', $targetUser);
        }

        $validated = $request->validate([
            'fullname' => 'sometimes|string|max:255',
            'kelas' => 'sometimes|string|max:50',
            'nisn' => 'sometimes|string|max:50|unique:users,nisn,' . $id,
            'role' => 'sometimes|in:SUPER_ADMIN,SCHOOL_ADMIN,TEACHER,STUDENT',
            'status' => 'sometimes|in:PENDING,ACTIVE,SUSPENDED',
            'school_id' => 'sometimes|integer|exists:schools,id',
        ]);

        DB::beginTransaction();
        try {
            // Filter out sensitive fields if not authorized
            $updateData = [];
            $userRole = $user->role;

            foreach ($validated as $key => $value) {
                // SUPER_ADMIN can update everything
                if ($user->isSuperAdmin()) {
                    $updateData[$key] = $value;
                }
                // SCHOOL_ADMIN can update status of non-admin users
                elseif ($user->isSchoolAdmin() && $key === 'status' && !$targetUser->isAdmin()) {
                    $updateData[$key] = $value;
                }
                // Users can update their own limited profile
                elseif ($user->id === $targetUser->id && in_array($key, ['fullname', 'kelas'])) {
                    $updateData[$key] = $value;
                }
            }

            if (!empty($updateData)) {
                $targetUser->update($updateData);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'User updated successfully',
                'data' => $targetUser->fresh(),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to update user: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Approve a pending user registration.
     * PUT /api/users/{id}/approve
     */
    public function approve(Request $request, $id)
    {
        $targetUser = User::find($id);

        if (!$targetUser) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('approve', $targetUser);

        if (!$targetUser->isPending()) {
            return response()->json([
                'success' => false,
                'message' => 'User is not pending approval',
            ], 400);
        }

        DB::beginTransaction();
        try {
            $targetUser->update(['status' => User::STATUS_ACTIVE]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'User approved successfully',
                'data' => $targetUser->fresh(),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to approve user: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Toggle user status (suspend/activate).
     * PUT /api/users/{id}/toggle-status
     */
    public function toggleStatus(Request $request, $id)
    {
        $targetUser = User::find($id);

        if (!$targetUser) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('toggleStatus', $targetUser);

        $validated = $request->validate([
            'status' => 'required|in:ACTIVE,SUSPENDED',
        ]);

        $action = $validated['status'] === 'ACTIVE' ? 'activated' : 'suspended';

        DB::beginTransaction();
        try {
            $targetUser->update(['status' => $validated['status']]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => "User {$action} successfully",
                'data' => $targetUser->fresh(),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => "Failed to {$action} user: " . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified user.
     * DELETE /api/users/{id}
     */
    public function destroy($id)
    {
        $targetUser = User::find($id);

        if (!$targetUser) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('delete', $targetUser);

        DB::beginTransaction();
        try {
            $targetUser->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'User deleted successfully',
            ]);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to delete user: ' . $e->getMessage(),
            ], 500);
        }
    }
}
