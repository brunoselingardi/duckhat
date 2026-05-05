# DuckHat

Aplicativo acadêmico com frontend Flutter, backend Spring Boot e banco MySQL.

## Stack

- Flutter
- Java 17
- Spring Boot
- MySQL 8.4 via Docker Compose

## Estrutura

```text
duckhat/
├── AGENTS.md              # instrucoes locais para revisao e manutencao
├── docs/                  # documentacao complementar do projeto
├── lib/                  # frontend Flutter
├── backend/              # API Spring Boot
├── database/             # compose, schema, migration e seed
├── assets/               # imagens, fontes e ícones
└── test/                 # testes Flutter
```

## Leitura funcional recomendada

Antes de revisar funcionalidades do projeto, ler:

```text
AGENTS.md
docs/funcionalidades-por-arquivo.md
```

Esse material resume a responsabilidade dos arquivos principais, telas, botoes, fluxos e pontos integrados com API.

## Requisitos

- Flutter instalado e disponível no PATH
- Java 17
- Docker + Docker Compose
- Android Studio ou dispositivo Android para rodar o app mobile

## Banco local

Crie o arquivo de ambiente do banco:

```bash
cp database/.env.example database/.env
```

Suba o MySQL:

```bash
docker compose -f database/compose.yaml --env-file database/.env up -d
```

Se precisar de dados de desenvolvimento:

```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
  mysql -u duckhat_user -pduckhat_pass duckhat < database/seed/001_seed_dev.sql
```

Para os serviços reais da Barbie Dream Barber usados no fluxo de agendamento:

```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
  mysql -u duckhat_user -pduckhat_pass duckhat < database/seed/002_seed_barbie_services.sql
```

Para atualizar um banco local existente com notificações in-app e preferências:

```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
  mysql -u duckhat_user -pduckhat_pass duckhat < database/migrations/V6__notification_feed_and_preferences.sql
```

## Backend

Crie um ambiente local opcional para sobrescrever as configurações padrão:

```bash
cp backend/.env.example backend/.env
set -a
source backend/.env
set +a
```

As variáveis suportadas são:

- `SERVER_PORT`
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `SPRING_JPA_HIBERNATE_DDL_AUTO`
- `SPRING_JPA_SHOW_SQL`
- `SPRING_JPA_PROPERTIES_HIBERNATE_FORMAT_SQL`
- `JWT_SECRET`
- `JWT_EXPIRATION`

Se nenhuma variável for exportada, o backend continua funcionando com os defaults locais atuais.

Rodar testes do backend:

```bash
cd backend
./mvnw test
```

Subir a API:

```bash
cd backend
./mvnw spring-boot:run
```

Health check esperado:

```text
GET http://localhost:8081/api/health
```

## Flutter

Instalar dependências:

```bash
flutter pub get
```

Verificações:

```bash
flutter analyze
flutter test
```

Rodar no host local:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456
```

Rodar no emulador Android:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456
```

Rodar no celular físico via USB.

Observação: em celular físico, `localhost` dentro do app aponta para o próprio celular, não para o computador. Para usar a API local do computador em `8081`, primeiro crie o túnel USB com `adb reverse` e rode o app usando `http://127.0.0.1:8081`.

Dispositivo validado nesta máquina:

```text
SM G770F (RX8N309MYQA)
```

```bash
adb -s RX8N309MYQA reverse tcp:8081 tcp:8081
flutter run -d RX8N309MYQA \
  --dart-define=API_BASE_URL=http://127.0.0.1:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456
```

## Fluxo real validado

Fluxo principal integrado atualmente:

1. Abrir a página do estabelecimento
2. Entrar em `Serviços`
3. Selecionar um serviço real
4. Ir para `Agendar`
5. Escolher data e horário em `schedule_date.dart`
6. Criar agendamento via API Spring Boot
7. Ver o item refletido na agenda integrada

Também estão integrados com API e MySQL:

- chat real entre cliente e prestador
- notificações in-app geradas por agenda e chat
- preferências persistidas de notificações
- leitura individual e leitura em massa de notificações

## Observações técnicas

- O backend escuta por padrão em `8081`.
- O banco local esperado fica em `localhost:3307`.
- O app depende de `DUCKHAT_LOGIN_EMAIL` e `DUCKHAT_LOGIN_PASSWORD` para autenticar na API.
- Parte do app ainda usa dados mockados, mas agenda, chat, autenticação e notificações estão integrados com API e MySQL.
- O arquivo `backend/.env` é local e não deve ser versionado.
