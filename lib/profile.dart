import 'package:flutter/material.dart';
import 'main.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = AuthStorage.currentUser;

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

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],

                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),

                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  
                  actions: [

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        AuthStorage.currentUser = null;
                        AuthStorage.authToken = null;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.white)),
                    ),

                  ],
                ),
              );
            },
          ),

        ],
      ),

      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Icon(
                    Icons.person_off,
                    size: 80,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Not logged in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Please login to view your profile',
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

                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),

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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
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
                            
                            title: const Text(
                              'User ID',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),

                            subtitle: Text(
                              user.id.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),

                          ),

                          ListTile(
                            leading: const Icon(Icons.shield, color: Colors.white70),

                            title: const Text(
                              'Role',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            
                            subtitle: Text(
                              user.role,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),

                          ),

                          ListTile(
                            leading: const Icon(Icons.email, color: Colors.white70),

                            title: const Text(
                              'Email',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),

                            subtitle: Text(
                              user.email,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),

                          ),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                        );
                      },

                      icon: const Icon(Icons.store, color: Colors.white),

                      label: const Text(
                        'Go to Store',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit profile feature coming soon')),
                        );
                      },

                      icon: const Icon(Icons.edit, color: Colors.white),

                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  ),

                ],
              ),
            ),
    );
  }
}