package com.duckhat.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "chat_conversas",
    uniqueConstraints = @UniqueConstraint(
        name = "uq_chat_conversas_cliente_prestador",
        columnNames = {"cliente_id", "prestador_id"}))
public class ChatConversa {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "cliente_id", nullable = false)
  private Usuario cliente;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "prestador_id", nullable = false)
  private Usuario prestador;

  @Column(name = "ultima_mensagem_em")
  private LocalDateTime ultimaMensagemEm;

  @Column(name = "criado_em", insertable = false, updatable = false)
  private LocalDateTime criadoEm;

  @Column(name = "atualizado_em", insertable = false)
  private LocalDateTime atualizadoEm;

  public Long getId() {
    return id;
  }

  public Usuario getCliente() {
    return cliente;
  }

  public Usuario getPrestador() {
    return prestador;
  }

  public LocalDateTime getUltimaMensagemEm() {
    return ultimaMensagemEm;
  }

  public LocalDateTime getCriadoEm() {
    return criadoEm;
  }

  public LocalDateTime getAtualizadoEm() {
    return atualizadoEm;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public void setCliente(Usuario cliente) {
    this.cliente = cliente;
  }

  public void setPrestador(Usuario prestador) {
    this.prestador = prestador;
  }

  public void setUltimaMensagemEm(LocalDateTime ultimaMensagemEm) {
    this.ultimaMensagemEm = ultimaMensagemEm;
  }

  public void setCriadoEm(LocalDateTime criadoEm) {
    this.criadoEm = criadoEm;
  }

  public void setAtualizadoEm(LocalDateTime atualizadoEm) {
    this.atualizadoEm = atualizadoEm;
  }
}
