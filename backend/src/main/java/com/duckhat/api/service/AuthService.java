package com.duckhat.api.service;

import com.duckhat.api.dto.LoginRequest;
import com.duckhat.api.dto.LoginResponse;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.EstabelecimentoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

  private final UsuarioRepository usuarioRepository;
  private final EstabelecimentoRepository estabelecimentoRepository;
  private final PasswordEncoder passwordEncoder;
  private final JwtService jwtService;

  public AuthService(UsuarioRepository usuarioRepository,
      EstabelecimentoRepository estabelecimentoRepository,
      PasswordEncoder passwordEncoder,
      JwtService jwtService) {
    this.usuarioRepository = usuarioRepository;
    this.estabelecimentoRepository = estabelecimentoRepository;
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
    Estabelecimento estabelecimento = usuario.getTipo() == TipoUsuario.PRESTADOR
        ? estabelecimentoRepository.findByUsuarioId(usuario.getId()).orElse(null)
        : null;

    return new LoginResponse(
        usuario.getId(),
        estabelecimento == null || estabelecimento.getNome() == null
            ? usuario.getNome()
            : estabelecimento.getNome(),
        usuario.getEmail(),
        estabelecimento == null || estabelecimento.getTelefone() == null
            ? usuario.getTelefone()
            : estabelecimento.getTelefone(),
        estabelecimento == null || estabelecimento.getCnpj() == null
            ? usuario.getCnpj()
            : estabelecimento.getCnpj(),
        estabelecimento == null || estabelecimento.getResponsavelNome() == null
            ? usuario.getResponsavelNome()
            : estabelecimento.getResponsavelNome(),
        usuario.getDataNascimento(),
        estabelecimento == null || estabelecimento.getEndereco() == null
            ? usuario.getEndereco()
            : estabelecimento.getEndereco(),
        estabelecimento == null ? null : estabelecimento.getCategoria(),
        estabelecimento == null
            ? null
            : EstabelecimentoCategoriaCatalog.label(estabelecimento.getCategoria()),
        estabelecimento == null ? null : estabelecimento.getDescricao(),
        estabelecimento == null ? null : estabelecimento.getHorarioAtendimento(),
        estabelecimento == null ? null : estabelecimento.getBannerImagemBase64(),
        estabelecimento == null ? null : estabelecimento.getFotoPerfilBase64(),
        usuario.getTipo(),
        token,
        "Login realizado com sucesso");
  }
}
