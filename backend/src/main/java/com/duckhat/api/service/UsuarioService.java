package com.duckhat.api.service;

import com.duckhat.api.dto.CreateUsuarioRequest;
import com.duckhat.api.dto.CatalogoPrestadorBuscaResponse;
import com.duckhat.api.dto.PrestadorPublicoResponse;
import com.duckhat.api.dto.UpdatePerfilRequest;
import com.duckhat.api.dto.UsuarioResponse;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.AvaliacaoRepository;
import com.duckhat.api.repository.ChatConversaRepository;
import com.duckhat.api.repository.ChatMensagemRepository;
import com.duckhat.api.repository.DisponibilidadeRepository;
import com.duckhat.api.repository.EstabelecimentoRepository;
import com.duckhat.api.repository.NotificacaoEventoRepository;
import com.duckhat.api.repository.NotificacaoPreferenciaRepository;
import com.duckhat.api.repository.RecuperacaoSenhaTokenRepository;
import com.duckhat.api.repository.ServicoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.regex.Pattern;

@Service
public class UsuarioService {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$",
            Pattern.CASE_INSENSITIVE);

    private final UsuarioRepository usuarioRepository;
    private final EstabelecimentoRepository estabelecimentoRepository;
    private final AgendamentoRepository agendamentoRepository;
    private final AvaliacaoRepository avaliacaoRepository;
    private final ChatConversaRepository chatConversaRepository;
    private final ChatMensagemRepository chatMensagemRepository;
    private final DisponibilidadeRepository disponibilidadeRepository;
    private final NotificacaoEventoRepository notificacaoEventoRepository;
    private final NotificacaoPreferenciaRepository notificacaoPreferenciaRepository;
    private final RecuperacaoSenhaTokenRepository recuperacaoSenhaTokenRepository;
    private final ServicoRepository servicoRepository;
    private final PasswordEncoder passwordEncoder;
    private final DisponibilidadePadraoService disponibilidadePadraoService;

    @PersistenceContext
    private EntityManager entityManager;

    public UsuarioService(
            UsuarioRepository usuarioRepository,
            EstabelecimentoRepository estabelecimentoRepository,
            AgendamentoRepository agendamentoRepository,
            AvaliacaoRepository avaliacaoRepository,
            ChatConversaRepository chatConversaRepository,
            ChatMensagemRepository chatMensagemRepository,
            DisponibilidadeRepository disponibilidadeRepository,
            NotificacaoEventoRepository notificacaoEventoRepository,
            NotificacaoPreferenciaRepository notificacaoPreferenciaRepository,
            RecuperacaoSenhaTokenRepository recuperacaoSenhaTokenRepository,
            ServicoRepository servicoRepository,
            PasswordEncoder passwordEncoder,
            DisponibilidadePadraoService disponibilidadePadraoService
    ) {
        this.usuarioRepository = usuarioRepository;
        this.estabelecimentoRepository = estabelecimentoRepository;
        this.agendamentoRepository = agendamentoRepository;
        this.avaliacaoRepository = avaliacaoRepository;
        this.chatConversaRepository = chatConversaRepository;
        this.chatMensagemRepository = chatMensagemRepository;
        this.disponibilidadeRepository = disponibilidadeRepository;
        this.notificacaoEventoRepository = notificacaoEventoRepository;
        this.notificacaoPreferenciaRepository = notificacaoPreferenciaRepository;
        this.recuperacaoSenhaTokenRepository = recuperacaoSenhaTokenRepository;
        this.servicoRepository = servicoRepository;
        this.passwordEncoder = passwordEncoder;
        this.disponibilidadePadraoService = disponibilidadePadraoService;
    }

    @Transactional
    public UsuarioResponse criar(CreateUsuarioRequest request) {
        String emailNormalizado = normalizarEmail(request.email());
        String telefoneNormalizado = normalizarTelefone(request.telefone());
        String cnpjNormalizado = normalizarCnpj(request.cnpj());
        String responsavelNome = normalizarTexto(request.responsavelNome());
        String categoria = normalizarCategoria(request.categoria(), request.tipo(), true);

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
            salvarEstabelecimento(salvo, null, categoria, null, null, null, null);
            disponibilidadePadraoService.garantirDisponibilidadePadrao(salvo);
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

    @Transactional(readOnly = true)
    public PrestadorPublicoResponse buscarPrestadorPublico(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Prestador não encontrado"));

        if (usuario.getTipo() != TipoUsuario.PRESTADOR) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Prestador não encontrado");
        }

        Estabelecimento estabelecimento = estabelecimentoRepository.findByUsuarioId(usuario.getId()).orElse(null);
        return PrestadorPublicoResponse.fromEntity(usuario, estabelecimento);
    }

    @Transactional(readOnly = true)
    public List<CatalogoPrestadorBuscaResponse> buscarPrestadoresPublicosPorNome(
            String nome,
            List<Long> prestadorIdsPorServico
    ) {
        String termo = nome == null ? "" : nome.trim();
        LinkedHashMap<Long, CatalogoPrestadorBuscaResponse> resultados = new LinkedHashMap<>();

        if (!termo.isEmpty()) {
            usuarioRepository.findByTipoAndNomeContainingIgnoreCase(TipoUsuario.PRESTADOR, termo)
                    .forEach(usuario -> resultados.putIfAbsent(
                            usuario.getId(),
                            CatalogoPrestadorBuscaResponse.fromEntity(
                                    usuario,
                                    buscarEstabelecimentoDoPrestador(usuario),
                                    "Estabelecimento")));
        }

        if (prestadorIdsPorServico != null && !prestadorIdsPorServico.isEmpty()) {
            usuarioRepository.findAllById(prestadorIdsPorServico)
                    .stream()
                    .filter(usuario -> usuario.getTipo() == TipoUsuario.PRESTADOR)
                    .forEach(usuario -> resultados.putIfAbsent(
                            usuario.getId(),
                            CatalogoPrestadorBuscaResponse.fromEntity(
                                    usuario,
                                    buscarEstabelecimentoDoPrestador(usuario),
                                    "Servico no DuckHat")));
        }

        return List.copyOf(resultados.values());
    }

    private Estabelecimento buscarEstabelecimentoDoPrestador(Usuario usuario) {
        return estabelecimentoRepository.findByUsuarioId(usuario.getId()).orElse(null);
    }

    @Transactional(readOnly = true)
    public UsuarioResponse buscarMeuPerfil(Usuario autenticado) {
        Usuario usuario = usuarioRepository.findById(autenticado.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        Estabelecimento estabelecimento = null;
        if (usuario.getTipo() == TipoUsuario.PRESTADOR) {
            estabelecimento = estabelecimentoRepository.findByUsuarioId(usuario.getId()).orElse(null);
        }

        return UsuarioResponse.fromEntity(usuario, estabelecimento);
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
        String categoria = normalizarCategoria(request.categoria(), usuario.getTipo(), false);
        String descricao = normalizarTextoLimitado(request.descricao(), 500, "Descrição deve ter no máximo 500 caracteres");
        String horarioAtendimento = normalizarTextoLimitado(
                request.horarioAtendimento(),
                160,
                "Horário de atendimento deve ter no máximo 160 caracteres");
        String bannerImagemBase64 = normalizarImagemBase64(request.bannerImagemBase64());
        String fotoPerfilBase64 = normalizarImagemBase64(request.fotoPerfilBase64());
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
        usuario.setFotoPerfilBase64(fotoPerfilBase64);

        Usuario salvo = usuarioRepository.save(usuario);
        Estabelecimento estabelecimento = null;
        if (salvo.getTipo() == TipoUsuario.PRESTADOR) {
            estabelecimento = salvarEstabelecimento(
                    salvo,
                    endereco,
                    categoria,
                    descricao,
                    horarioAtendimento,
                    bannerImagemBase64,
                    fotoPerfilBase64);
        }

        return UsuarioResponse.fromEntity(salvo, estabelecimento);
    }

    @Transactional
    public void excluirMinhaConta(Usuario autenticado) {
        if (!usuarioRepository.existsById(autenticado.getId())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado");
        }

        Long usuarioId = autenticado.getId();
        entityManager.flush();
        entityManager.clear();
        notificacaoEventoRepository.deleteByUsuarioOuRelacionamentos(usuarioId);
        avaliacaoRepository.deleteByAgendamentoClienteIdOrPrestadorId(usuarioId);
        chatMensagemRepository.deleteByUsuarioParticipante(usuarioId);
        chatConversaRepository.deleteByClienteIdOrPrestadorId(usuarioId);
        notificacaoPreferenciaRepository.deleteByUsuarioId(usuarioId);
        recuperacaoSenhaTokenRepository.deleteByUsuarioId(usuarioId);
        estabelecimentoRepository.deleteByUsuarioId(usuarioId);
        disponibilidadeRepository.deleteByPrestadorId(usuarioId);
        agendamentoRepository.deleteByClienteIdOrPrestadorId(usuarioId);
        servicoRepository.deleteByPrestadorId(usuarioId);
        usuarioRepository.deleteById(usuarioId);
        entityManager.flush();
        entityManager.clear();
    }

    private Estabelecimento salvarEstabelecimento(Usuario prestador, String endereco) {
        return salvarEstabelecimento(prestador, endereco, null, null, null, null, null);
    }

    private Estabelecimento salvarEstabelecimento(
            Usuario prestador,
            String endereco,
            String categoria,
            String descricao,
            String horarioAtendimento,
            String bannerImagemBase64,
            String fotoPerfilBase64
    ) {
        Estabelecimento estabelecimento = estabelecimentoRepository.findByUsuarioId(prestador.getId())
                .orElseGet(Estabelecimento::new);

        estabelecimento.setUsuario(prestador);
        estabelecimento.setNome(prestador.getNome());
        estabelecimento.setTelefone(prestador.getTelefone());
        estabelecimento.setCnpj(prestador.getCnpj());
        estabelecimento.setResponsavelNome(prestador.getResponsavelNome());
        estabelecimento.setEndereco(endereco);
        if (categoria != null) {
            estabelecimento.setCategoria(categoria);
        }
        estabelecimento.setDescricao(descricao);
        estabelecimento.setHorarioAtendimento(horarioAtendimento);
        if (bannerImagemBase64 != null) {
            estabelecimento.setBannerImagemBase64(bannerImagemBase64);
        }
        if (fotoPerfilBase64 != null) {
            estabelecimento.setFotoPerfilBase64(fotoPerfilBase64);
        }

        return estabelecimentoRepository.save(estabelecimento);
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

    private String normalizarCategoria(String categoria, TipoUsuario tipo, boolean obrigatoria) {
        String normalizada = normalizarTexto(categoria);
        if (tipo != TipoUsuario.PRESTADOR) {
            return null;
        }
        if (normalizada == null) {
            if (!obrigatoria) {
                return null;
            }
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Prestadores precisam escolher uma categoria de estabelecimento");
        }
        normalizada = normalizada.toLowerCase();
        if (!EstabelecimentoCategoriaCatalog.existe(normalizada)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Categoria de estabelecimento inválida");
        }
        return normalizada;
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

    private String normalizarTextoLimitado(String valor, int maxLength, String mensagemErro) {
        String normalizado = normalizarTexto(valor);
        if (normalizado == null) {
            return null;
        }
        String colapsado = normalizado.replaceAll("\\s+", " ");
        if (colapsado.length() > maxLength) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, mensagemErro);
        }
        return colapsado;
    }

    private String normalizarImagemBase64(String valor) {
        String normalizado = normalizarTexto(valor);
        if (normalizado == null) {
            return null;
        }
        if (normalizado.length() > 1_200_000) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Imagem deve ter no máximo 1.200.000 caracteres em Base64");
        }
        return normalizado;
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
