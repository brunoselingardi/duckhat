package com.duckhat.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RedefinirSenhaRequest(
    @NotBlank @Email @Size(max = 150) String email,
    @NotBlank @Size(min = 4, max = 12) String codigo,
    @NotBlank @Size(min = 6, max = 100) String novaSenha
) {
}
