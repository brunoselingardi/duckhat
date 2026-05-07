package com.duckhat.api.dto;

import com.duckhat.api.entity.Usuario;

public record PrestadorPublicoResponse(
    Long id,
    String nome,
    String telefone,
    String endereco,
    String descricaoPublica,
    String horarioAtendimento,
    String imagemCapa,
    String imagemLogo
) {
  public static PrestadorPublicoResponse fromEntity(Usuario usuario) {
    return new PrestadorPublicoResponse(
        usuario.getId(),
        usuario.getNome(),
        usuario.getTelefone(),
        usuario.getEndereco(),
        usuario.getDescricaoPublica(),
        usuario.getHorarioAtendimento(),
        usuario.getImagemCapa(),
        usuario.getImagemLogo());
  }
}
