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
    String prestadorFotoPerfilBase64,
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
        null,
        agendamento.getServico().getId(),
        agendamento.getServico().getNome(),
        agendamento.getInicioEm(),
        agendamento.getFimEm(),
        agendamento.getStatus(),
        agendamento.getObservacoes(),
        agendamento.getCriadoEm());
  }

  public static AgendamentoResponse fromEntity(
      Agendamento agendamento,
      String prestadorFotoPerfilBase64) {
    return new AgendamentoResponse(
        agendamento.getId(),
        agendamento.getCliente().getId(),
        agendamento.getCliente().getNome(),
        agendamento.getPrestador().getId(),
        agendamento.getPrestador().getNome(),
        prestadorFotoPerfilBase64,
        agendamento.getServico().getId(),
        agendamento.getServico().getNome(),
        agendamento.getInicioEm(),
        agendamento.getFimEm(),
        agendamento.getStatus(),
        agendamento.getObservacoes(),
        agendamento.getCriadoEm());
  }
}
