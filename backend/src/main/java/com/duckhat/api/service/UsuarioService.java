package com.duckhat.api.service;

import com.duckhat.api.dto.CreateUsuarioRequest;
import com.duckhat.api.dto.UpdatePerfilRequest;
import com.duckhat.api.dto.UsuarioResponse;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public UsuarioResponse criar(CreateUsuarioRequest request) {
        String emailNormalizado = normalizarEmail(request.email());
        String telefoneNormalizado = normalizarTelefone(request.telefone());
        String cnpjNormalizado = normalizarCnpj(request.cnpj());
        String responsavelNome = normalizarTexto(request.responsavelNome());

        validarCamposPrestador(request.tipo(), cnpjNormalizado, responsavelNome);

        if (usuarioRepository.existsByEmail(emailNormalizado)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email já cadastrado");
        }

        if (cnpjNormalizado != null && usuarioRepository.existsByCnpj(cnpjNormalizado)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "CNPJ já cadastrado");
        }

        Usuario usuario = new Usuario();
        usuario.setNome(request.nome().trim());
        usuario.setEmail(emailNormalizado);
        usuario.setSenhaHash(passwordEncoder.encode(request.senha()));
        usuario.setTelefone(telefoneNormalizado);
        usuario.setCnpj(cnpjNormalizado);
        usuario.setResponsavelNome(responsavelNome);
        usuario.setTipo(request.tipo());

        Usuario salvo = usuarioRepository.save(usuario);
        return UsuarioResponse.fromEntity(salvo);
    }

    @Transactional(readOnly = true)
    public List<UsuarioResponse> listar() {
        return usuarioRepository.findAll()
                .stream()
                .map(UsuarioResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public UsuarioResponse buscarPorId(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        return UsuarioResponse.fromEntity(usuario);
    }

    @Transactional
    public UsuarioResponse atualizarPerfil(Usuario autenticado, UpdatePerfilRequest request) {
        Usuario usuario = usuarioRepository.findById(autenticado.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        String emailNormalizado = normalizarEmail(request.email());
        String telefoneNormalizado = normalizarTelefone(request.telefone());
        String cnpjNormalizado = normalizarCnpj(request.cnpj());
        String responsavelNome = normalizarTexto(request.responsavelNome());
        String endereco = normalizarTexto(request.endereco());

        if (!emailNormalizado.equals(usuario.getEmail()) && usuarioRepository.existsByEmail(emailNormalizado)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email já cadastrado");
        }

        if (usuario.getTipo() == TipoUsuario.PRESTADOR) {
            validarCamposPrestador(usuario.getTipo(), cnpjNormalizado, responsavelNome);
            if (cnpjNormalizado != null
                    && !cnpjNormalizado.equals(usuario.getCnpj())
                    && usuarioRepository.existsByCnpj(cnpjNormalizado)) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "CNPJ já cadastrado");
            }
        } else {
            cnpjNormalizado = null;
            responsavelNome = null;
        }

        usuario.setNome(request.nome().trim());
        usuario.setEmail(emailNormalizado);
        usuario.setTelefone(telefoneNormalizado);
        usuario.setCnpj(cnpjNormalizado);
        usuario.setResponsavelNome(responsavelNome);
        usuario.setDataNascimento(request.dataNascimento());
        usuario.setEndereco(endereco);

        return UsuarioResponse.fromEntity(usuarioRepository.save(usuario));
    }

    private void validarCamposPrestador(
            TipoUsuario tipo,
            String cnpjNormalizado,
            String responsavelNome
    ) {
        if (tipo != TipoUsuario.PRESTADOR) {
            return;
        }

        if (cnpjNormalizado == null || cnpjNormalizado.length() != 14) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Prestadores precisam informar um CNPJ válido com 14 dígitos");
        }

        if (responsavelNome == null || responsavelNome.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Prestadores precisam informar o nome do responsável");
        }
    }

    private String normalizarEmail(String email) {
        return email.trim().toLowerCase();
    }

    private String normalizarTelefone(String telefone) {
        if (telefone == null || telefone.isBlank()) {
            return null;
        }
        return telefone.replaceAll("\\D", "");
    }

    private String normalizarCnpj(String cnpj) {
        if (cnpj == null || cnpj.isBlank()) {
            return null;
        }
        return cnpj.replaceAll("\\D", "");
    }

    private String normalizarTexto(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        return valor.trim();
    }
}
