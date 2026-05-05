package com.duckhat.api.dto;

import static org.junit.jupiter.api.Assertions.assertTrue;

import com.duckhat.api.entity.enums.TipoUsuario;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.Test;

class CreateUsuarioRequestValidationTest {

  private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

  @Test
  void aceitaCnpjFormatadoEnviadoPeloCadastroDeEstabelecimento() {
    CreateUsuarioRequest request = new CreateUsuarioRequest(
        "DuckHat Studio",
        "studio@duckhat.com",
        "123456",
        "(62) 99999-8888",
        "11.222.333/0001-44",
        "Ana Responsavel",
        TipoUsuario.PRESTADOR);

    assertTrue(validator.validate(request).isEmpty());
  }
}
