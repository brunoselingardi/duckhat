package com.duckhat.api.controller;

import com.duckhat.api.dto.AvaliacaoResponse;
import com.duckhat.api.dto.CreateAvaliacaoRequest;
import com.duckhat.api.service.AvaliacaoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/avaliacoes")
public class AvaliacaoController {

    private final AvaliacaoService avaliacaoService;

    public AvaliacaoController(AvaliacaoService avaliacaoService) {
        this.avaliacaoService = avaliacaoService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public AvaliacaoResponse criar(@Valid @RequestBody CreateAvaliacaoRequest request) {
        return avaliacaoService.criar(request);
    }

    @GetMapping
    public List<AvaliacaoResponse> listarTodas() {
        return avaliacaoService.listarTodas();
    }

    @GetMapping("/{id}")
    public AvaliacaoResponse buscarPorId(@PathVariable Long id) {
        return avaliacaoService.buscarPorId(id);
    }

    @GetMapping("/agendamento/{agendamentoId}")
    public AvaliacaoResponse buscarPorAgendamento(@PathVariable Long agendamentoId) {
        return avaliacaoService.buscarPorAgendamento(agendamentoId);
    }
}
