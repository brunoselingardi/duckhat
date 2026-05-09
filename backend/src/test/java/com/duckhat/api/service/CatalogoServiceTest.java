package com.duckhat.api.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.duckhat.api.dto.EstabelecimentoCatalogoResponse;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Servico;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.EstabelecimentoRepository;
import com.duckhat.api.repository.ServicoRepository;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

class CatalogoServiceTest {

  private final EstabelecimentoRepository estabelecimentoRepository = mock(EstabelecimentoRepository.class);
  private final ServicoRepository servicoRepository = mock(ServicoRepository.class);
  private final CatalogoService service = new CatalogoService(estabelecimentoRepository, servicoRepository);

  @Test
  void listarEstabelecimentosRetornaDadosPublicosComServicosAtivos() {
    Estabelecimento studio = estabelecimento(42L, "DuckHat Studio");
    Estabelecimento barber = estabelecimento(2L, "Barbie Dream Barber");

    when(estabelecimentoRepository.findAllByOrderByNomeAsc()).thenReturn(List.of(barber, studio));
    when(servicoRepository.findAtivosComPrestador()).thenReturn(List.of(
        servico(10L, studio.getUsuarioId(), "Corte premium", "Corte completo", "75.00"),
        servico(11L, studio.getUsuarioId(), "Barba", "Acabamento", "35.00")));

    List<EstabelecimentoCatalogoResponse> responses = service.listarEstabelecimentos(null);

    assertEquals(2, responses.size());
    assertEquals("DuckHat Studio", responses.get(0).nome());
    assertEquals(2, responses.get(0).totalServicos());
    assertEquals(new BigDecimal("35.00"), responses.get(0).precoInicial());
    assertEquals("Corte premium", responses.get(0).servicos().get(0).nome());
    assertEquals("Barbie Dream Barber", responses.get(1).nome());
    assertEquals(0, responses.get(1).totalServicos());
  }

  @Test
  void listarEstabelecimentosFiltraPorServico() {
    Estabelecimento studio = estabelecimento(42L, "DuckHat Studio");
    when(estabelecimentoRepository.findAllByOrderByNomeAsc()).thenReturn(List.of(studio));
    when(servicoRepository.findAtivosComPrestador()).thenReturn(List.of(
        servico(10L, 42L, "Corte premium", "Corte completo", "75.00")));

    List<EstabelecimentoCatalogoResponse> responses = service.listarEstabelecimentos("premium");

    assertEquals(1, responses.size());
    assertEquals("DuckHat Studio", responses.get(0).nome());
  }

  @Test
  void listarEstabelecimentosFiltraPorCategoriaEPalavraChaveNormalizada() {
    Estabelecimento encanador = estabelecimento(13L, "Jorje Encanamentos");
    encanador.setCategoria("encanador");
    when(estabelecimentoRepository.findAllByOrderByNomeAsc()).thenReturn(List.of(encanador));
    when(servicoRepository.findAtivosComPrestador()).thenReturn(List.of(
        servico(10L, 13L, "Visita tecnica", "Reparo de canos e vazamentos", "90.00")));

    List<EstabelecimentoCatalogoResponse> responses = service.listarEstabelecimentos("hidráulica perto de mim");

    assertEquals(1, responses.size());
    assertEquals("Encanador", responses.get(0).categoriaLabel());
  }

  @Test
  void buscarEstabelecimentoRetorna404QuandoNaoExiste() {
    when(estabelecimentoRepository.findByUsuarioId(99L)).thenReturn(Optional.empty());

    ResponseStatusException error = assertThrows(
        ResponseStatusException.class,
        () -> service.buscarEstabelecimento(99L));

    assertEquals(HttpStatus.NOT_FOUND, error.getStatusCode());
  }

  private Estabelecimento estabelecimento(Long usuarioId, String nome) {
    Estabelecimento estabelecimento = new Estabelecimento();
    estabelecimento.setUsuarioId(usuarioId);
    estabelecimento.setNome(nome);
    estabelecimento.setTelefone("62999998888");
    estabelecimento.setCnpj("11222333000144");
    estabelecimento.setResponsavelNome("Ana Responsavel");
    estabelecimento.setEndereco("Av. Central, 100");
    estabelecimento.setCategoria("barbearia");
    estabelecimento.setDescricao("Atendimento profissional.");
    estabelecimento.setHorarioAtendimento("Segunda a sexta 9h - 18h");
    estabelecimento.setBannerImagemBase64("banner");
    return estabelecimento;
  }

  private Servico servico(Long id, Long prestadorId, String nome, String descricao, String preco) {
    Servico servico = new Servico();
    servico.setId(id);
    servico.setPrestador(usuario(prestadorId));
    servico.setNome(nome);
    servico.setDescricao(descricao);
    servico.setDuracaoMin(45);
    servico.setPreco(new BigDecimal(preco));
    servico.setAtivo(true);
    return servico;
  }

  private Usuario usuario(Long id) {
    Usuario usuario = new Usuario();
    usuario.setId(id);
    usuario.setNome("Prestador " + id);
    usuario.setEmail("prestador" + id + "@duckhat.com");
    usuario.setSenhaHash("hash");
    usuario.setTipo(TipoUsuario.PRESTADOR);
    return usuario;
  }
}
