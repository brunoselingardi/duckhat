package com.duckhat.api.controller;

import com.duckhat.api.dto.DisponibilidadeResponse;
import com.duckhat.api.dto.ServicoResponse;
import com.duckhat.api.service.DisponibilidadeService;
import com.duckhat.api.service.ServicoService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class CatalogoController {

  private final ServicoService servicoService;
  private final DisponibilidadeService disponibilidadeService;

  public CatalogoController(ServicoService servicoService,
      DisponibilidadeService disponibilidadeService) {
    this.servicoService = servicoService;
    this.disponibilidadeService = disponibilidadeService;
  }

  @GetMapping("/api/catalogo/servicos")
  public List<ServicoResponse> listarServicosAtivos() {
    return servicoService.listarAtivos();
  }

  @GetMapping("/api/catalogo/servicos/busca")
  public List<ServicoResponse> buscarServicosAtivosPorNome(@RequestParam String nome) {
    return servicoService.buscarAtivosPorNomePublico(nome);
  }

  @GetMapping("/api/catalogo/servicos/{id}")
  public ServicoResponse buscarServicoAtivoPorId(@PathVariable Long id) {
    return servicoService.buscarAtivoPorIdPublico(id);
  }

  @GetMapping("/api/catalogo/servicos/prestador/{prestadorId}")
  public List<ServicoResponse> listarServicosAtivosPorPrestador(@PathVariable Long prestadorId) {
    return servicoService.listarPorPrestador(prestadorId)
        .stream()
        .filter(ServicoResponse::ativo)
        .toList();
  }

  @GetMapping("/api/catalogo/disponibilidades/prestador/{prestadorId}")
  public List<DisponibilidadeResponse> listarDisponibilidadesAtivasPorPrestador(@PathVariable Long prestadorId) {
    return disponibilidadeService.listarPorPrestador(prestadorId)
        .stream()
        .filter(DisponibilidadeResponse::ativo)
        .toList();
  }
}
