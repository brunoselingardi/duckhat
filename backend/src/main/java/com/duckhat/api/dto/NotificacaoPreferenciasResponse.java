package com.duckhat.api.dto;

import com.duckhat.api.entity.NotificacaoPreferencia;

public record NotificacaoPreferenciasResponse(
    boolean agendamentos,
    boolean mensagens,
    boolean promocoes,
    boolean novidades,
    boolean resumoEmail) {
  public static NotificacaoPreferenciasResponse fromEntity(NotificacaoPreferencia preferencias) {
    return new NotificacaoPreferenciasResponse(
        Boolean.TRUE.equals(preferencias.getAgendamentos()),
        Boolean.TRUE.equals(preferencias.getMensagens()),
        Boolean.TRUE.equals(preferencias.getPromocoes()),
        Boolean.TRUE.equals(preferencias.getNovidades()),
        Boolean.TRUE.equals(preferencias.getResumoEmail()));
  }
}
