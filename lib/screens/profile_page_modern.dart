import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../core/theme.dart';
import '../services/skincare_api_service.dart';

class ProfilePageModern extends StatefulWidget {
  const ProfilePageModern({Key? key}) : super(key: key);

  @override
  State<ProfilePageModern> createState() => _ProfilePageModernState();
}

class _ProfilePageModernState extends State<ProfilePageModern>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Text controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // Kullanıcı bilgileri
  String _name = "Rojin Güler";
  String _email = "roj.gulerr@gmail.com";
  String _selectedSkinType = "Combination";
  List<String> _selectedSkinProblems = ["Acne", "Blackheads"];

  // Cilt tipleri
  final List<Map<String, dynamic>> _skinTypes = [
    {
      'name': 'Combination',
      'description': 'Oily T-zone, normal cheeks',
    },
    {
      'name': 'Oily',
      'description': 'Oily and shiny all over',
    },
    {
      'name': 'Dry',
      'description': 'Tight and flaky',
    },
    {
      'name': 'Normal',
      'description': 'Balanced and healthy',
    },
    {
      'name': 'Sensitive',
      'description': 'Easily irritated',
    },
  ];

  // Cilt sorunları
  final List<String> _skinProblems = [
    'Acne',
    'Blackheads',
    'Wrinkles',
    'Blemishes',
    'Pores',
    'Dryness',
    'Oiliness',
    'Sensitivity',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize text controllers immediately with default values
    _nameController = TextEditingController(text: _name);
    _emailController = TextEditingController(text: _email);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    
    // Load user data after initialization
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? "Rojin Güler";
      _email = prefs.getString('user_email') ?? "roj.gulerr@gmail.com";
      _selectedSkinType = prefs.getString('skin_type') ?? "Combination";
      _selectedSkinProblems = prefs.getStringList('skin_problems') ?? ["Acne", "Blackheads"];
      
      // Profil fotoğrafını yükle
      final profileImagePath = prefs.getString('profile_image_path');
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        _profileImage = File(profileImagePath);
      }
    });
    
    // Update text controllers with loaded data
    _nameController.text = _name;
    _emailController.text = _email;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        // Profil fotoğrafı yolunu kaydet
        await _saveProfileImage(image.path);
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text('Error selecting photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
                          children: [
          Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
              color: AppColors.pink,
                                  boxShadow: [
                                    BoxShadow(
                  color: AppColors.pink.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
            child: _profileImage != null
                ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      width: 120,
                      height: 120,
                                              fit: BoxFit.cover,
                    ),
                  )
                : ClipOval(
                    child: Container(
                      color: AppColors.pink,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                                ),
                              ),
                            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.marron,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
        color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
                                style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // İsim
          _buildInfoField(
            'Name',
            _name,
            Icons.person_outline,
          ),
          const SizedBox(height: 16),
          
          // E-posta
          _buildInfoField(
            'Email',
            _email,
            Icons.email_outlined,
                            ),
                          ],
                        ),
    );
  }

  Widget _buildInfoField(
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.shadowLight),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.pink,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: label == 'Name' ? _nameController : _emailController,
                  onChanged: (newValue) {
                    if (label == 'Name') {
                      setState(() {
                        _name = newValue;
                      });
                      _saveName(newValue);
                    } else if (label == 'E-posta') {
                      setState(() {
                        _email = newValue;
                      });
                      _saveEmail(newValue);
                    }
                  },
                  keyboardType: label == 'Email' ? TextInputType.emailAddress : TextInputType.text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(String label, String value, IconData icon) {
    final controller = TextEditingController(text: value);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$label Edit',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: label == 'Email' ? TextInputType.emailAddress : TextInputType.text,
          style: GoogleFonts.poppins(fontSize: 16),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.pink),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              if (label == 'Name') {
                setState(() {
                  _name = controller.text;
                });
                _saveName(controller.text);
              } else if (label == 'Email') {
                setState(() {
                  _email = controller.text;
                });
                _saveEmail(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinTypeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            'My Skin Type',
              style: GoogleFonts.poppins(
              fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showSkinTypeDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.shadowLight),
              ),
              child: Row(
              children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: Colors.white,
                      size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedSkinType,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _skinTypes.firstWhere((type) => type['name'] == _selectedSkinType)['description'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                  ),
                ),
              ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
            ),
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSkinTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Skin Type',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _skinTypes.length,
            itemBuilder: (context, index) {
              final skinType = _skinTypes[index];
              final isSelected = _selectedSkinType == skinType['name'];
              
    return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
      decoration: BoxDecoration(
                      color: isSelected ? AppColors.pink : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
        border: Border.all(
                        color: isSelected ? AppColors.pink : AppColors.shadowLight,
                      ),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    skinType['name'],
            style: GoogleFonts.poppins(
              fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
            ),
          ),
                  subtitle: Text(
                    skinType['description'],
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedSkinType = skinType['name'];
                    });
                    _saveSkinType(skinType['name']);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSkinProblemsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                'My Skin Problems',
                  style: GoogleFonts.poppins(
                  fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                  GestureDetector(
                onTap: () => _showSkinProblemsDialog(),
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ),
          ],
        ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSkinProblems.map((problemName) {
    return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  problemName,
        style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showSkinProblemsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Skin Problems',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
        content: Container(
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (context, setState) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: _skinProblems.length,
                itemBuilder: (context, index) {
                  final problem = _skinProblems[index];
                  final isSelected = _selectedSkinProblems.contains(problem);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                    decoration: BoxDecoration(
                          color: isSelected ? AppColors.pink : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                            color: isSelected ? AppColors.pink : AppColors.shadowLight,
                          ),
                        ),
                        child: Icon(
                          Icons.circle,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        problem,
                              style: GoogleFonts.poppins(
                          fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedSkinProblems.add(problem);
                            } else {
                              _selectedSkinProblems.remove(problem);
                            }
                          });
                        },
                        activeColor: AppColors.pink,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveSkinProblems(_selectedSkinProblems);
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
        child: Column(
          children: [
          _buildSettingsItem(
            'Privacy',
            Icons.privacy_tip_outlined,
            () {
              _showPrivacyDialog();
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            'Help & Support',
            Icons.help_outline,
            () {
              _showHelpDialog();
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            'SkincareAPI Test',
            Icons.api,
            () {
              _testSkincareApi();
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            'Log Out',
            Icons.logout,
            () {
              _showLogoutDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
        content: Text(
          'Privacy settings will be displayed here.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Help & Support',
                          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
        content: Text(
          'Help and support information will be displayed here.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
  }

  void _testSkincareApi() async {
    // Loading dialog göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.pink),
            SizedBox(width: 20),
            Text(
              'Testing SkincareAPI...',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    // API test et
    final isConnected = await SkincareApiService.testApiConnection();
    
    // Loading dialog'u kapat
    Navigator.pop(context);
    
    // Sonuç dialog'u göster
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'SkincareAPI Test Result',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              color: isConnected ? Colors.green : Colors.red,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              isConnected 
                ? '✅ SkincareAPI connection successful!\n\nReal product data available.'
                : '❌ SkincareAPI connection failed!\n\nMock data will be used.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Çıkış yapma işlemi
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.pink,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textSecondary,
        size: 16,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: AppColors.shadowLight,
      height: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.pink,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.pink,
                    child: Center(
                      child: _buildProfileImage(),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileInfo(),
                    const SizedBox(height: 20),
                    _buildSkinTypeSection(),
                    const SizedBox(height: 20),
                    _buildSkinProblemsSection(),
                    const SizedBox(height: 20),
                    _buildSettingsSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kaydetme fonksiyonları
  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    // İsim kaydedildi
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    // E-posta kaydedildi
  }

  Future<void> _saveSkinType(String skinType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('skin_type', skinType);
    // Cilt tipi kaydedildi
  }

  Future<void> _saveSkinProblems(List<String> problems) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('skin_problems', problems);
    // Cilt sorunları kaydedildi
  }

  Future<void> _saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', imagePath);
    // Profil fotoğrafı kaydedildi
  }
}