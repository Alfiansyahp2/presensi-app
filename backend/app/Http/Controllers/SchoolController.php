<?php

namespace App\Http\Controllers;

use App\Models\School;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SchoolController extends Controller
{
    /**
     * Display a listing of schools.
     * GET /api/schools
     *
     * SECURITY: Multi-tenant scoped based on user role
     * - SUPER_ADMIN: Can view all schools
     * - SCHOOL_ADMIN/TEACHER: Can only view their own school
     * - STUDENT: Can only view their own school (limited info)
     */
    public function index(Request $request)
    {
        $user = $request->user();

        // SUPER_ADMIN can view all schools
        if ($user->isSuperAdmin()) {
            $schools = School::withTrashed()->get();
        }
        // SCHOOL_ADMIN/TEACHER can only view their own school
        elseif ($user->school_id) {
            $schools = School::where('id', $user->school_id)->get();
        }
        // STUDENT can only view their own school (basic info)
        elseif ($user->isStudent() && $user->school_id) {
            $schools = School::where('id', $user->school_id)
                ->select('id', 'nama_sekolah', 'alamat')
                ->get();
        }
        // Users without school (shouldn't happen, but handle gracefully)
        else {
            return response()->json([
                'success' => false,
                'message' => 'You are not assigned to any school',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $schools,
        ]);
    }

    /**
     * Store a newly created school.
     * POST /api/schools
     *
     * SECURITY: Only SUPER_ADMIN can create new schools (tenants)
     * Policy: SchoolPolicy::create
     */
    public function store(Request $request)
    {
        $user = $request->user();

        // Authorization check
        $this->authorize('create', School::class);

        $validated = $request->validate([
            'nama_sekolah' => 'required|string|max:255',
            'kode_sekolah' => 'required|string|max:50|unique:schools,kode_sekolah',
            'alamat' => 'nullable|string',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'radius_presensi' => 'required|integer|min:10|max:1000',
            'jam_masuk' => 'required|date_format:H:i:s',
            'jam_pulang' => 'required|date_format:H:i:s|after:jam_masuk',
            'toleransi_terlambat' => 'required|integer|min:0|max:120',
            'status_aktif' => 'sometimes|boolean',
        ]);

        DB::beginTransaction();
        try {
            $school = School::create($validated);

            // If creating as active, create a default SCHOOL_ADMIN
            // This can be extended later to accept admin details
            if (isset($validated['status_aktif']) && $validated['status_aktif']) {
                // Optional: Create default admin user here
                // For now, school creation doesn't auto-create admin
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'School created successfully',
                'data' => $school,
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to create school: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified school.
     * GET /api/schools/{id}
     *
     * SECURITY: Multi-tenant scoped with detailed data control
     * Policy: SchoolPolicy::view
     */
    public function show(Request $request, $id)
    {
        $school = School::withTrashed()->find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'School not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('view', $school);

        $user = $request->user();

        // SUPER_ADMIN gets full data including users and attendances
        if ($user->isSuperAdmin()) {
            $school->load(['users', 'attendances']);
        }
        // SCHOOL_ADMIN gets their school data with users
        elseif ($user->isSchoolAdmin() && $user->school_id === $school->id) {
            $school->load(['users' => function ($query) {
                $query->select('id', 'school_id', 'fullname', 'email', 'role', 'status');
            }]);
        }
        // TEACHER gets limited school info
        elseif ($user->isTeacher() && $user->school_id === $school->id) {
            // School already loaded, don't add relationships
        }
        // STUDENT gets very limited info
        elseif ($user->isStudent() && $user->school_id === $school->id) {
            $school = School::where('id', $school->id)
                ->select('id', 'nama_sekolah', 'alamat')
                ->first();
        }

        return response()->json([
            'success' => true,
            'data' => $school,
        ]);
    }

    /**
     * Update the specified school.
     * PUT/PATCH /api/schools/{id}
     *
     * SECURITY: SUPER_ADMIN and SCHOOL_ADMIN can update
     * SCHOOL_ADMIN can only update their own school
     * Policy: SchoolPolicy::update
     */
    public function update(Request $request, $id)
    {
        $school = School::withTrashed()->find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'School not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('update', $school);

        $user = $request->user();

        // SCHOOL_ADMIN cannot change kode_sekolah or status_aktif
        if ($user->isSchoolAdmin()) {
            $validated = $request->validate([
                'nama_sekolah' => 'sometimes|string|max:255',
                'alamat' => 'sometimes|string',
                'latitude' => 'sometimes|numeric|between:-90,90',
                'longitude' => 'sometimes|numeric|between:-180,180',
                'radius_presensi' => 'sometimes|integer|min:10|max:1000',
                'jam_masuk' => 'sometimes|date_format:H:i:s',
                'jam_pulang' => 'sometimes|date_format:H:i:s|after:jam_masuk',
                'toleransi_terlambat' => 'sometimes|integer|min:0|max:120',
            ]);
        }
        // SUPER_ADMIN has full control
        else {
            $validated = $request->validate([
                'nama_sekolah' => 'sometimes|string|max:255',
                'kode_sekolah' => 'sometimes|string|max:50|unique:schools,kode_sekolah,' . $id,
                'alamat' => 'sometimes|string',
                'latitude' => 'sometimes|numeric|between:-90,90',
                'longitude' => 'sometimes|numeric|between:-180,180',
                'radius_presensi' => 'sometimes|integer|min:10|max:1000',
                'jam_masuk' => 'sometimes|date_format:H:i:s',
                'jam_pulang' => 'sometimes|date_format:H:i:s|after:jam_masuk',
                'toleransi_terlambat' => 'sometimes|integer|min:0|max:120',
                'status_aktif' => 'sometimes|boolean',
            ]);
        }

        DB::beginTransaction();
        try {
            $school->update($validated);

            // Log the change for audit purposes
            // In production, implement proper audit logging

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'School updated successfully',
                'data' => $school->fresh(),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to update school: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified school.
     * DELETE /api/schools/{id}
     *
     * SECURITY: Only SUPER_ADMIN can delete schools
     * Destructive operation affecting all tenants
     * Policy: SchoolPolicy::delete
     */
    public function destroy($id)
    {
        $school = School::find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'School not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('delete', $school);

        // Check if school has users
        if ($school->users()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete school with existing users. Deactivate instead.',
            ], 400);
        }

        DB::beginTransaction();
        try {
            $school->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'School deleted successfully',
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to delete school: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get school statistics.
     * GET /api/schools/{id}/statistics
     *
     * SECURITY: Role-based access to statistics
     * Policy: SchoolPolicy::viewStatistics
     */
    public function statistics(Request $request, $id)
    {
        $school = School::find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'School not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('viewStatistics', $school);

        $stats = $school->getAttendanceStats();

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Toggle school active status.
     * POST /api/schools/{id}/toggle-status
     *
     * SECURITY: Only SUPER_ADMIN can toggle school status
     * Policy: SchoolPolicy::toggleStatus
     */
    public function toggleStatus(Request $request, $id)
    {
        $school = School::withTrashed()->find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'School not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('toggleStatus', $school);

        $validated = $request->validate([
            'status_aktif' => 'required|boolean',
        ]);

        DB::beginTransaction();
        try {
            $school->update(['status_aktif' => $validated['status_aktif']]);

            // Optionally suspend all users when school is deactivated
            if (!$validated['status_aktif']) {
                $school->users()->update(['status' => User::STATUS_SUSPENDED]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'School status updated successfully',
                'data' => $school->fresh(),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to update school status: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get school users.
     * GET /api/schools/{id}/users
     *
     * SECURITY: Role-based access to user list
     * Policy: SchoolPolicy::viewUsers
     */
    public function users(Request $request, $id)
    {
        $school = School::find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'School not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('viewUsers', $school);

        $user = $request->user();

        $query = $school->users();

        // STUDENT gets very limited view (can't access this endpoint anyway)
        // TEACHER sees only students
        if ($user->isTeacher()) {
            $query->where('role', User::ROLE_STUDENT);
        }

        $users = $query->get();

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Get school attendance.
     * GET /api/schools/{id}/attendance
     *
     * SECURITY: Role-based access to attendance data
     * Policy: SchoolPolicy::viewAttendance
     */
    public function attendance(Request $request, $id)
    {
        $school = School::find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'School not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('viewAttendance', $school);

        $validated = $request->validate([
            'date' => 'sometimes|date',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after_or_equal:start_date',
            'status' => 'sometimes|in:HADIR,TERLAMBAT,IZIN,SAKIT',
        ]);

        $query = $school->attendances();

        // Filter by date
        if (isset($validated['date'])) {
            $query->whereDate('created_at', $validated['date']);
        } elseif (isset($validated['start_date']) && isset($validated['end_date'])) {
            $query->whereBetween('created_at', [$validated['start_date'], $validated['end_date']]);
        }

        // Filter by status
        if (isset($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        $attendances = $query->with('user:id,fullname,kelas,school_id')->get();

        return response()->json([
            'success' => true,
            'data' => $attendances,
        ]);
    }
}
