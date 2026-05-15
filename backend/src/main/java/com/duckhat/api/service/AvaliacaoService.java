package com.duckhat.api.service;

import com.duckhat.api.dto.AvaliacaoResponse;
import com.duckhat.api.dto.AvaliacaoPublicaResponse;
import com.duckhat.api.dto.CreateAvaliacaoRequest;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.Avaliacao;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.StatusAgendamento;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.AvaliacaoRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class AvaliacaoService {

  private final AvaliacaoRepository avaliacaoRepository;
  private final AgendamentoRepository agendamentoRepository;

  public AvaliacaoService(AvaliacaoRepository avaliacaoRepository,
      AgendamentoRepository agendamentoRepository) {
    this.avaliacaoRepository = avaliacaoRepository;
    this.agendamentoRepository = agendamentoRepository;
  }

  @Transactional
  public AvaliacaoResponse criar(CreateAvaliacaoRequest request, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    Agendamento agendamento = agendamentoRepository.findById(request.agendamentoId())
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Agendamento não encontrado"));

    if (!agendamento.getCliente().getId().equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode avaliar um agendamento que não é seu");
    }
    if (agendamento.getStatus() != StatusAgendamento.CONCLUIDO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Só é possível avaliar um agendamento concluído");
    }
    if (avaliacaoRepository.existsByAgendamentoId(request.agendamentoId())) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Esse agendamento já possui avaliação");
    }

    Avaliacao avaliacao = new Avaliacao();
    avaliacao.setAgendamento(agendamento);
    avaliacao.setNota(request.nota());
    avaliacao.setComentario(normalizarComentario(request.comentario()));

    Avaliacao salva = avaliacaoRepository.save(avaliacao);
    return AvaliacaoResponse.fromEntity(salva);
  }

  @Transactional(readOnly = true)
  public List<AvaliacaoResponse> listarTodas(Usuario usuario) {
    List<Avaliacao> avaliacoes;
    if (usuario.getTipo() == TipoUsuario.CLIENTE) {
      avaliacoes = avaliacaoRepository.findByAgendamentoClienteId(usuario.getId());
    } else if (usuario.getTipo() == TipoUsuario.PRESTADOR) {
      avaliacoes = avaliacaoRepository.findByAgendamentoPrestadorId(usuario.getId());
    } else {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não pode acessar avaliações");
    }

    return avaliacoes
        .stream()
        .map(AvaliacaoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<AvaliacaoPublicaResponse> listarPublicasPorPrestador(Long prestadorId) {
    return avaliacaoRepository.findByAgendamentoPrestadorId(prestadorId)
        .stream()
        .map(AvaliacaoPublicaResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public AvaliacaoResponse buscarPorId(Long id, Usuario usuario) {
    Avaliacao avaliacao = avaliacaoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Avaliação não encontrada"));

    if (!podeAcessar(avaliacao.getAgendamento(), usuario)) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar uma avaliação que não é do seu atendimento");
    }

    return AvaliacaoResponse.fromEntity(avaliacao);
  }

  @Transactional(readOnly = true)
  public AvaliacaoResponse buscarPorAgendamento(Long agendamentoId, Usuario usuario) {
    Avaliacao avaliacao = avaliacaoRepository.findByAgendamentoId(agendamentoId)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Avaliação não encontrada para esse agendamento"));

    if (!podeAcessar(avaliacao.getAgendamento(), usuario)) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar a avaliação de um agendamento que não é seu");
    }

    return AvaliacaoResponse.fromEntity(avaliacao);
  }

  private boolean podeAcessar(Agendamento agendamento, Usuario usuario) {
    if (usuario.getTipo() == TipoUsuario.CLIENTE) {
      return agendamento.getCliente().getId().equals(usuario.getId());
    }
    if (usuario.getTipo() == TipoUsuario.PRESTADOR) {
      return agendamento.getPrestador().getId().equals(usuario.getId());
    }
    return false;
  }

  private String normalizarComentario(String comentario) {
    if (comentario == null || comentario.isBlank()) {
      return null;
    }
    return comentario.trim().replaceAll("\\s+", " ");
  }
}
