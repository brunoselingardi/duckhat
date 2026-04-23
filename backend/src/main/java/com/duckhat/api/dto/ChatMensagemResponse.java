package com.duckhat.api.dto;

import com.duckhat.api.entity.ChatMensagem;
import com.duckhat.api.entity.Usuario;
import java.time.LocalDateTime;

public record ChatMensagemResponse(
    Long id,
    Long conversaId,
    Long remetenteId,
    String remetenteNome,
    String conteudo,
    LocalDateTime criadoEm,
    boolean enviadaPorMim
) {
  public static ChatMensagemResponse fromEntity(ChatMensagem mensagem, Usuario usuario) {
    return new ChatMensagemResponse(
        mensagem.getId(),
        mensagem.getConversa().getId(),
        mensagem.getRemetente().getId(),
        mensagem.getRemetente().getNome(),
        mensagem.getConteudo(),
        mensagem.getCriadoEm(),
        mensagem.getRemetente().getId().equals(usuario.getId()));
  }
}
