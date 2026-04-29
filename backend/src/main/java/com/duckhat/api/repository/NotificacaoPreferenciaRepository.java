package com.duckhat.api.repository;

import com.duckhat.api.entity.NotificacaoPreferencia;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificacaoPreferenciaRepository extends JpaRepository<NotificacaoPreferencia, Long> {

  Optional<NotificacaoPreferencia> findByUsuarioId(Long usuarioId);
}
