import 'package:flutter/material.dart';
import 'package:ridehailing/view/auth/login_view.dart';
import 'package:ridehailing/services/profile_main_services.dart';
import 'package:ridehailing/bloc/data.dart';
import 'package:ridehailing/components/localstorage_models.dart';
import 'package:ridehailing/view/security/change_password_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Driver? driver;
  bool isLoading = true;
  bool isEditing = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController simController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDriverData();
  }

  Future<void> fetchDriverData() async {
    try {
      final data = await ApiService.fetchDriver();
      if (!mounted) return;
      setState(() {
        driver = data;
        nameController.text = data.name;
        emailController.text = data.email;
        licenseController.text = data.licenseNumber;
        simController.text = data.sim;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> saveChanges() async {
    try {
      final updatedData = {
        'name': nameController.text,
        'email': emailController.text,
        'license_number': licenseController.text,
        'SIM': simController.text,
      };
      await ApiService.updateDriver(updatedData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5B9BD5),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          color: const Color(0xFF5B9BD5),
                          width: double.infinity,
                          height: 100,
                        ),
                        Positioned(
                          bottom: -50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 4.0),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(driver?.profilePictureUrl ?? ''),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 300,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Name
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                leading: const Icon(Icons.person,
                                    color: Colors.blue),
                                title: Text(
                                  isEditing ? '' : driver!.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: isEditing
                                    ? SizedBox(
                                        width: 240,
                                        child: TextFormField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter your name',
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const Divider(),
                              // Email
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                leading: const Icon(Icons.email,
                                    color: Colors.green),
                                title: Text(
                                  isEditing ? '' : driver!.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: isEditing
                                    ? SizedBox(
                                        width: 240,
                                        child: TextFormField(
                                          controller: emailController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter your email',
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const Divider(),
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                leading: const Icon(Icons.credit_card,
                                    color: Colors.orange),
                                title: Text(
                                  isEditing
                                      ? ''
                                      : driver!.licenseNumber.isNotEmpty
                                          ? driver!.licenseNumber
                                          : 'Not provided',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: isEditing
                                    ? SizedBox(
                                        width: 240,
                                        child: TextFormField(
                                          controller: licenseController,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Enter your license number',
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const Divider(),
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                leading: const Icon(Icons.card_membership,
                                    color: Colors.purple),
                                title: Text(
                                  isEditing
                                      ? ''
                                      : driver!.sim.isNotEmpty
                                          ? driver!.sim
                                          : 'Not provided',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: isEditing
                                    ? SizedBox(
                                        width: 240,
                                        child: TextFormField(
                                          controller: simController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter your SIM',
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const Divider(
                                color: Colors.transparent,
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 170, // Batasi lebar tombol menjadi 170
                            child: ElevatedButton(
                              onPressed: () {
                                if (isEditing) {
                                  saveChanges(); // Save changes if in edit mode
                                } else {
                                  setState(() {
                                    isEditing = !isEditing; // Toggle edit mode
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4678A5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'Save' : 'Edit Profile',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 170,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChangePasswordView(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4678A5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Ubah Kata Sandi',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 170,
                            child: ElevatedButton(
                              onPressed: () async {
                                await LocalStorage.clearToken();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 0, 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Keluar',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
