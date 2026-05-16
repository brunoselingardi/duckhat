package com.duckhat.api.dto;

import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Usuario;

public record PrestadorPublicoResponse(
    Long id,
    String nome,
    String telefone,
    String endereco,
    String descricaoPublica,
    String horarioAtendimento,
    String imagemCapa,
    String imagemLogo,
    String fotoPerfilBase64
) {
  public static PrestadorPublicoResponse fromEntity(
      Usuario usuario,
      Estabelecimento estabelecimento
  ) {
    return new PrestadorPublicoResponse(
        usuario.getId(),
        estabelecimento == null || estabelecimento.getNome() == null
            ? usuario.getNome()
            : estabelecimento.getNome(),
        estabelecimento == null || estabelecimento.getTelefone() == null
            ? usuario.getTelefone()
            : estabelecimento.getTelefone(),
        estabelecimento == null || estabelecimento.getEndereco() == null
            ? usuario.getEndereco()
            : estabelecimento.getEndereco(),
        estabelecimento == null ? null : estabelecimento.getDescricao(),
        estabelecimento == null ? null : estabelecimento.getHorarioAtendimento(),
        null,
        null,
        estabelecimento == null ? null : estabelecimento.getFotoPerfilBase64());
  }
}
