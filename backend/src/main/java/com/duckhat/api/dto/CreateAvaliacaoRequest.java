package com.duckhat.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateAvaliacaoRequest(

        @NotNull
        Long agendamentoId,

        @NotNull
        @Min(1)
        @Max(5)
        Integer nota,

        @Size(max = 1000)
        String comentario
) {
}
