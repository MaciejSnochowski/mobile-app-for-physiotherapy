class UserModel {
  String id;
  String email;
  String firstName;
  String? lastName;
  String? address;
  String? phoneNumber;
  bool firstLogin;
  bool? isPhysiotherapist;

  UserModel(
      {required this.id,
      required this.email,
      this.firstName = '',
      this.lastName,
      this.address,
      this.phoneNumber,
      this.firstLogin = true,
      this.isPhysiotherapist});

  // Metoda do konwersji z/do mapy (dla zapisu w Firebase)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'phoneNumber': phoneNumber,
      'firstLogin': firstLogin,
      'isPhysiotherapist': isPhysiotherapist
    };
  }

  // factory UserModel.fromMap(Map<String, dynamic> map) {
  //   return UserModel(
  //     id: map['id'] ?? '',
  //     email: map['email'] ?? '',
  //     firstName: map['firstName'] ?? '',
  //     lastName: map['lastName'] ?? '',
  //     address: map['address'] ?? '',
  //     phoneNumber: map['phoneNumber'] ?? '',
  //     firstLogin: map['phoneNumber'] ?? '',
  //   );
  // }
  // to już powininiem jest viewmodel?
  // Asynchroniczna metoda fromMap, która zwraca Future<UserModel>
  static Future<UserModel> fromMap(Map<String, dynamic> map) async {
    // Możesz dodać tutaj jakąś operację asynchroniczną, jeśli jest taka potrzeba.
    return Future.value(
      UserModel(
          id: map['id'] ?? '',
          email: map['email'] ?? '',
          firstName: map['firstName'] ?? '',
          lastName: map['lastName'] ?? '',
          address: map['address'] ?? '',
          phoneNumber: map['phoneNumber'] ?? '',
          firstLogin: map['firstLogin'] ?? false,
          isPhysiotherapist: map['isPhysiotherapist'] ?? false),
    );
  }
}
