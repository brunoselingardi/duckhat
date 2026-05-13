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
    String categoria,
    String categoriaLabel,
    String descricao,
    String horarioAtendimento,
    String bannerImagemBase64,
    TipoUsuario tipo,
    String token,
    String mensagem) {
}
