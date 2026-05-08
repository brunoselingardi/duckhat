package com.duckhat.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PostLoad;
import jakarta.persistence.PostPersist;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.time.LocalDateTime;
import org.springframework.data.domain.Persistable;

@Entity
@Table(name = "notificacao_preferencias")
public class NotificacaoPreferencia implements Persistable<Long> {

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

    @Transient
    private boolean novo = true;

    @Override
    public Long getId() {
        return usuarioId;
    }

    @Override
    public boolean isNew() {
        return novo;
    }

    @PostLoad
    @PostPersist
    void marcarComoPersistido() {
        this.novo = false;
    }

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
