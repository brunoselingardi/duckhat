package com.duckhat.api.dto;

import com.duckhat.api.entity.Agendamento;

import java.time.LocalDateTime;

public record OcupacaoPrestadorResponse(
    LocalDateTime inicioEm,
    LocalDateTime fimEm) {
  public static OcupacaoPrestadorResponse fromEntity(Agendamento agendamento) {
    return new OcupacaoPrestadorResponse(
        agendamento.getInicioEm(),
        agendamento.getFimEm());
  }
}
