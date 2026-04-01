package com.duckhat.api.dto;

import com.duckhat.api.entity.enums.CanalNotificacao;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public record CreateNotificacaoEventoRequest(

        @NotNull
        Long agendamentoId,

        @NotNull
        CanalNotificacao canal,

        @NotNull
        LocalDateTime agendadoPara,

        LocalDateTime enviadoEm,

        @NotBlank
        @Size(max = 10)
        String status
) {
}
