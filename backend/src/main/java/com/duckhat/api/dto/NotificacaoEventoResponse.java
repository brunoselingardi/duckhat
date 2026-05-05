package com.duckhat.api.dto;

import com.duckhat.api.entity.NotificacaoEvento;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import com.duckhat.api.entity.enums.TipoNotificacao;
import java.time.LocalDateTime;

public record NotificacaoEventoResponse(
    Long id,
    Long usuarioId,
    Long agendamentoId,
    Long chatConversaId,
    TipoNotificacao tipo,
    CanalNotificacao canal,
    String titulo,
    String mensagem,
    LocalDateTime criadoEm,
    LocalDateTime agendadoPara,
    LocalDateTime enviadoEm,
    LocalDateTime lidoEm,
    StatusNotificacao status,
    boolean lida) {
  public static NotificacaoEventoResponse fromEntity(NotificacaoEvento notificacaoEvento) {
    return new NotificacaoEventoResponse(
        notificacaoEvento.getId(),
        notificacaoEvento.getUsuario().getId(),
        notificacaoEvento.getAgendamento() == null ? null : notificacaoEvento.getAgendamento().getId(),
        notificacaoEvento.getChatConversa() == null ? null : notificacaoEvento.getChatConversa().getId(),
        notificacaoEvento.getTipo(),
        notificacaoEvento.getCanal(),
        notificacaoEvento.getTitulo(),
        notificacaoEvento.getMensagem(),
        notificacaoEvento.getCriadoEm(),
        notificacaoEvento.getAgendadoPara(),
        notificacaoEvento.getEnviadoEm(),
        notificacaoEvento.getLidoEm(),
        notificacaoEvento.getStatus(),
        notificacaoEvento.getLidoEm() != null);
  }
}
