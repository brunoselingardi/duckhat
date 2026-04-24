# DuckHat - Funcionalidades por Arquivo

## Como usar

Leia este arquivo antes de revisar funcionalidades do DuckHat. Ele serve como indice funcional do projeto e deve ser confirmado com o codigo real quando houver duvida.

## Entradas principais

- `lib/main.dart`
  - inicia o app com `MyApp`
  - define `LoginPage` como tela inicial
  - registra a rota nomeada `/schedule-date`
- `lib/pages/app_shell.dart`
  - define `MainNavigator`
  - controla as 4 abas principais: `Home`, `Agenda`, `Chat`, `Perfil`
- `lib/services/duckhat_api.dart`
  - encapsula login, autenticacao automatica por `dart-define`, listagem de servicos, disponibilidades, ocupacoes, agendamentos, cancelamento e chat
- `lib/core/api_config.dart`
  - centraliza `API_BASE_URL`, `DUCKHAT_LOGIN_EMAIL` e `DUCKHAT_LOGIN_PASSWORD`

## Telas principais

- `lib/pages/login.dart`
  - login inicial do app
  - botoes de tipo de conta: `Cliente` e `Empresa`
  - campos: `E-mail` e `Senha`
  - botao no campo senha alterna entre `Mostrar senha` e `Ocultar senha`
  - CTA principal: `Entrar como cliente` ou `Entrar como empresa`
  - link `Esqueci minha senha` abre `ForgotPasswordPage`
  - link `Criar conta` abre `SignupPage`
  - autentica sempre na API real
- `lib/pages/home.dart`
  - home visual com header, busca, banner promocional, rebook e agendamentos do dia
  - card de busca abre `SearchPage`
  - cards de rebook abrem `ServicePage`
  - CTA visual `Ver promoções` nao possui handler real
  - secao de agendamentos do dia ainda e visual/mockada
- `lib/pages/search.dart`
  - tela de busca com filtros, campo de texto, localizacao, sugestoes e recentes
  - botao voltar retorna para a tela anterior
  - filtros horizontais alternam categoria localmente
  - CTA `Ver todos` e exibido na secao de sugestoes
  - CTA `Pesquisar` abre `SearchResultsPage` com termo, localizacao e categoria selecionados
  - toque em recente ou sugestao aplica texto ou leva para `ServicePage`
  - busca ainda e local, sem integracao com catalogo real
- `lib/pages/search_results.dart`
  - tela de resultados locais da busca
  - exibe barra de busca compacta, filtros rapidos, mapa e cards de estabelecimentos
  - usa `flutter_map` com tiles do OpenStreetMap
  - solicita localizacao via `geolocator`; se falhar, usa Goiania como fallback visual
  - botao voltar retorna para a busca
  - botao `Pesquisar` refiltra a lista localmente
  - botoes do mapa permitem aproximar, afastar e recentralizar
  - toque em estabelecimento ou CTA `Servicos disponiveis` abre `ServicePage`
  - resultados ainda sao locais/mockados, sem integracao com catalogo real
- `lib/pages/service.dart`
  - pagina do estabelecimento/prestador
  - carrega servicos reais do prestador pela API
  - possui hero, info card, tabs, galeria, reviews, FAQ e CTA `Agendar`
  - botao voltar no hero retorna
  - tabs horizontais navegam entre secoes
  - toque na galeria abre fullscreen
  - cada servico possui botao `Agendar`
  - CTA global flutuante agenda o primeiro servico disponivel
  - CTA `Enviar Mensagem` do info card cria/abre conversa real com o prestador
  - existem CTAs visuais locais sem acao real em componentes como experiencia
- `lib/pages/schedule.dart`
  - agenda integrada do usuario
  - lista agendamentos via API
  - botao atualizar recarrega dados
  - estado de erro exibe CTA `Tentar novamente`
  - cada card pode abrir detalhe ou cancelar direto
  - em sessao `PRESTADOR`, usa a agenda do prestador e mostra acoes de confirmar/concluir
  - toque em item abre `AppointmentDetailPage`
- `lib/pages/schedule_date.dart`
  - etapa final do fluxo de agendamento vindo da pagina de servico
  - carrega disponibilidade e ocupacao do prestador
  - permite escolher data e horario
  - botao voltar retorna
  - botoes de mes anterior e proximo navegam no calendario
  - CTA de erro `Tentar novamente` recarrega disponibilidades
  - toque em dia/horario seleciona slot
  - CTA de confirmacao abre dialogo e cria agendamento real via API
