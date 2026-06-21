<?php

namespace App\Http\Controllers;

use App\Models\School;
use Illuminate\Http\Request;

class SchoolController extends Controller
{
    /**
     * Display a listing of schools.
     * GET /api/schools
     */
    public function index()
    {
        $schools = School::all();

        return response()->json([
            'success' => true,
            'data' => $schools,
        ]);
    }

    /**
     * Store a newly created school.
     * POST /api/schools
     */
    public function store(Request $request)
    {
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

        $school = School::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Sekolah berhasil ditambahkan',
            'data' => $school,
        ], 201);
    }

    /**
     * Display the specified school.
     * GET /api/schools/{id}
     */
    public function show($id)
    {
        $school = School::with(['users', 'attendances'])->find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'Sekolah tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $school,
        ]);
    }

    /**
     * Update the specified school.
     * PUT/PATCH /api/schools/{id}
     */
    public function update(Request $request, $id)
    {
        $school = School::find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'Sekolah tidak ditemukan',
            ], 404);
        }

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

        $school->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Data sekolah berhasil diupdate',
            'data' => $school->fresh(),
        ]);
    }

    /**
     * Remove the specified school.
     * DELETE /api/schools/{id}
     */
    public function destroy($id)
    {
        $school = School::find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'Sekolah tidak ditemukan',
            ], 404);
        }

        // Cek apakah ada user terhubung
        if ($school->users()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak dapat menghapus sekolah yang masih memiliki user. Nonaktifkan saja.',
            ], 400);
        }

        $school->delete();

        return response()->json([
            'success' => true,
            'message' => 'Sekolah berhasil dihapus',
        ]);
    }

    /**
     * Get school statistics.
     * GET /api/schools/{id}/statistics
     */
    public function statistics($id)
    {
        $school = School::find($id);

        if (!$school) {
            return response()->json([
                'success' => false,
                'message' => 'Sekolah tidak ditemukan',
            ], 404);
        }

        $stats = [
            'total_users' => $school->users()->count(),
            'total_attendances' => $school->attendances()->count(),
            'attendances_today' => $school->attendances()
                                          ->whereDate('created_at', today())
                                          ->count(),
            'attendances_this_month' => $school->attendances()
                                              ->whereYear('created_at', now()->year)
                                              ->whereMonth('created_at', now()->month)
                                              ->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }
}
