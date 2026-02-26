class ValidationService {
  ValidationResult validateWorkRecord(DateTime startTime, DateTime endTime) {
    final errors = <String>[];

    if (startTime.isAfter(endTime)) {
      errors.add('开始时间不能晚于结束时间');
    }

    if (startTime.isAtSameMomentAs(endTime)) {
      errors.add('开始时间和结束时间不能相同');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  ValidationResult validateDateRange(DateTime start, DateTime end) {
    final errors = <String>[];

    if (start.isAfter(end)) {
      errors.add('开始日期不能晚于结束日期');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
}
