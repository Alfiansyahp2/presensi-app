class UserModel {
  final int? id;
  final String fullname;
  final String nisn;
  final String kelas;
  final String email;
  final String? token;

  UserModel({
    this.id,
    required this.fullname,
    required this.nisn,
    required this.kelas,
    required this.email,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullname: json['fullname'] ?? '',
      nisn: json['nisn'] ?? '',
      kelas: json['kelas'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'nisn': nisn,
      'kelas': kelas,
      'email': email,
      'token': token,
    };
  }
}
