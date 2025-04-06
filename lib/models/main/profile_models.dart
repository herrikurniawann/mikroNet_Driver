import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ridehailing/controllers/main/profile_main_services.dart';
import 'package:ridehailing/models/main/data.dart';

class ProfileState {
  final Driver? driver;
  final bool isLoading;
  final bool isEditing;
  final bool isUploadingImage;

  ProfileState({
    this.driver,
    this.isLoading = true,
    this.isEditing = false,
    this.isUploadingImage = false,
  });

  ProfileState copyWith({
    Driver? driver,
    bool? isLoading,
    bool? isEditing,
    bool? isUploadingImage,
  }) {
    return ProfileState(
      driver: driver ?? this.driver,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    );
  }
}

class ProfileViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController simController = TextEditingController();

  // Backup untuk jika user cancel editing
  String _originalName = '';
  String _originalEmail = '';
  String _originalLicense = '';
  String _originalSim = '';

  // Initialize state
  ProfileState _state = ProfileState();
  ProfileState get state => _state;

  Future<void> fetchDriverData() async {
    try {
      _state = _state.copyWith(isLoading: true);
      notifyListeners();

      final data = await ApiService.fetchDriver();
      _state = _state.copyWith(
        driver: data,
        isLoading: false,
      );

      // Set text controllers
      nameController.text = data.name;
      emailController.text = data.email;
      licenseController.text = data.licenseNumber;
      simController.text = data.sim;

      // Backup original values
      _saveOriginalValues();

      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
    }
  }

  void _saveOriginalValues() {
    _originalName = nameController.text;
    _originalEmail = emailController.text;
    _originalLicense = licenseController.text;
    _originalSim = simController.text;
  }

  void _restoreOriginalValues() {
    nameController.text = _originalName;
    emailController.text = _originalEmail;
    licenseController.text = _originalLicense;
    simController.text = _originalSim;
  }

  Future<bool> saveChanges() async {
    try {
      _state = _state.copyWith(isLoading: true);
      notifyListeners();

      final updatedData = {
        'name': nameController.text,
        'email': emailController.text,
        'license_number': licenseController.text,
        'SIM': simController.text,
      };

      await ApiService.updateDriver(updatedData);

      // After successful update, refresh driver data
      final data = await ApiService.fetchDriver();
      _state =
          _state.copyWith(driver: data, isEditing: false, isLoading: false);

      // Update controllers with fresh data
      nameController.text = data.name;
      emailController.text = data.email;
      licenseController.text = data.licenseNumber;
      simController.text = data.sim;

      // Save new original values
      _saveOriginalValues();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving changes: ${e.toString()}');
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfilePicture(File imageFile) async {
    try {
      _state = _state.copyWith(isUploadingImage: true);
      notifyListeners();

      await ApiService.uploadProfilePicture(imageFile);

      // After successful upload, refresh driver data
      final data = await ApiService.fetchDriver();
      _state = _state.copyWith(driver: data, isUploadingImage: false);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error uploading profile picture: ${e.toString()}');
      _state = _state.copyWith(isUploadingImage: false);
      notifyListeners();
      return false;
    }
  }

  void toggleEditMode() {
    debugPrint('toggleEditMode: Current isEditing=${_state.isEditing}');

    // Create a new state with the toggled isEditing value
    bool newEditingState = !_state.isEditing;
    _state = _state.copyWith(isEditing: newEditingState);

    debugPrint('toggleEditMode: New isEditing=$newEditingState');

    // Save original values when entering edit mode
    if (newEditingState) {
      _saveOriginalValues();
    }

    // Make sure to call notifyListeners to update all consumers
    notifyListeners();
  }

  void cancelEdit() {
    debugPrint('cancelEdit: Restoring original values');
    _restoreOriginalValues();
    _state = _state.copyWith(isEditing: false);
    notifyListeners();
  }
}
