package com.duckhat.api.service;

import com.duckhat.api.entity.Usuario;

import java.time.LocalDateTime;

public interface RecuperacaoSenhaEmailSender {

  boolean configurado();

  void enviarCodigo(Usuario usuario, String codigo, LocalDateTime expiraEm);
}
