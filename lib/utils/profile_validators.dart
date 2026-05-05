class ProfileValidators {
  static final RegExp _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  static String? requiredText(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Preencha este campo.';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail.';
    if (!_emailPattern.hasMatch(email)) return 'Digite um e-mail valido.';
    return null;
  }

  static String? phone(String? value) {
    final digits = digitsOnly(value ?? '');
    if (digits.isEmpty) return null;
    if (!_validPhoneDigits(digits)) {
      return 'Informe um telefone valido com DDD.';
    }
    return null;
  }

  static String? cnpj(String? value) {
    final digits = digitsOnly(value ?? '');
    if (digits.length != 14) return 'Informe um CNPJ com 14 digitos.';
    return null;
  }

  static String? birthDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final date = parseBirthDate(text);
    if (date == null || !_validBirthDate(date)) {
      return 'Informe uma data de nascimento valida para maiores de 13 anos.';
    }
    return null;
  }

  static String? address(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > 255) return 'Use ate 255 caracteres.';

    final hasLetter = RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(text);
    final hasNumber = RegExp(r'\d').hasMatch(text);
    if (text.length < 8 || !hasLetter || !hasNumber) {
      return 'Informe um endereco valido com rua e numero.';
    }
    return null;
  }

  static DateTime? parseBirthDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final isoMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(trimmed);
    if (isoMatch != null) {
      return _strictDate(
        int.parse(isoMatch.group(1)!),
        int.parse(isoMatch.group(2)!),
        int.parse(isoMatch.group(3)!),
      );
    }

    final brMatch = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(trimmed);
    if (brMatch == null) return null;

    return _strictDate(
      int.parse(brMatch.group(3)!),
      int.parse(brMatch.group(2)!),
      int.parse(brMatch.group(1)!),
    );
  }

  static String formatDate(DateTime? value) {
    if (value == null) return '';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  static String formatBirthDateInput(String value) {
    final digits = digitsOnly(value);
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    if (limited.length <= 2) return limited;
    if (limited.length <= 4) {
      return '${limited.substring(0, 2)}/${limited.substring(2)}';
    }
    return '${limited.substring(0, 2)}/${limited.substring(2, 4)}/${limited.substring(4)}';
  }

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static DateTime? _strictDate(int year, int month, int day) {
    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return DateTime(year, month, day);
  }

  static bool _validBirthDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minimumBirthDate = DateTime(today.year - 13, today.month, today.day);
    final maximumBirthDate = DateTime(today.year - 120, today.month, today.day);

    return !date.isAfter(minimumBirthDate) && !date.isBefore(maximumBirthDate);
  }

  static bool _validPhoneDigits(String digits) {
    if (digits.length != 10 && digits.length != 11) return false;
    if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return false;

    final ddd = int.tryParse(digits.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) return false;

    if (digits.length == 11) return digits[2] == '9';
    return true;
  }
}
