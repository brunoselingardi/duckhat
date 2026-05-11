package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.duckhat.api.entity.Disponibilidade;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.DisponibilidadeRepository;
import java.time.LocalTime;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class DisponibilidadePadraoServiceTest {

  private final DisponibilidadeRepository disponibilidadeRepository =
      mock(DisponibilidadeRepository.class);
  private final DisponibilidadePadraoService service =
      new DisponibilidadePadraoService(disponibilidadeRepository);

  @Test
  void criaDisponibilidadePadraoDeSegundaASextaParaPrestadorSemAgenda() {
    Usuario prestador = usuario(42L, TipoUsuario.PRESTADOR);

    service.garantirDisponibilidadePadrao(prestador);

    ArgumentCaptor<Disponibilidade> captor = ArgumentCaptor.forClass(Disponibilidade.class);
    verify(disponibilidadeRepository, times(5)).save(captor.capture());

    for (int index = 0; index < captor.getAllValues().size(); index++) {
      Disponibilidade disponibilidade = captor.getAllValues().get(index);
      assertEquals(42L, disponibilidade.getPrestador().getId());
      assertEquals((byte) (index + 1), disponibilidade.getDiaSemana());
      assertEquals(LocalTime.of(9, 0), disponibilidade.getHoraInicio());
      assertEquals(LocalTime.of(18, 0), disponibilidade.getHoraFim());
      assertTrue(disponibilidade.getAtivo());
    }
  }

  @Test
  void naoDuplicaDiaQueJaPossuiDisponibilidade() {
    Usuario prestador = usuario(42L, TipoUsuario.PRESTADOR);
    when(disponibilidadeRepository.existsByPrestadorIdAndDiaSemana(42L, (byte) 1))
        .thenReturn(true);

    service.garantirDisponibilidadePadrao(prestador);

    ArgumentCaptor<Disponibilidade> captor = ArgumentCaptor.forClass(Disponibilidade.class);
    verify(disponibilidadeRepository, times(4)).save(captor.capture());
    assertEquals((byte) 2, captor.getAllValues().get(0).getDiaSemana());
  }

  @Test
  void ignoraUsuarioQueNaoEPrestador() {
    Usuario cliente = usuario(7L, TipoUsuario.CLIENTE);

    service.garantirDisponibilidadePadrao(cliente);

    verify(disponibilidadeRepository, never()).save(any());
  }

  private Usuario usuario(Long id, TipoUsuario tipo) {
    Usuario usuario = new Usuario();
    usuario.setId(id);
    usuario.setNome("Usuario " + id);
    usuario.setEmail("usuario" + id + "@duckhat.com");
    usuario.setSenhaHash("hash");
    usuario.setTipo(tipo);
    return usuario;
  }
}
