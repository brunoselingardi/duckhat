package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.duckhat.api.dto.CreateServicoRequest;
import com.duckhat.api.dto.ServicoResponse;
import com.duckhat.api.entity.Servico;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.ServicoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import java.math.BigDecimal;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class ServicoServiceTest {

  private final ServicoRepository servicoRepository = mock(ServicoRepository.class);
  private final UsuarioRepository usuarioRepository = mock(UsuarioRepository.class);
  private final DisponibilidadePadraoService disponibilidadePadraoService =
      mock(DisponibilidadePadraoService.class);
  private final ServicoService service = new ServicoService(
      servicoRepository,
      usuarioRepository,
      disponibilidadePadraoService);

  @Test
  void criarGaranteDisponibilidadePadraoDoPrestador() {
    Usuario prestador = usuario(2L, TipoUsuario.PRESTADOR);
    when(servicoRepository.save(any(Servico.class))).thenAnswer(invocation -> {
      Servico servico = invocation.getArgument(0);
      servico.setId(10L);
      return servico;
    });

    ServicoResponse response = service.criar(
        new CreateServicoRequest("Corte", "Corte completo", 30, new BigDecimal("40.00"), true),
        prestador);

    assertEquals(10L, response.id());
    verify(disponibilidadePadraoService).garantirDisponibilidadePadrao(prestador);
  }

  @Test
  void atualizarEditaServicoDoPrestadorAutenticado() {
    Usuario prestador = usuario(2L, TipoUsuario.PRESTADOR);
    Servico servico = servico(8L, prestador);

    when(servicoRepository.findById(8L)).thenReturn(Optional.of(servico));
    when(servicoRepository.save(any(Servico.class))).thenAnswer(invocation -> invocation.getArgument(0));

    ServicoResponse response = service.atualizar(
        8L,
        new CreateServicoRequest(
            "  Corte premium  ",
            " Corte completo   com finalizacao ",
            45,
            new BigDecimal("75.00"),
            true),
        prestador);

    assertEquals(8L, response.id());
    assertEquals("Corte premium", response.nome());
    assertEquals("Corte completo com finalizacao", response.descricao());
    assertEquals(45, response.duracaoMin());
    assertEquals(new BigDecimal("75.00"), response.preco());
    assertEquals(true, response.ativo());
    verify(servicoRepository).save(servico);
  }

  @Test
  void atualizarRecusaServicoDeOutroPrestador() {
    Usuario prestador = usuario(2L, TipoUsuario.PRESTADOR);
    Servico servico = servico(8L, usuario(3L, TipoUsuario.PRESTADOR));
    when(servicoRepository.findById(8L)).thenReturn(Optional.of(servico));

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.atualizar(
            8L,
            new CreateServicoRequest("Corte", null, 30, new BigDecimal("40.00"), true),
            prestador));

    assertEquals(HttpStatus.FORBIDDEN, error.getStatusCode());
  }

  @Test
  void criarRecusaClienteAutenticado() {
    Usuario cliente = usuario(9L, TipoUsuario.CLIENTE);

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.criar(
            new CreateServicoRequest("Corte", null, 30, new BigDecimal("40.00"), true),
            cliente));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
  }

  private Usuario usuario(Long id, TipoUsuario tipo) {
    Usuario usuario = new Usuario();
    usuario.setId(id);
    usuario.setNome("Usuario " + id);
    usuario.setEmail("usuario" + id + "@duckhat.com");
    usuario.setTipo(tipo);
    usuario.setSenhaHash("hash");
    return usuario;
  }

  private Servico servico(Long id, Usuario prestador) {
    Servico servico = new Servico();
    servico.setId(id);
    servico.setPrestador(prestador);
    servico.setNome("Servico antigo");
    servico.setDescricao("Descricao antiga");
    servico.setDuracaoMin(30);
    servico.setPreco(new BigDecimal("50.00"));
    servico.setAtivo(true);
    return servico;
  }
}
