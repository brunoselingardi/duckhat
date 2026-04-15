# DuckHat Database Workflow

Este pacote foi revisado com base no backend atual do projeto.

## O que foi alinhado com o backend

O schema está congruente com:
- `backend/src/main/resources/application.properties`
- entidades JPA em `backend/src/main/java/com/duckhat/api/entity`
- repositórios Spring Data e consultas atuais

Credenciais esperadas pela API:
- banco: `duckhat`
- usuário: `duckhat_user`
- senha: `duckhat_pass`
- porta local padrão: `3307`

## Estrutura

```text
database/
├── init/
│   ├── 000_create_database_and_user.sql
│   └── 001_initial_schema.sql
├── migrations/
│   └── V2__align_current_schema_with_backend.sql
├── seed/
│   └── 001_seed_dev.sql
├── compose.yaml
├── .env.example
└── README_DATABASE_WORKFLOW.md
```

## Quando usar cada arquivo

### `init/000_create_database_and_user.sql`
Cria o banco `duckhat`, garante o usuário `duckhat_user` com senha `duckhat_pass` e aplica permissões.

### `init/001_initial_schema.sql`
Schema inicial completo para ambientes novos.

### `migrations/V2__align_current_schema_with_backend.sql`
Migration para quem já possui um banco antigo local e precisa alinhar a estrutura ao backend atual.

### `seed/001_seed_dev.sql`
Carga opcional de dados de desenvolvimento.

Todos os usuários do seed usam a senha:

```text
123456
```

## Observações importantes

- O seed foi ajustado para respeitar a regra atual do backend de avaliação em agendamento concluído.
- Os índices foram adicionados com foco nas consultas dos repositórios atuais.
- As regras de papel de usuário (`CLIENTE` versus `PRESTADOR`) continuam principalmente no backend. O banco garante integridade relacional, tipos e intervalos básicos.
- O arquivo de migration deve ser executado uma única vez por ambiente já existente.

## Fluxo recomendado para ambiente novo

1. Copie o arquivo de ambiente:

```bash
cp database/.env.example database/.env
```

2. Suba o banco:

```bash
docker compose -f database/compose.yaml --env-file database/.env up -d
```

3. O MySQL executará automaticamente os scripts dentro de `database/init/` na primeira inicialização do volume.

4. Caso queira dados de desenvolvimento, aplique o seed manualmente:

```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
  mysql -u duckhat_user -pduckhat_pass duckhat < database/seed/001_seed_dev.sql
```

## Fluxo recomendado para banco local já existente

1. Garanta que fez backup ou que o ambiente é de desenvolvimento.

2. Aplique a migration:

```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
  mysql -u duckhat_user -pduckhat_pass duckhat < database/migrations/V2__align_current_schema_with_backend.sql
```

3. Atualize a conexão no DBeaver e valide tabelas, índices e colunas.

4. Se quiser recriar os dados de exemplo, aplique depois o seed.

## Validação rápida no DBeaver

Confira se existem estas tabelas:
- `usuarios`
- `servicos`
- `disponibilidades`
- `agendamentos`
- `avaliacoes`
- `notificacao_eventos`

Confira também estes pontos:
- `usuarios.email` único
- `servicos.prestador_id` apontando para `usuarios.id`
- `agendamentos` com colunas `cliente_id`, `prestador_id`, `servico_id`, `inicio_at`, `fim_at`, `status`
- `avaliacoes.agendamento_id` único
- `notificacao_eventos.status` com valores `PENDENTE`, `ENVIADO`, `FALHA`
