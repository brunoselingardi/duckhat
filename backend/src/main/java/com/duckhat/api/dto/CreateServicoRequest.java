package com.duckhat.api.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record CreateServicoRequest(

        @NotNull
        Long prestadorId,

        @NotBlank
        @Size(max = 120)
        String nome,

        @Size(max = 1000)
        String descricao,

        @NotNull
        @Positive
        Integer duracaoMin,

        @NotNull
        @DecimalMin(value = "0.0", inclusive = false)
        BigDecimal preco,

        @NotNull
        Boolean ativo
) {
}
