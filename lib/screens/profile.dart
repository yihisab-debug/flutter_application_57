import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  bool isEditing = false;
  bool isSaving = false;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController avatarController;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    avatarController = TextEditingController(text: user?.avatar ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    final user = AuthService.currentUser;
    if (!isEditing && user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      avatarController.text = user.avatar ?? '';
    }
    setState(() => isEditing = !isEditing);
  }

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required')),
      );
      return;
    }

    setState(() => isSaving = true);

    final success = await _authService.updateUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      avatar: avatarController.text.trim().isNotEmpty
          ? avatarController.text.trim()
          : null,
    );

    if (mounted) {
      setState(() {
        isSaving = false;
        if (success) isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Profile'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (user != null) ...[

            IconButton(
              icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
              onPressed: toggleEdit,
            ),

            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[900],

                    title: const Text('Выход', style: TextStyle(color: Colors.white)),

                    content: const Text(
                      'Are you sure you want to log out?',
                      style: TextStyle(color: Colors.white70),
                    ),

                    actions: [

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          await _authService.logout();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        },
                        child: const Text('Exit', style: TextStyle(color: Colors.white)),
                      ),

                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),

      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Icon(Icons.person_off, size: 80, color: Colors.grey),

                  const SizedBox(height: 16),

                  const Text(
                    'You are not logged in',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Log in to see your profile',
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),

                ],
              ),
            )

          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                      user.avatar ?? 'https://placehold.co/400x400',
                    ),
                    onBackgroundImageError: (_, __) {},
                    child: user.avatar == null
                        ? const Icon(Icons.person, size: 80, color: Colors.white)
                        : null,
                  ),

                  const SizedBox(height: 24),

                  if (isEditing) ...[

                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.person, color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),

                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,

                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.email, color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),

                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: avatarController,
                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: 'Avatar URL',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.image, color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),

                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),

                        child: isSaving

                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )

                            : const Text(
                                'Save',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),

                      ),
                    ),

                  ] else ...[

                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    Card(
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 16),

                            ListTile(
                              leading: const Icon(Icons.badge, color: Colors.white70),

                              title: const Text('ID', style: TextStyle(color: Colors.white70, fontSize: 14)),

                              subtitle: Text(
                                user.id.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),

                            ),

                            ListTile(
                              leading: const Icon(Icons.email, color: Colors.white70),

                              title: const Text('Email', style: TextStyle(color: Colors.white70, fontSize: 14)),

                              subtitle: Text(
                                user.email,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),

                            ),

                          ],
                        ),
                      ),
                    ),
                  ],

                ],
              ),
            ),
    );
  }
}