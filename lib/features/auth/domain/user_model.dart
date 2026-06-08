class AppUser {
  final String name;
  final int maxScore;
  final int level;

  AppUser({
    required this.name,
    required this.maxScore,
    required this.level,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: json['Name'] ?? '',
      maxScore: json['MaxScore'] ?? 0,
      level: json['Level'] ?? 1,
    );
  }
}
