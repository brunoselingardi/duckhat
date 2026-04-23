package com.duckhat.api.controller;

import com.duckhat.api.dto.ChatConversaResponse;
import com.duckhat.api.dto.ChatMensagemResponse;
import com.duckhat.api.dto.CreateChatConversaRequest;
import com.duckhat.api.dto.CreateChatMensagemRequest;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.service.ChatService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

  private final ChatService chatService;

  public ChatController(ChatService chatService) {
    this.chatService = chatService;
  }

  @GetMapping("/conversas")
  public List<ChatConversaResponse> listarConversas(@AuthenticationPrincipal Usuario usuario) {
    return chatService.listarConversas(usuario);
  }

  @PostMapping("/conversas")
  @ResponseStatus(HttpStatus.CREATED)
  public ChatConversaResponse criarOuBuscarConversa(
      @Valid @RequestBody CreateChatConversaRequest request,
      @AuthenticationPrincipal Usuario usuario) {
    return chatService.criarOuBuscarConversa(request, usuario);
  }

  @GetMapping("/conversas/{conversaId}/mensagens")
  public List<ChatMensagemResponse> listarMensagens(
      @PathVariable Long conversaId,
      @AuthenticationPrincipal Usuario usuario) {
    return chatService.listarMensagens(conversaId, usuario);
  }

  @PostMapping("/conversas/{conversaId}/mensagens")
  @ResponseStatus(HttpStatus.CREATED)
  public ChatMensagemResponse enviarMensagem(
      @PathVariable Long conversaId,
      @Valid @RequestBody CreateChatMensagemRequest request,
      @AuthenticationPrincipal Usuario usuario) {
    return chatService.enviarMensagem(conversaId, request, usuario);
  }
}
