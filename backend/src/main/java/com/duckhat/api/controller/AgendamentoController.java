package com.duckhat.api.controller;

import com.duckhat.api.dto.AgendamentoResponse;
import com.duckhat.api.dto.CreateAgendamentoRequest;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.StatusAgendamento;
import com.duckhat.api.service.AgendamentoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agendamentos")
public class AgendamentoController {

  private final AgendamentoService agendamentoService;

  public AgendamentoController(AgendamentoService agendamentoService) {
    this.agendamentoService = agendamentoService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public AgendamentoResponse criar(
      @Valid @RequestBody CreateAgendamentoRequest request,
      @AuthenticationPrincipal Usuario usuario) {
    return agendamentoService.criar(request, usuario);
  }

  @GetMapping
  public List<AgendamentoResponse> listarTodos(@AuthenticationPrincipal Usuario usuario) {
    return agendamentoService.listarTodos(usuario);
  }

  @GetMapping("/{id}")
  public AgendamentoResponse buscarPorId(
      @PathVariable Long id,
      @AuthenticationPrincipal Usuario usuario) {
    return agendamentoService.buscarPorId(id, usuario);
  }

  @GetMapping("/cliente/{clienteId}")
  public List<AgendamentoResponse> listarPorCliente(
      @PathVariable Long clienteId,
      @AuthenticationPrincipal Usuario usuario) {
    return agendamentoService.listarPorCliente(clienteId, usuario);
  }

  @GetMapping("/servico/{servicoId}")
  public List<AgendamentoResponse> listarPorServico(
      @PathVariable Long servicoId,
      @AuthenticationPrincipal Usuario usuario) {
    return agendamentoService.listarPorServico(servicoId, usuario);
  }

  @GetMapping("/status/{status}")
  public List<AgendamentoResponse> listarPorStatus(
      @PathVariable StatusAgendamento status,
      @AuthenticationPrincipal Usuario usuario) {
    return agendamentoService.listarPorStatus(status, usuario);
  }
}
