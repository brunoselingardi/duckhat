package com.duckhat.api.dto;

import com.duckhat.api.entity.Avaliacao;

import java.time.LocalDateTime;

public record AvaliacaoResponse(
        Long id,
        Long agendamentoId,
        Long prestadorId,
        Long servicoId,
        Long clienteId,
        String clienteNome,
        Integer nota,
        String comentario,
        LocalDateTime criadoEm
) {
    public static AvaliacaoResponse fromEntity(Avaliacao avaliacao) {
        return new AvaliacaoResponse(
                avaliacao.getId(),
                avaliacao.getAgendamento().getId(),
                avaliacao.getAgendamento().getPrestador().getId(),
                avaliacao.getAgendamento().getServico().getId(),
                avaliacao.getAgendamento().getCliente().getId(),
                avaliacao.getAgendamento().getCliente().getNome(),
                avaliacao.getNota(),
                avaliacao.getComentario(),
                avaliacao.getCriadoEm()
        );
    }
}
