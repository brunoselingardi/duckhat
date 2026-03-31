package com.duckhat.api.service;

import com.duckhat.api.dto.AvaliacaoResponse;
import com.duckhat.api.dto.CreateAvaliacaoRequest;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.Avaliacao;
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
    public AvaliacaoResponse criar(CreateAvaliacaoRequest request) {
        Agendamento agendamento = agendamentoRepository.findById(request.agendamentoId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Agendamento não encontrado"
                ));

        if (avaliacaoRepository.existsByAgendamentoId(request.agendamentoId())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Esse agendamento já possui avaliação"
            );
        }

        Avaliacao avaliacao = new Avaliacao();
        avaliacao.setAgendamento(agendamento);
        avaliacao.setNota(request.nota());
        avaliacao.setComentario(request.comentario());

        Avaliacao salva = avaliacaoRepository.save(avaliacao);
        return AvaliacaoResponse.fromEntity(salva);
    }

    @Transactional(readOnly = true)
    public List<AvaliacaoResponse> listarTodas() {
        return avaliacaoRepository.findAll()
                .stream()
                .map(AvaliacaoResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public AvaliacaoResponse buscarPorId(Long id) {
        Avaliacao avaliacao = avaliacaoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Avaliação não encontrada"
                ));

        return AvaliacaoResponse.fromEntity(avaliacao);
    }

    @Transactional(readOnly = true)
    public AvaliacaoResponse buscarPorAgendamento(Long agendamentoId) {
        Avaliacao avaliacao = avaliacaoRepository.findByAgendamentoId(agendamentoId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Avaliação não encontrada para esse agendamento"
                ));

        return AvaliacaoResponse.fromEntity(avaliacao);
    }
}
