package com.duckhat.api.dto;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import com.duckhat.api.entity.Estabelecimento;
import com.duckhat.api.entity.Usuario;
import org.junit.jupiter.api.Test;

class PrestadorPublicoResponseTest {

  @Test
  void fromEntityMapeiaCamposPublicosDoPrestador() {
    Usuario usuario = new Usuario();
    usuario.setId(2L);
    usuario.setNome("Barbie Dream Barber");
    usuario.setTelefone("62999998888");
    usuario.setEndereco("Av. DuckHat, 120 - Setor Bueno");
    Estabelecimento estabelecimento = new Estabelecimento();
    estabelecimento.setUsuario(usuario);
    estabelecimento.setDescricao("Cortes e cuidados para todos os estilos.");
    estabelecimento.setHorarioAtendimento("Segunda a sexta 9h - 20h");

    PrestadorPublicoResponse response = PrestadorPublicoResponse.fromEntity(usuario, estabelecimento);

    assertEquals(2L, response.id());
    assertEquals("Barbie Dream Barber", response.nome());
    assertEquals("62999998888", response.telefone());
    assertEquals("Av. DuckHat, 120 - Setor Bueno", response.endereco());
    assertEquals("Cortes e cuidados para todos os estilos.", response.descricaoPublica());
    assertEquals("Segunda a sexta 9h - 20h", response.horarioAtendimento());
    assertNull(response.imagemCapa());
    assertNull(response.imagemLogo());
  }
}
