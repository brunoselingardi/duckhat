package com.duckhat.api.service;

import com.duckhat.api.dto.ContagemNotificacoesResponse;
import com.duckhat.api.dto.CreateNotificacaoEventoRequest;
import com.duckhat.api.dto.NotificacaoEventoResponse;
import com.duckhat.api.dto.NotificacaoPreferenciasResponse;
import com.duckhat.api.dto.UpdateNotificacaoPreferenciasRequest;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.ChatConversa;
import com.duckhat.api.entity.NotificacaoEvento;
import com.duckhat.api.entity.NotificacaoPreferencia;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import com.duckhat.api.entity.enums.TipoNotificacao;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.NotificacaoEventoRepository;
import com.duckhat.api.repository.NotificacaoPreferenciaRepository;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class NotificacaoEventoService {

  private static final DateTimeFormatter DATA_HORA_FORMATTER =
      DateTimeFormatter.ofPattern("dd/MM 'as' HH:mm");
  private static final int LIMITE_PREVIEW_MENSAGEM = 120;

  private final NotificacaoEventoRepository notificacaoEventoRepository;
  private final NotificacaoPreferenciaRepository notificacaoPreferenciaRepository;
  private final AgendamentoRepository agendamentoRepository;

  public NotificacaoEventoService(
      NotificacaoEventoRepository notificacaoEventoRepository,
      NotificacaoPreferenciaRepository notificacaoPreferenciaRepository,
      AgendamentoRepository agendamentoRepository) {
    this.notificacaoEventoRepository = notificacaoEventoRepository;
    this.notificacaoPreferenciaRepository = notificacaoPreferenciaRepository;
    this.agendamentoRepository = agendamentoRepository;
  }

  @Transactional
  public NotificacaoEventoResponse criar(CreateNotificacaoEventoRequest request, Usuario usuario) {
    Agendamento agendamento = agendamentoRepository.findById(request.agendamentoId())
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Agendamento não encontrado"));

    if (!participaDoAgendamento(agendamento, usuario)) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode criar notificação para um agendamento de outro usuário");
    }

    NotificacaoEvento notificacao = criarEventoBase(
        usuario,
        TipoNotificacao.AGENDAMENTO,
        request.canal(),
        textoOuPadrao(request.titulo(), "Lembrete de agendamento"),
        textoOuPadrao(
            request.mensagem(),
            "Voce tem um agendamento em " + formatarDataHora(agendamento.getInicioEm()) + "."),
        request.agendadoPara(),
        null,
        StatusNotificacao.PENDENTE,
        agendamento,
        null);

    return NotificacaoEventoResponse.fromEntity(notificacaoEventoRepository.save(notificacao));
  }

  @Transactional(readOnly = true)
  public List<NotificacaoEventoResponse> listarTodas(Usuario usuario) {
    return notificacaoEventoRepository.findByUsuarioIdOrderByCriadoEmDescIdDesc(usuario.getId())
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public NotificacaoEventoResponse buscarPorId(Long id, Usuario usuario) {
    return NotificacaoEventoResponse.fromEntity(buscarNotificacaoDoUsuario(id, usuario));
  }

  @Transactional(readOnly = true)
  public List<NotificacaoEventoResponse> listarPorAgendamento(Long agendamentoId, Usuario usuario) {
    Agendamento agendamento = agendamentoRepository.findById(agendamentoId)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND, "Agendamento não encontrado"));

    if (!participaDoAgendamento(agendamento, usuario)) {
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Você não pode acessar notificações de um agendamento de outro usuário");
    }

    return notificacaoEventoRepository
        .findByUsuarioIdAndAgendamentoIdOrderByCriadoEmDescIdDesc(usuario.getId(), agendamentoId)
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<NotificacaoEventoResponse> listarPorStatus(StatusNotificacao status, Usuario usuario) {
    return notificacaoEventoRepository
        .findByUsuarioIdAndStatusOrderByCriadoEmDescIdDesc(usuario.getId(), status)
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<NotificacaoEventoResponse> listarPorCanal(CanalNotificacao canal, Usuario usuario) {
    return notificacaoEventoRepository
        .findByUsuarioIdAndCanalOrderByCriadoEmDescIdDesc(usuario.getId(), canal)
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }

  @Transactional(readOnly = true)
  public ContagemNotificacoesResponse contarNaoLidas(Usuario usuario) {
    return new ContagemNotificacoesResponse(
        notificacaoEventoRepository.countByUsuarioIdAndLidoEmIsNull(usuario.getId()));
  }

  @Transactional
  public NotificacaoEventoResponse marcarComoLida(Long id, Usuario usuario) {
    NotificacaoEvento notificacao = buscarNotificacaoDoUsuario(id, usuario);
    if (notificacao.getLidoEm() == null) {
      notificacao.setLidoEm(LocalDateTime.now());
    }
    return NotificacaoEventoResponse.fromEntity(notificacaoEventoRepository.save(notificacao));
  }

  @Transactional
  public List<NotificacaoEventoResponse> marcarTodasComoLidas(Usuario usuario) {
    LocalDateTime agora = LocalDateTime.now();
    List<NotificacaoEvento> notificacoes =
        notificacaoEventoRepository.findByUsuarioIdAndLidoEmIsNull(usuario.getId());

    notificacoes.forEach(notificacao -> notificacao.setLidoEm(agora));

    return notificacaoEventoRepository.saveAll(notificacoes)
        .stream()
        .map(NotificacaoEventoResponse::fromEntity)
        .toList();
  }

  @Transactional
  public NotificacaoPreferenciasResponse obterPreferencias(Usuario usuario) {
    return NotificacaoPreferenciasResponse.fromEntity(preferenciasDoUsuario(usuario));
  }

  @Transactional
  public NotificacaoPreferenciasResponse atualizarPreferencias(
      UpdateNotificacaoPreferenciasRequest request,
      Usuario usuario) {
    NotificacaoPreferencia preferencias = preferenciasDoUsuario(usuario);
    preferencias.setAgendamentos(request.agendamentos());
    preferencias.setMensagens(request.mensagens());
    preferencias.setPromocoes(request.promocoes());
    preferencias.setNovidades(request.novidades());
    preferencias.setResumoEmail(request.resumoEmail());
    return NotificacaoPreferenciasResponse.fromEntity(
        notificacaoPreferenciaRepository.save(preferencias));
  }

  @Transactional
  public void registrarAgendamentoCriado(Agendamento agendamento) {
    criarAutomatica(
        agendamento.getCliente(),
        TipoNotificacao.AGENDAMENTO,
        "Agendamento solicitado",
        "Seu horario para " + agendamento.getServico().getNome() + " foi solicitado para "
            + formatarDataHora(agendamento.getInicioEm()) + ".",
        agendamento,
        null);

    criarAutomatica(
        agendamento.getPrestador(),
        TipoNotificacao.AGENDAMENTO,
        "Novo agendamento",
        agendamento.getCliente().getNome() + " solicitou " + agendamento.getServico().getNome()
            + " para " + formatarDataHora(agendamento.getInicioEm()) + ".",
        agendamento,
        null);
  }

  @Transactional
  public void registrarAgendamentoCancelado(Agendamento agendamento, Usuario autor) {
    Usuario outroParticipante = agendamento.getCliente().getId().equals(autor.getId())
        ? agendamento.getPrestador()
        : agendamento.getCliente();

    criarAutomatica(
        autor,
        TipoNotificacao.AGENDAMENTO,
        "Agendamento cancelado",
        "Voce cancelou o horario de " + agendamento.getServico().getNome() + " em "
            + formatarDataHora(agendamento.getInicioEm()) + ".",
        agendamento,
        null);

    criarAutomatica(
        outroParticipante,
        TipoNotificacao.AGENDAMENTO,
        "Agendamento cancelado",
        autor.getNome() + " cancelou o horario de " + agendamento.getServico().getNome()
            + " em " + formatarDataHora(agendamento.getInicioEm()) + ".",
        agendamento,
        null);
  }

  @Transactional
  public void registrarAgendamentoConfirmado(Agendamento agendamento) {
    criarAutomatica(
        agendamento.getCliente(),
        TipoNotificacao.AGENDAMENTO,
        "Agendamento confirmado",
        agendamento.getPrestador().getNome() + " confirmou seu horario de "
            + agendamento.getServico().getNome() + " em "
            + formatarDataHora(agendamento.getInicioEm()) + ".",
        agendamento,
        null);
  }

  @Transactional
  public void registrarAgendamentoConcluido(Agendamento agendamento) {
    criarAutomatica(
        agendamento.getCliente(),
        TipoNotificacao.AGENDAMENTO,
        "Atendimento concluido",
        "Seu atendimento com " + agendamento.getPrestador().getNome()
            + " foi concluido. Voce ja pode avaliar a experiencia.",
        agendamento,
        null);
  }

  @Transactional
  public void registrarMensagem(ChatConversa conversa, Usuario remetente, String conteudo) {
    Usuario destinatario = conversa.getCliente().getId().equals(remetente.getId())
        ? conversa.getPrestador()
        : conversa.getCliente();

    criarAutomatica(
        destinatario,
        TipoNotificacao.MENSAGEM,
        "Nova mensagem de " + remetente.getNome(),
        preview(conteudo),
        null,
        conversa);
  }

  private NotificacaoEvento buscarNotificacaoDoUsuario(Long id, Usuario usuario) {
    return notificacaoEventoRepository.findByIdAndUsuarioId(id, usuario.getId())
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND,
            "Notificação não encontrada"));
  }

  private NotificacaoPreferencia preferenciasDoUsuario(Usuario usuario) {
    return notificacaoPreferenciaRepository.findByUsuarioId(usuario.getId())
        .orElseGet(() -> {
          NotificacaoPreferencia preferencias = new NotificacaoPreferencia();
          preferencias.setUsuario(usuario);
          return notificacaoPreferenciaRepository.save(preferencias);
        });
  }

  private void criarAutomatica(
      Usuario usuario,
      TipoNotificacao tipo,
      String titulo,
      String mensagem,
      Agendamento agendamento,
      ChatConversa conversa) {
    if (!preferenciaPermite(usuario, tipo)) {
      return;
    }

    LocalDateTime agora = LocalDateTime.now();
    NotificacaoEvento notificacao = criarEventoBase(
        usuario,
        tipo,
        CanalNotificacao.APP,
        titulo,
        mensagem,
        agora,
        agora,
        StatusNotificacao.ENVIADO,
        agendamento,
        conversa);
    notificacaoEventoRepository.save(notificacao);
  }

  private NotificacaoEvento criarEventoBase(
      Usuario usuario,
      TipoNotificacao tipo,
      CanalNotificacao canal,
      String titulo,
      String mensagem,
      LocalDateTime agendadoPara,
      LocalDateTime enviadoEm,
      StatusNotificacao status,
      Agendamento agendamento,
      ChatConversa conversa) {
    NotificacaoEvento notificacao = new NotificacaoEvento();
    notificacao.setUsuario(usuario);
    notificacao.setTipo(tipo);
    notificacao.setCanal(canal);
    notificacao.setTitulo(titulo.trim());
    notificacao.setMensagem(mensagem.trim());
    notificacao.setAgendadoPara(agendadoPara);
    notificacao.setEnviadoEm(enviadoEm);
    notificacao.setStatus(status);
    notificacao.setAgendamento(agendamento);
    notificacao.setChatConversa(conversa);
    return notificacao;
  }

  private boolean preferenciaPermite(Usuario usuario, TipoNotificacao tipo) {
    NotificacaoPreferencia preferencias = preferenciasDoUsuario(usuario);
    return switch (tipo) {
      case AGENDAMENTO -> Boolean.TRUE.equals(preferencias.getAgendamentos());
      case MENSAGEM -> Boolean.TRUE.equals(preferencias.getMensagens());
      case PROMOCAO -> Boolean.TRUE.equals(preferencias.getPromocoes());
      case SISTEMA -> true;
    };
  }

  private boolean participaDoAgendamento(Agendamento agendamento, Usuario usuario) {
    return agendamento.getCliente().getId().equals(usuario.getId())
        || agendamento.getPrestador().getId().equals(usuario.getId());
  }

  private String textoOuPadrao(String valor, String padrao) {
    if (valor == null || valor.trim().isEmpty()) {
      return padrao;
    }
    return valor.trim();
  }

  private String preview(String conteudo) {
    String texto = conteudo == null ? "" : conteudo.trim();
    if (texto.length() <= LIMITE_PREVIEW_MENSAGEM) {
      return texto;
    }
    return texto.substring(0, LIMITE_PREVIEW_MENSAGEM - 3) + "...";
  }

  private String formatarDataHora(LocalDateTime dataHora) {
    return dataHora.format(DATA_HORA_FORMATTER);
  }
}
