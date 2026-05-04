package com.duckhat.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "notificacao_preferencias")
public class NotificacaoPreferencia {

    @Id
    @Column(name = "usuario_id")
    private Long usuarioId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Column(nullable = false)
    private Boolean agendamentos = true;

    @Column(nullable = false)
    private Boolean mensagens = true;

    @Column(nullable = false)
    private Boolean promocoes = true;

    @Column(nullable = false)
    private Boolean novidades = false;

    @Column(name = "resumo_email", nullable = false)
    private Boolean resumoEmail = true;

    @Column(name = "atualizado_em", insertable = false, updatable = false)
    private LocalDateTime atualizadoEm;

    public Long getUsuarioId() {
        return usuarioId;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public Boolean getAgendamentos() {
        return agendamentos;
    }

    public Boolean getMensagens() {
        return mensagens;
    }

    public Boolean getPromocoes() {
        return promocoes;
    }

    public Boolean getNovidades() {
        return novidades;
    }

    public Boolean getResumoEmail() {
        return resumoEmail;
    }

    public LocalDateTime getAtualizadoEm() {
        return atualizadoEm;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
        this.usuarioId = usuario == null ? null : usuario.getId();
    }

    public void setAgendamentos(Boolean agendamentos) {
        this.agendamentos = agendamentos;
    }

    public void setMensagens(Boolean mensagens) {
        this.mensagens = mensagens;
    }

    public void setPromocoes(Boolean promocoes) {
        this.promocoes = promocoes;
    }

    public void setNovidades(Boolean novidades) {
        this.novidades = novidades;
    }

    public void setResumoEmail(Boolean resumoEmail) {
        this.resumoEmail = resumoEmail;
    }
}
