package com.duckhat.api.dto;

import com.duckhat.api.entity.Disponibilidade;

import java.time.LocalTime;

public record DisponibilidadeResponse(
        Long id,
        Long prestadorId,
        Byte diaSemana,
        LocalTime horaInicio,
        LocalTime horaFim,
        Boolean ativo
) {
    public static DisponibilidadeResponse fromEntity(Disponibilidade disponibilidade) {
        return new DisponibilidadeResponse(
                disponibilidade.getId(),
                disponibilidade.getPrestador().getId(),
                disponibilidade.getDiaSemana(),
                disponibilidade.getHoraInicio(),
                disponibilidade.getHoraFim(),
                disponibilidade.getAtivo()
        );
    }
}
