package com.duckhat.api.dto;

import com.duckhat.api.entity.Avaliacao;

import java.time.LocalDateTime;

public record AvaliacaoResponse(
        Long id,
        Long agendamentoId,
        Integer nota,
        String comentario,
        LocalDateTime criadoEm
) {
    public static AvaliacaoResponse fromEntity(Avaliacao avaliacao) {
        return new AvaliacaoResponse(
                avaliacao.getId(),
                avaliacao.getAgendamento().getId(),
                avaliacao.getNota(),
                avaliacao.getComentario(),
                avaliacao.getCriadoEm()
        );
    }
}
