package com.duckhat.api.repository;

import com.duckhat.api.entity.Servico;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ServicoRepository extends JpaRepository<Servico, Long> {

  List<Servico> findByPrestadorId(Long prestadorId);

  List<Servico> findByAtivoTrue();

  List<Servico> findByPrestadorIdAndAtivoTrue(Long prestadorId);

  List<Servico> findByAtivoTrueAndNomeContainingIgnoreCase(String nome);

  @Query("select s from Servico s join fetch s.prestador where s.ativo = true order by s.prestador.id asc, s.nome asc")
  List<Servico> findAtivosComPrestador();

  void deleteByPrestadorId(Long prestadorId);
}
