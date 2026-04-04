package com.duckhat.api.controller;

import com.duckhat.api.dto.CreateNotificacaoEventoRequest;
import com.duckhat.api.dto.NotificacaoEventoResponse;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import com.duckhat.api.service.NotificacaoEventoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notificacoes")
public class NotificacaoEventoController {

  private final NotificacaoEventoService notificacaoEventoService;

  public NotificacaoEventoController(NotificacaoEventoService notificacaoEventoService) {
    this.notificacaoEventoService = notificacaoEventoService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public NotificacaoEventoResponse criar(
      @Valid @RequestBody CreateNotificacaoEventoRequest request,
      @AuthenticationPrincipal Usuario usuario) {
    return notificacaoEventoService.criar(request, usuario);
  }

  @GetMapping
  public List<NotificacaoEventoResponse> listarTodas(@AuthenticationPrincipal Usuario usuario) {
    return notificacaoEventoService.listarTodas(usuario);
  }

  @GetMapping("/{id}")
  public NotificacaoEventoResponse buscarPorId(
      @PathVariable Long id,
      @AuthenticationPrincipal Usuario usuario) {
    return notificacaoEventoService.buscarPorId(id, usuario);
  }

  @GetMapping("/agendamento/{agendamentoId}")
  public List<NotificacaoEventoResponse> listarPorAgendamento(
      @PathVariable Long agendamentoId,
      @AuthenticationPrincipal Usuario usuario) {
    return notificacaoEventoService.listarPorAgendamento(agendamentoId, usuario);
  }

  @GetMapping("/status/{status}")
  public List<NotificacaoEventoResponse> listarPorStatus(
      @PathVariable StatusNotificacao status,
      @AuthenticationPrincipal Usuario usuario) {
    return notificacaoEventoService.listarPorStatus(status, usuario);
  }

  @GetMapping("/canal/{canal}")
  public List<NotificacaoEventoResponse> listarPorCanal(
      @PathVariable CanalNotificacao canal,
      @AuthenticationPrincipal Usuario usuario) {
    return notificacaoEventoService.listarPorCanal(canal, usuario);
  }
}
