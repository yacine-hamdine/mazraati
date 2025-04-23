import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../widgets/custom_main_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  Map<String, dynamic>? userAccount;
  bool loading = true;
  bool updating = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      loading = true;
    });
    try {
      final profile = await ApiService.getUserProfile();
      final account = await ApiService.getUserAccount();
      setState(() {
        userProfile = profile;
        userAccount = account;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void _showEditAccountSheet() {
    if (userProfile == null || userAccount == null) return;
    final TextEditingController firstNameController =
        TextEditingController(text: userProfile!['firstName'] ?? '');
    final TextEditingController lastNameController =
        TextEditingController(text: userProfile!['lastName'] ?? '');
    final TextEditingController profilePictureController =
        TextEditingController(text: userProfile!['profilePicture'] ?? '');
    final TextEditingController usernameController =
        TextEditingController(text: userAccount!['username'] ?? '');
    final TextEditingController emailController =
        TextEditingController(text: userAccount!['email'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Modifier le compte",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 18),
                CircleAvatar(
                  radius: 36,
                  backgroundImage: (profilePictureController.text.isNotEmpty)
                      ? MemoryImage(base64Decode(profilePictureController.text.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')))
                      : null,
                  child: profilePictureController.text.isEmpty
                      ? const Icon(Icons.person, size: 36)
                      : null,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "Prénom"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Nom d'utilisateur"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: profilePictureController,
                  decoration: const InputDecoration(labelText: "Photo (base64)"),
                ),
                const SizedBox(height: 20),
                updating
                    ? const CircularProgressIndicator()
                    :
                    CustomMainButton(
                        text: "Enregistrer",
                        onPressed: () async {
                          setState(() {
                            updating = true;
                          });
                          // Update profile fields
                          final updatedProfile = {
                            'firstName': firstNameController.text,
                            'lastName': lastNameController.text,
                            'profilePicture': profilePictureController.text,
                          };
                          // Update account fields
                          final updatedAccount = {
                            'username': usernameController.text,
                            'email': emailController.text,
                          };
                          await ApiService.updateUserProfile(updatedProfile);
                          await ApiService.updateUserAccount(updatedAccount);
                          await fetchUserData();
                          setState(() {
                            updating = false;
                          });
                          Navigator.pop(context);
                        }
                    ) 
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout() async {
    await ApiService.clearToken();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 40,
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (userProfile == null || userAccount == null)
              ? const Center(child: Text("Erreur lors du chargement du profil"))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Profile",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const SizedBox(height: 12),
                    // User Info Card
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00826C),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: (userProfile!['profilePicture'] != null && userProfile!['profilePicture'].isNotEmpty)
                                ? MemoryImage(
                                    base64Decode(
                                      userProfile!['profilePicture'].replaceFirst(RegExp(r'data:image/[^;]+;base64,'), ''),
                                    ),
                                  )
                                : null,
                            child: (userProfile!['profilePicture'] == null || userProfile!['profilePicture'].isEmpty)
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${userProfile!['firstName'] ?? ''} ${userProfile!['lastName'] ?? ''}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "@${userAccount!['username'] ?? ''}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Account Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_outline, color: Color(0xFF00826C)),
                            title: const Text("Mon compte", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text("Changez vos informations"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.black38),
                              ],
                            ),
                            onTap: _showEditAccountSheet,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Favorites Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        leading: const Icon(Icons.favorite_border, color: Color(0xFF00826C)),
                        title: const Text("Favoris", style: TextStyle(fontWeight: FontWeight.bold)),
                        children: [
                          if (userProfile!['favorites'] == null || (userProfile!['favorites'] as List).isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("Aucun favori trouvé"),
                            )
                          else
                            ...((userProfile!['favorites'] as List).map<Widget>((fav) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(fav['image']),
                                  ),
                                  title: Text(fav['name']),
                                  onTap: () {
                                    // TODO: Show product details or navigate
                                  },
                                ))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Logout
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Color(0xFF00826C)),
                        title: const Text("Se déconnecter", style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: _logout,
                        trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                      ),
                    ),
                  ],
                ),
    );
  }
}