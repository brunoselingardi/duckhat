package com.duckhat.api.repository;

import com.duckhat.api.entity.NotificacaoEvento;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

  @Modifying
  @Query(
      value = """
          DELETE FROM notificacao_eventos
          WHERE usuario_id = :usuarioId
             OR agendamento_id IN (
               SELECT id FROM agendamentos WHERE cliente_id = :usuarioId OR prestador_id = :usuarioId
             )
             OR chat_conversa_id IN (
               SELECT id FROM chat_conversas WHERE cliente_id = :usuarioId OR prestador_id = :usuarioId
             )
          """,
      nativeQuery = true)
  int deleteByUsuarioOuRelacionamentos(@Param("usuarioId") Long usuarioId);
}
