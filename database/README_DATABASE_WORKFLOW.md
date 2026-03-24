# Fluxo de Trabalho do Banco de Dados

Este documento define o fluxo oficial de trabalho do banco de dados do projeto **Duckhat**.

O objetivo é garantir que todos os desenvolvedores trabalhem de forma padronizada, previsível e segura, evitando alterações isoladas no banco local e mantendo toda a evolução do schema versionada no GitHub.

---

## 1. Objetivo

A equipe irá trabalhar com:

- **MySQL em Docker**
- **estrutura do banco versionada no repositório**
- **DBeaver** para visualização e testes
- **arquivos `.sql`** para alterações oficiais
- **GitHub + Pull Request** para controle das mudanças

Em outras palavras:

- o **Docker** executa o banco localmente
- o **DBeaver** ajuda a visualizar e testar
- o **GitHub** guarda a verdade oficial do banco
- os **arquivos SQL** registram a evolução da estrutura

---

## 2. Estrutura esperada no projeto

```text
database/
├── .env.example
├── compose.yaml
├── README.md
├── init/
│   └── 001_initial_schema.sql
├── migrations/
└── seed/
```

### Função de cada item

#### `database/.env.example`
Arquivo modelo com as variáveis de ambiente do banco.

#### `database/compose.yaml`
Arquivo do Docker Compose responsável por subir o MySQL e os serviços auxiliares.

#### `database/init/001_initial_schema.sql`
Script inicial que cria a primeira versão oficial da estrutura do banco.

#### `database/migrations/`
Pasta onde devem ser criadas as **novas alterações estruturais** do banco após a base inicial.

#### `database/seed/`
Pasta reservada para dados iniciais ou dados de apoio para desenvolvimento.

---

## 3. Regra principal da equipe

### O banco oficial não vive no DBeaver
O banco oficial vive no **repositório GitHub**, por meio dos arquivos SQL.

Isso significa que:

- criar tabela só no DBeaver **não é suficiente**
- alterar coluna só na sua máquina **não é suficiente**
- adicionar relacionamento sem registrar em arquivo SQL **não é permitido como mudança oficial**

Toda alteração estrutural precisa existir em um arquivo `.sql` dentro do projeto.

---

## 4. Fluxo inicial para novos desenvolvedores

Depois que a branch inicial do banco for mergeada na `main`, cada desenvolvedor deverá seguir estes passos.

### 4.1 Clonar ou atualizar o projeto

```bash
git checkout main
git pull origin main
```

### 4.2 Criar o arquivo `.env` local

```bash
cp database/.env.example database/.env
```

### 4.3 Subir o banco com Docker

```bash
docker compose -f database/compose.yaml --env-file database/.env up -d
```

### 4.4 Verificar se o banco está rodando

```bash
docker compose -f database/compose.yaml --env-file database/.env ps
```

### 4.5 Conectar no DBeaver

Configuração padrão:

- **Host:** `localhost`
- **Porta:** `3307`
- **Banco:** `duckhat`
- **Usuário:** `duckhat_user`
- **Senha:** `duckhat_pass`

Se necessário, nas propriedades do driver MySQL do DBeaver:

- `allowPublicKeyRetrieval = true`
- `useSSL = false`

---

## 5. Fluxo oficial para alterar o banco de dados

Depois que a base inicial já estiver estabelecida, **não devemos mais alterar o arquivo `001_initial_schema.sql` para mudanças normais do dia a dia**.

As alterações futuras devem ser feitas por meio de **novos arquivos SQL na pasta `database/migrations/`**.

### 5.1 Criar uma branch nova

Exemplo:

```bash
git checkout main
git pull origin main
git checkout -b feat/create-pagamentos-table
```

### 5.2 Criar um novo arquivo SQL na pasta de migrations

Exemplo:

```bash
touch database/migrations/V2__create_pagamentos.sql
```

### 5.3 Escrever a alteração no arquivo

Exemplo:

```sql
CREATE TABLE pagamentos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    agendamento_id BIGINT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status ENUM('PENDENTE', 'PAGO', 'CANCELADO') NOT NULL DEFAULT 'PENDENTE',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pagamentos_agendamento
        FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id)
);
```

### 5.4 Aplicar o arquivo no banco local

```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
mysql -u duckhat_user -pduckhat_pass duckhat < database/migrations/V2__create_pagamentos.sql
```

### 5.5 Validar no DBeaver

Depois de aplicar a migration:

- atualizar a conexão
- verificar se a tabela/coluna/índice foi criado corretamente
- rodar queries de teste se necessário

### 5.6 Commitar a alteração

```bash
git add database/migrations/V2__create_pagamentos.sql
git commit -m "feat(database): create pagamentos table"
git push -u origin feat/create-pagamentos-table
```

### 5.7 Abrir Pull Request

Toda alteração estrutural do banco deve entrar por **Pull Request**.

---

## 6. Como nomear os arquivos de migration

Adotaremos o seguinte padrão:

