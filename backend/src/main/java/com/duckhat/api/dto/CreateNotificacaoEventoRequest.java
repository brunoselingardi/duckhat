package com.duckhat.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public record CreateNotificacaoEventoRequest(

        @NotNull
        Long agendamentoId,

        @NotBlank
        @Size(max = 10)
        String canal,

        @NotNull
        LocalDateTime agendadoPara,

        LocalDateTime enviadoEm,

        @NotBlank
        @Size(max = 10)
        String status
) {
}
