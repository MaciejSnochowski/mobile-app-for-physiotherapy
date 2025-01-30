import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/user.dart';

class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  UserModel? _currentUser;
  bool? isPhysiotherapist;

  UserSessionService._internal();

  factory UserSessionService() {
    return _instance;
  }

  void loginUser(UserModel user) {
    _currentUser = user;
    isPhysiotherapist = user.isPhysiotherapist;
  }

  UserModel get currentUser => _currentUser!;

  void logoutUser() {
    _currentUser = null;
  }

  // Metoda do pobrania pełnej nazwy użytkownika
  String get userName {
    try {
      return _currentUser!.firstName;
    } catch (e) {
      logger.e('Null user in session');
      return 'Unknown';
    }
  }

  String get userId {
    try {
      return _currentUser!.id;
    } catch (e) {
      logger.e('Null user in session');
      return 'Unknown';
    }
  }

  bool get isLoggedIn => _currentUser != null;
}
