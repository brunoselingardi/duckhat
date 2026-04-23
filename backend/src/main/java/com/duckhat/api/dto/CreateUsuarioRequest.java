package com.duckhat.api.dto;

import com.duckhat.api.entity.enums.TipoUsuario;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateUsuarioRequest(

        @NotBlank
        @Size(max = 120)
        String nome,

        @NotBlank
        @Email
        @Size(max = 150)
        String email,

        @NotBlank
        @Size(min = 6, max = 100)
        String senha,

        @Size(max = 20)
        String telefone,

        @Size(min = 14, max = 14)
        String cnpj,

        @Size(max = 120)
        String responsavelNome,

        @NotNull
        TipoUsuario tipo
) {
}
