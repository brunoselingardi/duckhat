package com.duckhat.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateChatMensagemRequest(
    @NotBlank @Size(max = 2000) String conteudo
) {
}
