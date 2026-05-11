package com.duckhat.api.service;

import com.duckhat.api.dto.EstabelecimentoCatalogoResponse;
import com.duckhat.api.dto.ServicoResponse;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.repository.EstabelecimentoRepository;
import com.duckhat.api.repository.ServicoRepository;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class CatalogoService {

  private final EstabelecimentoRepository estabelecimentoRepository;
  private final ServicoRepository servicoRepository;

  public CatalogoService(
      EstabelecimentoRepository estabelecimentoRepository,
      ServicoRepository servicoRepository) {
    this.estabelecimentoRepository = estabelecimentoRepository;
    this.servicoRepository = servicoRepository;
  }

  @Transactional(readOnly = true)
  public List<EstabelecimentoCatalogoResponse> listarEstabelecimentos(String termo) {
    String termoNormalizado = normalizarBusca(termo);
    return montarCatalogo().stream()
        .filter(item -> termoNormalizado == null || combinaComBusca(item, termoNormalizado))
        .toList();
  }

  @Transactional(readOnly = true)
  public EstabelecimentoCatalogoResponse buscarEstabelecimento(Long prestadorId) {
    Estabelecimento estabelecimento = estabelecimentoRepository.findByUsuarioId(prestadorId)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Estabelecimento não encontrado"));

    List<ServicoResponse> servicos = servicoRepository.findByPrestadorIdAndAtivoTrue(prestadorId)
        .stream()
        .map(ServicoResponse::fromEntity)
        .toList();

    return EstabelecimentoCatalogoResponse.fromEntity(estabelecimento, servicos);
  }

  private List<EstabelecimentoCatalogoResponse> montarCatalogo() {
    Map<Long, List<ServicoResponse>> servicosPorPrestador = servicoRepository
        .findAtivosComPrestador()
        .stream()
        .map(ServicoResponse::fromEntity)
        .collect(Collectors.groupingBy(
            ServicoResponse::prestadorId,
            LinkedHashMap::new,
            Collectors.toList()));

    List<EstabelecimentoCatalogoResponse> responses = new ArrayList<>();
    for (Estabelecimento estabelecimento : estabelecimentoRepository.findAllByOrderByNomeAsc()) {
      List<ServicoResponse> servicos = servicosPorPrestador.getOrDefault(
          estabelecimento.getUsuarioId(),
          List.of());
      responses.add(EstabelecimentoCatalogoResponse.fromEntity(estabelecimento, servicos));
    }

    responses.sort(Comparator
        .comparing((EstabelecimentoCatalogoResponse item) -> item.totalServicos() > 0)
        .reversed()
        .thenComparing(item -> item.nome().toLowerCase(Locale.ROOT)));
    return responses;
  }

  private boolean combinaComBusca(EstabelecimentoCatalogoResponse item, String termo) {
    if (combinaTermo(item, termo)) {
      return true;
    }

    List<String> tokens = tokensBusca(termo);
    return !tokens.isEmpty() && tokens.stream().anyMatch(token -> combinaTermo(item, token));
  }

  private boolean combinaTermo(EstabelecimentoCatalogoResponse item, String termo) {
    if (EstabelecimentoCategoriaCatalog.combina(item.categoria(), termo)
        || contem(item.categoriaLabel(), termo)
        || contem(item.nome(), termo)
        || contem(item.endereco(), termo)
        || contem(item.descricao(), termo)) {
      return true;
    }

    return item.servicos().stream()
        .anyMatch(servico -> contem(servico.nome(), termo) || contem(servico.descricao(), termo));
  }

  private List<String> tokensBusca(String termo) {
    if (termo == null || termo.isBlank()) {
      return List.of();
    }
    return List.of(termo.split(" "))
        .stream()
        .filter(token -> token.length() >= 3)
        .filter(token -> !List.of("para", "com", "sem", "perto", "mim", "servico", "servicos").contains(token))
        .toList();
  }

  private boolean contem(String valor, String termo) {
    String normalizado = EstabelecimentoCategoriaCatalog.normalizar(valor);
    return normalizado != null && normalizado.contains(termo);
  }

  private String normalizarBusca(String termo) {
    if (termo == null || termo.isBlank()) {
      return null;
    }
    return EstabelecimentoCategoriaCatalog.normalizar(termo);
  }
}
