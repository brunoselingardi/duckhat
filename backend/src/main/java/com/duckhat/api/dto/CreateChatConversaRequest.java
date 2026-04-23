package com.duckhat.api.dto;

import jakarta.validation.constraints.NotNull;

public record CreateChatConversaRequest(
    @NotNull Long participanteId
) {
}
