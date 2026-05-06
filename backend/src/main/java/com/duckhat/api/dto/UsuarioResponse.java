package com.duckhat.api.dto;

import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.enums.TipoUsuario;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record UsuarioResponse(
        Long id,
        String nome,
        String email,
        String telefone,
        String cnpj,
        String responsavelNome,
        LocalDate dataNascimento,
        String endereco,
        String descricao,
        String horarioAtendimento,
        TipoUsuario tipo,
        LocalDateTime criadoEm
) {
    public static UsuarioResponse fromEntity(Usuario usuario) {
        return new UsuarioResponse(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getTelefone(),
                usuario.getCnpj(),
                usuario.getResponsavelNome(),
                usuario.getDataNascimento(),
                usuario.getEndereco(),
                null,
                null,
                usuario.getTipo(),
                usuario.getCriadoEm()
        );
    }

    public static UsuarioResponse fromEntity(Usuario usuario, Estabelecimento estabelecimento) {
        if (estabelecimento == null) {
            return fromEntity(usuario);
        }

        return new UsuarioResponse(
                usuario.getId(),
                estabelecimento.getNome() == null ? usuario.getNome() : estabelecimento.getNome(),
                usuario.getEmail(),
                estabelecimento.getTelefone() == null ? usuario.getTelefone() : estabelecimento.getTelefone(),
                estabelecimento.getCnpj() == null ? usuario.getCnpj() : estabelecimento.getCnpj(),
                estabelecimento.getResponsavelNome() == null ? usuario.getResponsavelNome() : estabelecimento.getResponsavelNome(),
                usuario.getDataNascimento(),
                estabelecimento.getEndereco() == null ? usuario.getEndereco() : estabelecimento.getEndereco(),
                estabelecimento.getDescricao(),
                estabelecimento.getHorarioAtendimento(),
                usuario.getTipo(),
                usuario.getCriadoEm()
        );
    }
}
