package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.duckhat.api.dto.AvaliacaoResponse;
import com.duckhat.api.dto.CreateAvaliacaoRequest;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.Avaliacao;
import com.duckhat.api.entity.Servico;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.StatusAgendamento;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.AvaliacaoRepository;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class AvaliacaoServiceTest {

  private final AvaliacaoRepository avaliacaoRepository = mock(AvaliacaoRepository.class);
  private final AgendamentoRepository agendamentoRepository = mock(AgendamentoRepository.class);
  private final AvaliacaoService service = new AvaliacaoService(
      avaliacaoRepository,
      agendamentoRepository);

  @Test
  void criarPersisteAvaliacaoParaAgendamentoConcluidoDoClienteAutenticado() {
    Usuario cliente = usuario(1L, TipoUsuario.CLIENTE);
    Agendamento agendamento = agendamento(cliente, StatusAgendamento.CONCLUIDO);
    when(agendamentoRepository.findById(55L)).thenReturn(Optional.of(agendamento));
    when(avaliacaoRepository.existsByAgendamentoId(55L)).thenReturn(false);
    when(avaliacaoRepository.save(any(Avaliacao.class))).thenAnswer(invocation -> {
      Avaliacao avaliacao = invocation.getArgument(0);
      avaliacao.setId(9L);
      return avaliacao;
    });

    AvaliacaoResponse response = service.criar(
        new CreateAvaliacaoRequest(55L, 5, "  Atendimento   excelente  "),
        cliente);

    assertEquals(9L, response.id());
    assertEquals(55L, response.agendamentoId());
    assertEquals(5, response.nota());
    assertEquals("Atendimento excelente", response.comentario());

    ArgumentCaptor<Avaliacao> captor = ArgumentCaptor.forClass(Avaliacao.class);
    verify(avaliacaoRepository).save(captor.capture());
    assertEquals("Atendimento excelente", captor.getValue().getComentario());
  }

  @Test
  void criarConverteComentarioVazioParaNull() {
    Usuario cliente = usuario(1L, TipoUsuario.CLIENTE);
    Agendamento agendamento = agendamento(cliente, StatusAgendamento.CONCLUIDO);
    when(agendamentoRepository.findById(55L)).thenReturn(Optional.of(agendamento));
    when(avaliacaoRepository.save(any(Avaliacao.class))).thenAnswer(invocation -> invocation.getArgument(0));

    AvaliacaoResponse response = service.criar(
        new CreateAvaliacaoRequest(55L, 4, "   "),
        cliente);

    assertNull(response.comentario());
  }

  @Test
  void criarBloqueiaAvaliacaoDeAgendamentoDeOutroCliente() {
    Usuario cliente = usuario(1L, TipoUsuario.CLIENTE);
    Usuario outroCliente = usuario(2L, TipoUsuario.CLIENTE);
    Agendamento agendamento = agendamento(outroCliente, StatusAgendamento.CONCLUIDO);
    when(agendamentoRepository.findById(55L)).thenReturn(Optional.of(agendamento));

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.criar(new CreateAvaliacaoRequest(55L, 5, null), cliente));

    assertEquals(HttpStatus.FORBIDDEN, error.getStatusCode());
    verify(avaliacaoRepository, never()).save(any(Avaliacao.class));
  }

  @Test
  void criarBloqueiaAvaliacaoAntesDoAgendamentoSerConcluido() {
    Usuario cliente = usuario(1L, TipoUsuario.CLIENTE);
    Agendamento agendamento = agendamento(cliente, StatusAgendamento.PENDENTE);
    when(agendamentoRepository.findById(55L)).thenReturn(Optional.of(agendamento));

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.criar(new CreateAvaliacaoRequest(55L, 5, null), cliente));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
    assertEquals("Só é possível avaliar um agendamento concluído", error.getReason());
  }

  @Test
  void criarBloqueiaAvaliacaoDuplicadaDoMesmoAgendamento() {
    Usuario cliente = usuario(1L, TipoUsuario.CLIENTE);
    Agendamento agendamento = agendamento(cliente, StatusAgendamento.CONCLUIDO);
    when(agendamentoRepository.findById(55L)).thenReturn(Optional.of(agendamento));
    when(avaliacaoRepository.existsByAgendamentoId(55L)).thenReturn(true);

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.criar(new CreateAvaliacaoRequest(55L, 5, null), cliente));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
    assertEquals("Esse agendamento já possui avaliação", error.getReason());
    verify(avaliacaoRepository, never()).save(any(Avaliacao.class));
  }

  @Test
  void buscarPorAgendamentoBloqueiaAvaliacaoDeOutroCliente() {
    Usuario cliente = usuario(1L, TipoUsuario.CLIENTE);
    Usuario outroCliente = usuario(2L, TipoUsuario.CLIENTE);
    Avaliacao avaliacao = avaliacao(agendamento(outroCliente, StatusAgendamento.CONCLUIDO));
    when(avaliacaoRepository.findByAgendamentoId(55L)).thenReturn(Optional.of(avaliacao));

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.buscarPorAgendamento(55L, cliente));

    assertEquals(HttpStatus.FORBIDDEN, error.getStatusCode());
  }

  private Usuario usuario(Long id, TipoUsuario tipo) {
    Usuario usuario = new Usuario();
    usuario.setId(id);
    usuario.setNome("Usuario %s".formatted(id));
    usuario.setEmail("usuario%s@duckhat.com".formatted(id));
    usuario.setTipo(tipo);
    return usuario;
  }

  private Agendamento agendamento(Usuario cliente, StatusAgendamento status) {
    Usuario prestador = usuario(3L, TipoUsuario.PRESTADOR);
    Servico servico = new Servico();
    servico.setId(10L);
    servico.setNome("Corte");
    servico.setPrestador(prestador);

    Agendamento agendamento = new Agendamento();
    agendamento.setId(55L);
    agendamento.setCliente(cliente);
    agendamento.setPrestador(prestador);
    agendamento.setServico(servico);
    agendamento.setInicioEm(LocalDateTime.of(2026, 5, 4, 10, 0));
    agendamento.setFimEm(LocalDateTime.of(2026, 5, 4, 10, 50));
    agendamento.setStatus(status);
    return agendamento;
  }

  private Avaliacao avaliacao(Agendamento agendamento) {
    Avaliacao avaliacao = new Avaliacao();
    avaliacao.setId(9L);
    avaliacao.setAgendamento(agendamento);
    avaliacao.setNota(5);
    avaliacao.setComentario("Bom atendimento");
    return avaliacao;
  }
}
