/// Represents diagnostic test results in the Diagnostic_Data table.
class DiagnosticData {
  final int userId;
  final bool hasTakenTest;
  final String? cvdType;
  final String? severity;
  final DateTime? testDate;

  const DiagnosticData({
    required this.userId,
    required this.hasTakenTest,
    this.cvdType,
    this.severity,
    this.testDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'has_taken_test': hasTakenTest ? 1 : 0,
      'cvd_type': cvdType,
      'severity': severity,
      'test_date': testDate?.toIso8601String(),
    };
  }

  factory DiagnosticData.fromMap(Map<String, dynamic> map) {
    return DiagnosticData(
      userId: map['user_id'] as int,
      hasTakenTest: (map['has_taken_test'] as int?) == 1,
      cvdType: map['cvd_type'] as String?,
      severity: map['severity'] as String?,
      testDate: map['test_date'] != null
          ? DateTime.tryParse(map['test_date'] as String)
          : null,
    );
  }

  DiagnosticData copyWith({
    int? userId,
    bool? hasTakenTest,
    String? cvdType,
    String? severity,
    DateTime? testDate,
  }) {
    return DiagnosticData(
      userId: userId ?? this.userId,
      hasTakenTest: hasTakenTest ?? this.hasTakenTest,
      cvdType: cvdType ?? this.cvdType,
      severity: severity ?? this.severity,
      testDate: testDate ?? this.testDate,
    );
  }

  @override
  String toString() =>
      'DiagnosticData(user_id: $userId, has_taken_test: $hasTakenTest, cvd_type: $cvdType, severity: $severity, test_date: $testDate)';
}
