package com.duckhat.api.dto;

import com.duckhat.api.entity.ChatConversa;
import com.duckhat.api.entity.ChatMensagem;
import com.duckhat.api.entity.Usuario;
import java.time.LocalDateTime;

public record ChatConversaResponse(
    Long id,
    Long clienteId,
    String clienteNome,
    Long prestadorId,
    String prestadorNome,
    Long participanteId,
    String participanteNome,
    String ultimaMensagem,
    LocalDateTime ultimaMensagemEm
) {
  public static ChatConversaResponse fromEntity(
      ChatConversa conversa,
      Usuario usuario,
      ChatMensagem ultimaMensagem) {
    boolean usuarioEhCliente = conversa.getCliente().getId().equals(usuario.getId());
    Usuario participante = usuarioEhCliente ? conversa.getPrestador() : conversa.getCliente();

    return new ChatConversaResponse(
        conversa.getId(),
        conversa.getCliente().getId(),
        conversa.getCliente().getNome(),
        conversa.getPrestador().getId(),
        conversa.getPrestador().getNome(),
        participante.getId(),
        participante.getNome(),
        ultimaMensagem == null ? null : ultimaMensagem.getConteudo(),
        conversa.getUltimaMensagemEm());
  }
}
