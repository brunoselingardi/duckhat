package com.duckhat.api.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalTime;

public record CreateDisponibilidadeRequest(

    @NotNull Byte diaSemana,

    @NotNull LocalTime horaInicio,

    @NotNull LocalTime horaFim,

    @NotNull Boolean ativo) {
}
