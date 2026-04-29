package com.duckhat.api.dto;

import com.duckhat.api.entity.enums.CanalNotificacao;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;

public record CreateNotificacaoEventoRequest(

    @NotNull Long agendamentoId,

    @NotNull CanalNotificacao canal,

    @NotNull LocalDateTime agendadoPara,

    @Size(max = 120) String titulo,

    @Size(max = 500) String mensagem

) {
}