```text
V2__create_pagamentos.sql
V3__add_foto_url_to_usuarios.sql
V4__create_enderecos_table.sql
V5__add_index_to_agendamentos.sql
```

### Convenção

- começa com `V`
- seguido do número da versão
- usa `__` entre a versão e a descrição
- a descrição deve ser objetiva e clara

---

## 7. Quando editar o `001_initial_schema.sql`

### Pode editar o `001_initial_schema.sql` quando:
- o banco ainda está sendo desenhado
- a base inicial ainda não foi consolidada
- a equipe ainda está refinando a primeira modelagem

### Não deve editar o `001_initial_schema.sql` quando:
- a estrutura inicial já foi aceita
- a branch inicial já foi mergeada
- outros desenvolvedores já começaram a usar o banco

Depois dessa estabilização, toda alteração nova deve entrar em `database/migrations/`.

---

## 8. Fluxo para os outros desenvolvedores depois que uma migration entrar na main

Quando uma migration for aprovada e mergeada:

### 8.1 Atualizar o repositório

```bash
git checkout main
git pull origin main
```

### 8.2 Aplicar a migration nova

Exemplo:

```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
mysql -u duckhat_user -pduckhat_pass duckhat < database/migrations/V2__create_pagamentos.sql
```

### 8.3 Validar no DBeaver
Após aplicar a migration, conferir se a alteração apareceu corretamente.

---

## 9. Papel do DBeaver no projeto

O DBeaver será usado para:

- visualizar tabelas
- inspecionar colunas
- executar `SELECT`
- testar `INSERT`, `UPDATE` e `DELETE`
- validar migrations
- navegar pela estrutura do banco

### Importante
O DBeaver **não substitui** os arquivos SQL do projeto.

Tudo que for uma mudança estrutural oficial deve ser registrado em arquivo `.sql`.

---

## 10. Sobre dados de teste e seed

A pasta `database/seed/` pode ser usada para:

- dados iniciais de apoio
- registros padrão para desenvolvimento
- categorias fixas
- usuários de teste
- dados mínimos para popular o ambiente local

Exemplo:

```sql
INSERT INTO categorias (nome) VALUES
('Cabelo'),
('Barba'),
('Manicure');
```

Esses arquivos não substituem migrations estruturais.

### Resumo:
- **migrations** = mudanças de estrutura
- **seed** = dados de apoio

---

## 11. O que não fazer

Para evitar inconsistências, a equipe **não deve**:

- criar tabela apenas no DBeaver e esquecer de registrar em SQL
- alterar a estrutura direto no banco sem versionar
- editar o banco local e assumir que os outros terão a mesma mudança
- fazer mudanças diretamente na `main`
- criar arquivos SQL sem branch e sem Pull Request
- usar o banco local de uma única pessoa como banco oficial do time

---

## 12. Fluxo resumido da equipe

### Base inicial
1. criar a estrutura inicial do banco
2. subir em uma branch
3. abrir Pull Request
4. fazer merge na `main`

### Novos desenvolvedores
1. atualizar a `main`
2. criar `database/.env`
3. subir o Docker
4. conectar no DBeaver

### Mudanças futuras
1. criar branch nova
2. criar novo arquivo em `database/migrations/`
3. aplicar no banco local
4. testar no DBeaver
5. commitar
6. subir para o GitHub
7. abrir Pull Request

---

## 13. Comandos úteis

### Subir o banco
```bash
docker compose -f database/compose.yaml --env-file database/.env up -d
```

### Parar o banco
```bash
docker compose -f database/compose.yaml --env-file database/.env down
```

### Ver status dos containers
```bash
docker compose -f database/compose.yaml --env-file database/.env ps
```

### Ver logs
```bash
docker compose -f database/compose.yaml --env-file database/.env logs -f
```

### Executar um arquivo SQL de migration
```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
mysql -u duckhat_user -pduckhat_pass duckhat < database/migrations/NOME_DO_ARQUIVO.sql
```

---

## 14. Padrão de governança recomendado

Para manter o banco organizado, recomenda-se:

- revisar toda migration em Pull Request
- manter nomes de arquivos claros
- evitar alterações simultâneas sobre a mesma tabela sem alinhamento
- discutir mudanças grandes antes de implementá-las
- validar relacionamentos e integridade referencial antes do merge

---

## 15. Conclusão

A partir deste fluxo:

- cada desenvolvedor terá seu próprio banco local em Docker
- toda alteração ficará rastreável no GitHub
- o time trabalhará de forma colaborativa sem depender da máquina de uma única pessoa
- o banco de dados terá evolução organizada e reproduzível

Este passa a ser o fluxo oficial de trabalho do banco de dados do projeto.

---

## 16. Contato interno da equipe

Em caso de dúvida sobre mudanças estruturais:

- alinhar com o responsável pela modelagem inicial
- revisar o histórico das migrations
- evitar alterações diretas fora do fluxo definido neste documento
