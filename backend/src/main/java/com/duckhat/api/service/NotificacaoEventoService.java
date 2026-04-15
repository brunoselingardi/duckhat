package com.duckhat.api.service;

import com.duckhat.api.dto.CreateNotificacaoEventoRequest;
import com.duckhat.api.dto.NotificacaoEventoResponse;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.NotificacaoEvento;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.NotificacaoEventoRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.io.ObjectInputFilter.Status;
import java.util.List;

@Service
public class NotificacaoEventoService {

  private final NotificacaoEventoRepository notificacaoEventoRepository;
  private final AgendamentoRepository agendamentoRepository;

  public NotificacaoEventoService(NotificacaoEventoRepository notificacaoEventoRepository,
      AgendamentoRepository agendamentoRepository) {
    this.notificacaoEventoRepository = notificacaoEventoRepository;
    this.agendamentoRepository = agendamentoRepository;
  }

  @Transactional
  public NotificacaoEventoResponse criar(CreateNotificacaoEventoRequest request, Usuario usuario) {
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
          "Você não pode criar notificação para um agendamento que não é seu");
    }

    NotificacaoEvento notificacaoEvento = new NotificacaoEvento();
    notificacaoEvento.setAgendamento(agendamento);
    notificacaoEvento.setCanal(request.canal());
    notificacaoEvento.setAgendadoPara(request.agendadoPara());
    notificacaoEvento.setEnviadoEm(null);
    notificacaoEvento.setStatus(StatusNotificacao.PENDENTE);

    NotificacaoEvento salva = notificacaoEventoRepository.save(notificacaoEvento);
    return NotificacaoEventoResponse.fromEntity(salva);
  }

  @Transactional(readOnly = true)
  public List<NotificacaoEventoResponse> listarTodas(Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    return notificacaoEventoRepository.findByAgendamentoClienteId(usuario.getId())
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public NotificacaoEventoResponse buscarPorId(Long id, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    NotificacaoEvento notificacaoEvento = notificacaoEventoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Notificação não encontrada"));

    if (!notificacaoEvento.getAgendamento().getCliente().getId().equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar uma notificação que não é sua");
    }

    return NotificacaoEventoResponse.fromEntity(notificacaoEvento);
  }

  @Transactional(readOnly = true)
  public List<NotificacaoEventoResponse> listarPorAgendamento(Long agendamentoId, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    Agendamento agendamento = agendamentoRepository.findById(agendamentoId)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Agendamento não encontrado"));

    if (!agendamento.getCliente().getId().equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar notificações de um agendamento que não é seu");
    }

    return notificacaoEventoRepository.findByAgendamentoId(agendamentoId)
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<NotificacaoEventoResponse> listarPorStatus(StatusNotificacao status, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    return notificacaoEventoRepository.findByAgendamentoClienteIdAndStatus(usuario.getId(), status)
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<NotificacaoEventoResponse> listarPorCanal(CanalNotificacao canal, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    return notificacaoEventoRepository.findByAgendamentoClienteIdAndCanal(usuario.getId(), canal)
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }
}
