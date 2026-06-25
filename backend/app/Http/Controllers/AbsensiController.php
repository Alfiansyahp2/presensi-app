<?php

namespace App\Http\Controllers;

use App\Models\Absensi;
use App\Models\User;
use App\Services\AttendanceService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AbsensiController extends Controller
{
    protected $attendanceService;

    public function __construct(AttendanceService $attendanceService)
    {
        $this->attendanceService = $attendanceService;
    }

    /**
     * Absen masuk (check-in)
     * POST /api/absensi/checkin
     *
     * SECURITY: Only STUDENT role can check in
     * Uses auth()->id() to prevent attendance forgery
     */
    public function checkIn(Request $request)
    {
        $user = $request->user();

        // Only students can check in
        if (!$user->isStudent()) {
            return response()->json([
                'success' => false,
                'message' => 'Only students can check in',
            ], 403);
        }

        // Authorization check
        $this->authorize('create', Absensi::class);

        $validated = $request->validate([
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'foto' => 'required|image|max:2048', // max 2MB
            'alasan' => 'nullable|string|max:500',
        ]);

        try {
            // Check if user has a school
            if (!$user->school_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not assigned to any school. Please contact administrator.',
                ], 403);
            }

            // Check if school is active
            if (!$user->school || !$user->school->status_aktif) {
                return response()->json([
                    'success' => false,
                    'message' => 'Your school is currently inactive. Please contact administrator.',
                ], 403);
            }

            // Cek apakah sudah absen hari ini
            $existing = Absensi::getTodayAttendance($user->id, $user->school_id);
            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'You have already checked in today',
                    'data' => $existing,
                ], 400);
            }

            // Upload foto absen masuk
            $fotoPath = null;
            if ($request->hasFile('foto')) {
                $fotoPath = $request->file('foto')
                                    ->store('absensi-masuk', 'public');
            }

            // Proses absen masuk - SECURITY: user_id and school_id set in service, not from request
            $attendance = $this->attendanceService->checkIn($user, [
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'foto' => $fotoPath,
                'alasan' => $validated['alasan'] ?? null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Check-in successful',
                'data' => $attendance,
                'status_info' => [
                    'status' => $attendance->status,
                    'jam_masuk' => $attendance->jam_masuk,
                    'jam_pulang' => $attendance->jam_pulang,
                    'jarak_meter' => $attendance->jarak_meter . 'm',
                    'sekolah' => $user->school->nama_sekolah,
                ],
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Absen pulang (check-out)
     * POST /api/absensi/checkout
     *
     * SECURITY: Only STUDENT role can check out
     */
    public function checkOut(Request $request)
    {
        $user = $request->user();

        // Only students can check out
        if (!$user->isStudent()) {
            return response()->json([
                'success' => false,
                'message' => 'Only students can check out',
            ], 403);
        }

        $validated = $request->validate([
            'foto' => 'required|image|max:2048',
        ]);

        try {
            // Check if user has a school
            if (!$user->school_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not assigned to any school. Please contact administrator.',
                ], 403);
            }

            // Upload foto absen pulang
            $fotoPath = null;
            if ($request->hasFile('foto')) {
                $fotoPath = $request->file('foto')
                                    ->store('absensi-pulang', 'public');
            }

            // Proses absen pulang
            $attendance = $this->attendanceService->checkOut($user, [
                'foto' => $fotoPath,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Check-out successful',
                'data' => $attendance,
                'status_info' => [
                    'status' => $attendance->status,
                    'jam_masuk' => $attendance->jam_masuk,
                    'jam_pulang' => $attendance->jam_pulang,
                    'durasi_kerja' => $this->calculateDuration($attendance->jam_masuk, $attendance->jam_pulang),
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Cek status hari ini
     * GET /api/absensi/today
     *
     * SECURITY: Multi-tenant scoped to user's own attendance
     */
    public function getTodayStatus(Request $request)
    {
        $user = $request->user();

        // Authorization check - users can check their own status
        $this->authorize('viewAny', Absensi::class);

        $statusInfo = $this->attendanceService->getTodayStatus($user->id);
        $attendance = $statusInfo['data'];
        $status = $statusInfo['status'];

        // Tentukan tombol yang aktif
        $canCheckIn = ($status === 'BELUM_ABSEN');
        $canCheckOut = in_array($status, ['HADIR', 'TERLAMBAT']);
        $activeButton = null;
        $message = '';

        switch ($status) {
            case 'BELUM_ABSEN':
                $activeButton = 'checkin';
                $message = 'Silakan absen masuk';
                break;
            case 'HADIR':
                $activeButton = 'checkout';
                $message = 'Anda sudah Hadir. Silakan absen pulang setelah jam pulang.';
                break;
            case 'TERLAMBAT':
                $activeButton = 'checkout';
                $message = 'Anda terlambat. Silakan absen pulang setelah jam pulang.';
                break;
            case 'PULANG':
                $activeButton = 'none';
                $message = 'Anda sudah absen pulang hari ini.';
                break;
            default:
                $activeButton = 'none';
                $message = 'Status tidak dikenali';
        }

        $response = [
            'success' => true,
            'data' => [
                'status' => $status,
                'active_button' => $activeButton,
                'can_checkin' => $canCheckIn,
                'can_checkout' => $canCheckOut,
                'message' => $message,
                'attendance' => $attendance,
                'school' => $user->school ? [
                    'nama_sekolah' => $user->school->nama_sekolah,
                    'jam_masuk' => $user->school->jam_masuk,
                    'jam_pulang' => $user->school->jam_pulang,
                    'radius_presensi' => $user->school->radius_presensi,
                ] : null,
            ],
        ];

        return response()->json($response);
    }

    /**
     * Riwayat absensi user
     * GET /api/absensi/history
     *
     * SECURITY: Multi-tenant scoped to user's own attendance
     */
    public function history(Request $request)
    {
        $user = $request->user();

        // Authorization check - users can view their own history
        $this->authorize('viewAny', Absensi::class);

        $absenList = Absensi::where('user_id', $user->id)
            ->with('school:id,nama_sekolah')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $absenList
        ]);
    }

    /**
     * Get attendance for admin views (multi-tenant scoped)
     * GET /api/absensi/admin
     *
     * SECURITY: Admin/Teacher can view attendance from their school
     */
    public function adminIndex(Request $request)
    {
        $user = $request->user();

        // Authorization check
        $this->authorize('viewReports', Absensi::class);

        $validated = $request->validate([
            'school_id' => 'sometimes|integer|exists:schools,id',
            'user_id' => 'sometimes|integer|exists:users,id',
            'date' => 'sometimes|date',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after_or_equal:start_date',
            'status' => 'sometimes|in:HADIR,TERLAMBAT,IZIN,SAKIT',
        ]);

        $query = Absensi::with(['user:id,name,role,school_id', 'school:id,nama_sekolah']);

        // SUPER_ADMIN can filter by school
        if ($user->isSuperAdmin() && isset($validated['school_id'])) {
            $query->where('school_id', $validated['school_id']);
        }
        // Other roles are scoped to their school
        elseif ($user->school_id) {
            $query->where('school_id', $user->school_id);
        }

        // Filter by user (if authorized)
        if (isset($validated['user_id'])) {
            // SUPER_ADMIN can filter any user
            if (!$user->isSuperAdmin()) {
                // Others can only filter users from their school
                $targetUser = User::find($validated['user_id']);
                if (!$targetUser || $targetUser->school_id !== $user->school_id) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Cannot view attendance for users outside your school',
                    ], 403);
                }
            }
            $query->where('user_id', $validated['user_id']);
        }

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

        $attendances = $query->orderBy('created_at', 'desc')->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $attendances,
        ]);
    }

    /**
     * Approve/Reject attendance (izin/sakit)
     * PUT /api/absensi/{id}/approve
     *
     * SECURITY: Admin/Teacher can approve attendance in their school
     */
    public function approve(Request $request, $id)
    {
        $attendance = Absensi::find($id);

        if (!$attendance) {
            return response()->json([
                'success' => false,
                'message' => 'Attendance not found',
            ], 404);
        }

        // Authorization check
        $this->authorize('approve', $attendance);

        $validated = $request->validate([
            'approved' => 'required|boolean',
            'notes' => 'nullable|string|max:500',
        ]);

        DB::beginTransaction();
        try {
            if ($validated['approved']) {
                // Already approved logic here
                // For now, just mark as reviewed
            } else {
                // Rejection logic here
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => $validated['approved'] ? 'Attendance approved' : 'Attendance rejected',
                'data' => $attendance->fresh(),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to approve attendance: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Helper: hitung durasi kerja (format: X jam Y menit)
     */
    private function calculateDuration($jamMasuk, $jamPulang): string
    {
        if (!$jamMasuk || !$jamPulang) {
            return '-';
        }

        $masuk = \Carbon\Carbon::parse($jamMasuk);
        $pulang = \Carbon\Carbon::parse($jamPulang);
        $diff = $masuk->diff($pulang);

        $hours = $diff->h + ($diff->days * 24);
        $minutes = $diff->i;

        return "{$hours} jam {$minutes} menit";
    }
}
