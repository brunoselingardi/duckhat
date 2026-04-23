package com.duckhat.api.service;

import com.duckhat.api.dto.LoginRequest;
import com.duckhat.api.dto.LoginResponse;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

  private final UsuarioRepository usuarioRepository;
  private final PasswordEncoder passwordEncoder;
  private final JwtService jwtService;

  public AuthService(UsuarioRepository usuarioRepository,
      PasswordEncoder passwordEncoder,
      JwtService jwtService) {
    this.usuarioRepository = usuarioRepository;
    this.passwordEncoder = passwordEncoder;
    this.jwtService = jwtService;
  }

  @Transactional(readOnly = true)
  public LoginResponse login(LoginRequest request) {
    Usuario usuario = usuarioRepository.findByEmail(request.email().trim().toLowerCase())
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.UNAUTHORIZED,
            "Email ou senha inválidos"));

    boolean senhaCorreta = passwordEncoder.matches(request.senha(), usuario.getSenhaHash());

    if (!senhaCorreta) {
      throw new ResponseStatusException(
          HttpStatus.UNAUTHORIZED,
          "Email ou senha inválidos");
    }

    String token = jwtService.gerarToken(usuario);

    return new LoginResponse(
        usuario.getId(),
        usuario.getNome(),
        usuario.getEmail(),
        usuario.getTipo(),
        token,
        "Login realizado com sucesso");
  }
}
