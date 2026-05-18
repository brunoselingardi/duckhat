package com.duckhat.api.repository;

import com.duckhat.api.entity.Agendamento;
import org.springframework.data.jpa.repository.JpaRepository;
import com.duckhat.api.entity.enums.StatusAgendamento;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AgendamentoRepository extends JpaRepository<Agendamento, Long> {

  List<Agendamento> findByClienteId(Long clienteId);

  List<Agendamento> findByServicoId(Long servicoId);

  List<Agendamento> findByStatus(StatusAgendamento status);

  List<Agendamento> findByClienteIdAndServicoId(Long clienteId, Long servicoId);

  List<Agendamento> findByClienteIdAndStatus(Long clienteId, StatusAgendamento status);

  List<Agendamento> findByPrestadorId(Long prestadorId);

  List<Agendamento> findByPrestadorIdAndStatusNotAndFimEmAfterOrderByInicioEmAsc(
      Long prestadorId,
      StatusAgendamento status,
      LocalDateTime inicio);

  boolean existsByPrestadorIdAndStatusNotAndInicioEmLessThanAndFimEmGreaterThan(
      Long prestadorId,
      StatusAgendamento status,
      LocalDateTime fimEm,
      LocalDateTime inicioEm);

  @Modifying
  @Query("delete from Agendamento a where a.cliente.id = :usuarioId or a.prestador.id = :usuarioId")
  int deleteByClienteIdOrPrestadorId(@Param("usuarioId") Long usuarioId);
}
