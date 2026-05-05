package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.duckhat.api.dto.CreateUsuarioRequest;
import com.duckhat.api.dto.UpdatePerfilRequest;
import com.duckhat.api.dto.UsuarioResponse;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.EstabelecimentoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import java.time.LocalDate;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

class UsuarioServiceTest {

  private final UsuarioRepository usuarioRepository = mock(UsuarioRepository.class);
  private final EstabelecimentoRepository estabelecimentoRepository = mock(EstabelecimentoRepository.class);
  private final PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
  private final UsuarioService service = new UsuarioService(
      usuarioRepository,
      estabelecimentoRepository,
      passwordEncoder);

  @Test
  void criarPrestadorCriaUsuarioEEstabelecimentoVinculado() {
    when(passwordEncoder.encode("123456")).thenReturn("hash");
    when(usuarioRepository.save(any(Usuario.class))).thenAnswer(invocation -> {
      Usuario usuario = invocation.getArgument(0);
      usuario.setId(42L);
      return usuario;
    });
    when(estabelecimentoRepository.findByUsuarioId(42L)).thenReturn(Optional.empty());
    when(estabelecimentoRepository.save(any(Estabelecimento.class))).thenAnswer(invocation -> invocation.getArgument(0));

    UsuarioResponse response = service.criar(new CreateUsuarioRequest(
        "DuckHat Studio",
        "STUDIO@DUCKHAT.COM",
        "123456",
        "(62) 99999-8888",
        "11.222.333/0001-44",
        "Ana Responsavel",
        TipoUsuario.PRESTADOR));

    assertEquals(42L, response.id());
    assertEquals("DuckHat Studio", response.nome());
    assertEquals("studio@duckhat.com", response.email());
    assertEquals("62999998888", response.telefone());
    assertEquals("11222333000144", response.cnpj());
    assertEquals("Ana Responsavel", response.responsavelNome());

    ArgumentCaptor<Estabelecimento> captor = ArgumentCaptor.forClass(Estabelecimento.class);
    verify(estabelecimentoRepository).save(captor.capture());
    Estabelecimento estabelecimento = captor.getValue();
    assertEquals(42L, estabelecimento.getUsuarioId());
    assertEquals("DuckHat Studio", estabelecimento.getNome());
    assertEquals("62999998888", estabelecimento.getTelefone());
    assertEquals("11222333000144", estabelecimento.getCnpj());
    assertEquals("Ana Responsavel", estabelecimento.getResponsavelNome());
  }

  @Test
  void criarClienteNaoCriaEstabelecimento() {
    when(passwordEncoder.encode("123456")).thenReturn("hash");
    when(usuarioRepository.save(any(Usuario.class))).thenAnswer(invocation -> invocation.getArgument(0));

    service.criar(new CreateUsuarioRequest(
        "Maria Duck",
        "maria@duckhat.com",
        "123456",
        "(62) 99999-8888",
        null,
        null,
        TipoUsuario.CLIENTE));

    verify(estabelecimentoRepository, never()).save(any(Estabelecimento.class));
  }

  @Test
  void atualizarPerfilAtualizaDadosDoUsuarioAutenticado() {
    Usuario usuario = usuario(7L, TipoUsuario.CLIENTE);
    when(usuarioRepository.findById(7L)).thenReturn(Optional.of(usuario));
    when(usuarioRepository.save(usuario)).thenReturn(usuario);

    UsuarioResponse response = service.atualizarPerfil(
        usuario,
        new UpdatePerfilRequest(
            "Maria Duck",
            "MARIA@DUCKHAT.COM",
            "(62) 99999-8888",
            null,
            null,
            LocalDate.of(1998, 5, 12),
            "Rua das Palmas, 42"));

    assertEquals("Maria Duck", response.nome());
    assertEquals("maria@duckhat.com", response.email());
    assertEquals("62999998888", response.telefone());
    assertEquals(LocalDate.of(1998, 5, 12), response.dataNascimento());
    assertEquals("Rua das Palmas, 42", response.endereco());
    verify(usuarioRepository).save(usuario);
  }

  @Test
  void atualizarPerfilAtualizaCamposDePrestador() {
    Usuario usuario = usuario(2L, TipoUsuario.PRESTADOR);
    when(usuarioRepository.findById(2L)).thenReturn(Optional.of(usuario));
    when(usuarioRepository.save(usuario)).thenReturn(usuario);
    when(estabelecimentoRepository.findByUsuarioId(2L)).thenReturn(Optional.empty());

    UsuarioResponse response = service.atualizarPerfil(
        usuario,
        new UpdatePerfilRequest(
            "DuckHat Studio",
            "studio@duckhat.com",
            "62988887777",
            "11222333000144",
            "Ana Responsavel",
            null,
            "Av. Central, 100"));

    assertEquals("DuckHat Studio", response.nome());
    assertEquals("11222333000144", response.cnpj());
    assertEquals("Ana Responsavel", response.responsavelNome());
    assertEquals("Av. Central, 100", response.endereco());

    ArgumentCaptor<Estabelecimento> captor = ArgumentCaptor.forClass(Estabelecimento.class);
    verify(estabelecimentoRepository).save(captor.capture());
    Estabelecimento estabelecimento = captor.getValue();
    assertEquals(2L, estabelecimento.getUsuarioId());
    assertEquals("DuckHat Studio", estabelecimento.getNome());
    assertEquals("62988887777", estabelecimento.getTelefone());
    assertEquals("11222333000144", estabelecimento.getCnpj());
    assertEquals("Ana Responsavel", estabelecimento.getResponsavelNome());
    assertEquals("Av. Central, 100", estabelecimento.getEndereco());
  }

