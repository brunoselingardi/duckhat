package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.duckhat.api.dto.LoginRequest;
import com.duckhat.api.dto.LoginResponse;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.EstabelecimentoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;

class AuthServiceTest {

  private final UsuarioRepository usuarioRepository = mock(UsuarioRepository.class);
  private final EstabelecimentoRepository estabelecimentoRepository =
      mock(EstabelecimentoRepository.class);
  private final PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
  private final JwtService jwtService = mock(JwtService.class);
  private final AuthService service = new AuthService(
      usuarioRepository,
      estabelecimentoRepository,
      passwordEncoder,
      jwtService);

  @Test
  void loginPrestadorRetornaCategoriaEDadosPublicosDoEstabelecimento() {
    Usuario usuario = new Usuario();
    usuario.setId(42L);
    usuario.setNome("Nome da conta");
    usuario.setEmail("studio@duckhat.com");
    usuario.setTelefone("62999990000");
    usuario.setCnpj("11222333000144");
    usuario.setResponsavelNome("Ana Responsavel");
    usuario.setSenhaHash("hash");
    usuario.setTipo(TipoUsuario.PRESTADOR);

    Estabelecimento estabelecimento = new Estabelecimento();
    estabelecimento.setUsuario(usuario);
    estabelecimento.setNome("DuckHat Studio");
    estabelecimento.setTelefone("62988887777");
    estabelecimento.setCnpj("11222333000144");
    estabelecimento.setResponsavelNome("Ana Responsavel");
    estabelecimento.setEndereco("Av. Central, 100");
    estabelecimento.setCategoria("barbearia");
    estabelecimento.setDescricao("Atendimento profissional.");
    estabelecimento.setHorarioAtendimento("Segunda a sexta 8h - 18h");
    estabelecimento.setBannerImagemBase64("banner");
    estabelecimento.setFotoPerfilBase64("logo");

    when(usuarioRepository.findByEmail("studio@duckhat.com")).thenReturn(Optional.of(usuario));
    when(passwordEncoder.matches("123456", "hash")).thenReturn(true);
    when(jwtService.gerarToken(usuario)).thenReturn("jwt-token");
    when(estabelecimentoRepository.findByUsuarioId(42L)).thenReturn(Optional.of(estabelecimento));

    LoginResponse response = service.login(new LoginRequest("studio@duckhat.com", "123456"));

    assertEquals("DuckHat Studio", response.nome());
    assertEquals("barbearia", response.categoria());
    assertEquals("Barbearia", response.categoriaLabel());
    assertEquals("Atendimento profissional.", response.descricao());
    assertEquals("Segunda a sexta 8h - 18h", response.horarioAtendimento());
    assertEquals("banner", response.bannerImagemBase64());
    assertEquals("logo", response.fotoPerfilBase64());
  }
}
