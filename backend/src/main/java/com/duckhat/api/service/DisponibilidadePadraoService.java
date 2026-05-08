package com.duckhat.api.service;

import com.duckhat.api.entity.Disponibilidade;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.DisponibilidadeRepository;
import java.time.LocalTime;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DisponibilidadePadraoService {

  private static final LocalTime DEFAULT_START = LocalTime.of(9, 0);
  private static final LocalTime DEFAULT_END = LocalTime.of(18, 0);

  private final DisponibilidadeRepository disponibilidadeRepository;

  public DisponibilidadePadraoService(DisponibilidadeRepository disponibilidadeRepository) {
    this.disponibilidadeRepository = disponibilidadeRepository;
  }

  @Transactional
  public void garantirDisponibilidadePadrao(Usuario prestador) {
    if (prestador == null || prestador.getTipo() != TipoUsuario.PRESTADOR) {
      return;
    }

    for (byte diaSemana = 1; diaSemana <= 5; diaSemana++) {
      if (disponibilidadeRepository.existsByPrestadorIdAndDiaSemana(
          prestador.getId(),
          diaSemana)) {
        continue;
      }

      Disponibilidade disponibilidade = new Disponibilidade();
      disponibilidade.setPrestador(prestador);
      disponibilidade.setDiaSemana(diaSemana);
      disponibilidade.setHoraInicio(DEFAULT_START);
      disponibilidade.setHoraFim(DEFAULT_END);
      disponibilidade.setAtivo(true);
      disponibilidadeRepository.save(disponibilidade);
    }
  }
}
