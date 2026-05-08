package com.duckhat.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
public class SecurityConfig {

  private final JwtAuthenticationFilter jwtAuthenticationFilter;

  public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
    this.jwtAuthenticationFilter = jwtAuthenticationFilter;
  }

  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .csrf(AbstractHttpConfigurer::disable)
        .cors(cors -> cors.configurationSource(corsConfigurationSource()))
        .httpBasic(AbstractHttpConfigurer::disable)
        .formLogin(AbstractHttpConfigurer::disable)
        .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/auth/**").permitAll()
            .requestMatchers("/api/health").permitAll()
            .requestMatchers("/api/catalogo/**").permitAll()

            .requestMatchers(HttpMethod.POST, "/api/usuarios").permitAll()
            .requestMatchers("/api/usuarios/**").denyAll()

            .requestMatchers("/api/servicos/**").hasRole("PRESTADOR")
            .requestMatchers("/api/disponibilidades/**").hasRole("PRESTADOR")

            .requestMatchers(HttpMethod.GET, "/api/agendamentos/prestador").hasRole("PRESTADOR")
            .requestMatchers(HttpMethod.PATCH, "/api/agendamentos/{id}/confirmar").hasRole("PRESTADOR")
            .requestMatchers(HttpMethod.PATCH, "/api/agendamentos/{id}/concluir").hasRole("PRESTADOR")
            .requestMatchers("/api/agendamentos/**").hasRole("CLIENTE")
            .requestMatchers("/api/avaliacoes/**").hasRole("CLIENTE")
            .requestMatchers("/api/chat/**").hasAnyRole("CLIENTE", "PRESTADOR")
            .requestMatchers("/api/notificacoes", "/api/notificacoes/**").hasAnyRole("CLIENTE", "PRESTADOR")

            .anyRequest().authenticated())
        .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

    return http.build();
  }

  @Bean
  public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOriginPatterns(List.of(
        "http://localhost:*",
        "http://127.0.0.1:*"
    ));
    configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(List.of("*"));
    configuration.setAllowCredentials(false);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/api/**", configuration);
    return source;
  }
}
