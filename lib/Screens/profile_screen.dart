import 'package:career_guidance/Screens/login_screen.dart';
import 'package:career_guidance/Theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  bool _isEditingName = false;
  bool _isEditingPassword = false;
  bool _isEditingPreferences = false;
  bool _isLoadingPreferences = true;
  bool _isSavingPreferences = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dreamJobController = TextEditingController();
  final _scrollController = ScrollController();

  // Preferences data
  String _selectedCurrentStatus = '';
  String _selectedLearningStyle = '';
  Set<String> _selectedInterests = {};

  // Options for dropdowns
  static const List<String> _currentStatusOptions = [
    'Middle School Student',
    'High School Student',
    'College/University Student',
    'Recent Graduate',
    'Currently Working',
    'Career Changer',
  ];

  static const List<String> _learningStyleOptions = [
    'Online Courses',
    'Video Tutorials',
    'Books & Articles',
    'Hands-on Projects',
    'Mentorship',
    'Bootcamps',
  ];

  static const List<String> _interestOptions = [
    'Technology',
    'Healthcare',
    'Business',
    'Arts & Design',
    'Education',
    'Science',
    'Engineering',
    'Finance',
    'Marketing',
    'Law',
    'Media',
    'Social Services',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _dreamJobController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _dreamJobController.text = data['dream_job'] ?? '';
          _selectedCurrentStatus = data['current_status'] ?? '';
          _selectedLearningStyle = data['learning_style'] ?? '';
          _selectedInterests = Set<String>.from(data['interests'] ?? []);
          _isLoadingPreferences = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingPreferences = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      if (mounted) {
        setState(() {
          _isLoadingPreferences = false;
        });
      }
    }
  }

  Future<void> _savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_dreamJobController.text.trim().isEmpty) {
      _showSnackBar('Please enter your dream job', isError: true);
      return;
    }

    if (_selectedCurrentStatus.isEmpty) {
      _showSnackBar('Please select your current status', isError: true);
      return;
    }

    setState(() {
      _isSavingPreferences = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'dream_job': _dreamJobController.text.trim(),
        'current_status': _selectedCurrentStatus,
        'learning_style': _selectedLearningStyle,
        'interests': _selectedInterests.toList(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isEditingPreferences = false;
        _isSavingPreferences = false;
      });

      if (mounted) {
        _showSnackBar('Preferences saved successfully', isError: false);
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      setState(() {
        _isSavingPreferences = false;
      });
      if (mounted) {
        _showSnackBar('Error saving preferences. Please try again.', isError: true);
      }
    }
  }

  void _startEditingPreferences() {
    setState(() {
      _isEditingPreferences = true;
    });
  }

  void _cancelEditingPreferences() {
    _loadPreferences();
    setState(() {
      _isEditingPreferences = false;
    });
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error signing out: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _startEditingName(User user) {
    final currentName = user.displayName ?? '';
    final nameParts = currentName.split(' ');

    _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
    _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    setState(() {
      _isEditingName = true;
    });
  }

  void _cancelEditingName() {
    setState(() {
      _isEditingName = false;
    });
    _firstNameController.clear();
    _lastNameController.clear();
  }

  Future<void> _saveName() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty) {
      _showSnackBar('Please enter a first name', isError: true);
      return;
    }

    final fullName = '$firstName ${lastName}'.trim();

    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(fullName);
      await FirebaseAuth.instance.currentUser?.reload();

      setState(() {
        _isEditingName = false;
      });

      if (mounted) {
        _showSnackBar('Name updated successfully', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error updating name: ${e.toString()}', isError: true);
      }
    }
  }

  void _startEditingPassword() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    setState(() {
      _isEditingPassword = true;
    });
  }

  void _cancelEditingPassword() {
    setState(() {
      _isEditingPassword = false;
    });
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _savePassword(User user) async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('New passwords do not match', isError: true);
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return;
    }

    try {
      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      setState(() {
        _isEditingPassword = false;
      });

      if (mounted) {
        _showSnackBar('Password changed successfully', isError: false);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error changing password';
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak';
      }
      if (mounted) {
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceLight,
      appBar: AppBar(
        backgroundColor: kSurfaceLight,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading profile...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          final user = snapshot.data!;
          final currentName = user.displayName ?? '';
          final nameParts = currentName.split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shadowColor: Colors.blue.shade700.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade700.withOpacity(0.05),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade700.withOpacity(0.15),
                          child: user.photoURL != null
                              ? ClipOval(
                            child: Image.network(
                              user.photoURL!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Text(
                                    _getInitials(user.displayName ?? user.email),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                            ),
                          )
                              : Text(
                            _getInitials(user.displayName ?? user.email),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display Name
                        Text(
                          user.displayName ?? 'User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Email
                        Text(
                          user.email ?? 'No email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Divider
                        Divider(color: Colors.grey.shade300),

                        const SizedBox(height: 24),

                        // Name Section (First and Last)
                        _buildNameSection(
                          firstName: firstName,
                          lastName: lastName,
                          isEditing: _isEditingName,
                          onEdit: () => _startEditingName(user),
                        ),

                        // Save/Cancel buttons for name
                        if (_isEditingName) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _cancelEditingName,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveName,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Password
                        _buildInfoItem(
                          icon: Icons.lock,
                          label: 'Password',
                          value: '••••••••',
                          isEditing: _isEditingPassword,
                          onEdit: _startEditingPassword,
                        ),

                        // Password change fields
                        if (_isEditingPassword) ...[
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            icon: Icons.lock_outline,
                            label: 'Current Password',
                            controller: _currentPasswordController,
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            icon: Icons.lock_reset,
                            label: 'New Password',
                            controller: _newPasswordController,
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            icon: Icons.lock,
                            label: 'Confirm New Password',
                            controller: _confirmPasswordController,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _cancelEditingPassword,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancelll',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _savePassword(user),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Preferences Section
                _buildPreferencesSection(),

                const SizedBox(height: 8),

                // Sign Out Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _showSignOutDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade600,
                            Colors.red.shade600.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade600.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 20,
                              ),
                            const SizedBox(width: 12),
                            Text(
                              _isLoading ? 'Signing Out...' : 'Sign Out',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameSection({
    required String firstName,
    required String lastName,
    required bool isEditing,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!isEditing)
                      Text(
                        '${firstName.isEmpty ? 'Not set' : firstName} ${lastName}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (!isEditing)
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  onPressed: onEdit,
                ),
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'First Name',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 0,
                          ),
                          border: InputBorder.none,
                          hintText: 'Enter First Name',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Name',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 0,
                          ),
                          border: InputBorder.none,
                          hintText: 'Enter Last Name',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isEditing = false,
    TextEditingController? controller,
    VoidCallback? onEdit,
    bool showEditButton = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditing && controller != null)
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 0,
                      ),
                      border: InputBorder.none,
                      hintText: 'Enter $label',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (showEditButton && onEdit != null && !isEditing)
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 20,
                color: Colors.blue.shade700,
              ),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 0,
                    ),
                    border: InputBorder.none,
                    hintText: 'Enter $label',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.purple.shade700.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade700.withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.route,
                    color: Colors.purple.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Career Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Help us personalize your career path',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isEditingPreferences && !_isLoadingPreferences)
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.purple.shade700,
                    ),
                    onPressed: _startEditingPreferences,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            if (_isLoadingPreferences)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // Dream Job Field
              _buildPreferenceField(
                icon: Icons.stars,
                label: 'Dream Job / Career Goal',
                hint: 'e.g., Software Engineer, Doctor, Designer',
                isEditing: _isEditingPreferences,
                child: _isEditingPreferences
                    ? TextField(
                        controller: _dreamJobController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.purple.shade400),
                          ),
                          hintText: 'Enter your dream job',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      )
                    : Text(
                        _dreamJobController.text.isEmpty
                            ? 'Not set'
                            : _dreamJobController.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _dreamJobController.text.isEmpty
                              ? Colors.grey.shade400
                              : Colors.grey.shade800,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Current Status Dropdown
              _buildPreferenceField(
                icon: Icons.school,
                label: 'Current Status',
                hint: 'Where are you in your journey?',
                isEditing: _isEditingPreferences,
                child: _isEditingPreferences
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCurrentStatus.isEmpty
                                ? null
                                : _selectedCurrentStatus,
                            hint: Text(
                              'Select your current status',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.purple.shade400),
                            items: _currentStatusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCurrentStatus = value ?? '';
                              });
                            },
                          ),
                        ),
                      )
                    : Text(
                        _selectedCurrentStatus.isEmpty
                            ? 'Not set'
                            : _selectedCurrentStatus,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedCurrentStatus.isEmpty
                              ? Colors.grey.shade400
                              : Colors.grey.shade800,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Learning Style Dropdown
              _buildPreferenceField(
                icon: Icons.lightbulb,
                label: 'Preferred Learning Style',
                hint: 'How do you learn best?',
                isEditing: _isEditingPreferences,
                child: _isEditingPreferences
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLearningStyle.isEmpty
                                ? null
                                : _selectedLearningStyle,
                            hint: Text(
                              'Select your learning style',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.purple.shade400),
                            items: _learningStyleOptions.map((style) {
                              return DropdownMenuItem(
                                value: style,
                                child: Text(style),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLearningStyle = value ?? '';
                              });
                            },
                          ),
                        ),
                      )
                    : Text(
                        _selectedLearningStyle.isEmpty
                            ? 'Not set'
                            : _selectedLearningStyle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedLearningStyle.isEmpty
                              ? Colors.grey.shade400
                              : Colors.grey.shade800,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Interests Multi-select
              _buildPreferenceField(
                icon: Icons.interests,
                label: 'Areas of Interest',
                hint: 'Select all that apply',
                isEditing: _isEditingPreferences,
                child: _isEditingPreferences
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _interestOptions.map((interest) {
                          final isSelected =
                              _selectedInterests.contains(interest);
                          return FilterChip(
                            label: Text(
                              interest,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInterests.add(interest);
                                } else {
                                  _selectedInterests.remove(interest);
                                }
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.purple.shade400,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }).toList(),
                      )
                    : _selectedInterests.isEmpty
                        ? Text(
                            'Not set',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedInterests.map((interest) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  interest,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
              ),

              // Save/Cancel buttons for preferences
              if (_isEditingPreferences) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _isSavingPreferences ? null : _cancelEditingPreferences,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSavingPreferences ? null : _savePreferences,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSavingPreferences
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Preferences'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceField({
    required IconData icon,
    required String label,
    required String hint,
    required bool isEditing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.purple.shade400,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: 4),
            Text(
              hint,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}