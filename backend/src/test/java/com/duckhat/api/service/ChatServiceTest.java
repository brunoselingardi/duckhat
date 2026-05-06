package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.duckhat.api.dto.ChatConversaResponse;
import com.duckhat.api.dto.ChatMensagemResponse;
import com.duckhat.api.dto.CreateChatConversaRequest;
import com.duckhat.api.dto.CreateChatMensagemRequest;
import com.duckhat.api.entity.ChatConversa;
import com.duckhat.api.entity.ChatMensagem;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.ChatConversaRepository;
import com.duckhat.api.repository.ChatMensagemRepository;
import com.duckhat.api.repository.UsuarioRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class ChatServiceTest {

  private final ChatConversaRepository conversaRepository = mock(ChatConversaRepository.class);
  private final ChatMensagemRepository mensagemRepository = mock(ChatMensagemRepository.class);
  private final UsuarioRepository usuarioRepository = mock(UsuarioRepository.class);
  private final NotificacaoEventoService notificacaoEventoService = mock(NotificacaoEventoService.class);
  private final ChatService service = new ChatService(
      conversaRepository,
      mensagemRepository,
      usuarioRepository,
      notificacaoEventoService);

  @Test
  void listarConversasComoPrestadorRetornaClientesEUltimaMensagemEmLote() {
    Usuario cliente = usuario(1L, "Cliente", TipoUsuario.CLIENTE);
    Usuario prestador = usuario(2L, "Barbearia", TipoUsuario.PRESTADOR);
    ChatConversa conversa = conversa(10L, cliente, prestador);
    ChatMensagem ultimaMensagem = mensagem(30L, conversa, cliente, "Ainda tem horario hoje?");

    when(conversaRepository.findByPrestadorIdOrderByUltimaMensagemEmDescIdDesc(2L))
        .thenReturn(List.of(conversa));
    when(mensagemRepository.findUltimasMensagensByConversaIds(List.of(10L)))
        .thenReturn(List.of(ultimaMensagem));

    List<ChatConversaResponse> responses = service.listarConversas(prestador);

    assertEquals(1, responses.size());
    assertEquals(1L, responses.get(0).participanteId());
    assertEquals("Cliente", responses.get(0).participanteNome());
    assertEquals("Ainda tem horario hoje?", responses.get(0).ultimaMensagem());
    verify(mensagemRepository, never()).findFirstByConversaIdOrderByCriadoEmDescIdDesc(10L);
  }

  @Test
  void enviarMensagemComoPrestadorPersisteERegistraNotificacaoNaConversa() {
    Usuario cliente = usuario(1L, "Cliente", TipoUsuario.CLIENTE);
    Usuario prestador = usuario(2L, "Barbearia", TipoUsuario.PRESTADOR);
    ChatConversa conversa = conversa(10L, cliente, prestador);

    when(conversaRepository.findByIdAndPrestadorId(10L, 2L))
        .thenReturn(Optional.of(conversa));
    when(mensagemRepository.save(any(ChatMensagem.class))).thenAnswer(invocation -> {
      ChatMensagem mensagem = invocation.getArgument(0);
      mensagem.setId(40L);
      return mensagem;
    });

    ChatMensagemResponse response = service.enviarMensagem(
        10L,
        new CreateChatMensagemRequest("  Podemos atender as 15h.  "),
        prestador);

    assertEquals(40L, response.id());
    assertEquals(10L, response.conversaId());
    assertEquals(2L, response.remetenteId());
    assertEquals("Podemos atender as 15h.", response.conteudo());
    assertEquals(true, response.enviadaPorMim());

    ArgumentCaptor<ChatMensagem> mensagemCaptor = ArgumentCaptor.forClass(ChatMensagem.class);
    verify(mensagemRepository).save(mensagemCaptor.capture());
    assertEquals("Podemos atender as 15h.", mensagemCaptor.getValue().getConteudo());
    verify(conversaRepository).save(conversa);
    verify(notificacaoEventoService)
        .registrarMensagem(conversa, prestador, "Podemos atender as 15h.");
  }

  @Test
  void enviarMensagemBloqueiaPrestadorForaDaConversa() {
    Usuario prestador = usuario(3L, "Outro prestador", TipoUsuario.PRESTADOR);
    when(conversaRepository.findByIdAndPrestadorId(10L, 3L))
        .thenReturn(Optional.empty());

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.enviarMensagem(
            10L,
            new CreateChatMensagemRequest("Oi"),
            prestador));

    assertEquals(HttpStatus.NOT_FOUND, error.getStatusCode());
    verify(mensagemRepository, never()).save(any(ChatMensagem.class));
    verify(notificacaoEventoService, never())
        .registrarMensagem(any(ChatConversa.class), any(Usuario.class), any(String.class));
  }

  @Test
  void criarOuBuscarConversaBloqueiaParticipantesDoMesmoTipo() {
    Usuario prestador = usuario(2L, "Barbearia", TipoUsuario.PRESTADOR);
    Usuario outroPrestador = usuario(3L, "Outro estabelecimento", TipoUsuario.PRESTADOR);
    when(usuarioRepository.findById(3L)).thenReturn(Optional.of(outroPrestador));

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.criarOuBuscarConversa(
            new CreateChatConversaRequest(3L),
            prestador));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
    assertEquals("O chat deve ser entre um cliente e um prestador", error.getReason());
    verify(conversaRepository, never()).save(any(ChatConversa.class));
  }

  private Usuario usuario(Long id, String nome, TipoUsuario tipo) {
    Usuario usuario = new Usuario();
    usuario.setId(id);
    usuario.setNome(nome);
    usuario.setEmail("usuario%s@duckhat.com".formatted(id));
    usuario.setTipo(tipo);
    return usuario;
  }

  private ChatConversa conversa(Long id, Usuario cliente, Usuario prestador) {
    ChatConversa conversa = new ChatConversa();
    conversa.setId(id);
    conversa.setCliente(cliente);
    conversa.setPrestador(prestador);
    conversa.setUltimaMensagemEm(LocalDateTime.of(2026, 5, 6, 10, 0));
    return conversa;
  }

  private ChatMensagem mensagem(
      Long id,
      ChatConversa conversa,
      Usuario remetente,
      String conteudo) {
    ChatMensagem mensagem = new ChatMensagem();
    mensagem.setId(id);
    mensagem.setConversa(conversa);
    mensagem.setRemetente(remetente);
    mensagem.setConteudo(conteudo);
    mensagem.setCriadoEm(LocalDateTime.of(2026, 5, 6, 10, 5));
    return mensagem;
  }
}
