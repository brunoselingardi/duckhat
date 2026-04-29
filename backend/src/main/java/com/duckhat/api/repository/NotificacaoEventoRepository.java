package com.duckhat.api.repository;

import com.duckhat.api.entity.NotificacaoEvento;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificacaoEventoRepository extends JpaRepository<NotificacaoEvento, Long> {

  List<NotificacaoEvento> findByAgendamentoId(Long agendamentoId);

  List<NotificacaoEvento> findByUsuarioIdOrderByCriadoEmDescIdDesc(Long usuarioId);

  Optional<NotificacaoEvento> findByIdAndUsuarioId(Long id, Long usuarioId);

  List<NotificacaoEvento> findByUsuarioIdAndAgendamentoIdOrderByCriadoEmDescIdDesc(
      Long usuarioId,
      Long agendamentoId);

  List<NotificacaoEvento> findByUsuarioIdAndStatusOrderByCriadoEmDescIdDesc(
      Long usuarioId,
      StatusNotificacao status);

  List<NotificacaoEvento> findByUsuarioIdAndCanalOrderByCriadoEmDescIdDesc(
      Long usuarioId,
      CanalNotificacao canal);

  List<NotificacaoEvento> findByUsuarioIdAndLidoEmIsNull(Long usuarioId);

  long countByUsuarioIdAndLidoEmIsNull(Long usuarioId);
}
