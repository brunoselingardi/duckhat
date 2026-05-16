package com.duckhat.api.service;

import com.duckhat.api.repository.DisponibilidadeRepository;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import com.duckhat.api.dto.AgendamentoResponse;
import com.duckhat.api.dto.CreateAgendamentoRequest;
import com.duckhat.api.dto.OcupacaoPrestadorResponse;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Servico;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.EstabelecimentoRepository;
import com.duckhat.api.repository.ServicoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.duckhat.api.entity.enums.StatusAgendamento;
import java.util.List;
import java.util.Collections;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AgendamentoService {

  private final AgendamentoRepository agendamentoRepository;
  private final UsuarioRepository usuarioRepository;
  private final ServicoRepository servicoRepository;
  private final DisponibilidadeRepository disponibilidadeRepository;
  private final EstabelecimentoRepository estabelecimentoRepository;
  private final NotificacaoEventoService notificacaoEventoService;

  public AgendamentoService(AgendamentoRepository agendamentoRepository,
      UsuarioRepository usuarioRepository,
      ServicoRepository servicoRepository,
      DisponibilidadeRepository disponibilidadeRepository,
      EstabelecimentoRepository estabelecimentoRepository,
      NotificacaoEventoService notificacaoEventoService) {
    this.agendamentoRepository = agendamentoRepository;
    this.usuarioRepository = usuarioRepository;
    this.servicoRepository = servicoRepository;
    this.disponibilidadeRepository = disponibilidadeRepository;
    this.estabelecimentoRepository = estabelecimentoRepository;
    this.notificacaoEventoService = notificacaoEventoService;
  }

  @Transactional
  public AgendamentoResponse criar(CreateAgendamentoRequest request, Usuario cliente) {
    if (cliente.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }
    Servico servico = buscarServicoAgendavel(request.servicoId());

    if (!request.inicioEm().isBefore(request.fimEm())) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "inicioEm deve ser menor que fimEm");
    }

    if (request.inicioEm().isBefore(LocalDateTime.now())) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Não é possível criar agendamento em horário passado");
    }

    long duracaoSolicitada = Duration.between(request.inicioEm(), request.fimEm()).toMinutes();
    if (duracaoSolicitada != servico.getDuracaoMin().longValue()) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "A duração do agendamento deve ser igual à duração do serviço");
    }

    Byte diaSemana = (byte) request.inicioEm().getDayOfWeek().getValue();
    LocalTime horaInicio = request.inicioEm().toLocalTime();
    LocalTime horaFim = request.fimEm().toLocalTime();

    boolean dentroDaDisponibilidade = disponibilidadeRepository
        .findByPrestadorIdAndDiaSemanaAndAtivoTrue(servico.getPrestador().getId(), diaSemana)
        .stream()
        .anyMatch(disponibilidade -> !horaInicio.isBefore(disponibilidade.getHoraInicio()) &&
            !horaFim.isAfter(disponibilidade.getHoraFim()));

    if (!dentroDaDisponibilidade) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O horário solicitado está fora da disponibilidade do prestador");
    }
    boolean existeConflito = agendamentoRepository
        .existsByPrestadorIdAndStatusNotAndInicioEmLessThanAndFimEmGreaterThan(
            servico.getPrestador().getId(),
            StatusAgendamento.CANCELADO,
            request.fimEm(),
            request.inicioEm());

    if (existeConflito) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Já existe um agendamento nesse intervalo para o prestador");
    }
    Agendamento agendamento = new Agendamento();
    agendamento.setCliente(cliente);
    agendamento.setPrestador(servico.getPrestador());
    agendamento.setServico(servico);
    agendamento.setInicioEm(request.inicioEm());
    agendamento.setFimEm(request.fimEm());
    agendamento.setStatus(StatusAgendamento.PENDENTE);
    agendamento.setObservacoes(request.observacoes());

    Agendamento salvo = agendamentoRepository.save(agendamento);
    notificacaoEventoService.registrarAgendamentoCriado(salvo);
    return toResponse(salvo);
  }

  private Servico buscarServicoAgendavel(Long servicoId) {
    Servico servico = servicoRepository.findById(servicoId)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Serviço não encontrado"));

    if (!Boolean.TRUE.equals(servico.getAtivo())) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O serviço informado está pausado e não aceita agendamentos");
    }

    return servico;
  }

  @Transactional(readOnly = true)
  public List<AgendamentoResponse> listarTodos(Usuario cliente) {
    if (cliente.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    return toResponses(agendamentoRepository.findByClienteId(cliente.getId()));
  }

  @Transactional(readOnly = true)
  public List<AgendamentoResponse> listarPorCliente(Long clienteId, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    if (!clienteId.equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar agendamentos de outro cliente");
    }

    return toResponses(agendamentoRepository.findByClienteId(clienteId));
  }

  @Transactional(readOnly = true)
  public List<AgendamentoResponse> listarPorServico(Long servicoId, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    return toResponses(agendamentoRepository.findByClienteIdAndServicoId(usuario.getId(), servicoId));
  }

  @Transactional(readOnly = true)
  public List<AgendamentoResponse> listarPorStatus(StatusAgendamento status, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    return toResponses(agendamentoRepository.findByClienteIdAndStatus(usuario.getId(), status));
  }

  @Transactional(readOnly = true)
  public AgendamentoResponse buscarPorId(Long id, Usuario cliente) {
    if (cliente.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    Agendamento agendamento = agendamentoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Agendamento não encontrado"));

    if (!agendamento.getCliente().getId().equals(cliente.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar um agendamento que não é seu");
    }

    return toResponse(agendamento);
  }

  @Transactional
  public AgendamentoResponse cancelar(Long id, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.CLIENTE) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um cliente");
    }

    Agendamento agendamento = agendamentoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Agendamento não encontrado"));

    if (!agendamento.getCliente().getId().equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode cancelar um agendamento que não é seu");
    }

    if (agendamento.getStatus() == StatusAgendamento.CANCELADO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O agendamento já está cancelado");
    }

    if (agendamento.getStatus() == StatusAgendamento.CONCLUIDO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Não é possível cancelar um agendamento concluído");
    }

    agendamento.setStatus(StatusAgendamento.CANCELADO);

    Agendamento salvo = agendamentoRepository.save(agendamento);
    notificacaoEventoService.registrarAgendamentoCancelado(salvo, usuario);
    return toResponse(salvo);
  }

  @Transactional(readOnly = true)
  public List<AgendamentoResponse> listarParaPrestador(Usuario prestador) {
    if (prestador.getTipo() != TipoUsuario.PRESTADOR) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um prestador");
    }

    return toResponses(agendamentoRepository.findByPrestadorId(prestador.getId()));
  }

  @Transactional(readOnly = true)
  public List<OcupacaoPrestadorResponse> listarOcupacoesPublicas(Long prestadorId) {
    return agendamentoRepository
        .findByPrestadorIdAndStatusNotAndFimEmAfterOrderByInicioEmAsc(
            prestadorId,
            StatusAgendamento.CANCELADO,
            LocalDateTime.now())
        .stream()
        .map(OcupacaoPrestadorResponse::fromEntity)
        .toList();
  }

  @Transactional
  public AgendamentoResponse confirmar(Long id, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.PRESTADOR) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um prestador");
    }

    Agendamento agendamento = agendamentoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Agendamento não encontrado"));

    if (!agendamento.getPrestador().getId().equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode confirmar um agendamento que não é seu");
    }

    if (agendamento.getStatus() == StatusAgendamento.CANCELADO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Não é possível confirmar um agendamento cancelado");
    }

    if (agendamento.getStatus() == StatusAgendamento.CONCLUIDO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Não é possível confirmar um agendamento concluído");
    }

    if (agendamento.getStatus() == StatusAgendamento.CONFIRMADO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O agendamento já está confirmado");
    }

    agendamento.setStatus(StatusAgendamento.CONFIRMADO);

    Agendamento salvo = agendamentoRepository.save(agendamento);
    notificacaoEventoService.registrarAgendamentoConfirmado(salvo);
    return toResponse(salvo);
  }

  @Transactional
  public AgendamentoResponse concluir(Long id, Usuario usuario) {
    if (usuario.getTipo() != TipoUsuario.PRESTADOR) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O usuário autenticado não é um prestador");
    }

    Agendamento agendamento = agendamentoRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Agendamento não encontrado"));

    if (!agendamento.getPrestador().getId().equals(usuario.getId())) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode concluir um agendamento que não é seu");
    }

    if (agendamento.getStatus() == StatusAgendamento.CANCELADO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Não é possível concluir um agendamento cancelado");
    }

    if (agendamento.getStatus() == StatusAgendamento.CONCLUIDO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "O agendamento já está concluído");
    }

    if (agendamento.getStatus() != StatusAgendamento.CONFIRMADO) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Só é possível concluir um agendamento confirmado");
    }

    agendamento.setStatus(StatusAgendamento.CONCLUIDO);

    Agendamento salvo = agendamentoRepository.save(agendamento);
    notificacaoEventoService.registrarAgendamentoConcluido(salvo);
    return toResponse(salvo);
  }

  private AgendamentoResponse toResponse(Agendamento agendamento) {
    String fotoPerfilBase64 = estabelecimentoRepository
        .findByUsuarioId(agendamento.getPrestador().getId())
        .map(Estabelecimento::getFotoPerfilBase64)
        .orElse(null);
    return AgendamentoResponse.fromEntity(agendamento, fotoPerfilBase64);
  }

  private List<AgendamentoResponse> toResponses(List<Agendamento> agendamentos) {
    if (agendamentos.isEmpty()) {
      return List.of();
    }

    Map<Long, String> fotosPerfil = buscarFotosPerfilPorPrestador(agendamentos);
    return agendamentos.stream()
        .map(agendamento -> AgendamentoResponse.fromEntity(
            agendamento,
            fotosPerfil.get(agendamento.getPrestador().getId())))
        .toList();
  }

  private Map<Long, String> buscarFotosPerfilPorPrestador(List<Agendamento> agendamentos) {
    if (agendamentos.isEmpty()) {
      return Collections.emptyMap();
    }

    List<Long> prestadorIds = agendamentos.stream()
        .map(agendamento -> agendamento.getPrestador().getId())
        .distinct()
        .toList();

    return estabelecimentoRepository.findByUsuarioIdIn(prestadorIds)
        .stream()
        .filter(estabelecimento -> estabelecimento.getFotoPerfilBase64() != null)
        .collect(Collectors.toMap(
            Estabelecimento::getUsuarioId,
            Estabelecimento::getFotoPerfilBase64));
  }
}
