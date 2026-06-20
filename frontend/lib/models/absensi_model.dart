class AbsensiModel {
  final int? id;
  final double latitude;
  final double longitude;
  final String status;
  final String? waktuAbsen;
  final String? createdAt;

  AbsensiModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.waktuAbsen,
    this.createdAt,
  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      id: json['id'],
      latitude: (json['latitude'] is num)
          ? json['latitude'].toDouble()
          : double.parse(json['latitude'].toString()),
      longitude: (json['longitude'] is num)
          ? json['longitude'].toDouble()
          : double.parse(json['longitude'].toString()),
      status: json['status'] ?? 'hadir',
      waktuAbsen: json['waktu_absen'] ?? json['created_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'waktu_absen': waktuAbsen,
      'created_at': createdAt,
    };
  }
}
