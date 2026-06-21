<?php

namespace App\Http\Controllers;

use App\Models\Absensi;
use App\Models\School;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    /**
     * Generate attendance report.
     * GET /api/reports/attendance
     *
     * SECURITY: Multi-tenant scoped based on user role
     */
    public function attendanceReport(Request $request)
    {
        $user = $request->user();

        // Authorization check
        $this->authorize('viewReports', Absensi::class);

        $validated = $request->validate([
            'school_id' => 'sometimes|integer|exists:schools,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'status' => 'sometimes|in:HADIR,TERLAMBAT,IZIN,SAKIT',
            'role' => 'sometimes|in:STUDENT,TEACHER',
        ]);

        $query = Absensi::with(['user:id,fullname,kelas,role', 'school:id,nama_sekolah']);

        // SUPER_ADMIN can filter by school
        if ($user->isSuperAdmin() && isset($validated['school_id'])) {
            $query->where('school_id', $validated['school_id']);
        }
        // Other roles are scoped to their school
        elseif ($user->school_id) {
            $query->where('school_id', $user->school_id);
        }

        // Date range filter
        $query->whereBetween('created_at', [
            $validated['start_date'] . ' 00:00:00',
            $validated['end_date'] . ' 23:59:59'
        ]);

        // Status filter
        if (isset($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        // Role filter (if user role is STUDENT, only show their own)
        if ($user->isStudent()) {
            $query->where('user_id', $user->id);
        }

        $attendances = $query->orderBy('created_at', 'desc')->get();

        // Generate statistics
        $statistics = [
            'total_records' => $attendances->count(),
            'hadir' => $attendances->where('status', 'HADIR')->count(),
            'terlambat' => $attendances->where('status', 'TERLAMBAT')->count(),
            'izin' => $attendances->where('status', 'IZIN')->count(),
            'sakit' => $attendances->where('status', 'SAKIT')->count(),
            'attendance_rate' => $attendances->count() > 0 ? round(($attendances->whereIn('status', ['HADIR', 'TERLAMBAT'])->count() / $attendances->count()) * 100, 2) : 0,
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'attendances' => $attendances,
                'statistics' => $statistics,
                'filters' => [
                    'start_date' => $validated['start_date'],
                    'end_date' => $validated['end_date'],
                    'school_id' => $validated['school_id'] ?? $user->school_id,
                ],
            ],
        ]);
    }

    /**
     * Export attendance report to CSV.
     * GET /api/reports/attendance/export
     *
     * SECURITY: Multi-tenant scoped based on user role
     */
    public function exportAttendance(Request $request)
    {
        $user = $request->user();

        // Authorization check
        $this->authorize('exportReports', Absensi::class);

        $validated = $request->validate([
            'school_id' => 'sometimes|integer|exists:schools,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'format' => 'sometimes|in:csv,xlsx',
        ]);

        $format = $validated['format'] ?? 'csv';

        // Get attendance data (same logic as attendanceReport)
        $query = Absensi::with(['user:id,fullname,kelas,role', 'school:id,nama_sekolah']);

        // SUPER_ADMIN can filter by school
        if ($user->isSuperAdmin() && isset($validated['school_id'])) {
            $query->where('school_id', $validated['school_id']);
        }
        // Other roles are scoped to their school
        elseif ($user->school_id) {
            $query->where('school_id', $user->school_id);
        }

        // Date range filter
        $query->whereBetween('created_at', [
            $validated['start_date'] . ' 00:00:00',
            $validated['end_date'] . ' 23:59:59'
        ]);

        // STUDENT can only export their own
        if ($user->isStudent()) {
            $query->where('user_id', $user->id);
        }

        $attendances = $query->orderBy('created_at', 'desc')->get();

        // Generate CSV data
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="attendance_report_' . date('Y-m-d') . '.csv"',
        ];

        $callback = function () use ($attendances) {
            $file = fopen('php://output', 'w');

            // CSV Header
            fputcsv($file, [
                'Date',
                'Student Name',
                'Class',
                'School',
                'Check In',
                'Check Out',
                'Status',
                'Distance (m)',
                'Reason',
            ]);

            // CSV Data
            foreach ($attendances as $attendance) {
                fputcsv($file, [
                    $attendance->created_at->format('Y-m-d'),
                    $attendance->user->fullname,
                    $attendance->user->kelas,
                    $attendance->school->nama_sekolah,
                    $attendance->jam_masuk,
                    $attendance->jam_pulang,
                    $attendance->status,
                    $attendance->jarak_meter,
                    $attendance->alasan,
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }

    /**
     * Generate summary report.
     * GET /api/reports/summary
     *
     * SECURITY: Multi-tenant scoped based on user role
     */
    public function summary(Request $request)
    {
        $user = $request->user();

        // Authorization check
        $this->authorize('viewReports', Absensi::class);

        $validated = $request->validate([
            'school_id' => 'sometimes|integer|exists:schools,id',
            'month' => 'sometimes|integer|min:1|max:12',
            'year' => 'sometimes|integer|min:2020|max:2099',
        ]);

        // Default to current month/year
        $month = $validated['month'] ?? now()->month;
        $year = $validated['year'] ?? now()->year;

        // Determine school scope
        $schoolId = null;

        if ($user->isSuperAdmin() && isset($validated['school_id'])) {
            $schoolId = $validated['school_id'];
        } elseif ($user->school_id) {
            $schoolId = $user->school_id;
        }

        // Get school
        $school = $schoolId ? School::find($schoolId) : null;

        if (!$school && $schoolId) {
            return response()->json([
                'success' => false,
                'message' => 'School not found',
            ], 404);
        }

        // Get attendance data for the month
        $query = Absensi::whereYear('created_at', $year)
            ->whereMonth('created_at', $month);

        if ($school) {
            $query->where('school_id', $school->id);
        }

        // STUDENT only sees own summary
        if ($user->isStudent()) {
            $query->where('user_id', $user->id);
        }

        $attendances = $query->get();

        // Calculate statistics
        $totalDays = $attendances->pluck('created_at')->unique(function ($date) {
            return $date->format('Y-m-d');
        })->count();

        $statistics = [
            'period' => [
                'month' => $month,
                'year' => $year,
                'month_name' => date('F', mktime(0, 0, 0, $month, 1, $year)),
            ],
            'school' => $school ? [
                'id' => $school->id,
                'nama_sekolah' => $school->nama_sekolah,
            ] : null,
            'attendance' => [
                'total_records' => $attendances->count(),
                'total_days' => $totalDays,
                'hadir' => $attendances->where('status', 'HADIR')->count(),
                'terlambat' => $attendances->where('status', 'TERLAMBAT')->count(),
                'izin' => $attendances->where('status', 'IZIN')->count(),
                'sakit' => $attendances->where('status', 'SAKIT')->count(),
                'attendance_rate' => $attendances->count() > 0 ? round(($attendances->whereIn('status', ['HADIR', 'TERLAMBAT'])->count() / $attendances->count()) * 100, 2) : 0,
                'on_time_rate' => $attendances->count() > 0 ? round(($attendances->where('status', 'HADIR')->count() / $attendances->count()) * 100, 2) : 0,
            ],
        ];

        // For STUDENT role, add personal statistics
        if ($user->isStudent()) {
            $statistics['personal'] = [
                'user_id' => $user->id,
                'fullname' => $user->fullname,
                'kelas' => $user->kelas,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $statistics,
        ]);
    }
}
