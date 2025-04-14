import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridehailing/views/widget/logout_button.dart';
import 'package:ridehailing/views/security/change_password_view.dart';
import 'package:ridehailing/views/widget/form_label.dart';
import 'package:ridehailing/models/main/profile_models.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      viewModel.fetchDriverData();
    });
  }

  void _showSuccessMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13)),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13)),
        backgroundColor: Colors.red,
      ),
    );
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
          title: const Text('Profile',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          backgroundColor: const Color.fromARGB(255, 0x29, 0x45, 0x5F),
          centerTitle: true,
          leading: state.isEditing
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  onPressed: () {
                    viewModel.cancelEdit();
                  },
                )
              : null,
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
                      height: 80,
                    ),
                    Positioned(
                      bottom: -40,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 3.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!) as ImageProvider
                                  : (state.driver?.profilePictureUrl != null &&
                                          state.driver!.profilePictureUrl
                                              .isNotEmpty)
                                      ? NetworkImage(
                                          state.driver!.profilePictureUrl)
                                      : null,
                              child: (state.driver?.profilePictureUrl == null ||
                                          state.driver!.profilePictureUrl
                                              .isEmpty) &&
                                      _imageFile == null
                                  ? const Icon(Icons.person,
                                      size: 40, color: Colors.grey)
                                  : null,
                            ),
                          ), // Edit image button
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Profile info card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personal Info Section
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              'Informasi Pribadi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
                              ),
                            ),
                          ),
                          const Divider(height: 16),

                          // Name
                          FormFieldWithLabel(
                            label: 'Nama',
                            icon: Icons.person,
                            value: state.driver!.name,
                            controller: viewModel.nameController,
                            isEditing: state.isEditing,
                          ),
                          const Divider(height: 16),

                          // Email
                          FormFieldWithLabel(
                            label: 'Email',
                            icon: Icons.email,
                            value: state.driver!.email,
                            controller: viewModel.emailController,
                            isEditing: state.isEditing,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const Divider(height: 16),

                          // License Info Section
                          const Padding(
                            padding: EdgeInsets.only(top: 12.0, bottom: 6.0),
                            child: Text(
                              'Dokumen Pengemudi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0x29, 0x45, 0x5F),
                              ),
                            ),
                          ),
                          const Divider(height: 16),

                          // License Number
                          FormFieldWithLabel(
                            label: 'Nomor Lisensi',
                            icon: Icons.credit_card,
                            value: state.driver!.licenseNumber.isNotEmpty
                                ? state.driver!.licenseNumber
                                : 'Belum ditambahkan',
                            controller: viewModel.licenseController,
                            isEditing: state.isEditing,
                          ),
                          const Divider(height: 16),

                          // SIM
                          FormFieldWithLabel(
                            label: 'Nomor SIM',
                            icon: Icons.card_membership,
                            value: state.driver!.sim.isNotEmpty
                                ? state.driver!.sim
                                : 'Belum ditambahkan',
                            controller: viewModel.simController,
                            isEditing: state.isEditing,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    children: [
                      // Edit/Save Profile Button
                      SizedBox(
                        width: 170,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (state.isEditing) {
                              try {
                                final success = await viewModel.saveChanges();
                                if (!mounted) return;

                                if (success) {
                                  _showSuccessMessage(
                                      'Profil berhasil diperbarui!');
                                } else {
                                  _showErrorMessage(
                                      'Gagal memperbarui profil.');
                                }
                              } catch (e) {
                                if (!mounted) return;
                                _showErrorMessage('Error: ${e.toString()}');
                              }
                            } else {
                              viewModel.toggleEditMode();
                              setState(() {});
                            }
                          },
                          icon: Icon(
                            state.isEditing ? Icons.save : Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            state.isEditing
                                ? 'Simpan Perubahan'
                                : 'Edit Profil',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0x29, 0x45, 0x5F),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: 170,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordView(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock_outline,
                              color: Colors.white, size: 18),
                          label: const Text(
                            'Ubah Kata Sandi',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const LogoutButton(),
                      const SizedBox(height: 24),
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
