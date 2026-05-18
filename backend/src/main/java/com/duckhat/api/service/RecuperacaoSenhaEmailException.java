package com.duckhat.api.service;

public class RecuperacaoSenhaEmailException extends RuntimeException {

  public RecuperacaoSenhaEmailException(String message) {
    super(message);
  }

  public RecuperacaoSenhaEmailException(String message, Throwable cause) {
    super(message, cause);
  }
}
