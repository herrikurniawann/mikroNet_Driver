import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/views/widget/logout_button.dart';
import 'package:ridehailing/views/security/change_password_view.dart';
import 'package:ridehailing/views/widget/form_label.dart';
import 'package:ridehailing/models/profile_models.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Definisikan scaffoldMessengerKey di tingkat state
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    viewModel.fetchDriverData();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);
    final state = viewModel.state;

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 0x29, 0x45, 0x5F),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      color: const Color.fromARGB(255, 0x29, 0x45, 0x5F),
                      width: double.infinity,
                      height: 100,
                    ),
                    Positioned(
                      bottom: -50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4.0),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              state.driver?.profilePictureUrl ?? ''),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Name
                            FormFieldWithLabel(
                              label: 'Nama',
                              icon: Icons.person,
                              value: state.driver!.name,
                              controller: viewModel.nameController,
                              isEditing: state.isEditing,
                            ),
                            const Divider(),
                            // Email
                            FormFieldWithLabel(
                              label: 'Email',
                              icon: Icons.email,
                              value: state.driver!.email,
                              controller: viewModel.emailController,
                              isEditing: state.isEditing,
                            ),
                            const Divider(),
                            // License Number
                            FormFieldWithLabel(
                              label: 'Nomor Lisensi',
                              icon: Icons.credit_card,
                              value: state.driver!.licenseNumber.isNotEmpty
                                  ? state.driver!.licenseNumber
                                  : 'Not provided',
                              controller: viewModel.licenseController,
                              isEditing: state.isEditing,
                            ),
                            const Divider(),
                            // SIM
                            FormFieldWithLabel(
                              label: 'Nomor SIM',
                              icon: Icons.card_membership,
                              value: state.driver!.sim.isNotEmpty
                                  ? state.driver!.sim
                                  : 'Not provided',
                              controller: viewModel.simController,
                              isEditing: state.isEditing,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 170,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (state.isEditing) {
                              final success = await viewModel.saveChanges();
                              if (success) {
                                scaffoldMessengerKey.currentState?.showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Profile updated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                scaffoldMessengerKey.currentState?.showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update profile.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              viewModel.toggleEditMode();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0x29, 0x45, 0x5F),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            state.isEditing ? 'Simpan' : 'Edit Profil',
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
                            backgroundColor:
                                const Color.fromARGB(255, 0x29, 0x45, 0x5F),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Ubah Kata Sandi',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const LogoutButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
