import 'package:flutter/material.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/theme/app_colors.dart';
import '../../api/school_api.dart';
import '../../utils/shared_storage.dart';
import '../../widgets/layouts/dashboard_layout.dart';
import '../../widgets/dashboard/dashboard_section_card.dart';
import '../../providers/theme_provider.dart';

/// School Admin - User Management Screen dengan Data Aktual
///
/// Fitur:
/// - List users di sekolah (real-time dari API)
/// - Filter berdasarkan role
/// - Approve/reject pending users
/// - User statistics
class SchoolAdminUsersScreen extends StatefulWidget {
  const SchoolAdminUsersScreen({super.key});

  @override
  State<SchoolAdminUsersScreen> createState() =>
      _SchoolAdminUsersScreenState();
}

class _SchoolAdminUsersScreenState extends State<SchoolAdminUsersScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  bool _isLoading = true;

  // Data dari API
  List<dynamic>? _users;
  Map<String, dynamic>? _stats;

  // Filter
  String _selectedRoleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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

      // Load users dari sekolah ini
      final usersResult = await SchoolApiService.getSchoolUsers(
        token: token,
        schoolId: schoolId,
      );

      if (mounted) {
        setState(() {
          if (usersResult['success'] == true) {
            _users = usersResult['users'];

            // Calculate statistics
            if (_users != null) {
              _stats = {
                'total': _users!.length,
                'students': _users!.where((u) => u['role'] == 'STUDENT').length,
                'teachers': _users!.where((u) => u['role'] == 'TEACHER').length,
                'admins': _users!.where((u) => u['role'] == 'SCHOOL_ADMIN').length,
                'active': _users!.where((u) => u['status'] == 'ACTIVE').length,
                'pending': _users!.where((u) => u['status'] == 'PENDING').length,
              };
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      _handleError('Terjadi kesalahan: ${e.toString()}');
      setState(() => _isLoading = false);
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

  List<dynamic> get _filteredUsers {
    if (_users == null) return [];

    if (_selectedRoleFilter == 'ALL') {
      return _users!;
    }

    return _users!.where((u) => u['role'] == _selectedRoleFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      isDarkMode: _themeProvider.isDarkMode,
      child: DashboardLayout(
        title: 'Manajemen Users',
        userRole: 'SCHOOL_ADMIN',
        isDarkMode: _themeProvider.isDarkMode,
        onRefresh: _loadUserData,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 80, // ✅ Increased space for bottom navigation
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📊 Statistics
              if (!_isLoading && _stats != null) _buildStatsGrid(),
              const SizedBox(height: 24),

              // 🔍 Filter
              _buildFilterRow(),
              const SizedBox(height: 20),

              // 👥 User List
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? _buildEmptyState()
                      : _buildUserList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        // Cards dengan icon dan angka sejajar
        GridView.count(
          crossAxisCount: 3, // ✅ 3 columns sejajar kesamping
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            _buildCompactStatCard(
              icon: Icons.people,
              label: 'Total',
              value: '${_stats!['total']}',
              color: AppColors.formalNavy,
            ),
            _buildCompactStatCard(
              icon: Icons.how_to_reg,
              label: 'Pending',
              value: '${_stats!['pending']}',
              color: Colors.orange,
            ),
            _buildCompactStatCard(
              icon: Icons.check_circle,
              label: 'Active',
              value: '${_stats!['active']}',
              color: AppColors.formalGreen,
            ),
          ],
        ),
        // Labels di bawah setiap card
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatLabel('Total'),
              _buildStatLabel('Pending'),
              _buildStatLabel('Active'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _themeProvider.isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon di kiri
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            // Angka di samping icon
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Label di bawah card
  Widget _buildStatLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: _themeProvider.isDarkMode
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFilterRow() {
    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter berdasarkan Role',
            style: TextStyle(
              color: _themeProvider.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ALL', 'Semua'),
                _buildFilterChip('STUDENT', 'Siswa'),
                _buildFilterChip('TEACHER', 'Guru'),
                _buildFilterChip('SCHOOL_ADMIN', 'Admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String role, String label) {
    final isSelected = _selectedRoleFilter == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoleFilter = role;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (_themeProvider.isDarkMode
                      ? AppColors.darkAccent
                      : AppColors.formalNavy)
              : (_themeProvider.isDarkMode
                      ? AppColors.darkSurface
                      : Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (_themeProvider.isDarkMode
                        ? AppColors.darkAccent
                        : AppColors.formalNavy)
                : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (_themeProvider.isDarkMode
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
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
            Icons.people_outline,
            size: 80,
            color: _themeProvider.isDarkMode
                ? AppColors.darkAccent.withValues(alpha: 0.5)
                : AppColors.formalNavy.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ada users $_selectedRoleFilter',
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

  Widget _buildUserList() {
    return Column(
      children: [
        for (int i = 0; i < _filteredUsers.length; i++)
          Padding(
            padding: i < _filteredUsers.length - 1
                ? const EdgeInsets.only(bottom: 16) // ✅ Space between cards
                : EdgeInsets.zero,
            child: _buildUserCard(_filteredUsers[i]),
          ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] as String? ?? 'STUDENT';
    final status = user['status'] as String? ?? 'PENDING';
    final isPending = status == 'PENDING';

    // Tentukan warna role
    Color roleColor;
    switch (role) {
      case 'STUDENT':
        roleColor = Colors.blue;
        break;
      case 'TEACHER':
        roleColor = Colors.purple;
        break;
      case 'SCHOOL_ADMIN':
        roleColor = AppColors.formalNavy;
        break;
      default:
        roleColor = Colors.grey;
    }

    // Tentukan warna status
    Color statusColor;
    switch (status) {
      case 'ACTIVE':
        statusColor = AppColors.formalGreen;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'SUSPENDED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return DashboardSectionCard(
      isDarkMode: _themeProvider.isDarkMode,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar/Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  role == 'STUDENT'
                      ? Icons.school
                      : role == 'TEACHER'
                          ? Icons.person
                          : Icons.admin_panel_settings,
                  color: roleColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['fullname'] ?? 'Unknown',
                      style: TextStyle(
                        color: _themeProvider.isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (role == 'STUDENT' && user['kelas'] != null)
                      Text(
                        'Kelas: ${user['kelas']}',
                        style: TextStyle(
                          color: _themeProvider.isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      user['email'] ?? '',
                      style: TextStyle(
                        color: _themeProvider.isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Role & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action buttons untuk pending users
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Reject user
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Approve user
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.formalGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
