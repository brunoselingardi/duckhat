package com.duckhat.api.repository;

import com.duckhat.api.entity.ChatMensagem;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ChatMensagemRepository extends JpaRepository<ChatMensagem, Long> {

  List<ChatMensagem> findByConversaIdOrderByCriadoEmAscIdAsc(Long conversaId);

  Optional<ChatMensagem> findFirstByConversaIdOrderByCriadoEmDescIdDesc(Long conversaId);

  @Modifying
  @Query(
      value = """
          DELETE m FROM chat_mensagens m
          JOIN chat_conversas c ON c.id = m.conversa_id
          LEFT JOIN (
            SELECT conversa_id, MAX(id) AS ultima_mensagem_id
            FROM chat_mensagens
            GROUP BY conversa_id
          ) ult ON ult.conversa_id = m.conversa_id
          WHERE m.criado_em < :limitePadrao
            AND c.ultima_mensagem_em < :limiteComGraca
            AND m.id <> ult.ultima_mensagem_id
          """,
      nativeQuery = true)
  int deleteMensagensExpiradas(
      @Param("limitePadrao") LocalDateTime limitePadrao,
      @Param("limiteComGraca") LocalDateTime limiteComGraca);
}
