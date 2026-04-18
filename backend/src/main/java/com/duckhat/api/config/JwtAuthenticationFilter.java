package com.duckhat.api.config;

import java.util.List;
import com.duckhat.api.entity.Usuario;
import com.duckhat.api.repository.UsuarioRepository;
import com.duckhat.api.service.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

import org.springframework.security.core.authority.SimpleGrantedAuthority;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

  private final JwtService jwtService;
  private final UsuarioRepository usuarioRepository;

  public JwtAuthenticationFilter(JwtService jwtService, UsuarioRepository usuarioRepository) {
    this.jwtService = jwtService;
    this.usuarioRepository = usuarioRepository;
  }

  @Override
  protected void doFilterInternal(HttpServletRequest request,
      HttpServletResponse response,
      FilterChain filterChain) throws ServletException, IOException {

    String authHeader = request.getHeader("Authorization");

    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
      filterChain.doFilter(request, response);
      return;
    }

    String token = authHeader.substring(7);
    String email = jwtService.extrairEmail(token);

    if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
      Usuario usuario = usuarioRepository.findByEmail(email).orElse(null);

      if (usuario != null && jwtService.tokenValido(token, usuario)) {
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
            usuario,
            null,
            List.of(new SimpleGrantedAuthority("ROLE_" + usuario.getTipo().name())));

        authentication.setDetails(
            new WebAuthenticationDetailsSource().buildDetails(request));

        SecurityContextHolder.getContext().setAuthentication(authentication);
      }
    }

    filterChain.doFilter(request, response);
  }
}
