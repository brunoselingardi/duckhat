package com.duckhat.api.dto;

import com.duckhat.api.entity.enums.TipoUsuario;

public record LoginResponse(
    Long id,
    String nome,
    String email,
    TipoUsuario tipo,
    String token,
    String mensagem) {
}
