package com.duckhat.api.dto;

public record SolicitarRecuperacaoSenhaResponse(
    String mensagem,
    String codigoRecuperacao
) {
}
