# DuckHat

DuckHat é um aplicativo acadêmico de agendamento de serviços. O projeto reúne um app Flutter, uma API Spring Boot e um banco MySQL local para validar fluxos reais de cliente e estabelecimento: cadastro, login, busca, página pública, chat, serviços, agenda e notificações.

## Stack

- Flutter e Dart para o aplicativo mobile.
- Spring Boot, Spring Security, JWT e Spring Data JPA para a API.
- MySQL 8.4 via Docker Compose para desenvolvimento local.
- Maven Wrapper para build e testes do backend.
- Testes Flutter em `test/` e testes backend com perfil `test` usando H2.

## Estrutura

```text
duckhat/
├── AGENTS.md       # instruções locais para agentes e manutenção
├── assets/         # imagens, fontes e ícones do app
├── backend/        # API Spring Boot
├── database/       # Docker Compose, migrations e seeds SQL
├── docs/           # documentação funcional e planos técnicos
├── lib/            # frontend Flutter
├── test/           # testes automatizados do Flutter
├── pubspec.yaml    # dependências e assets do app
└── README.md
```

## Estado funcional

Fluxos principais já integrados com API:

- Login real por tipo de conta: cliente ou prestador.
- Cadastro de cliente e estabelecimento.
- Edição de perfil do cliente, incluindo foto de perfil em Base64 exibida no perfil e no chat.
- Edição da vitrine pública do estabelecimento, incluindo banner e foto/logo de perfil.
- Cadastro e edição de serviços/preços do estabelecimento.
- Busca por categoria, termo, endereço, CEP ou localização atual.
- Página pública do estabelecimento com dados reais do catálogo.
- Chat entre cliente e prestador, com foto do outro participante na lista e na conversa.
- Agendamento com serviço, data, horário e disponibilidade.
- Agenda do cliente e agenda do estabelecimento.
- Notificações e preferências de notificação.
- Recuperação de senha via API.
- Tema claro/escuro aplicado nos fluxos principais e hotspots de cards/formulários.

Conteúdos ainda tratados como fase futura ou fallback controlado:

- Galeria, avaliações e FAQ reais do estabelecimento.
- Storage externo definitivo para imagens; hoje o fluxo funcional usa Base64 persistido no banco.
- Favoritos persistidos no backend.

## Requisitos

- Flutter disponível no `PATH`.
- Java 17 ou compatível com o backend do projeto.
- Docker e Docker Compose.
- Android SDK/ADB para rodar em emulador ou dispositivo físico.

## Configuração do banco

Crie o arquivo de ambiente do banco:

```bash
cp database/.env.example database/.env
```

Suba MySQL e Adminer:

```bash
docker compose -f database/compose.yaml --env-file database/.env up -d
```

Aplicar seeds de desenvolvimento, quando necessário:

```bash
docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
  mysql -u duckhat_user -pduckhat_pass duckhat < database/seed/001_seed_dev.sql

docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
  mysql -u duckhat_user -pduckhat_pass duckhat < database/seed/002_seed_barbie_services.sql

docker compose -f database/compose.yaml --env-file database/.env exec -T mysql \
  mysql -u duckhat_user -pduckhat_pass duckhat < database/seed/003_seed_plumbing_provider.sql
```

O banco local padrão fica em `localhost:3307`.

## Backend

O backend possui defaults locais suficientes para desenvolvimento. Para sobrescrever configurações, crie `backend/.env`:

```bash
cp backend/.env.example backend/.env
set -a
source backend/.env
set +a
```

Variáveis aceitas:

- `SERVER_PORT`
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `SPRING_JPA_HIBERNATE_DDL_AUTO`
- `SPRING_JPA_SHOW_SQL`
- `SPRING_JPA_PROPERTIES_HIBERNATE_FORMAT_SQL`
- `JWT_SECRET`
- `JWT_EXPIRATION`
- `APP_AUTH_RETURN_RESET_CODE`
- `APP_EMAIL_ENABLED`
- `APP_EMAIL_HOST`
- `APP_EMAIL_PORT`
- `APP_EMAIL_USERNAME`
- `APP_EMAIL_PASSWORD`
- `APP_EMAIL_FROM`
- `APP_EMAIL_FROM_NAME`
- `APP_EMAIL_AUTH`
- `APP_EMAIL_SSL`
- `APP_EMAIL_START_TLS`
- `APP_EMAIL_CONNECT_TIMEOUT_MS`
- `APP_EMAIL_READ_TIMEOUT_MS`

