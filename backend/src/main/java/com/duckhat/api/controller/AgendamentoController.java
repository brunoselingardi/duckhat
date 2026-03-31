package com.duckhat.api.controller;

import com.duckhat.api.dto.AgendamentoResponse;
import com.duckhat.api.dto.CreateAgendamentoRequest;
import com.duckhat.api.service.AgendamentoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agendamentos")
public class AgendamentoController {

    private final AgendamentoService agendamentoService;

    public AgendamentoController(AgendamentoService agendamentoService) {
        this.agendamentoService = agendamentoService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public AgendamentoResponse criar(@Valid @RequestBody CreateAgendamentoRequest request) {
        return agendamentoService.criar(request);
    }

    @GetMapping
    public List<AgendamentoResponse> listarTodos() {
        return agendamentoService.listarTodos();
    }

    @GetMapping("/{id}")
    public AgendamentoResponse buscarPorId(@PathVariable Long id) {
        return agendamentoService.buscarPorId(id);
    }

    @GetMapping("/cliente/{clienteId}")
    public List<AgendamentoResponse> listarPorCliente(@PathVariable Long clienteId) {
        return agendamentoService.listarPorCliente(clienteId);
    }

    @GetMapping("/servico/{servicoId}")
    public List<AgendamentoResponse> listarPorServico(@PathVariable Long servicoId) {
        return agendamentoService.listarPorServico(servicoId);
    }

    @GetMapping("/status/{status}")
    public List<AgendamentoResponse> listarPorStatus(@PathVariable String status) {
        return agendamentoService.listarPorStatus(status);
    }
}
