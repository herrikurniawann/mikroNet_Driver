import 'package:flutter/material.dart';
import 'package:ridehailing/controllers/profile_main_services.dart';
import 'package:ridehailing/models/data.dart';

class ProfileState {
  final Driver? driver;
  final bool isLoading;
  final bool isEditing;

  ProfileState({
    this.driver,
    this.isLoading = true,
    this.isEditing = false,
  });

  ProfileState copyWith({
    Driver? driver,
    bool? isLoading,
    bool? isEditing,
  }) {
    return ProfileState(
      driver: driver ?? this.driver,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ProfileViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController simController = TextEditingController();

  ProfileState _state = ProfileState();

  ProfileState get state => _state;

  Future<void> fetchDriverData() async {
    try {
      final data = await ApiService.fetchDriver();
      _state = _state.copyWith(
        driver: data,
        isLoading: false,
      );
      nameController.text = data.name;
      emailController.text = data.email;
      licenseController.text = data.licenseNumber;
      simController.text = data.sim;
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> saveChanges() async {
    try {
      final updatedData = {
        'name': nameController.text,
        'email': emailController.text,
        'license_number': licenseController.text,
        'SIM': simController.text,
      };
      await ApiService.updateDriver(updatedData);

      // Fetch data terbaru setelah update
      await fetchDriverData();

      // Keluar dari mode edit
      _state = _state.copyWith(isEditing: false);
      notifyListeners();

      return true; // Berhasil
    } catch (e) {
      return false; // Gagal
    }
  }

  void toggleEditMode() {
    _state = _state.copyWith(isEditing: !_state.isEditing);
    notifyListeners();
  }
}