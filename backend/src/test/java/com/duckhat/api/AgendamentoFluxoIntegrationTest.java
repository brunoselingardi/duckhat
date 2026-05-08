package com.duckhat.api;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

import com.duckhat.api.dto.AgendamentoResponse;
import com.duckhat.api.dto.CreateAgendamentoRequest;
import com.duckhat.api.dto.CreateServicoRequest;
import com.duckhat.api.dto.CreateUsuarioRequest;
import com.duckhat.api.dto.ServicoResponse;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.entity.enums.StatusAgendamento;
import com.duckhat.api.entity.enums.TipoUsuario;
import com.duckhat.api.repository.DisponibilidadeRepository;
import com.duckhat.api.repository.UsuarioRepository;
import com.duckhat.api.service.AgendamentoService;
import com.duckhat.api.service.ServicoService;
import com.duckhat.api.service.UsuarioService;
import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AgendamentoFluxoIntegrationTest {

  @Autowired
  private UsuarioService usuarioService;

  @Autowired
  private ServicoService servicoService;

  @Autowired
  private AgendamentoService agendamentoService;

  @Autowired
  private UsuarioRepository usuarioRepository;

  @Autowired
  private DisponibilidadeRepository disponibilidadeRepository;

  @Test
  void novoPrestadorComServicoNovoConsegueReceberAgendamento() {
    usuarioService.criar(new CreateUsuarioRequest(
        "Studio Agenda",
        "studio.agenda@duckhat.test",
        "123456",
        "62999998888",
        "11.222.333/0001-44",
        "Ana Responsavel",
        TipoUsuario.PRESTADOR));
    Usuario prestador = usuarioRepository.findByEmail("studio.agenda@duckhat.test")
        .orElseThrow();

    ServicoResponse servico = servicoService.criar(
        new CreateServicoRequest(
            "Corte agenda",
            "Servico usado para validar agendamento de prestador novo",
            30,
            new BigDecimal("45.00"),
            true),
        prestador);

    usuarioService.criar(new CreateUsuarioRequest(
        "Cliente Agenda",
        "cliente.agenda@duckhat.test",
        "123456",
        "62999997777",
        null,
        null,
        TipoUsuario.CLIENTE));
    Usuario cliente = usuarioRepository.findByEmail("cliente.agenda@duckhat.test")
        .orElseThrow();

    LocalDateTime inicio = proximoDiaUtilAs10h();
    assertFalse(disponibilidadeRepository
        .findByPrestadorIdAndDiaSemanaAndAtivoTrue(
            prestador.getId(),
            (byte) inicio.getDayOfWeek().getValue())
        .isEmpty());

    AgendamentoResponse agendamento = agendamentoService.criar(
        new CreateAgendamentoRequest(
            servico.id(),
            inicio,
            inicio.plusMinutes(30),
            "Fluxo de regressao"),
        cliente);

    assertEquals(prestador.getId(), agendamento.prestadorId());
    assertEquals(cliente.getId(), agendamento.clienteId());
    assertEquals(servico.id(), agendamento.servicoId());
    assertEquals(StatusAgendamento.PENDENTE, agendamento.status());
  }

  private LocalDateTime proximoDiaUtilAs10h() {
    LocalDate date = LocalDate.now();
    int daysUntilMonday = (DayOfWeek.MONDAY.getValue() - date.getDayOfWeek().getValue() + 7) % 7;
    if (daysUntilMonday == 0 && LocalTime.now().isAfter(LocalTime.of(9, 59))) {
      daysUntilMonday = 7;
    }
    return date.plusDays(daysUntilMonday).atTime(10, 0);
  }
}
