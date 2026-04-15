package com.duckhat.api.controller;

import com.duckhat.api.dto.CreateServicoRequest;
import com.duckhat.api.dto.ServicoResponse;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.service.ServicoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/servicos")
public class ServicoController {

  private final ServicoService servicoService;

  public ServicoController(ServicoService servicoService) {
    this.servicoService = servicoService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public ServicoResponse criar(
      @Valid @RequestBody CreateServicoRequest request,
      @AuthenticationPrincipal Usuario usuario) {
    return servicoService.criar(request, usuario);
  }

  @GetMapping
  public List<ServicoResponse> listarTodos(@AuthenticationPrincipal Usuario usuario) {
    return servicoService.listarTodos(usuario);
  }

  @GetMapping("/ativos")
  public List<ServicoResponse> listarAtivos() {
    return servicoService.listarAtivos();
  }

  @GetMapping("/{id}")
  public ServicoResponse buscarPorId(
      @PathVariable Long id,
      @AuthenticationPrincipal Usuario usuario) {
    return servicoService.buscarPorId(id, usuario);
  }

  @GetMapping("/prestador/{prestadorId}")
  public List<ServicoResponse> listarPorPrestador(
      @PathVariable Long prestadorId,
      @AuthenticationPrincipal Usuario usuario) {
    return servicoService.listarPorPrestador(prestadorId, usuario);
  }
}