### Recuperação de senha por e-mail

O fluxo `Esqueci minha senha` usa `POST /api/auth/recuperar-senha/solicitar`.
Em execução normal, configure SMTP pelas variáveis `APP_EMAIL_*` para o código chegar ao e-mail cadastrado.
Se SMTP não estiver configurado e `APP_AUTH_RETURN_RESET_CODE=false`, a API retorna `503` em vez de gerar um token que o usuário nunca receberia.

Para teste local sem SMTP, use:

```bash
APP_AUTH_RETURN_RESET_CODE=true
```

Esse modo retorna o código no payload da API e não deve ser usado em execução real.

Para o teste físico real, mantenha `APP_AUTH_RETURN_RESET_CODE=false` e suba o backend com `backend/run-local.sh`.
Esse script carrega `backend/.env` antes de iniciar a API; rodar `cd backend && ./mvnw spring-boot:run` direto não carrega SMTP.

Rodar testes:

```bash
cd backend
./mvnw test
```

Subir API:

```bash
backend/run-local.sh
```

Health check:

```text
GET http://localhost:8081/api/health
```

## Flutter

Instale dependências:

```bash
flutter pub get
```

Valide o frontend:

```bash
flutter analyze
flutter test
```

Rodar no desktop/emulador com API local:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456
```

No emulador Android, use `10.0.2.2` para acessar a API do host:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456
```

## Celular físico

Em celular físico, `localhost` aponta para o próprio aparelho. Para usar a API da máquina em `8081`, aplique o túnel USB:

```bash
adb -s RX8N309MYQA reverse tcp:8081 tcp:8081
```

Depois rode:

```bash
flutter run -d RX8N309MYQA \
  --dart-define=API_BASE_URL=http://127.0.0.1:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456
```

Dispositivo validado neste ambiente:

```text
SM G770F - RX8N309MYQA
```

## Variáveis do app

- `API_BASE_URL`: URL base da API.
- `DUCKHAT_LOGIN_EMAIL`: e-mail usado por autenticação automática em fluxos que exigem token.
- `DUCKHAT_LOGIN_PASSWORD`: senha usada por autenticação automática.
- `GEOAPIFY_API_KEY`: chave para geocodificação e busca externa por localização.
- `DUCKHAT_ENABLE_DEV_LOGIN`: quando `true`, exibe os botões de login de desenvolvimento. Deve ficar desativado em execução normal.

Exemplo com Geoapify:

```bash
flutter run -d RX8N309MYQA \
  --dart-define=API_BASE_URL=http://127.0.0.1:8081 \
  --dart-define=DUCKHAT_LOGIN_EMAIL=login@duckhat.com \
  --dart-define=DUCKHAT_LOGIN_PASSWORD=123456 \
  --dart-define=GEOAPIFY_API_KEY=SUA_CHAVE
```

## Fluxos de validação recomendados

Cliente:

1. Entrar como cliente.
2. Pesquisar por `encanador`.
3. Abrir `Jorje Encanamentos`.
4. Conferir serviços e página pública.
5. Abrir chat.
6. Criar agendamento.
7. Conferir o agendamento na agenda.

Estabelecimento:

1. Entrar como prestador.
2. Abrir perfil do estabelecimento.
3. Editar vitrine pública.
4. Editar serviços e preços.
5. Conferir agenda do prestador.
6. Confirmar ou concluir agendamentos quando houver itens pendentes.

## Qualidade

Antes de concluir qualquer alteração:

```bash
dart format lib test
flutter analyze
flutter test
git diff --check
```

Para alterações no backend:

```bash
cd backend
./mvnw test
```

## Observações de manutenção

- Leia `AGENTS.md` antes de mudanças relevantes.
- Preserve alterações locais do usuário.
- Prefira os padrões existentes de `lib/theme.dart`, `DuckHatApi` e componentes próximos.
- Não exponha fluxos de desenvolvimento na UI normal.
- Quando o schema do backend mudar, adicione migration em `database/migrations`.
- Para bancos locais antigos, aplique migrations pendentes antes de investigar falhas de `ddl-auto=validate`.
