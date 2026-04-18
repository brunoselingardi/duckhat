package com.duckhat.api.service;

import com.duckhat.api.dto.CreateDisponibilidadeRequest;
import com.duckhat.api.dto.DisponibilidadeResponse;
import com.duckhat.api.entity.Disponibilidade;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.DisponibilidadeRepository;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class DisponibilidadeService {

  private final DisponibilidadeRepository disponibilidadeRepository;
  private final UsuarioRepository usuarioRepository;

  public DisponibilidadeService(DisponibilidadeRepository disponibilidadeRepository,
      UsuarioRepository usuarioRepository) {
    this.disponibilidadeRepository = disponibilidadeRepository;
    this.usuarioRepository = usuarioRepository;
  }

  @Transactional
  public DisponibilidadeResponse criar(CreateDisponibilidadeRequest request, Usuario prestador) {
    if (prestador.getTipo() != TipoUsuario.PRESTADOR) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um prestador");
    }
    if (!request.horaInicio().isBefore(request.horaFim())) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "horaInicio deve ser menor que horaFim");
    }

    Disponibilidade disponibilidade = new Disponibilidade();
    disponibilidade.setPrestador(prestador);
    disponibilidade.setDiaSemana(request.diaSemana());
    disponibilidade.setHoraInicio(request.horaInicio());
    disponibilidade.setHoraFim(request.horaFim());
    disponibilidade.setAtivo(request.ativo());

    Disponibilidade salva = disponibilidadeRepository.save(disponibilidade);
    return DisponibilidadeResponse.fromEntity(salva);
  }

  @Transactional(readOnly = true)
  public List<DisponibilidadeResponse> listarTodas(Usuario prestador) {
    if (prestador.getTipo() != TipoUsuario.PRESTADOR) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um prestador");
    }

    return disponibilidadeRepository.findByPrestadorId(prestador.getId())
        .stream()
        .map(DisponibilidadeResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<DisponibilidadeResponse> listarAtivas() {
    return disponibilidadeRepository.findByAtivoTrue()
        .stream()
        .map(DisponibilidadeResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<DisponibilidadeResponse> listarPorPrestador(Long prestadorId, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.PRESTADOR) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um prestador");
    }

    if (!prestadorId.equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar disponibilidades de outro prestador");
    }

    return disponibilidadeRepository.findByPrestadorId(prestadorId)
        .stream()
        .map(DisponibilidadeResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<DisponibilidadeResponse> listarCatalogoPorPrestador(Long prestadorId) {
    return disponibilidadeRepository.findByPrestadorIdAndAtivoTrue(prestadorId)
        .stream()
        .map(DisponibilidadeResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public DisponibilidadeResponse buscarPorId(Long id, Usuario prestador) {
    if (prestador.getTipo() != TipoUsuario.PRESTADOR) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um prestador");
    }

    Disponibilidade disponibilidade = disponibilidadeRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Disponibilidade não encontrada"));

    if (!disponibilidade.getPrestador().getId().equals(prestador.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar uma disponibilidade que não é sua");
    }

    return DisponibilidadeResponse.fromEntity(disponibilidade);
  }
}
