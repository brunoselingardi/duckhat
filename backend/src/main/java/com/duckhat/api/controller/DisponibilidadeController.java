package com.duckhat.api.controller;

import com.duckhat.api.dto.CreateDisponibilidadeRequest;
import com.duckhat.api.dto.DisponibilidadeResponse;
import com.duckhat.api.service.DisponibilidadeService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import com.duckhat.api.entity.Usuario;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.List;

@RestController
@RequestMapping("/api/disponibilidades")
public class DisponibilidadeController {

  private final DisponibilidadeService disponibilidadeService;

  public DisponibilidadeController(DisponibilidadeService disponibilidadeService) {
    this.disponibilidadeService = disponibilidadeService;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public DisponibilidadeResponse criar(
      @Valid @RequestBody CreateDisponibilidadeRequest request,
      @AuthenticationPrincipal Usuario usuario) {
    return disponibilidadeService.criar(request, usuario);
  }

  @GetMapping
  public List<DisponibilidadeResponse> listarTodas(@AuthenticationPrincipal Usuario usuario) {
    return disponibilidadeService.listarTodas(usuario);
  }

  @GetMapping("/ativas")
  public List<DisponibilidadeResponse> listarAtivas() {
    return disponibilidadeService.listarAtivas();
  }

  @GetMapping("/{id}")
  public DisponibilidadeResponse buscarPorId(
      @PathVariable Long id,
      @AuthenticationPrincipal Usuario usuario) {
    return disponibilidadeService.buscarPorId(id, usuario);
  }

  @GetMapping("/prestador/{prestadorId}")
  public List<DisponibilidadeResponse> listarPorPrestador(@PathVariable Long prestadorId) {
    return disponibilidadeService.listarPorPrestador(prestadorId);
  }
}
