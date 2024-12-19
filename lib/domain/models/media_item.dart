enum MediaType {
  image,
  video,
  audio,
  document
}

class MediaItem {
  final String id;
  final String url;
  final String? localPath;
  final String? thumbnailPath;
  final String? thumbnailUrl;
  final MediaType type;
  final String? description;
  final DateTime uploadedAt;
  final String uploadedBy;

  MediaItem({
    required this.id,
    required this.url,
    this.localPath,
    this.thumbnailPath,
    this.thumbnailUrl,
    required this.type,
    this.description,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      localPath: json['localPath'],
      thumbnailPath: json['thumbnailPath'],
      thumbnailUrl: json['thumbnailUrl'],
      type: MediaType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'image'),
      ),
      description: json['description'],
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? DateTime.now().toIso8601String()),
      uploadedBy: json['uploadedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'localPath': localPath,
      'thumbnailPath': thumbnailPath,
      'thumbnailUrl': thumbnailUrl,
      'type': type.toString().split('.').last,
      'description': description,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ url.hashCode ^ type.hashCode;
}
