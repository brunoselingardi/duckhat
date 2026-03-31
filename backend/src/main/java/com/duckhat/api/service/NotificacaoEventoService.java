package com.duckhat.api.service;

import com.duckhat.api.dto.CreateNotificacaoEventoRequest;
import com.duckhat.api.dto.NotificacaoEventoResponse;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.NotificacaoEvento;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.NotificacaoEventoRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Set;

@Service
public class NotificacaoEventoService {

    private static final Set<String> CANAIS_VALIDOS = Set.of("APP", "EMAIL", "SMS");
    private static final Set<String> STATUS_VALIDOS = Set.of("PENDENTE", "ENVIADO", "FALHA");

    private final NotificacaoEventoRepository notificacaoEventoRepository;
    private final AgendamentoRepository agendamentoRepository;

    public NotificacaoEventoService(NotificacaoEventoRepository notificacaoEventoRepository,
                                    AgendamentoRepository agendamentoRepository) {
        this.notificacaoEventoRepository = notificacaoEventoRepository;
        this.agendamentoRepository = agendamentoRepository;
    }

    @Transactional
    public NotificacaoEventoResponse criar(CreateNotificacaoEventoRequest request) {
        Agendamento agendamento = agendamentoRepository.findById(request.agendamentoId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Agendamento não encontrado"
                ));

        if (!CANAIS_VALIDOS.contains(request.canal())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Canal inválido. Use APP, EMAIL ou SMS"
            );
        }

        if (!STATUS_VALIDOS.contains(request.status())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Status inválido. Use PENDENTE, ENVIADO ou FALHA"
            );
        }

        NotificacaoEvento notificacaoEvento = new NotificacaoEvento();
        notificacaoEvento.setAgendamento(agendamento);
        notificacaoEvento.setCanal(request.canal());
        notificacaoEvento.setAgendadoPara(request.agendadoPara());
        notificacaoEvento.setEnviadoEm(request.enviadoEm());
        notificacaoEvento.setStatus(request.status());

        NotificacaoEvento salva = notificacaoEventoRepository.save(notificacaoEvento);
        return NotificacaoEventoResponse.fromEntity(salva);
    }

    @Transactional(readOnly = true)
    public List<NotificacaoEventoResponse> listarTodas() {
        return notificacaoEventoRepository.findAll()
                .stream()
                .map(NotificacaoEventoResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public NotificacaoEventoResponse buscarPorId(Long id) {
        NotificacaoEvento notificacaoEvento = notificacaoEventoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Notificação não encontrada"
                ));

        return NotificacaoEventoResponse.fromEntity(notificacaoEvento);
    }

    @Transactional(readOnly = true)
    public List<NotificacaoEventoResponse> listarPorAgendamento(Long agendamentoId) {
        return notificacaoEventoRepository.findByAgendamentoId(agendamentoId)
                .stream()
                .map(NotificacaoEventoResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<NotificacaoEventoResponse> listarPorStatus(String status) {
        return notificacaoEventoRepository.findByStatus(status)
                .stream()
                .map(NotificacaoEventoResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<NotificacaoEventoResponse> listarPorCanal(String canal) {
        return notificacaoEventoRepository.findByCanal(canal)
                .stream()
                .map(NotificacaoEventoResponse::fromEntity)
                .toList();
    }
}
