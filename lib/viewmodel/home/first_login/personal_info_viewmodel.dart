import 'package:flutter/material.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/services/auth/firebase_auth_service.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';

class PersonalInfoViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _shouldShowSettingsIcon = false;

  bool isPhysiotherapist = false;

  final _auth = FirebaseAuthService();
  final _sessionService = UserSessionService();

  bool get shouldShowSettingsIcon => _shouldShowSettingsIcon;
  set shouldShowSettingsIcon(bool shouldShowSettingsIcon) {
    _shouldShowSettingsIcon = shouldShowSettingsIcon;
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> createUserData() async {
    try {
      Map<String, dynamic> addData = {
        'firstName': nameController.text,
        'lastName': surnameController.text,
        'address': addressController.text,
        'phoneNumber': phoneController.text,
        'isPhysiotherapist':
            isPhysiotherapist, // Dodano zmienną isPhysiotherapist
        'firstLogin': false,
      };

      _auth.updateUserData(_sessionService.userId, addData);
    } catch (exception) {
      logger.w("Create user data error message: ${exception.toString()}");
    }
  }
}
