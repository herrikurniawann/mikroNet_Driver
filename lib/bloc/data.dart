class Driver {
  final String id;
  final String name;
  final String email;
  final String sim;
  final String licenseNumber;
  final String profilePictureUrl;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.sim,
    required this.licenseNumber,
    required this.profilePictureUrl,
  });

  factory Driver.fromJson(Map<String, dynamic> data) {
    return Driver(
      id: data['id'] ?? 'nothing',
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? 'No Email provided',
      sim: data['SIM'] ?? 'No SIM provided',
      licenseNumber: data['license_number'] ?? 'No License provided',
      profilePictureUrl: data['image'] ??
          'http://188.166.179.146:8000/api/driver/images${data['id']}',
    );
  }
}
