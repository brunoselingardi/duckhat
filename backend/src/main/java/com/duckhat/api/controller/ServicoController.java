package com.duckhat.api.controller;

import com.duckhat.api.dto.CreateServicoRequest;
import com.duckhat.api.dto.ServicoResponse;
import com.duckhat.api.service.ServicoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/servicos")
public class ServicoController {

    private final ServicoService servicoService;

    public ServicoController(ServicoService servicoService) {
        this.servicoService = servicoService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ServicoResponse criar(@Valid @RequestBody CreateServicoRequest request) {
        return servicoService.criar(request);
    }

    @GetMapping
    public List<ServicoResponse> listarTodos() {
        return servicoService.listarTodos();
    }

    @GetMapping("/ativos")
    public List<ServicoResponse> listarAtivos() {
        return servicoService.listarAtivos();
    }

    @GetMapping("/{id}")
    public ServicoResponse buscarPorId(@PathVariable Long id) {
        return servicoService.buscarPorId(id);
    }

    @GetMapping("/prestador/{prestadorId}")
    public List<ServicoResponse> listarPorPrestador(@PathVariable Long prestadorId) {
        return servicoService.listarPorPrestador(prestadorId);
    }
}
