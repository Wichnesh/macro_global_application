class ProjectModel {
  final String id;
  final String name;
  final String description;
  final int peopleWorking;
  final Map<String, dynamic> projectedRevenue;
  final String? imageUrl;
  final String? videoUrl;
  final String? imageBase64;
  final String? videoBase64;
  final double? latitude;
  final double? longitude;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.peopleWorking,
    required this.projectedRevenue,
    this.imageUrl,
    this.videoUrl,
    this.imageBase64,
    this.videoBase64,
    this.latitude,
    this.longitude,
  });

  factory ProjectModel.fromMap(String id, Map<String, dynamic> data) {
    return ProjectModel(
      id: id,
      name: data['name'],
      description: data['description'],
      peopleWorking: data['peopleWorking'],
      projectedRevenue: Map<String, dynamic>.from(data['projectedRevenue']),
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],
      imageBase64: data['imageBase64'],
      videoBase64: data['videoBase64'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'peopleWorking': peopleWorking,
      'projectedRevenue': projectedRevenue,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'imageBase64': imageBase64,
      'videoBase64': videoBase64,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