- `lib/pages/appointment_detail.dart`
  - mostra resumo do agendamento
  - permite cancelar quando o status suporta isso
  - botao voltar no app bar retorna
  - botao `Cancelar agendamento` executa cancelamento real quando disponivel
  - mostra avaliacao local quando o status e `CONCLUIDO`
  - estrelas de nota e botao de envio de review sao locais/mockados
- `lib/pages/chat.dart`
  - lista conversas reais do usuario autenticado pela API
  - possui busca local por nome do participante ou ultima mensagem
  - possui refresh manual e pull-to-refresh
  - toque em conversa abre `ChatDetailPage`
- `lib/pages/chat_detail.dart`
  - tela real de conversa
  - botao voltar retorna
  - botao atualizar recarrega mensagens
  - lista mensagens da conversa pela API
  - input envia nova mensagem real para o backend
- `lib/pages/user.dart`
  - hub do perfil
  - abre subpaginas de editar perfil, notificacoes, seguranca, configuracoes e ajuda
  - item `Minhas Localizações` exibe `SnackBar` de placeholder
  - `Sair` abre dialogo de confirmacao
- `lib/pages/forgot_password.dart`
  - fluxo real de recuperacao em duas etapas
  - botao voltar retorna
  - CTA principal gera codigo de recuperacao via API
  - codigo so aparece na tela quando o backend for iniciado explicitamente com retorno de codigo de demo
  - segunda etapa recebe codigo e nova senha e redefine na API
  - retorna o e-mail para a tela de login ao concluir
- `lib/pages/signup.dart`
  - cadastro real para cliente ou empresa
  - botao voltar retorna
  - seletor de tipo de conta alterna entre `Cliente` e `Empresa`
  - botoes de mostrar/ocultar senha e confirmar senha
  - CTA principal cria conta real e devolve credenciais para login imediato
  - CTA `Ja tenho conta` volta ao login
  - para prestador, envia tambem `cnpj` e `responsavelNome`

## Componentes principais por area

### Navegacao

- `lib/components/bottomnav.dart`
  - bottom navigation com 4 abas e icones SVG

### Home

- `lib/components/home/header.dart`
  - cabecalho com saudacao
- `lib/components/home/rebook.dart`
  - secao de reagendamento
- `lib/components/home/rebookcard.dart`
  - card clicavel que abre `ServicePage`
- `lib/components/home/appointment.dart`
  - secao de agendamentos do dia
- `lib/components/home/appointmentcard.dart`
  - card visual de agendamento
- `lib/components/home/filtersection.dart`
  - lista horizontal de filtros mockados
- `lib/components/home/filtercard.dart`
  - card individual de filtro
- `lib/components/home/searchbar.dart`
  - componente de busca estilizada

### Service

- `lib/components/service/service_hero.dart`
  - hero da pagina do estabelecimento com retorno visual
- `lib/components/service/service_info_card.dart`
  - resumo do estabelecimento
  - possui CTA visual local sem integracao real
- `lib/components/service/service_tab_menu.dart`
  - tabs horizontais da pagina de servico
- `lib/components/service/service_sections.dart`
  - organiza as secoes experiencia, servicos, galeria, reviews e FAQ
- `lib/components/service/service_services_section.dart`
  - lista servicos e precos
  - cada linha possui botao `Agendar`
- `lib/components/service/service_gallery_section.dart`
  - galeria com selecao e abertura fullscreen
- `lib/components/service/service_reviews_section.dart`
  - reviews mockadas
- `lib/components/service/service_faq_section.dart`
  - FAQ mockado
- `lib/components/service/service_experience_section.dart`
  - bloco de experiencia/descricao
  - possui CTA visual local sem handler funcional
- `lib/components/service/service_data.dart`
  - dados locais usados pela pagina de servico
- `lib/components/service/service_models.dart`
  - modelos de apoio para ofertas, reviews e FAQ

### Perfil

- `lib/components/user/editar_perfil.dart`
  - formulario visual de perfil com botao voltar e botao `Salvar`
- `lib/components/user/notificacoes.dart`
  - botao voltar
  - toggles locais de notificacoes
- `lib/components/user/seguranca.dart`
  - botao voltar
  - itens de senha, biometria, 2FA, privacidade e exclusao
  - `Excluir Conta` abre dialogo local
- `lib/components/user/configuracoes.dart`
  - botao voltar
  - idioma, moeda, formato, tema, sons, versao, termos e politica
  - switches de tema e audio sao locais
- `lib/components/user/ajuda.dart`
  - botao voltar
  - FAQ com `ExpansionTile` e canais de contato
  - contatos exibem `SnackBar` placeholder

## Modelos

- `lib/models/agendamento.dart`
  - modelo consumido pela agenda e detalhe do agendamento
- `lib/models/servico_catalogo.dart`
  - modelo de servicos vindos do catalogo/API
