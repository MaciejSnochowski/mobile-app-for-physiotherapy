class Protocol {
  final String name;
  String? downloadUrl;

  Protocol({
    required this.name,
    this.downloadUrl,
  });

  factory Protocol.fromMap(Map<String, dynamic> map, String id) {
    return Protocol(
      name: map['name'],
      downloadUrl: map['downloadUrl'],
    );
  }
}
