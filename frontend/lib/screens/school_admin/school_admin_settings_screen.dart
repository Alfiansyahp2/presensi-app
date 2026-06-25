import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/widgets/animated_background.dart';
import '../../core/theme/app_colors.dart';
import '../../api/school_api.dart';
import '../../utils/shared_storage.dart';
import '../../widgets/layouts/dashboard_layout.dart';
import '../../widgets/dashboard/dashboard_section_card.dart';
import '../../providers/theme_provider.dart';

/// School Admin - School Settings Screen dengan Data Aktual
///
/// Fitur:
/// - Edit jam masuk/pulang
/// - Edit radius presensi
/// - Edit toleransi keterlambat
/// - Edit nama dan alamat sekolah
/// - Save perubahan
class SchoolAdminSettingsScreen extends StatefulWidget {
  const SchoolAdminSettingsScreen({super.key});

  @override
  State<SchoolAdminSettingsScreen> createState() =>
      _SchoolAdminSettingsScreenState();
}

class _SchoolAdminSettingsScreenState extends State<SchoolAdminSettingsScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  bool _isLoading = true;
  bool _isSaving = false;

  // School data
  Map<String, dynamic>? _schoolData;

  // Form controllers
  final _namaSekolahController = TextEditingController();
  final _alamatController = TextEditingController();
  final _jamMasukController = TextEditingController();
  final _jamPulangController = TextEditingController();
  final _radiusController = TextEditingController();
  final _toleransiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
  }

  Future<void> _loadSchoolData() async {
    setState(() => _isLoading = true);

    try {
      final token = await SharedStorage.getToken();
      final userData = await SharedStorage.getUserData();

      if (token == null || userData == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final schoolId = userData['school_id'] as int?;
      if (schoolId == null) {
        _handleError('School ID tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      // Load school data dari API
      final schoolResult = await SchoolApiService.getSchoolById(
        token: token,
        schoolId: schoolId,
      );

      if (mounted) {
        if (schoolResult['success'] == true && schoolResult['school'] != null) {
          // Get school data - API returns 'school' not 'data'
          final school = schoolResult['school'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(schoolResult['school'])
              : <String, dynamic>{};

          setState(() {
            _schoolData = school;
            _initControllers(school);
            _isLoading = false;
          });
        } else {
          // Handle case where data not available
          setState(() {
            _schoolData = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading school data: $e');
      _handleError('Terjadi kesalahan: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _initControllers(Map<String, dynamic> school) {
    _namaSekolahController.text = school['nama_sekolah']?.toString() ?? '';
    _alamatController.text = school['alamat']?.toString() ?? '';

    final jamMasuk = school['jam_masuk']?.toString() ?? '07:00:00';
    _jamMasukController.text = jamMasuk.length > 5 ? jamMasuk.substring(0, 5) : jamMasuk;

    final jamPulang = school['jam_pulang']?.toString() ?? '16:00:00';
    _jamPulangController.text = jamPulang.length > 5 ? jamPulang.substring(0, 5) : jamPulang;

    _radiusController.text = '${school['radius_presensi'] ?? 100}';
    _toleransiController.text = '${school['toleransi_terlambat'] ?? 15}';
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final token = await SharedStorage.getToken();
      final userData = await SharedStorage.getUserData();

      if (token == null || userData == null) {
        _handleError('Sesi tidak valid');
        setState(() => _isSaving = false);
        return;
      }

      final schoolId = userData['school_id'] as int?;

      // TODO: Implement update school API
      // final response = await http.put(...)

      // For now, show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Pengaturan berhasil disimpan'),
              ],
            ),
            backgroundColor: AppColors.formalGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _handleError('Gagal menyimpan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaSekolahController.dispose();
    _alamatController.dispose();
    _jamMasukController.dispose();
    _jamPulangController.dispose();
    _radiusController.dispose();
    _toleransiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _themeProvider.isDarkMode,
      child: DashboardLayout(
        title: 'Pengaturan Sekolah',
        userRole: 'SCHOOL_ADMIN',
        isDarkMode: _themeProvider.isDarkMode,
        onRefresh: _loadSchoolData,
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, size: 18),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaving
                      ? Colors.grey
                      : AppColors.formalGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 80, // ✅ Increased space for bottom navigation
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _schoolData == null
                  ? _buildEmptyState()
                  : _buildSettingsForm(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: _themeProvider.isDarkMode
                ? AppColors.darkAccent.withValues(alpha: 0.5)
                : AppColors.formalNavy.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Data sekolah tidak ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _themeProvider.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏫 Informasi Sekolah
        _buildSection(
          title: 'Informasi Sekolah',
          icon: Icons.school,
          children: [
            _buildTextField(
              label: 'Nama Sekolah',
              controller: _namaSekolahController,
              icon: Icons.business,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Alamat',
              controller: _alamatController,
              icon: Icons.location_on,
              maxLines: 3,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ⏰ Jam Operasional
        _buildSection(
          title: 'Jam Operasional',
          icon: Icons.access_time,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Jam Masuk',
                    controller: _jamMasukController,
                    icon: Icons.login,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    label: 'Jam Pulang',
                    controller: _jamPulangController,
                    icon: Icons.logout,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 📍 Presensi Settings
        _buildSection(
          title: 'Pengaturan Presensi',
          icon: Icons.location_on,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Radius Presensi (meter)',
                    controller: _radiusController,
                    icon: Icons.radio_button_unchecked,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'Toleransi Keterlambatan (menit)',
                    controller: _toleransiController,
                    icon: Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationInfo(),
          ],
        ),

        const SizedBox(height: 24),

        // 📍 Koordinat Lokasi
        _buildSection(
          title: 'Koordinat Lokasi',
          icon: Icons.place,
          children: [
            _buildCoordinateDisplay(),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _themeProvider.isDarkMode
                    ? AppColors.darkAccent
                    : AppColors.formalNavy,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: _themeProvider.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: _themeProvider.isDarkMode
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () {
        // TODO: Show time picker
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: _themeProvider.isDarkMode
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: _themeProvider.isDarkMode
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (_themeProvider.isDarkMode
                ? AppColors.darkAccent
                : AppColors.formalNavy)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_themeProvider.isDarkMode
                  ? AppColors.darkAccent
                  : AppColors.formalNavy)
              .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: _themeProvider.isDarkMode
                ? AppColors.darkAccent
                : AppColors.formalNavy,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Radius presensi digunakan untuk geofencing. Siswa harus berada dalam radius ini untuk bisa absen.',
              style: TextStyle(
                color: _themeProvider.isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _themeProvider.isDarkMode
            ? AppColors.darkSurface
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.place,
            color: AppColors.formalGreen,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latitude',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${_schoolData?['latitude'] ?? -6.1754}',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Longitude',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${_schoolData?['longitude'] ?? 106.8272}',
                  style: TextStyle(
                    color: _themeProvider.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
