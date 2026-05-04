package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.duckhat.api.dto.CreateNotificacaoEventoRequest;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.ChatConversa;
import com.duckhat.api.entity.NotificacaoEvento;
import com.duckhat.api.entity.NotificacaoPreferencia;
import com.duckhat.api.entity.Servico;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.TipoNotificacao;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.NotificacaoEventoRepository;
import com.duckhat.api.repository.NotificacaoPreferenciaRepository;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class NotificacaoEventoServiceTest {

  private final NotificacaoEventoRepository notificacaoRepository =
      mock(NotificacaoEventoRepository.class);
  private final NotificacaoPreferenciaRepository preferenciaRepository =
      mock(NotificacaoPreferenciaRepository.class);
  private final AgendamentoRepository agendamentoRepository =
      mock(AgendamentoRepository.class);
  private final NotificacaoEventoService service = new NotificacaoEventoService(
      notificacaoRepository,
      preferenciaRepository,
      agendamentoRepository);

  @Test
  void registrarAgendamentoCriadoCriaNotificacaoParaClienteEPrestador() {
    Usuario cliente = usuario(1L, "Cliente", TipoUsuario.CLIENTE);
    Usuario prestador = usuario(2L, "Prestador", TipoUsuario.PRESTADOR);
    Agendamento agendamento = agendamento(cliente, prestador);

    when(preferenciaRepository.findByUsuarioId(1L))
        .thenReturn(Optional.of(preferencias(cliente, true, true)));
    when(preferenciaRepository.findByUsuarioId(2L))
        .thenReturn(Optional.of(preferencias(prestador, true, true)));
    when(notificacaoRepository.save(any(NotificacaoEvento.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    service.registrarAgendamentoCriado(agendamento);

    ArgumentCaptor<NotificacaoEvento> captor =
        ArgumentCaptor.forClass(NotificacaoEvento.class);
    verify(notificacaoRepository, org.mockito.Mockito.times(2)).save(captor.capture());

    assertEquals(1L, captor.getAllValues().get(0).getUsuario().getId());
    assertEquals(2L, captor.getAllValues().get(1).getUsuario().getId());
    assertEquals(TipoNotificacao.AGENDAMENTO, captor.getAllValues().get(0).getTipo());
    assertEquals(TipoNotificacao.AGENDAMENTO, captor.getAllValues().get(1).getTipo());
  }

  @Test
  void registrarMensagemNaoCriaNotificacaoQuandoPreferenciaDeMensagemEstaDesligada() {
    Usuario cliente = usuario(1L, "Cliente", TipoUsuario.CLIENTE);
    Usuario prestador = usuario(2L, "Prestador", TipoUsuario.PRESTADOR);
    ChatConversa conversa = new ChatConversa();
    conversa.setCliente(cliente);
    conversa.setPrestador(prestador);

    when(preferenciaRepository.findByUsuarioId(2L))
        .thenReturn(Optional.of(preferencias(prestador, true, false)));

    service.registrarMensagem(conversa, cliente, "Oi, tudo bem?");

    verify(notificacaoRepository, never()).save(any(NotificacaoEvento.class));
  }

  @Test
  void criarBloqueiaNotificacaoParaAgendamentoDeOutroUsuario() {
    Usuario cliente = usuario(1L, "Cliente", TipoUsuario.CLIENTE);
    Usuario prestador = usuario(2L, "Prestador", TipoUsuario.PRESTADOR);
    Usuario terceiro = usuario(3L, "Terceiro", TipoUsuario.CLIENTE);
    Agendamento agendamento = agendamento(cliente, prestador);

    when(agendamentoRepository.findById(55L)).thenReturn(Optional.of(agendamento));

    ResponseStatusException erro = assertThrows(
        ResponseStatusException.class,
        () -> service.criar(
            new CreateNotificacaoEventoRequest(
                55L,
                CanalNotificacao.APP,
                LocalDateTime.now().plusHours(1),
                null,
                null),
            terceiro));

    assertEquals(HttpStatus.FORBIDDEN, erro.getStatusCode());
    verify(notificacaoRepository, never()).save(any(NotificacaoEvento.class));
  }

  private Usuario usuario(Long id, String nome, TipoUsuario tipo) {
    Usuario usuario = new Usuario();
    usuario.setId(id);
    usuario.setNome(nome);
    usuario.setEmail("usuario%s@duckhat.com".formatted(id));
    usuario.setTipo(tipo);
    return usuario;
  }

  private Agendamento agendamento(Usuario cliente, Usuario prestador) {
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
    return agendamento;
  }

  private NotificacaoPreferencia preferencias(
      Usuario usuario,
      boolean agendamentos,
      boolean mensagens) {
    NotificacaoPreferencia preferencias = new NotificacaoPreferencia();
    preferencias.setUsuario(usuario);
    preferencias.setAgendamentos(agendamentos);
    preferencias.setMensagens(mensagens);
    preferencias.setPromocoes(true);
    preferencias.setNovidades(false);
    preferencias.setResumoEmail(true);
    return preferencias;
  }
}
