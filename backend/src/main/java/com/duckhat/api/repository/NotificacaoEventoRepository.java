package com.duckhat.api.repository;

import com.duckhat.api.entity.NotificacaoEvento;
import org.springframework.data.jpa.repository.JpaRepository;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import java.util.List;

public interface NotificacaoEventoRepository extends JpaRepository<NotificacaoEvento, Long> {

  List<NotificacaoEvento> findByAgendamentoId(Long agendamentoId);

  List<NotificacaoEvento> findByStatus(StatusNotificacao status);

  List<NotificacaoEvento> findByCanal(CanalNotificacao canal);

  List<NotificacaoEvento> findByAgendamentoClienteId(Long clienteId);

  List<NotificacaoEvento> findByAgendamentoClienteIdAndStatus(Long clienteId, StatusNotificacao status);

  List<NotificacaoEvento> findByAgendamentoClienteIdAndCanal(Long clienteId, CanalNotificacao canal);
}
