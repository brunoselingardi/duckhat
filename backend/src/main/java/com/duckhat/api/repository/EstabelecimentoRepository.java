package com.duckhat.api.repository;

import com.duckhat.api.entity.Estabelecimento;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface EstabelecimentoRepository extends JpaRepository<Estabelecimento, Long> {
    Optional<Estabelecimento> findByUsuarioId(Long usuarioId);
    List<Estabelecimento> findAllByOrderByNomeAsc();
    boolean existsByCnpj(String cnpj);
    void deleteByUsuarioId(Long usuarioId);
}
