package com.duckhat.api.dto;

import com.duckhat.api.entity.NotificacaoEvento;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import java.time.LocalDateTime;

public record NotificacaoEventoResponse(
    Long id,
    Long agendamentoId,
    CanalNotificacao canal,
    LocalDateTime agendadoPara,
    LocalDateTime enviadoEm,
    StatusNotificacao status) {
  public static NotificacaoEventoResponse fromEntity(NotificacaoEvento notificacaoEvento) {
    return new NotificacaoEventoResponse(
        notificacaoEvento.getId(),
        notificacaoEvento.getAgendamento().getId(),
        notificacaoEvento.getCanal(),
        notificacaoEvento.getAgendadoPara(),
        notificacaoEvento.getEnviadoEm(),
        notificacaoEvento.getStatus());
  }
}
