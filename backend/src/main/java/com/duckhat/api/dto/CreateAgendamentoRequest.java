package com.duckhat.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import com.duckhat.api.entity.enums.StatusAgendamento;

import java.time.LocalDateTime;

public record CreateAgendamentoRequest(

        @NotNull
        Long clienteId,

        @NotNull
        Long servicoId,

        @NotNull
        LocalDateTime inicioEm,

        @NotNull
        LocalDateTime fimEm,

        @NotNull
        StatusAgendamento status,

        @Size(max = 1000)
        String observacoes
) {
}
