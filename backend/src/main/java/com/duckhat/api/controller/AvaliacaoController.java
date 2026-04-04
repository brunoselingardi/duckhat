package com.duckhat.api.controller;

import com.duckhat.api.dto.AvaliacaoResponse;
import com.duckhat.api.dto.CreateAvaliacaoRequest;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.service.AvaliacaoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/avaliacoes")
public class AvaliacaoController {

  private final AvaliacaoService avaliacaoService;

  public AvaliacaoController(AvaliacaoService avaliacaoService) {
    this.avaliacaoService = avaliacaoService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public AvaliacaoResponse criar(
      @Valid @RequestBody CreateAvaliacaoRequest request,
      @AuthenticationPrincipal Usuario usuario) {
    return avaliacaoService.criar(request, usuario);
  }

  @GetMapping
  public List<AvaliacaoResponse> listarTodas(@AuthenticationPrincipal Usuario usuario) {
    return avaliacaoService.listarTodas(usuario);
  }

  @GetMapping("/{id}")
  public AvaliacaoResponse buscarPorId(
      @PathVariable Long id,
      @AuthenticationPrincipal Usuario usuario) {
    return avaliacaoService.buscarPorId(id, usuario);
  }

  @GetMapping("/agendamento/{agendamentoId}")
  public AvaliacaoResponse buscarPorAgendamento(
      @PathVariable Long agendamentoId,
      @AuthenticationPrincipal Usuario usuario) {
    return avaliacaoService.buscarPorAgendamento(agendamentoId, usuario);
  }
}
