package com.duckhat.api.controller;

import com.duckhat.api.dto.UpdatePerfilRequest;
import com.duckhat.api.dto.UsuarioResponse;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MeController {

  private final UsuarioService usuarioService;

  public MeController(UsuarioService usuarioService) {
    this.usuarioService = usuarioService;
  }

  @GetMapping("/api/me")
  public UsuarioResponse me(@AuthenticationPrincipal Usuario usuario) {
    return UsuarioResponse.fromEntity(usuario);
  }

  @PutMapping("/api/me")
  public UsuarioResponse atualizar(
      @AuthenticationPrincipal Usuario usuario,
      @Valid @RequestBody UpdatePerfilRequest request
  ) {
    return usuarioService.atualizarPerfil(usuario, request);
  }
}
