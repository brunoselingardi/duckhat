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

import java.time.LocalDateTime;

@Entity
@Table(name = "chat_mensagens")
public class ChatMensagem {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "conversa_id", nullable = false)
  private ChatConversa conversa;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "remetente_id", nullable = false)
  private Usuario remetente;

  @Column(nullable = false, columnDefinition = "TEXT")
  private String conteudo;

  @Column(name = "criado_em", nullable = false)
  private LocalDateTime criadoEm;

  public Long getId() {
    return id;
  }

  public ChatConversa getConversa() {
    return conversa;
  }

  public Usuario getRemetente() {
    return remetente;
  }

  public String getConteudo() {
    return conteudo;
  }

  public LocalDateTime getCriadoEm() {
    return criadoEm;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public void setConversa(ChatConversa conversa) {
    this.conversa = conversa;
  }

  public void setRemetente(Usuario remetente) {
    this.remetente = remetente;
  }

  public void setConteudo(String conteudo) {
    this.conteudo = conteudo;
  }

  public void setCriadoEm(LocalDateTime criadoEm) {
    this.criadoEm = criadoEm;
  }
}
