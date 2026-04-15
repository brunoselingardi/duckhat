package com.duckhat.api.dto;

import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;

import java.time.LocalDateTime;

public record UsuarioResponse(
        Long id,
        String nome,
        String email,
        String telefone,
        TipoUsuario tipo,
        LocalDateTime criadoEm
) {
    public static UsuarioResponse fromEntity(Usuario usuario) {
        return new UsuarioResponse(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getTelefone(),
                usuario.getTipo(),
                usuario.getCriadoEm()
        );
    }
}
