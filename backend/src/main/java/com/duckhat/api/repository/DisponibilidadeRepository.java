package com.duckhat.api.repository;

import com.duckhat.api.entity.Disponibilidade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DisponibilidadeRepository extends JpaRepository<Disponibilidade, Long> {

    List<Disponibilidade> findByPrestadorId(Long prestadorId);

    List<Disponibilidade> findByPrestadorIdAndAtivoTrue(Long prestadorId);

    List<Disponibilidade> findByAtivoTrue();
}
