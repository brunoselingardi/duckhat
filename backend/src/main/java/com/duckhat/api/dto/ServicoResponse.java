package com.duckhat.api.dto;

import com.duckhat.api.entity.Servico;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ServicoResponse(
        Long id,
        Long prestadorId,
        String nome,
        String descricao,
        Integer duracaoMin,
        BigDecimal preco,
        Boolean ativo,
        LocalDateTime criadoEm
) {
    public static ServicoResponse fromEntity(Servico servico) {
        return new ServicoResponse(
                servico.getId(),
                servico.getPrestador().getId(),
                servico.getNome(),
                servico.getDescricao(),
                servico.getDuracaoMin(),
                servico.getPreco(),
                servico.getAtivo(),
                servico.getCriadoEm()
        );
    }
}
