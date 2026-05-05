package com.duckhat.api.repository;

import com.duckhat.api.entity.Estabelecimento;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EstabelecimentoRepository extends JpaRepository<Estabelecimento, Long> {
    Optional<Estabelecimento> findByUsuarioId(Long usuarioId);
    boolean existsByCnpj(String cnpj);
}
