package com.duckhat.api.service;

import com.duckhat.api.entity.Usuario;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;

@Service
public class JwtService {

  @Value("${jwt.secret}")
  private String secret;

  @Value("${jwt.expiration}")
  private long expiration;

  public String gerarToken(Usuario usuario) {
    Date agora = new Date();
    Date expiracao = new Date(agora.getTime() + expiration);

    return Jwts.builder()
        .subject(usuario.getEmail())
        .claim("userId", usuario.getId())
        .claim("nome", usuario.getNome())
        .claim("tipo", usuario.getTipo().name())
        .issuedAt(agora)
        .expiration(expiracao)
        .signWith(getSigningKey())
        .compact();
  }

  public String extrairEmail(String token) {
    return extrairClaims(token).getSubject();
  }

  public Long extrairUsuarioId(String token) {
    Object userId = extrairClaims(token).get("userId");
    if (userId == null) {
      return null;
    }
    if (userId instanceof Number number) {
      return number.longValue();
    }
    return Long.parseLong(userId.toString());
  }

  public boolean tokenValido(String token, Usuario usuario) {
    Long usuarioId = extrairUsuarioId(token);
    if (usuarioId != null) {
      return usuarioId.equals(usuario.getId()) && !tokenExpirado(token);
    }
    String email = extrairEmail(token);
    return email.equals(usuario.getEmail()) && !tokenExpirado(token);
  }

  private boolean tokenExpirado(String token) {
    return extrairClaims(token).getExpiration().before(new Date());
  }

  private Claims extrairClaims(String token) {
    return Jwts.parser()
        .verifyWith(getSigningKey())
        .build()
        .parseSignedClaims(token)
        .getPayload();
  }

  private SecretKey getSigningKey() {
    byte[] keyBytes = Decoders.BASE64.decode(secret);
    return Keys.hmacShaKeyFor(keyBytes);
  }
}
