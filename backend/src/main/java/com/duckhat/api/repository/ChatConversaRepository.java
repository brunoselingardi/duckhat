package com.duckhat.api.repository;

import com.duckhat.api.entity.ChatConversa;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChatConversaRepository extends JpaRepository<ChatConversa, Long> {

  Optional<ChatConversa> findByClienteIdAndPrestadorId(Long clienteId, Long prestadorId);

  Optional<ChatConversa> findByIdAndClienteId(Long id, Long clienteId);

  Optional<ChatConversa> findByIdAndPrestadorId(Long id, Long prestadorId);

  List<ChatConversa> findByClienteIdOrderByUltimaMensagemEmDescIdDesc(Long clienteId);

  List<ChatConversa> findByPrestadorIdOrderByUltimaMensagemEmDescIdDesc(Long prestadorId);
}
