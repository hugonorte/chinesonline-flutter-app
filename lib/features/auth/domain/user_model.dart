class AppUser {
  final String name;
  final int totalScore;
  final int level;

  AppUser({
    required this.name,
    required this.totalScore,
    required this.level,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: json['Name'] ?? '',
      totalScore: json['TotalScore'] ?? json['total_score'] ?? 0,
      level: json['Level'] ?? 1,
    );
  }
}
