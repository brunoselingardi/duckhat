package com.duckhat.api.dto;

import com.duckhat.api.entity.Estabelecimento;
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;

public record EstabelecimentoCatalogoResponse(
    Long prestadorId,
    String nome,
    String telefone,
    String endereco,
    String categoria,
    String categoriaLabel,
    String descricao,
    String horarioAtendimento,
    String bannerImagemBase64,
    Integer totalServicos,
    BigDecimal precoInicial,
    List<ServicoResponse> servicos
) {
  public static EstabelecimentoCatalogoResponse fromEntity(
      Estabelecimento estabelecimento,
      List<ServicoResponse> servicos) {
    BigDecimal precoInicial = servicos.stream()
        .map(ServicoResponse::preco)
        .min(Comparator.naturalOrder())
        .orElse(null);

    return new EstabelecimentoCatalogoResponse(
        estabelecimento.getUsuarioId(),
        estabelecimento.getNome(),
        estabelecimento.getTelefone(),
        estabelecimento.getEndereco(),
        estabelecimento.getCategoria(),
        com.duckhat.api.service.EstabelecimentoCategoriaCatalog.label(estabelecimento.getCategoria()),
        estabelecimento.getDescricao(),
        estabelecimento.getHorarioAtendimento(),
        estabelecimento.getBannerImagemBase64(),
        servicos.size(),
        precoInicial,
        servicos);
  }
}
