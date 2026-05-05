package com.duckhat.api.entity;

import com.duckhat.api.entity.enums.CanalNotificacao;
import com.duckhat.api.entity.enums.StatusNotificacao;
import com.duckhat.api.entity.enums.TipoNotificacao;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notificacao_eventos")
public class NotificacaoEvento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agendamento_id")
    private Agendamento agendamento;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chat_conversa_id")
    private ChatConversa chatConversa;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoNotificacao tipo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CanalNotificacao canal;

    @Column(nullable = false, length = 120)
    private String titulo;

    @Column(nullable = false, length = 500)
    private String mensagem;

    @Column(name = "criado_em", insertable = false, updatable = false)
    private LocalDateTime criadoEm;

    @Column(name = "agendado_para", nullable = false)
    private LocalDateTime agendadoPara;

    @Column(name = "enviado_em")
    private LocalDateTime enviadoEm;

    @Column(name = "lido_em")
    private LocalDateTime lidoEm;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusNotificacao status;

    public NotificacaoEvento() {
    }

    public Long getId() {
        return id;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public Agendamento getAgendamento() {
        return agendamento;
    }

    public ChatConversa getChatConversa() {
        return chatConversa;
    }

    public TipoNotificacao getTipo() {
        return tipo;
    }

    public CanalNotificacao getCanal() {
        return canal;
    }

    public String getTitulo() {
        return titulo;
    }

    public String getMensagem() {
        return mensagem;
    }

    public LocalDateTime getCriadoEm() {
        return criadoEm;
    }

    public LocalDateTime getAgendadoPara() {
        return agendadoPara;
    }

    public LocalDateTime getEnviadoEm() {
        return enviadoEm;
    }

    public LocalDateTime getLidoEm() {
        return lidoEm;
    }

    public StatusNotificacao getStatus() {
        return status;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    public void setAgendamento(Agendamento agendamento) {
        this.agendamento = agendamento;
    }

    public void setChatConversa(ChatConversa chatConversa) {
        this.chatConversa = chatConversa;
    }

    public void setTipo(TipoNotificacao tipo) {
        this.tipo = tipo;
    }

    public void setCanal(CanalNotificacao canal) {
        this.canal = canal;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }

    public void setCriadoEm(LocalDateTime criadoEm) {
        this.criadoEm = criadoEm;
    }

    public void setAgendadoPara(LocalDateTime agendadoPara) {
        this.agendadoPara = agendadoPara;
    }

    public void setEnviadoEm(LocalDateTime enviadoEm) {
        this.enviadoEm = enviadoEm;
    }

    public void setLidoEm(LocalDateTime lidoEm) {
        this.lidoEm = lidoEm;
    }

    public void setStatus(StatusNotificacao status) {
        this.status = status;
    }
}
