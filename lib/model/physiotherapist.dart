class Physiotherapist {
  final String id;
  final String name;
  final String lastName;
  final String bio;
  String profilePictureUrl;

  Physiotherapist({
    required this.id,
    required this.name,
    required this.lastName,
    required this.bio,
    required this.profilePictureUrl,
  });

  factory Physiotherapist.fromMap(String id, Map<String, dynamic> map) {
    return Physiotherapist(
      id: id,
      name: map['name'],
      lastName: map['lastName'],
      bio: map['bio'],
      profilePictureUrl: map['profilePictureUrl'],
    );
  }
}
