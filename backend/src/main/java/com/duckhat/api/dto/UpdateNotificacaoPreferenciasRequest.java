package com.duckhat.api.dto;

import jakarta.validation.constraints.NotNull;

public record UpdateNotificacaoPreferenciasRequest(
    @NotNull Boolean agendamentos,
    @NotNull Boolean mensagens,
    @NotNull Boolean promocoes,
    @NotNull Boolean novidades,
    @NotNull Boolean resumoEmail) {
}
