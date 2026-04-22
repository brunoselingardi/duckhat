package com.duckhat.api.service;

import com.duckhat.api.dto.RedefinirSenhaRequest;
import com.duckhat.api.dto.RespostaSimples;
import com.duckhat.api.dto.SolicitarRecuperacaoSenhaRequest;
import com.duckhat.api.dto.SolicitarRecuperacaoSenhaResponse;
import com.duckhat.api.entity.RecuperacaoSenhaToken;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.repository.RecuperacaoSenhaTokenRepository;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
public class RecuperacaoSenhaService {

  private static final SecureRandom RANDOM = new SecureRandom();

  private final UsuarioRepository usuarioRepository;
  private final RecuperacaoSenhaTokenRepository tokenRepository;
  private final PasswordEncoder passwordEncoder;
  private final boolean retornarCodigoRecuperacao;

  public RecuperacaoSenhaService(
      UsuarioRepository usuarioRepository,
      RecuperacaoSenhaTokenRepository tokenRepository,
      PasswordEncoder passwordEncoder,
      @Value("${app.auth.return-reset-code:true}") boolean retornarCodigoRecuperacao
  ) {
    this.usuarioRepository = usuarioRepository;
    this.tokenRepository = tokenRepository;
    this.passwordEncoder = passwordEncoder;
    this.retornarCodigoRecuperacao = retornarCodigoRecuperacao;
  }

  @Transactional
  public SolicitarRecuperacaoSenhaResponse solicitar(SolicitarRecuperacaoSenhaRequest request) {
    String email = request.email().trim().toLowerCase();
    Usuario usuario = usuarioRepository.findByEmail(email).orElse(null);

    if (usuario == null) {
      return new SolicitarRecuperacaoSenhaResponse(
          "Se o e-mail existir, um código de recuperação foi gerado para o ambiente atual.",
          null);
    }

    tokenRepository.deleteByUsuarioIdAndUsadoEmIsNull(usuario.getId());

    String codigo = gerarCodigo();
    RecuperacaoSenhaToken token = new RecuperacaoSenhaToken();
    token.setUsuario(usuario);
    token.setCodigo(codigo);
    token.setExpiraEm(LocalDateTime.now().plusMinutes(15));
    tokenRepository.save(token);

    return new SolicitarRecuperacaoSenhaResponse(
        "Código de recuperação gerado com sucesso.",
        retornarCodigoRecuperacao ? codigo : null);
  }

  @Transactional
  public RespostaSimples redefinir(RedefinirSenhaRequest request) {
    String email = request.email().trim().toLowerCase();
    Usuario usuario = usuarioRepository.findByEmail(email)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "Código de recuperação inválido ou expirado"));

    RecuperacaoSenhaToken token = tokenRepository
        .findFirstByUsuarioIdAndCodigoAndUsadoEmIsNullOrderByCriadoEmDesc(
            usuario.getId(),
            request.codigo().trim())
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "Código de recuperação inválido ou expirado"));

    if (token.getExpiraEm().isBefore(LocalDateTime.now())) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Código de recuperação expirado");
    }

    usuario.setSenhaHash(passwordEncoder.encode(request.novaSenha()));
    token.setUsadoEm(LocalDateTime.now());

    return new RespostaSimples("Senha redefinida com sucesso.");
  }

  private String gerarCodigo() {
    int valor = 100000 + RANDOM.nextInt(900000);
    return Integer.toString(valor);
  }
}
