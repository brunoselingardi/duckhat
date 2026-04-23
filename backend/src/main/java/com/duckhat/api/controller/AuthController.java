package com.duckhat.api.controller;

import com.duckhat.api.dto.LoginRequest;
import com.duckhat.api.dto.LoginResponse;
import com.duckhat.api.dto.RedefinirSenhaRequest;
import com.duckhat.api.dto.RespostaSimples;
import com.duckhat.api.dto.SolicitarRecuperacaoSenhaRequest;
import com.duckhat.api.dto.SolicitarRecuperacaoSenhaResponse;
import com.duckhat.api.service.AuthService;
import com.duckhat.api.service.RecuperacaoSenhaService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

  private final AuthService authService;
  private final RecuperacaoSenhaService recuperacaoSenhaService;

  public AuthController(
      AuthService authService,
      RecuperacaoSenhaService recuperacaoSenhaService
  ) {
    this.authService = authService;
    this.recuperacaoSenhaService = recuperacaoSenhaService;
  }

  @PostMapping("/login")
  public LoginResponse login(@Valid @RequestBody LoginRequest request) {
    return authService.login(request);
  }

  @PostMapping("/recuperar-senha/solicitar")
  public SolicitarRecuperacaoSenhaResponse solicitarRecuperacaoSenha(
      @Valid @RequestBody SolicitarRecuperacaoSenhaRequest request
  ) {
    return recuperacaoSenhaService.solicitar(request);
  }

  @PostMapping("/recuperar-senha/redefinir")
  public RespostaSimples redefinirSenha(
      @Valid @RequestBody RedefinirSenhaRequest request
  ) {
    return recuperacaoSenhaService.redefinir(request);
  }
}
