const String tableSites = 'Sites';

class SiteFields {
  static final List<String> values = [id, url, time];
  static const String id = '_id';
  static const String url = 'url';
  static const String time = 'time';
}

class Site {
  final int? id;
  final String url;
  final DateTime createdTime;

  const Site({this.id, required this.url, required this.createdTime});

  Site copy({int? id, String? url, DateTime? createdTime}) => Site(
      id: id ?? this.id,
      url: url ?? this.url,
      createdTime: createdTime ?? this.createdTime);

  static Site fromJson(Map<String, Object?> json) => Site(
      id: json[SiteFields.id] as int?,
      url: json[SiteFields.url] as String,
      createdTime: DateTime.parse(json[SiteFields.time] as String));

  Map<String, Object?> toJson() => {
        SiteFields.id: id,
        SiteFields.url: url,
        SiteFields.time: createdTime.toIso8601String()
      };
}
