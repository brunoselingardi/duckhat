import 'package:duckhat/utils/profile_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileValidators', () {
    test('accepts valid profile fields', () {
      expect(ProfileValidators.email('maria@duckhat.com'), isNull);
      expect(ProfileValidators.phone('(62) 99999-8888'), isNull);
      expect(ProfileValidators.birthDate('1998-05-12'), isNull);
      expect(ProfileValidators.birthDate('28/11/2005'), isNull);
      expect(ProfileValidators.address('Rua das Palmas, 42'), isNull);
    });

    test('formats birth date input with slashes while typing', () {
      expect(ProfileValidators.formatBirthDateInput('2'), '2');
      expect(ProfileValidators.formatBirthDateInput('281'), '28/1');
      expect(ProfileValidators.formatBirthDateInput('28112'), '28/11/2');
      expect(ProfileValidators.formatBirthDateInput('28112005'), '28/11/2005');
      expect(
        ProfileValidators.formatBirthDateInput('28/11/200599'),
        '28/11/2005',
      );
    });

    test('formats persisted date for Brazilian profile input', () {
      expect(
        ProfileValidators.formatDate(DateTime(2005, 11, 28)),
        '28/11/2005',
      );
    });

    test('rejects invalid email', () {
      expect(
        ProfileValidators.email('maria@duckhat'),
        'Digite um e-mail valido.',
      );
    });

    test('rejects invalid phone', () {
      expect(
        ProfileValidators.phone('12345'),
        'Informe um telefone valido com DDD.',
      );
    });

    test('rejects inconsistent birth date', () {
      final currentYear = DateTime.now().year;

      expect(
        ProfileValidators.birthDate('${currentYear - 12}-01-01'),
        'Informe uma data de nascimento valida para maiores de 13 anos.',
      );
      expect(
        ProfileValidators.birthDate('${currentYear - 121}-01-01'),
        'Informe uma data de nascimento valida para maiores de 13 anos.',
      );
      expect(
        ProfileValidators.birthDate('31/02/2005'),
        'Informe uma data de nascimento valida para maiores de 13 anos.',
      );
      expect(
        ProfileValidators.birthDate('2005/11/28'),
        'Informe uma data de nascimento valida para maiores de 13 anos.',
      );
    });

    test('rejects address without number', () {
      expect(
        ProfileValidators.address('Rua das Palmas'),
        'Informe um endereco valido com rua e numero.',
      );
    });
  });
}
