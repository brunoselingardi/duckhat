package com.duckhat.api.entity;

import com.duckhat.api.entity.enums.CanalNotificacao;
import jakarta.persistence.*;

import java.time.LocalDateTime;
import com.duckhat.api.entity.enums.StatusNotificacao;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;@Entity

@Table(name = "notificacao_eventos")
public class NotificacaoEvento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "agendamento_id", nullable = false)
    private Agendamento agendamento;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CanalNotificacao canal;

    @Column(name = "agendado_para", nullable = false)
    private LocalDateTime agendadoPara;

    @Column(name = "enviado_em")
    private LocalDateTime enviadoEm;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusNotificacao status;

    public NotificacaoEvento() {
    }

    public Long getId() {
        return id;
    }

    public Agendamento getAgendamento() {
        return agendamento;
    }

    public CanalNotificacao getCanal() {
        return canal;
    }

    public LocalDateTime getAgendadoPara() {
        return agendadoPara;
    }

    public LocalDateTime getEnviadoEm() {
        return enviadoEm;
    }
    public StatusNotificacao getStatus() {
        return status;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public void setAgendamento(Agendamento agendamento) {
        this.agendamento = agendamento;
    }

    public void setCanal(CanalNotificacao canal) {
        this.canal = canal;
    }

    public void setAgendadoPara(LocalDateTime agendadoPara) {
        this.agendadoPara = agendadoPara;
    }

    public void setEnviadoEm(LocalDateTime enviadoEm) {
        this.enviadoEm = enviadoEm;
    }

    public void setStatus(StatusNotificacao status) {
        this.status = status;
    }
}
