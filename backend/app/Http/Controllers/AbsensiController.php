<?php

namespace App\Http\Controllers;

use App\Models\Absensi;
use Illuminate\Http\Request;

class AbsensiController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'status' => 'required|in:hadir,izin,sakit',
        ]);

        if (!$request->has('latitude') || !$request->has('longitude')) {
            return response()->json(['message' => 'Lokasi tidak ditemukan'], 422);
        }

        // Lokasi MA-2, Jl. Medokan Asri Tengah No.12 Blok Q, Medokan Ayu, Kec. Rungkut, Surabaya
        $targetLat = -7.32787262808773;
        $targetLng = 112.79426795133186;

        $distance = $this->calculateDistance(
            $request->latitude,
            $request->longitude,
            $targetLat,
            $targetLng
        );

        if ($distance > 0.05) { // Radius 50m = 0.05km
            return response()->json([
                'success' => false,
                'message' => 'Anda berada di luar area absensi. Jarak: ' . round($distance * 1000) . ' meter'
            ], 403);
        }

        $absen = Absensi::create([
            'user_id'   => $request->user()->id,
            'status'    => $request->status,
            'latitude'  => $request->latitude,
            'longitude' => $request->longitude,
            // waktu_absen otomatis di-set oleh database (DEFAULT CURRENT_TIMESTAMP)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Absen berhasil',
            'data' => $absen
        ]);
    }

    public function history(Request $request)
    {
        $absenList = Absensi::where('user_id', $request->user()->id)
            ->orderBy('waktu_absen', 'desc')  // Gunakan waktu_absen, bukan tanggal
            ->get();

        return response()->json([
            'success' => true,
            'data' => $absenList
        ]);
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371;
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLon / 2) * sin($dLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        return $earthRadius * $c;
    }
}
