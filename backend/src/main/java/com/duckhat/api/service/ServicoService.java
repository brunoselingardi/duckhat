package com.duckhat.api.service;

import com.duckhat.api.dto.CreateServicoRequest;
import com.duckhat.api.dto.ServicoResponse;
import com.duckhat.api.entity.Servico;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.ServicoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class ServicoService {

  private final ServicoRepository servicoRepository;
  private final UsuarioRepository usuarioRepository;

  public ServicoService(ServicoRepository servicoRepository, UsuarioRepository usuarioRepository) {
    this.servicoRepository = servicoRepository;
    this.usuarioRepository = usuarioRepository;
  }

  @Transactional
  public ServicoResponse criar(CreateServicoRequest request, Usuario prestador) {
    validarPrestador(prestador);
    Servico servico = new Servico();
    servico.setPrestador(prestador);
    aplicarDados(servico, request);

    Servico salvo = servicoRepository.save(servico);
    return ServicoResponse.fromEntity(salvo);
  }

  @Transactional
  public ServicoResponse atualizar(Long id, CreateServicoRequest request, Usuario prestador) {
    validarPrestador(prestador);

    Servico servico = servicoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Serviço não encontrado"));

    if (!servico.getPrestador().getId().equals(prestador.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode editar um serviço que não é seu");
    }

    aplicarDados(servico, request);
    return ServicoResponse.fromEntity(servicoRepository.save(servico));
  }

  @Transactional(readOnly = true)
  public List<ServicoResponse> listarTodos(Usuario prestador) {
    validarPrestador(prestador);

    return servicoRepository.findByPrestadorId(prestador.getId())
        .stream()
        .map(ServicoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<ServicoResponse> listarAtivos() {
    return servicoRepository.findByAtivoTrue()
        .stream()
        .map(ServicoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<ServicoResponse> listarPorPrestador(Long prestadorId, Usuario usuario) {
    validarPrestador(usuario);

    if (!prestadorId.equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar serviços de outro prestador");
    }

    return servicoRepository.findByPrestadorId(prestadorId)
        .stream()
        .map(ServicoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<ServicoResponse> listarCatalogoPorPrestador(Long prestadorId) {
    return servicoRepository.findByPrestadorIdAndAtivoTrue(prestadorId)
        .stream()
        .map(ServicoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public ServicoResponse buscarPorId(Long id, Usuario prestador) {
    validarPrestador(prestador);

    Servico servico = servicoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Serviço não encontrado"));

    if (!servico.getPrestador().getId().equals(prestador.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar um serviço que não é seu");
    }

    return ServicoResponse.fromEntity(servico);
  }

  private void validarPrestador(Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.PRESTADOR) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um prestador");
    }
  }

  private void aplicarDados(Servico servico, CreateServicoRequest request) {
    servico.setNome(request.nome().trim());
    servico.setDescricao(normalizarTexto(request.descricao()));
    servico.setDuracaoMin(request.duracaoMin());
    servico.setPreco(request.preco());
    servico.setAtivo(request.ativo());
  }

  private String normalizarTexto(String valor) {
    if (valor == null || valor.isBlank()) {
      return null;
    }
    return valor.trim().replaceAll("\\s+", " ");
  }

  @Transactional(readOnly = true)
  public ServicoResponse buscarAtivoPorIdPublico(Long id) {
    Servico servico = servicoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Serviço não encontrado"));

    if (!Boolean.TRUE.equals(servico.getAtivo())) {
      throw new ResponseStatusException(
          HttpStatus.NOT_FOUND, "Serviço não encontrado");
    }

    return ServicoResponse.fromEntity(servico);
  }

  @Transactional(readOnly = true)
  public List<ServicoResponse> buscarAtivosPorNomePublico(String nome) {
    return servicoRepository.findByAtivoTrueAndNomeContainingIgnoreCase(nome)
        .stream()
        .map(ServicoResponse::fromEntity)
        .toList();
  }
}
