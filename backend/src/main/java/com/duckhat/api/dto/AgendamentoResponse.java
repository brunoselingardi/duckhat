package com.duckhat.api.dto;

import com.duckhat.api.entity.Agendamento;

import java.time.LocalDateTime;
import com.duckhat.api.entity.enums.StatusAgendamento;

public record AgendamentoResponse(
    Long id,
    Long clienteId,
    String clienteNome,
    Long prestadorId,
    String prestadorNome,
    Long servicoId,
    String servicoNome,
    LocalDateTime inicioEm,
    LocalDateTime fimEm,
    StatusAgendamento status,
    String observacoes,
    LocalDateTime criadoEm) {
  public static AgendamentoResponse fromEntity(Agendamento agendamento) {
    return new AgendamentoResponse(
        agendamento.getId(),
        agendamento.getCliente().getId(),
        agendamento.getCliente().getNome(),
        agendamento.getPrestador().getId(),
        agendamento.getPrestador().getNome(),
        agendamento.getServico().getId(),
        agendamento.getServico().getNome(),
        agendamento.getInicioEm(),
        agendamento.getFimEm(),
        agendamento.getStatus(),
        agendamento.getObservacoes(),
        agendamento.getCriadoEm());
  }
}
