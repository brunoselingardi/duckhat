package com.duckhat.api.controller;

import com.duckhat.api.dto.CreateNotificacaoEventoRequest;
import com.duckhat.api.dto.NotificacaoEventoResponse;
import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.service.NotificacaoEventoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notificacoes")
public class NotificacaoEventoController {

    private final NotificacaoEventoService notificacaoEventoService;

    public NotificacaoEventoController(NotificacaoEventoService notificacaoEventoService) {
        this.notificacaoEventoService = notificacaoEventoService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public NotificacaoEventoResponse criar(@Valid @RequestBody CreateNotificacaoEventoRequest request) {
        return notificacaoEventoService.criar(request);
    }

    @GetMapping
    public List<NotificacaoEventoResponse> listarTodas() {
        return notificacaoEventoService.listarTodas();
    }

    @GetMapping("/{id}")
    public NotificacaoEventoResponse buscarPorId(@PathVariable Long id) {
        return notificacaoEventoService.buscarPorId(id);
    }

    @GetMapping("/agendamento/{agendamentoId}")
    public List<NotificacaoEventoResponse> listarPorAgendamento(@PathVariable Long agendamentoId) {
        return notificacaoEventoService.listarPorAgendamento(agendamentoId);
    }

    @GetMapping("/status/{status}")
    public List<NotificacaoEventoResponse> listarPorStatus(@PathVariable String status) {
        return notificacaoEventoService.listarPorStatus(status);
    }

    @GetMapping("/canal/{canal}")
    public List<NotificacaoEventoResponse> listarPorCanal(@PathVariable CanalNotificacao canal) {
        return notificacaoEventoService.listarPorCanal(canal);
    }
}
