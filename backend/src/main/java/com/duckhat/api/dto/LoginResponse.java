package com.duckhat.api.dto;

import com.duckhat.api.entity.enums.TipoUsuario;
import java.time.LocalDate;

public record LoginResponse(
    Long id,
    String nome,
    String email,
    String telefone,
    String cnpj,
    String responsavelNome,
    LocalDate dataNascimento,
    String endereco,
    TipoUsuario tipo,
    String token,
    String mensagem) {
}
