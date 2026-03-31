package com.duckhat.api.dto;

import com.duckhat.api.entity.NotificacaoEvento;

import java.time.LocalDateTime;

public record NotificacaoEventoResponse(
        Long id,
        Long agendamentoId,
        String canal,
        LocalDateTime agendadoPara,
        LocalDateTime enviadoEm,
        String status
) {
    public static NotificacaoEventoResponse fromEntity(NotificacaoEvento notificacaoEvento) {
        return new NotificacaoEventoResponse(
                notificacaoEvento.getId(),
                notificacaoEvento.getAgendamento().getId(),
                notificacaoEvento.getCanal(),
                notificacaoEvento.getAgendadoPara(),
                notificacaoEvento.getEnviadoEm(),
                notificacaoEvento.getStatus()
        );
    }
}
