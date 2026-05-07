package com.duckhat.api.dto;

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
      String categoriaLabel
  ) {
    return new CatalogoPrestadorBuscaResponse(
        usuario.getId(),
        usuario.getNome(),
        categoriaLabel,
        usuario.getEndereco(),
        usuario.getTelefone(),
        usuario.getDescricaoPublica(),
        usuario.getHorarioAtendimento(),
        usuario.getImagemCapa(),
        usuario.getImagemLogo());
  }
}
