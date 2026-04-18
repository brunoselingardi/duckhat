package com.duckhat.api.controller;

import com.duckhat.api.entity.Usuario;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class MeController {

  @GetMapping("/api/me")
  public Map<String, Object> me(@AuthenticationPrincipal Usuario usuario) {
    return Map.of(
        "id", usuario.getId(),
        "nome", usuario.getNome(),
        "email", usuario.getEmail(),
        "tipo", usuario.getTipo());
  }
}
