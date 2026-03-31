package com.duckhat.api.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notificacao_eventos")
public class NotificacaoEvento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "agendamento_id", nullable = false)
    private Agendamento agendamento;

    @Column(nullable = false, length = 10)
    private String canal;

    @Column(name = "agendado_para", nullable = false)
    private LocalDateTime agendadoPara;

    @Column(name = "enviado_em")
    private LocalDateTime enviadoEm;

    @Column(nullable = false, length = 10)
    private String status;

    public NotificacaoEvento() {
    }

    public Long getId() {
        return id;
    }

    public Agendamento getAgendamento() {
        return agendamento;
    }

    public String getCanal() {
        return canal;
    }

    public LocalDateTime getAgendadoPara() {
        return agendadoPara;
    }

    public LocalDateTime getEnviadoEm() {
        return enviadoEm;
    }

    public String getStatus() {
        return status;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setAgendamento(Agendamento agendamento) {
        this.agendamento = agendamento;
    }

    public void setCanal(String canal) {
        this.canal = canal;
    }

    public void setAgendadoPara(LocalDateTime agendadoPara) {
        this.agendadoPara = agendadoPara;
    }

    public void setEnviadoEm(LocalDateTime enviadoEm) {
        this.enviadoEm = enviadoEm;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
