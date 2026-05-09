package com.duckhat.api.dto;

import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Usuario;

public record CatalogoPrestadorBuscaResponse(
    Long prestadorId,
    String nome,
    String categoriaLabel,
    String endereco,
    String telefone,
    String descricaoPublica,
    String horarioAtendimento,
    String imagemCapa,
    String imagemLogo
) {
  public static CatalogoPrestadorBuscaResponse fromEntity(
      Usuario usuario,
      Estabelecimento estabelecimento,
      String categoriaLabel
  ) {
    return new CatalogoPrestadorBuscaResponse(
        usuario.getId(),
        estabelecimento == null || estabelecimento.getNome() == null
            ? usuario.getNome()
            : estabelecimento.getNome(),
        categoriaLabel,
        estabelecimento == null || estabelecimento.getEndereco() == null
            ? usuario.getEndereco()
            : estabelecimento.getEndereco(),
        estabelecimento == null || estabelecimento.getTelefone() == null
            ? usuario.getTelefone()
            : estabelecimento.getTelefone(),
        estabelecimento == null ? null : estabelecimento.getDescricao(),
        estabelecimento == null ? null : estabelecimento.getHorarioAtendimento(),
        null,
        null);
  }
}