- `lib/models/disponibilidade_catalogo.dart`
  - disponibilidade publica do prestador
- `lib/models/ocupacao_prestador.dart`
  - horarios ocupados do prestador
- `lib/models/chat_conversa.dart`
  - modelo de conversa cliente/prestador vinda do backend
- `lib/models/chat_mensagem.dart`
  - modelo de mensagem de chat vinda do backend

## Backend principal

- `backend/src/main/java/com/duckhat/api/config/SecurityConfig.java`
  - define regras de acesso por rota e perfil
- `backend/src/main/java/com/duckhat/api/controller/AuthController.java`
  - login JWT
  - recuperacao de senha: solicitar codigo e redefinir senha
- `backend/src/main/java/com/duckhat/api/controller/CatalogoController.java`
  - endpoints publicos de catalogo, disponibilidade e ocupacao
- `backend/src/main/java/com/duckhat/api/controller/AgendamentoController.java`
  - criacao, listagem, cancelamento, confirmacao e conclusao de agendamentos
- `backend/src/main/java/com/duckhat/api/controller/ServicoController.java`
  - CRUD funcional de servicos do prestador
- `backend/src/main/java/com/duckhat/api/controller/DisponibilidadeController.java`
  - gestao de disponibilidades do prestador
- `backend/src/main/java/com/duckhat/api/controller/UsuarioController.java`
  - criacao e leitura de usuarios
- `backend/src/main/java/com/duckhat/api/controller/MeController.java`
  - retorno do usuario autenticado
- `backend/src/main/java/com/duckhat/api/controller/AvaliacaoController.java`
  - endpoints de avaliacoes
- `backend/src/main/java/com/duckhat/api/controller/NotificacaoEventoController.java`
  - endpoints de notificacoes
- `backend/src/main/java/com/duckhat/api/controller/ChatController.java`
  - endpoints de conversas e mensagens do chat autenticado
- `backend/src/main/java/com/duckhat/api/service/AgendamentoService.java`
  - regra de negocio principal do agendamento
  - valida duracao, horario passado, disponibilidade e conflito
- `backend/src/main/java/com/duckhat/api/service/JwtService.java`
  - gera e valida JWT
- `backend/src/main/java/com/duckhat/api/service/RecuperacaoSenhaService.java`
  - gera codigo, persiste token de recuperacao e redefine senha
  - aplica limite de tentativas invalidas e bloqueio temporario por token
- `backend/src/main/java/com/duckhat/api/service/ChatService.java`
  - cria/busca conversa entre cliente e prestador
  - lista conversas e mensagens autorizadas por participante
  - envia mensagens e atualiza `ultima_mensagem_em`
  - limpa mensagens expiradas diariamente preservando a ultima mensagem por conversa e aplicando graca de 5 dias pela ultima atividade
- `backend/src/main/resources/application.properties`
  - configuracao com fallback local e override por variaveis de ambiente

## Banco e suporte local

- `database/compose.yaml`
  - sobe MySQL e Adminer
- `database/init/000_create_database_and_user.sql`
  - bootstrap inicial do banco
- `database/init/001_initial_schema.sql`
  - schema inicial
- `database/migrations/V2__align_current_schema_with_backend.sql`
  - alinhamento do schema com backend atual
- `database/migrations/V3__auth_login_area_integration.sql`
  - adiciona campos de prestador em `usuarios` e cria tabela de `recuperacao_senha_tokens`
- `database/migrations/V4__password_reset_attempt_limits.sql`
  - adiciona limite persistente de tentativas na recuperacao de senha
- `database/migrations/V5__chat_conversations_and_messages.sql`
  - cria `chat_conversas`, `chat_mensagens` e indices do chat real
- `database/seed/001_seed_dev.sql`
  - seed de desenvolvimento
- `database/seed/002_seed_barbie_services.sql`
  - seed incremental dos servicos da Barbie Dream Barber

## Fluxos reais versus mockados

- Integrados com API
  - login real
  - cadastro real
  - recuperacao de senha real
  - servicos por prestador
  - agenda do cliente
  - agenda do prestador
  - criacao de agendamento
  - cancelamento de agendamento
  - disponibilidade e ocupacao do prestador
  - chat entre cliente e prestador
- Mockados ou locais
  - busca textual e filtros da busca
  - resultados e mapa da busca
  - reviews e FAQ do estabelecimento
  - subpaginas de perfil
  - minhas localizacoes no perfil
  - banner promocional e boa parte da home

## Regra de manutencao

Sempre que uma mudanca alterar comportamento, navegacao, botoes, integracao ou responsabilidade de arquivo, atualizar este documento junto com o codigo.
