package com.duckhat.api.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "recuperacao_senha_tokens")
public class RecuperacaoSenhaToken {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "usuario_id", nullable = false)
  private Usuario usuario;

  @Column(nullable = false, length = 12)
  private String codigo;

  @Column(name = "expira_em", nullable = false)
  private LocalDateTime expiraEm;

  @Column(name = "usado_em")
  private LocalDateTime usadoEm;

  @Column(name = "criado_em", insertable = false, updatable = false)
  private LocalDateTime criadoEm;

  public Long getId() {
    return id;
  }

  public Usuario getUsuario() {
    return usuario;
  }

  public String getCodigo() {
    return codigo;
  }

  public LocalDateTime getExpiraEm() {
    return expiraEm;
  }

  public LocalDateTime getUsadoEm() {
    return usadoEm;
  }

  public LocalDateTime getCriadoEm() {
    return criadoEm;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public void setUsuario(Usuario usuario) {
    this.usuario = usuario;
  }

  public void setCodigo(String codigo) {
    this.codigo = codigo;
  }

  public void setExpiraEm(LocalDateTime expiraEm) {
    this.expiraEm = expiraEm;
  }

  public void setUsadoEm(LocalDateTime usadoEm) {
    this.usadoEm = usadoEm;
  }

  public void setCriadoEm(LocalDateTime criadoEm) {
    this.criadoEm = criadoEm;
  }
}