  @Test
  void atualizarPerfilRecusaEmailDuplicadoDeOutroUsuario() {
    Usuario usuario = usuario(7L, TipoUsuario.CLIENTE);
    when(usuarioRepository.findById(7L)).thenReturn(Optional.of(usuario));
    when(usuarioRepository.existsByEmail("outro@duckhat.com")).thenReturn(true);

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.atualizarPerfil(
            usuario,
            new UpdatePerfilRequest(
                "Maria Duck",
                "outro@duckhat.com",
                null,
                null,
                null,
                null,
                null)));

    assertEquals(HttpStatus.CONFLICT, error.getStatusCode());
  }

  @Test
  void atualizarPerfilRecusaDataNascimentoMenorDeTrezeAnos() {
    Usuario usuario = usuario(7L, TipoUsuario.CLIENTE);
    when(usuarioRepository.findById(7L)).thenReturn(Optional.of(usuario));
    when(usuarioRepository.save(usuario)).thenReturn(usuario);

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.atualizarPerfil(
            usuario,
            new UpdatePerfilRequest(
                "Maria Duck",
                "maria@duckhat.com",
                "62999998888",
                null,
                null,
                LocalDate.now().minusYears(12),
                "Rua das Palmas, 42")));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
    assertEquals("Informe uma data de nascimento válida para maiores de 13 anos", error.getReason());
  }

  @Test
  void atualizarPerfilRecusaDataNascimentoAntigaDemais() {
    Usuario usuario = usuario(7L, TipoUsuario.CLIENTE);
    when(usuarioRepository.findById(7L)).thenReturn(Optional.of(usuario));
    when(usuarioRepository.save(usuario)).thenReturn(usuario);

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.atualizarPerfil(
            usuario,
            new UpdatePerfilRequest(
                "Maria Duck",
                "maria@duckhat.com",
                "62999998888",
                null,
                null,
                LocalDate.now().minusYears(121),
                "Rua das Palmas, 42")));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
    assertEquals("Informe uma data de nascimento válida para maiores de 13 anos", error.getReason());
  }

  @Test
  void atualizarPerfilRecusaTelefoneComQuantidadeInvalidaDeDigitos() {
    Usuario usuario = usuario(7L, TipoUsuario.CLIENTE);
    when(usuarioRepository.findById(7L)).thenReturn(Optional.of(usuario));
    when(usuarioRepository.save(usuario)).thenReturn(usuario);

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.atualizarPerfil(
            usuario,
            new UpdatePerfilRequest(
                "Maria Duck",
                "maria@duckhat.com",
                "12345",
                null,
                null,
                LocalDate.of(1998, 5, 12),
                "Rua das Palmas, 42")));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
    assertEquals("Informe um telefone válido com DDD", error.getReason());
  }

  @Test
  void atualizarPerfilRecusaEmailComDominioInvalido() {
    Usuario usuario = usuario(7L, TipoUsuario.CLIENTE);
    when(usuarioRepository.findById(7L)).thenReturn(Optional.of(usuario));
    when(usuarioRepository.save(usuario)).thenReturn(usuario);

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.atualizarPerfil(
            usuario,
            new UpdatePerfilRequest(
                "Maria Duck",
                "maria@duckhat",
                "62999998888",
                null,
                null,
                LocalDate.of(1998, 5, 12),
                "Rua das Palmas, 42")));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
    assertEquals("Informe um e-mail válido", error.getReason());
  }

  @Test
  void atualizarPerfilRecusaEnderecoSemNumero() {
    Usuario usuario = usuario(7L, TipoUsuario.CLIENTE);
    when(usuarioRepository.findById(7L)).thenReturn(Optional.of(usuario));
    when(usuarioRepository.save(usuario)).thenReturn(usuario);

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.atualizarPerfil(
            usuario,
            new UpdatePerfilRequest(
                "Maria Duck",
                "maria@duckhat.com",
                "62999998888",
                null,
                null,
                LocalDate.of(1998, 5, 12),
                "Rua das Palmas")));

    assertEquals(HttpStatus.BAD_REQUEST, error.getStatusCode());
    assertEquals("Informe um endereço válido com rua e número", error.getReason());
  }

  private Usuario usuario(Long id, TipoUsuario tipo) {
    Usuario usuario = new Usuario();
    usuario.setId(id);
    usuario.setNome("Nome Original");
    usuario.setEmail("original@duckhat.com");
    usuario.setTelefone("62999990000");
    usuario.setTipo(tipo);
    usuario.setSenhaHash("hash");
    return usuario;
  }
}
