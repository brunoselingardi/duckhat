package com.duckhat.api.repository;

import com.duckhat.api.entity.Avaliacao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AvaliacaoRepository extends JpaRepository<Avaliacao, Long> {

  Optional<Avaliacao> findByAgendamentoId(Long agendamentoId);

  boolean existsByAgendamentoId(Long agendamentoId);

  List<Avaliacao> findByAgendamentoClienteId(Long clienteId);

  List<Avaliacao> findByAgendamentoPrestadorId(Long prestadorId);

  @Modifying
  @Query("delete from Avaliacao a where a.agendamento.cliente.id = :usuarioId or a.agendamento.prestador.id = :usuarioId")
  int deleteByAgendamentoClienteIdOrPrestadorId(@Param("usuarioId") Long usuarioId);
}
