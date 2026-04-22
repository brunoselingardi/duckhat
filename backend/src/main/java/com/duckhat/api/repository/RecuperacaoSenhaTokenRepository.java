package com.duckhat.api.repository;

import com.duckhat.api.entity.RecuperacaoSenhaToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RecuperacaoSenhaTokenRepository extends JpaRepository<RecuperacaoSenhaToken, Long> {
  void deleteByUsuarioIdAndUsadoEmIsNull(Long usuarioId);

  Optional<RecuperacaoSenhaToken> findFirstByUsuarioIdAndCodigoAndUsadoEmIsNullOrderByCriadoEmDesc(
      Long usuarioId,
      String codigo
  );
}
