package com.duckhat.api.repository;

import com.duckhat.api.entity.Agendamento;
import org.springframework.data.jpa.repository.JpaRepository;
import com.duckhat.api.entity.enums.StatusAgendamento;
import java.util.List;

public interface AgendamentoRepository extends JpaRepository<Agendamento, Long> {

  List<Agendamento> findByClienteId(Long clienteId);

  List<Agendamento> findByServicoId(Long servicoId);

  List<Agendamento> findByStatus(StatusAgendamento status);

  List<Agendamento> findByClienteIdAndServicoId(Long clienteId, Long servicoId);

  List<Agendamento> findByClienteIdAndStatus(Long clienteId, StatusAgendamento status);
}
