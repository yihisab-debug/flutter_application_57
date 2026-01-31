import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    users = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/users'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Error loading users');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('https://api.escuelajs.co/api/v1/users/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        users = fetchUsers();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting user')),
        );
      }
    }
  }

  void showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final avatarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Create User', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),

                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                
              ),

              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),

                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),

              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),

                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),

              ),

              const SizedBox(height: 16),

              TextField(
                controller: avatarController,
                style: const TextStyle(color: Colors.white),

                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  hintText: 'https://placehold.co/400x400',
                  hintStyle: TextStyle(color: Colors.white30),
                ),

              ),

            ],
          ),
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && 
                  emailController.text.isNotEmpty && 
                  passwordController.text.isNotEmpty) {
                await createUser(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                  avatarController.text.isNotEmpty 
                    ? avatarController.text 
                    : 'https://placehold.co/400x400',
                );

                if (mounted) {
                  Navigator.pop(context);
                }

              }
            },

            child: const Text('Create'),
          ),

        ],
      ),
    );
  }

  Future<void> createUser(String name, String email, String password, String avatar) async {
    final response = await http.post(
      Uri.parse('https://api.escuelajs.co/api/v1/users/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'avatar': avatar,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        users = fetchUsers();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Users'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey,
        actions: [

          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: showCreateUserDialog,
          ),

          const ProfileButton(),

        ],
      ),

      body: FutureBuilder<List<User>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final user = items[index];

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(

                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      user.avatar ?? 'https://placehold.co/400x400',
                    ),

                    onBackgroundImageError: (_, __) {},
                    child: user.avatar == null 
                      ? const Icon(Icons.person, size: 30, color: Colors.white) 
                      : null,

                  ),

                  title: Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white70),
                      ),

                      Text(
                        'Role: ${user.role}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),

                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => UserDetailPage(
                                userId: user.id,
                                onUpdate: () {
                                  setState(() {
                                    users = fetchUsers();
                                  });
                                },
                              ),
                            ),

                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],

                              title: const Text(
                                'Delete User',
                                style: TextStyle(color: Colors.white),
                              ),

                              content: Text(
                                'Are you sure you want to delete "${user.name}"?',
                                style: const TextStyle(color: Colors.white70),
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
                                    deleteUser(user.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                ),

                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailPage(
                          userId: user.id,
                          onUpdate: () {
                            setState(() {
                              users = fetchUsers();
                            });
                          },
                        ),
                      ),
                    );
                  },

                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  final int userId;
  final VoidCallback onUpdate;

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.onUpdate,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late Future<User> user;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController avatarController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    user = fetchUser();
    nameController = TextEditingController();
    emailController = TextEditingController();
    avatarController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  Future<User> fetchUser() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/users/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final userData = User.fromJson(json.decode(response.body));
      nameController.text = userData.name;
      emailController.text = userData.email;
      avatarController.text = userData.avatar ?? '';
      return userData;
    } else {
      throw Exception('Error loading user');
    }
  }

  Future<void> updateUser() async {
    final response = await http.put(
      Uri.parse('https://api.escuelajs.co/api/v1/users/${widget.userId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'email': emailController.text,
        'avatar': avatarController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        user = fetchUser();
        isEditing = false;
      });
      widget.onUpdate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

        title: const Text('User Details'),

        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        backgroundColor: Colors.grey,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [

          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),

        ],
      ),

      body: FutureBuilder<User>(
        future: user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final usr = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Center(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                      usr.avatar ?? 'https://placehold.co/400x400',
                    ),

                    onBackgroundImageError: (_, __) {},
                    child: usr.avatar == null 
                      ? const Icon(Icons.person, size: 80, color: Colors.white) 
                      : null,

                  ),
                ),

                const SizedBox(height: 24),
                
                if (isEditing) ...[

                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),

                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),

                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: avatarController,
                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      labelText: 'Avatar URL',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),

                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updateUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),

                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                    ),
                  ),

                ] else ...[
                  const Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usr.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usr.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Role',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usr.role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'ID',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usr.id.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                ],
              ],
            ),
          );
        },
      ),
    );
  }
}