package com.duckhat.api.controller;

import com.duckhat.api.dto.CatalogoPrestadorBuscaResponse;
import com.duckhat.api.dto.OcupacaoPrestadorResponse;
import com.duckhat.api.dto.PrestadorPublicoResponse;
import com.duckhat.api.dto.DisponibilidadeResponse;
import com.duckhat.api.dto.EstabelecimentoCatalogoResponse;
import com.duckhat.api.dto.ServicoResponse;
import com.duckhat.api.service.AgendamentoService;
import com.duckhat.api.service.CatalogoService;
import com.duckhat.api.service.DisponibilidadeService;
import com.duckhat.api.service.ServicoService;
import com.duckhat.api.service.UsuarioService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class CatalogoController {

  private final ServicoService servicoService;
  private final CatalogoService catalogoService;
  private final DisponibilidadeService disponibilidadeService;
  private final AgendamentoService agendamentoService;
  private final UsuarioService usuarioService;

  public CatalogoController(ServicoService servicoService,
      CatalogoService catalogoService,
      DisponibilidadeService disponibilidadeService,
      AgendamentoService agendamentoService,
      UsuarioService usuarioService) {
    this.servicoService = servicoService;
    this.catalogoService = catalogoService;
    this.disponibilidadeService = disponibilidadeService;
    this.agendamentoService = agendamentoService;
    this.usuarioService = usuarioService;
  }

  @GetMapping("/api/catalogo/estabelecimentos")
  public List<EstabelecimentoCatalogoResponse> listarEstabelecimentos(
      @RequestParam(required = false) String termo) {
    return catalogoService.listarEstabelecimentos(termo);
  }

  @GetMapping("/api/catalogo/estabelecimentos/busca")
  public List<EstabelecimentoCatalogoResponse> buscarEstabelecimentos(
      @RequestParam(required = false) String termo) {
    return catalogoService.listarEstabelecimentos(termo);
  }

  @GetMapping("/api/catalogo/estabelecimentos/{prestadorId}")
  public EstabelecimentoCatalogoResponse buscarEstabelecimento(@PathVariable Long prestadorId) {
    return catalogoService.buscarEstabelecimento(prestadorId);
  }

  @GetMapping("/api/catalogo/servicos")
  public List<ServicoResponse> listarServicosAtivos() {
    return servicoService.listarAtivos();
  }

  @GetMapping("/api/catalogo/servicos/busca")
  public List<ServicoResponse> buscarServicosAtivosPorNome(@RequestParam String nome) {
    return servicoService.buscarAtivosPorNomePublico(nome);
  }

  @GetMapping("/api/catalogo/prestadores/busca")
  public List<CatalogoPrestadorBuscaResponse> buscarPrestadoresPublicosPorNome(
      @RequestParam String nome
  ) {
    return usuarioService.buscarPrestadoresPublicosPorNome(
        nome,
        servicoService.buscarPrestadorIdsPorNomeDeServicoPublico(nome));
  }

  @GetMapping("/api/catalogo/servicos/{id}")
  public ServicoResponse buscarServicoAtivoPorId(@PathVariable Long id) {
    return servicoService.buscarAtivoPorIdPublico(id);
  }

  @GetMapping("/api/catalogo/servicos/prestador/{prestadorId}")
  public List<ServicoResponse> listarServicosAtivosPorPrestador(@PathVariable Long prestadorId) {
    return servicoService.listarCatalogoPorPrestador(prestadorId);
  }

  @GetMapping("/api/catalogo/prestadores/{prestadorId}")
  public PrestadorPublicoResponse buscarPrestadorPublico(@PathVariable Long prestadorId) {
    return usuarioService.buscarPrestadorPublico(prestadorId);
  }

  @GetMapping("/api/catalogo/disponibilidades/prestador/{prestadorId}")
  public List<DisponibilidadeResponse> listarDisponibilidadesAtivasPorPrestador(@PathVariable Long prestadorId) {
    return disponibilidadeService.listarCatalogoPorPrestador(prestadorId);
  }

  @GetMapping("/api/catalogo/agendamentos/prestador/{prestadorId}/ocupados")
  public List<OcupacaoPrestadorResponse> listarOcupacoesPorPrestador(@PathVariable Long prestadorId) {
    return agendamentoService.listarOcupacoesPublicas(prestadorId);
  }
}
