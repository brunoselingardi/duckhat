package com.duckhat.api.service;

import com.duckhat.api.dto.CreateUsuarioRequest;
import com.duckhat.api.dto.UpdatePerfilRequest;
import com.duckhat.api.dto.UsuarioResponse;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.EstabelecimentoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.regex.Pattern;
import java.util.List;

@Service
public class UsuarioService {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$",
            Pattern.CASE_INSENSITIVE);

    private final UsuarioRepository usuarioRepository;
    private final EstabelecimentoRepository estabelecimentoRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(
            UsuarioRepository usuarioRepository,
            EstabelecimentoRepository estabelecimentoRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.usuarioRepository = usuarioRepository;
        this.estabelecimentoRepository = estabelecimentoRepository;
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
        if (salvo.getTipo() == TipoUsuario.PRESTADOR) {
            salvarEstabelecimento(salvo, null);
        }
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
        String endereco = normalizarEndereco(request.endereco());
        validarDataNascimento(request.dataNascimento());

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

        Usuario salvo = usuarioRepository.save(usuario);
        if (salvo.getTipo() == TipoUsuario.PRESTADOR) {
            salvarEstabelecimento(salvo, endereco);
        }

        return UsuarioResponse.fromEntity(salvo);
    }

    private void salvarEstabelecimento(Usuario prestador, String endereco) {
        Estabelecimento estabelecimento = estabelecimentoRepository.findByUsuarioId(prestador.getId())
                .orElseGet(Estabelecimento::new);

        estabelecimento.setUsuario(prestador);
        estabelecimento.setNome(prestador.getNome());
        estabelecimento.setTelefone(prestador.getTelefone());
        estabelecimento.setCnpj(prestador.getCnpj());
        estabelecimento.setResponsavelNome(prestador.getResponsavelNome());
        estabelecimento.setEndereco(endereco);

        estabelecimentoRepository.save(estabelecimento);
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
        String normalizado = normalizarTexto(email);
        if (normalizado == null || !EMAIL_PATTERN.matcher(normalizado).matches()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Informe um e-mail válido");
        }
        return normalizado.toLowerCase();
    }

    private String normalizarTelefone(String telefone) {
        if (telefone == null || telefone.isBlank()) {
            return null;
        }

        String digits = telefone.replaceAll("\\D", "");
        if (!telefoneValido(digits)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Informe um telefone válido com DDD");
        }
        return digits;
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

    private String normalizarEndereco(String endereco) {
        String normalizado = normalizarTexto(endereco);
        if (normalizado == null) {
            return null;
        }

        if (!enderecoValido(normalizado)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Informe um endereço válido com rua e número");
        }
        return normalizado.replaceAll("\\s+", " ");
    }

    private boolean telefoneValido(String digits) {
        if (digits.length() != 10 && digits.length() != 11) {
            return false;
        }
        if (digits.chars().distinct().count() == 1) {
            return false;
        }

        int ddd = Integer.parseInt(digits.substring(0, 2));
        if (ddd < 11 || ddd > 99) {
            return false;
        }

        if (digits.length() == 11) {
            return digits.charAt(2) == '9';
        }
        return true;
    }

    private boolean enderecoValido(String endereco) {
        if (endereco.length() < 8) {
            return false;
        }
        boolean temLetra = endereco.chars().anyMatch(Character::isLetter);
        boolean temNumero = endereco.chars().anyMatch(Character::isDigit);
        return temLetra && temNumero;
    }

    private void validarDataNascimento(LocalDate dataNascimento) {
        if (dataNascimento == null) {
            return;
        }

        LocalDate hoje = LocalDate.now();
        LocalDate idadeMinima = hoje.minusYears(13);
        LocalDate idadeMaxima = hoje.minusYears(120);
        if (dataNascimento.isAfter(idadeMinima) || dataNascimento.isBefore(idadeMaxima)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Informe uma data de nascimento válida para maiores de 13 anos");
        }
    }
}
