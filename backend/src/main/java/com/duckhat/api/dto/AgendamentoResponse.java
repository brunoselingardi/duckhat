package com.duckhat.api.dto;

import com.duckhat.api.entity.Agendamento;

import java.time.LocalDateTime;
import com.duckhat.api.entity.enums.StatusAgendamento;


public record AgendamentoResponse(
        Long id,
        Long clienteId,
        Long servicoId,
        LocalDateTime inicioEm,
        LocalDateTime fimEm,
        StatusAgendamento status,
        String observacoes,
        LocalDateTime criadoEm
) {
    public static AgendamentoResponse fromEntity(Agendamento agendamento) {
        return new AgendamentoResponse(
                agendamento.getId(),
                agendamento.getCliente().getId(),
                agendamento.getServico().getId(),
                agendamento.getInicioEm(),
                agendamento.getFimEm(),
                agendamento.getStatus(),
                agendamento.getObservacoes(),
                agendamento.getCriadoEm()
        );
    }
}
