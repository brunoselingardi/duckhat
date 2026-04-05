package com.duckhat.api.repository;

import com.duckhat.api.entity.Servico;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServicoRepository extends JpaRepository<Servico, Long> {

  List<Servico> findByPrestadorId(Long prestadorId);

  List<Servico> findByAtivoTrue();

  List<Servico> findByPrestadorIdAndAtivoTrue(Long prestadorId);

  List<Servico> findByAtivoTrueAndNomeContainingIgnoreCase(String nome);
}
