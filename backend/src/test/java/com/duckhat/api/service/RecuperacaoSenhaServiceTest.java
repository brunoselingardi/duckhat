package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.duckhat.api.dto.RedefinirSenhaRequest;
import com.duckhat.api.dto.SolicitarRecuperacaoSenhaRequest;
import com.duckhat.api.dto.SolicitarRecuperacaoSenhaResponse;
import com.duckhat.api.entity.RecuperacaoSenhaToken;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.repository.RecuperacaoSenhaTokenRepository;
import com.duckhat.api.repository.UsuarioRepository;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import static org.mockito.Mockito.mock;

class RecuperacaoSenhaServiceTest {

  private final UsuarioRepository usuarioRepository = mock(UsuarioRepository.class);
  private final RecuperacaoSenhaTokenRepository tokenRepository =
      mock(RecuperacaoSenhaTokenRepository.class);
  private final PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);

  @Test
  void solicitarNaoRetornaCodigoQuandoRecursoDeDemoEstaDesligado() {
    Usuario usuario = usuario(7L, "cliente@duckhat.com");
    RecuperacaoSenhaService service = new RecuperacaoSenhaService(
        usuarioRepository,
        tokenRepository,
        passwordEncoder,
        false);

    when(usuarioRepository.findByEmail("cliente@duckhat.com")).thenReturn(Optional.of(usuario));
    when(tokenRepository.save(any(RecuperacaoSenhaToken.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    SolicitarRecuperacaoSenhaResponse response = service.solicitar(
        new SolicitarRecuperacaoSenhaRequest("cliente@duckhat.com"));

    assertNull(response.codigoRecuperacao());

    ArgumentCaptor<RecuperacaoSenhaToken> tokenCaptor =
        ArgumentCaptor.forClass(RecuperacaoSenhaToken.class);
    verify(tokenRepository).save(tokenCaptor.capture());
    assertEquals(0, tokenCaptor.getValue().getTentativasFalhas());
    assertNull(tokenCaptor.getValue().getBloqueadoAte());
  }

  @Test
  void redefinirBloqueiaTokenAposCincoCodigosInvalidos() {
    Usuario usuario = usuario(7L, "cliente@duckhat.com");
    RecuperacaoSenhaToken token = token(usuario, "123456");
    RecuperacaoSenhaService service = new RecuperacaoSenhaService(
        usuarioRepository,
        tokenRepository,
        passwordEncoder,
        false);

    when(usuarioRepository.findByEmail("cliente@duckhat.com")).thenReturn(Optional.of(usuario));
    when(tokenRepository.findFirstByUsuarioIdAndUsadoEmIsNullOrderByCriadoEmDesc(7L))
        .thenReturn(Optional.of(token));

    for (int i = 1; i <= 4; i++) {
      ResponseStatusException erro = assertThrows(
          ResponseStatusException.class,
          () -> service.redefinir(
              new RedefinirSenhaRequest("cliente@duckhat.com", "000000", "novaSenha")));
      assertEquals(HttpStatus.BAD_REQUEST, erro.getStatusCode());
      assertEquals(i, token.getTentativasFalhas());
      assertNull(token.getBloqueadoAte());
    }

    ResponseStatusException bloqueio = assertThrows(
        ResponseStatusException.class,
        () -> service.redefinir(
            new RedefinirSenhaRequest("cliente@duckhat.com", "000000", "novaSenha")));

    assertEquals(HttpStatus.TOO_MANY_REQUESTS, bloqueio.getStatusCode());
    assertEquals(5, token.getTentativasFalhas());
    assertTrue(token.getBloqueadoAte().isAfter(LocalDateTime.now()));
    verify(passwordEncoder, never()).encode(any());
  }

  private Usuario usuario(Long id, String email) {
    Usuario usuario = new Usuario();
    usuario.setId(id);
    usuario.setEmail(email);
    return usuario;
  }

  private RecuperacaoSenhaToken token(Usuario usuario, String codigo) {
    RecuperacaoSenhaToken token = new RecuperacaoSenhaToken();
    token.setUsuario(usuario);
    token.setCodigo(codigo);
    token.setExpiraEm(LocalDateTime.now().plusMinutes(15));
    token.setTentativasFalhas(0);
    return token;
  }
}
