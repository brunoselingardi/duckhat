package com.duckhat.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public record UpdatePerfilRequest(

    @NotBlank
    @Size(max = 120)
    String nome,

    @NotBlank
    @Email
    @Size(max = 150)
    String email,

    @Size(max = 20)
    String telefone,

    @Size(max = 18)
    String cnpj,

    @Size(max = 120)
    String responsavelNome,

    @PastOrPresent
    LocalDate dataNascimento,

    @Size(max = 255)
    String endereco,

    @Size(max = 500)
    String descricao,

    @Size(max = 160)
    String horarioAtendimento
) {
}
