package com.duckhat.api.service;

import com.duckhat.api.dto.AgendamentoResponse;
import com.duckhat.api.dto.CreateAgendamentoRequest;
import com.duckhat.api.entity.Agendamento;
import com.duckhat.api.entity.Servico;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.AgendamentoRepository;
import com.duckhat.api.repository.ServicoRepository;
import com.duckhat.api.repository.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.duckhat.api.entity.enums.StatusAgendamento;
import java.util.List;

@Service
public class AgendamentoService {

    private final AgendamentoRepository agendamentoRepository;
    private final UsuarioRepository usuarioRepository;
    private final ServicoRepository servicoRepository;

    public AgendamentoService(AgendamentoRepository agendamentoRepository,
                              UsuarioRepository usuarioRepository,
                              ServicoRepository servicoRepository) {
        this.agendamentoRepository = agendamentoRepository;
        this.usuarioRepository = usuarioRepository;
        this.servicoRepository = servicoRepository;
    }

    @Transactional
    public AgendamentoResponse criar(CreateAgendamentoRequest request) {
        Usuario cliente = usuarioRepository.findById(request.clienteId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Cliente não encontrado"
                ));

        if (cliente.getTipo() != TipoUsuario.CLIENTE) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "O usuário informado não é um cliente"
            );
        }

        Servico servico = servicoRepository.findById(request.servicoId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Serviço não encontrado"
                ));

        if (!Boolean.TRUE.equals(servico.getAtivo())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "O serviço informado está inativo"
            );
        }

        if (!request.inicioEm().isBefore(request.fimEm())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "inicioEm deve ser menor que fimEm"
            );
        }

        Agendamento agendamento = new Agendamento();
        agendamento.setCliente(cliente);
        agendamento.setPrestador(servico.getPrestador());
        agendamento.setServico(servico);
        agendamento.setInicioEm(request.inicioEm());
        agendamento.setFimEm(request.fimEm());
        agendamento.setStatus(request.status());
        agendamento.setObservacoes(request.observacoes());

        Agendamento salvo = agendamentoRepository.save(agendamento);
        return AgendamentoResponse.fromEntity(salvo);
    }

    @Transactional(readOnly = true)
    public List<AgendamentoResponse> listarTodos() {
        return agendamentoRepository.findAll()
                .stream()
                .map(AgendamentoResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AgendamentoResponse> listarPorCliente(Long clienteId) {
        return agendamentoRepository.findByClienteId(clienteId)
                .stream()
                .map(AgendamentoResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AgendamentoResponse> listarPorServico(Long servicoId) {
        return agendamentoRepository.findByServicoId(servicoId)
                .stream()
                .map(AgendamentoResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AgendamentoResponse> listarPorStatus(StatusAgendamento status) {
         return agendamentoRepository.findByStatus(status)
            .stream()
            .map(AgendamentoResponse::fromEntity)
            .toList();
    } 

    @Transactional(readOnly = true)
    public AgendamentoResponse buscarPorId(Long id) {
        Agendamento agendamento = agendamentoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Agendamento não encontrado"
                ));

        return AgendamentoResponse.fromEntity(agendamento);
    }
}
