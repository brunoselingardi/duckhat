package com.duckhat.api.service;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public final class EstabelecimentoCategoriaCatalog {

  private static final Map<String, Categoria> CATEGORIAS = Map.ofEntries(
      categoria("barbearia", "Barbearia", "barbeiro", "barba", "corte masculino", "barber"),
      categoria("salao_cabeleireiro", "Salão de cabelo", "cabeleireiro", "cabelo", "escova", "coloracao", "salon"),
      categoria("manicure", "Manicure e unhas", "unha", "unhas", "pedicure", "nail"),
      categoria("estetica_spa", "Estética e spa", "estetica", "spa", "limpeza de pele", "massagem"),
      categoria("encanador", "Encanador", "encanamento", "hidraulica", "vazamento", "cano", "pia"),
      categoria("eletricista", "Eletricista", "eletrica", "luz", "tomada", "fiacao", "chuveiro"),
      categoria("chaveiro", "Chaveiro", "chave", "fechadura", "porta", "copia de chave"),
      categoria("pedreiro", "Pedreiro", "obra", "reforma", "construcao", "alvenaria"),
      categoria("limpeza", "Limpeza", "faxina", "diarista", "higienizacao"),
      categoria("pets", "Pet care", "pet", "banho e tosa", "veterinario", "animal"),
      categoria("saude_bem_estar", "Saúde e bem-estar", "saude", "fisioterapia", "personal", "pilates"),
      categoria("aulas", "Aulas e mentoria", "aula", "professor", "reforco", "curso"),
      categoria("tecnologia", "Tecnologia", "informatica", "computador", "celular", "suporte"),
      categoria("automotivo", "Automotivo", "carro", "mecanico", "lava jato", "moto"),
      categoria("eventos", "Eventos", "fotografia", "buffet", "decoracao", "cerimonial"));

  private EstabelecimentoCategoriaCatalog() {
  }

  public static Set<String> codigos() {
    return CATEGORIAS.keySet();
  }

  public static boolean existe(String codigo) {
    return codigo != null && CATEGORIAS.containsKey(codigo);
  }

  public static String label(String codigo) {
    Categoria categoria = CATEGORIAS.get(codigo);
    return categoria == null ? null : categoria.label();
  }

  public static boolean combina(String codigo, String termoNormalizado) {
    if (codigo == null || termoNormalizado == null || termoNormalizado.isBlank()) {
      return false;
    }

    Categoria categoria = CATEGORIAS.get(codigo);
    if (categoria == null) {
      return contem(codigo, termoNormalizado);
    }

    if (contem(codigo, termoNormalizado) || contem(categoria.label(), termoNormalizado)) {
      return true;
    }

    return categoria.keywords().stream()
        .anyMatch(keyword -> contem(keyword, termoNormalizado) || contem(termoNormalizado, normalizar(keyword)));
  }

  public static String normalizar(String valor) {
    if (valor == null) {
      return null;
    }
    String semAcento = Normalizer.normalize(valor, Normalizer.Form.NFD)
        .replaceAll("\\p{M}", "");
    return semAcento
        .toLowerCase(Locale.ROOT)
        .replaceAll("[^a-z0-9]+", " ")
        .replaceAll("\\s+", " ")
        .trim();
  }

  private static boolean contem(String valor, String termoNormalizado) {
    String normalizado = normalizar(valor);
    return normalizado != null && normalizado.contains(termoNormalizado);
  }

  private static Map.Entry<String, Categoria> categoria(String codigo, String label, String... keywords) {
    return Map.entry(codigo, new Categoria(label, List.of(keywords)));
  }

  private record Categoria(String label, List<String> keywords) {
  }
}
