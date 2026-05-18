package com.duckhat.api.service;

import com.duckhat.api.dto.RedefinirSenhaRequest;
import com.duckhat.api.dto.RespostaSimples;
import com.duckhat.api.dto.SolicitarRecuperacaoSenhaRequest;
import com.duckhat.api.dto.SolicitarRecuperacaoSenhaResponse;
import com.duckhat.api.entity.RecuperacaoSenhaToken;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.repository.RecuperacaoSenhaTokenRepository;
import com.duckhat.api.repository.UsuarioRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDateTime;

@Service
public class RecuperacaoSenhaService {

  private static final Logger LOGGER = LoggerFactory.getLogger(RecuperacaoSenhaService.class);
  private static final String MENSAGEM_SOLICITACAO =
      "Se o e-mail existir, enviaremos um código de recuperação.";
  private static final SecureRandom RANDOM = new SecureRandom();
  private static final int MAX_TENTATIVAS = 5;
  private static final Duration DURACAO_BLOQUEIO = Duration.ofMinutes(15);

  private final UsuarioRepository usuarioRepository;
  private final RecuperacaoSenhaTokenRepository tokenRepository;
  private final PasswordEncoder passwordEncoder;
  private final RecuperacaoSenhaEmailSender emailSender;
  private final boolean retornarCodigoRecuperacao;

  public RecuperacaoSenhaService(
      UsuarioRepository usuarioRepository,
      RecuperacaoSenhaTokenRepository tokenRepository,
      PasswordEncoder passwordEncoder,
      @Value("${app.auth.return-reset-code:false}") boolean retornarCodigoRecuperacao,
      RecuperacaoSenhaEmailSender emailSender
  ) {
    this.usuarioRepository = usuarioRepository;
    this.tokenRepository = tokenRepository;
    this.passwordEncoder = passwordEncoder;
    this.retornarCodigoRecuperacao = retornarCodigoRecuperacao;
    this.emailSender = emailSender;
  }

  @Transactional
  public SolicitarRecuperacaoSenhaResponse solicitar(SolicitarRecuperacaoSenhaRequest request) {
    String email = request.email().trim().toLowerCase();

    if (!retornarCodigoRecuperacao && !emailSender.configurado()) {
      throw new ResponseStatusException(
          HttpStatus.SERVICE_UNAVAILABLE,
          "Envio de e-mail de recuperação não configurado");
    }

    Usuario usuario = usuarioRepository.findByEmail(email).orElse(null);

    if (usuario == null) {
      return new SolicitarRecuperacaoSenhaResponse(MENSAGEM_SOLICITACAO, null);
    }

    tokenRepository.deleteByUsuarioIdAndUsadoEmIsNull(usuario.getId());

    String codigo = gerarCodigo();
    RecuperacaoSenhaToken token = new RecuperacaoSenhaToken();
    token.setUsuario(usuario);
    token.setCodigo(passwordEncoder.encode(codigo));
    token.setExpiraEm(LocalDateTime.now().plusMinutes(15));
    token.setTentativasFalhas(0);
    token.setBloqueadoAte(null);
    tokenRepository.saveAndFlush(token);

    if (emailSender.configurado()) {
      try {
        emailSender.enviarCodigo(usuario, codigo, token.getExpiraEm());
      } catch (RecuperacaoSenhaEmailException ex) {
        LOGGER.warn("Falha ao enviar e-mail de recuperação de senha.", ex);
        throw new ResponseStatusException(
            HttpStatus.SERVICE_UNAVAILABLE,
            "Não foi possível enviar o código de recuperação. Tente novamente mais tarde");
      }
    }

    return new SolicitarRecuperacaoSenhaResponse(
        MENSAGEM_SOLICITACAO,
        retornarCodigoRecuperacao ? codigo : null);
  }

  @Transactional(noRollbackFor = ResponseStatusException.class)
  public RespostaSimples redefinir(RedefinirSenhaRequest request) {
    String email = request.email().trim().toLowerCase();
    Usuario usuario = usuarioRepository.findByEmail(email)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "Código de recuperação inválido ou expirado"));

    RecuperacaoSenhaToken token = tokenRepository
        .findFirstByUsuarioIdAndUsadoEmIsNullOrderByCriadoEmDesc(usuario.getId())
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "Código de recuperação inválido ou expirado"));

    LocalDateTime agora = LocalDateTime.now();

    if (token.getBloqueadoAte() != null && token.getBloqueadoAte().isAfter(agora)) {
      throw new ResponseStatusException(
          HttpStatus.TOO_MANY_REQUESTS,
          "Muitas tentativas inválidas. Solicite um novo código mais tarde");
    }

    if (token.getExpiraEm().isBefore(agora)) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Código de recuperação expirado");
    }

    if (!passwordEncoder.matches(request.codigo().trim(), token.getCodigo())) {
      registrarTentativaFalha(token, agora);
    }

    usuario.setSenhaHash(passwordEncoder.encode(request.novaSenha()));
    token.setUsadoEm(agora);

    return new RespostaSimples("Senha redefinida com sucesso.");
  }

  private void registrarTentativaFalha(RecuperacaoSenhaToken token, LocalDateTime agora) {
    int tentativas = token.getTentativasFalhas() == null ? 0 : token.getTentativasFalhas();
    tentativas++;
    token.setTentativasFalhas(tentativas);

    if (tentativas >= MAX_TENTATIVAS) {
      token.setBloqueadoAte(agora.plus(DURACAO_BLOQUEIO));
      throw new ResponseStatusException(
          HttpStatus.TOO_MANY_REQUESTS,
          "Muitas tentativas inválidas. Solicite um novo código mais tarde");
    }

    throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Código de recuperação inválido ou expirado");
  }

  private String gerarCodigo() {
    int valor = 100000 + RANDOM.nextInt(900000);
    return Integer.toString(valor);
  }
}
