package com.duckhat.api.dto;

import com.duckhat.api.entity.Avaliacao;
import java.time.LocalDateTime;

public record AvaliacaoPublicaResponse(
    Long prestadorId,
    String clienteNome,
    Integer nota,
    String comentario,
    LocalDateTime criadoEm
) {
  public static AvaliacaoPublicaResponse fromEntity(Avaliacao avaliacao) {
    return new AvaliacaoPublicaResponse(
        avaliacao.getAgendamento().getPrestador().getId(),
        avaliacao.getAgendamento().getCliente().getNome(),
        avaliacao.getNota(),
        avaliacao.getComentario(),
        avaliacao.getCriadoEm()
    );
  }
}
