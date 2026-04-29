package com.duckhat.api.service;

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
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ChatService {

  private static final int DIAS_RETENCAO = 30;
  private static final int DIAS_GRACA_ULTIMA_CONVERSA = 5;

  private final ChatConversaRepository conversaRepository;
  private final ChatMensagemRepository mensagemRepository;
  private final UsuarioRepository usuarioRepository;
  private final NotificacaoEventoService notificacaoEventoService;

  public ChatService(
      ChatConversaRepository conversaRepository,
      ChatMensagemRepository mensagemRepository,
      UsuarioRepository usuarioRepository,
      NotificacaoEventoService notificacaoEventoService) {
    this.conversaRepository = conversaRepository;
    this.mensagemRepository = mensagemRepository;
    this.usuarioRepository = usuarioRepository;
    this.notificacaoEventoService = notificacaoEventoService;
  }

  @Transactional
  public ChatConversaResponse criarOuBuscarConversa(
      CreateChatConversaRequest request,
      Usuario usuario) {
    Usuario participante = usuarioRepository.findById(request.participanteId())
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND,
            "Participante não encontrado"));

    if (participante.getId().equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Não é possível abrir conversa consigo mesmo");
    }

    ChatConversa conversa = conversaRepository
        .findByClienteIdAndPrestadorId(
            cliente(usuario, participante).getId(),
            prestador(usuario, participante).getId())
        .orElseGet(() -> criarConversa(usuario, participante));

    return toConversaResponse(conversa, usuario);
  }

  @Transactional(readOnly = true)
  public List<ChatConversaResponse> listarConversas(Usuario usuario) {
    List<ChatConversa> conversas = switch (usuario.getTipo()) {
      case CLIENTE -> conversaRepository.findByClienteIdOrderByUltimaMensagemEmDescIdDesc(usuario.getId());
      case PRESTADOR -> conversaRepository.findByPrestadorIdOrderByUltimaMensagemEmDescIdDesc(usuario.getId());
    };

    return conversas.stream()
        .map(conversa -> toConversaResponse(conversa, usuario))
        .toList();
  }

  @Transactional(readOnly = true)
  public List<ChatMensagemResponse> listarMensagens(Long conversaId, Usuario usuario) {
    ChatConversa conversa = buscarConversaAutorizada(conversaId, usuario);

    return mensagemRepository.findByConversaIdOrderByCriadoEmAscIdAsc(conversa.getId())
        .stream()
        .map(mensagem -> ChatMensagemResponse.fromEntity(mensagem, usuario))
        .toList();
  }

  @Transactional
  public ChatMensagemResponse enviarMensagem(
      Long conversaId,
      CreateChatMensagemRequest request,
      Usuario usuario) {
    ChatConversa conversa = buscarConversaAutorizada(conversaId, usuario);
    LocalDateTime agora = LocalDateTime.now();

    ChatMensagem mensagem = new ChatMensagem();
    mensagem.setConversa(conversa);
    mensagem.setRemetente(usuario);
    mensagem.setConteudo(request.conteudo().trim());
    mensagem.setCriadoEm(agora);

    ChatMensagem salva = mensagemRepository.save(mensagem);
    conversa.setUltimaMensagemEm(agora);
    conversaRepository.save(conversa);
    notificacaoEventoService.registrarMensagem(conversa, usuario, salva.getConteudo());

    return ChatMensagemResponse.fromEntity(salva, usuario);
  }

  @Transactional
  @Scheduled(cron = "${app.chat.cleanup-cron:0 20 3 * * *}")
  public void limparMensagensExpiradas() {
    LocalDateTime agora = LocalDateTime.now();
    mensagemRepository.deleteMensagensExpiradas(
        agora.minusDays(DIAS_RETENCAO),
        agora.minusDays(DIAS_RETENCAO + DIAS_GRACA_ULTIMA_CONVERSA));
  }

  private ChatConversa criarConversa(Usuario usuario, Usuario participante) {
    ChatConversa conversa = new ChatConversa();
    conversa.setCliente(cliente(usuario, participante));
    conversa.setPrestador(prestador(usuario, participante));
    return conversaRepository.save(conversa);
  }

  private ChatConversa buscarConversaAutorizada(Long conversaId, Usuario usuario) {
    return (switch (usuario.getTipo()) {
      case CLIENTE -> conversaRepository.findByIdAndClienteId(conversaId, usuario.getId());
      case PRESTADOR -> conversaRepository.findByIdAndPrestadorId(conversaId, usuario.getId());
    }).orElseThrow(() -> new ResponseStatusException(
        HttpStatus.NOT_FOUND,
        "Conversa não encontrada"));
  }

  private Usuario cliente(Usuario usuario, Usuario participante) {
    if (usuario.getTipo() == TipoUsuario.CLIENTE && participante.getTipo() == TipoUsuario.PRESTADOR) {
      return usuario;
    }
    if (usuario.getTipo() == TipoUsuario.PRESTADOR && participante.getTipo() == TipoUsuario.CLIENTE) {
      return participante;
    }
    throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "O chat deve ser entre um cliente e um prestador");
  }

  private Usuario prestador(Usuario usuario, Usuario participante) {
    if (usuario.getTipo() == TipoUsuario.PRESTADOR && participante.getTipo() == TipoUsuario.CLIENTE) {
      return usuario;
    }
    if (usuario.getTipo() == TipoUsuario.CLIENTE && participante.getTipo() == TipoUsuario.PRESTADOR) {
      return participante;
    }
    throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "O chat deve ser entre um cliente e um prestador");
  }

  private ChatConversaResponse toConversaResponse(ChatConversa conversa, Usuario usuario) {
    ChatMensagem ultimaMensagem = mensagemRepository
        .findFirstByConversaIdOrderByCriadoEmDescIdDesc(conversa.getId())
        .orElse(null);
    return ChatConversaResponse.fromEntity(conversa, usuario, ultimaMensagem);
  }
}
