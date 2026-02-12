class JobHistory {
  final String role;
  final String experience;
  final String industry;

  JobHistory({
    required this.role,
    required this.experience,
    required this.industry,
  });

  /// ✅ TO MAP
  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'experience': experience,
      'industry': industry,
    };
  }

  /// ✅ FROM MAP
  factory JobHistory.fromMap(Map<String, dynamic> map) {
    return JobHistory(
      role: map['role'] ?? '',
      experience: map['experience'] ?? '',
      industry: map['industry'] ?? '',
    );
  }

  /// ✅ COPY WITH
  JobHistory copyWith({
    String? role,
    String? experience,
    String? industry,
  }) {
    return JobHistory(
      role: role ?? this.role,
      experience: experience ?? this.experience,
      industry: industry ?? this.industry,
    );
  }

  /// ✅ TO STRING (for debugging)
  @override
  String toString() {
    return 'JobHistory(role: $role, experience: $experience, industry: $industry)';
  }

  /// ✅ EQUALITY
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JobHistory &&
        other.role == role &&
        other.experience == experience &&
        other.industry == industry;
  }

  @override
  int get hashCode {
    return role.hashCode ^ experience.hashCode ^ industry.hashCode;
  }
}
