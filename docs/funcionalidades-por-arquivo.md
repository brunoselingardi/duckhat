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
- `lib/shop_main.dart`
  - define `ShopMainNavigator` da area mockada de estabelecimento
  - controla as 4 abas `Inicio`, `Agenda`, `Chat` e `Perfil` do fluxo `shop_*`
  - mantem estado das abas em `IndexedStack` com `PageStorage`
- `lib/services/duckhat_api.dart`
  - encapsula login, autenticacao automatica por `dart-define`, listagem de servicos, disponibilidades, ocupacoes, agendamentos, cancelamento, chat e notificacoes
- `lib/core/api_config.dart`
  - centraliza `API_BASE_URL`, `DUCKHAT_LOGIN_EMAIL` e `DUCKHAT_LOGIN_PASSWORD`

## Telas principais

- `lib/pages/login.dart`
  - login inicial do app
  - layout minimalista inspirado em referencia mobile, com e-mail e senha na mesma tela
  - botoes de tipo de conta: `Cliente` e `Empresa`
  - campos principais: `E-mail` e `Password`
  - no login bem-sucedido, dispara uma sequencia animada: expansao azul a partir do botao, tela azul com `hello` e circulo branco central antes de abrir o app
  - botao no campo senha alterna entre `Mostrar senha` e `Ocultar senha`
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
  - a lista de servicos e apenas informativa, sem botao `Agendar` por item
  - CTA global flutuante abre a tela de agendamento com os servicos do estabelecimento
  - CTA `Enviar Mensagem` do info card cria/abre conversa real com o prestador
  - existem CTAs visuais locais sem acao real em componentes como experiencia
- `lib/pages/schedule.dart`
  - agenda integrada do usuario
  - lista agendamentos via API
  - botao atualizar recarrega dados
  - botao adicionar abre bottom sheet de novo agendamento
  - estado de erro exibe CTA `Tentar novamente`
  - cada card inteiro abre os detalhes; cancelamento fica na tela de detalhe
  - bottom sheet possui selecao de servico, data, horario, observacoes e CTA de criacao
  - em sessao `PRESTADOR`, usa a agenda do prestador e mostra acoes de confirmar/concluir
  - toque em item abre `AppointmentDetailPage`
- `lib/pages/schedule_date.dart`
  - etapa final do fluxo de agendamento vindo da pagina de servico
  - carrega disponibilidade e ocupacao do prestador
  - exige escolher primeiro um servico do estabelecimento e so depois libera data e horario
  - botao voltar retorna
  - botoes de mes anterior e proximo navegam no calendario
  - CTA de erro `Tentar novamente` recarrega disponibilidades
  - toque em servico seleciona duracao/base do agendamento
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
  - quando nao ha sessao autenticada, mostra tela visitante com CTA de cadastro/login e imagem `assets/patrick.jpg`
  - abre subpaginas de editar perfil, notificacoes, seguranca, configuracoes e ajuda
  - item `Minhas Localizações` exibe `SnackBar` de placeholder
  - `Sair` abre dialogo de confirmacao, limpa a sessao e retorna para `LoginPage`
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
- `lib/shop_components/shop_bottomnav.dart`
  - bottom navigation da area `shop_*`
  - usa tokens de `AppColors` para fundo, borda, sombra, estados e labels
- `lib/shop_components/shop_ui.dart`
  - concentra helpers visuais reutilizados da area `shop_*`
  - padroniza app bar secundaria, sombra de card e `InputDecoration`

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
  - lista notificacoes reais do usuario autenticado
  - permite marcar uma notificacao como lida e marcar todas como lidas
  - carrega e salva preferencias reais de agendamentos, mensagens, promocoes, novidades e resumo por e-mail
  - possui estados de loading, erro, vazio e refresh integrado com API
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

### Area shop mockada

- `lib/shop_pages/shop_home.dart`
  - dashboard mockado do estabelecimento
  - cards e chips foram alinhados aos tokens de `AppColors`
- `lib/shop_pages/shop_schedule.dart`
  - agenda mockada do estabelecimento com calendario e lista do dia
  - cards, estados selecionados e superficies usam o tema central
- `lib/shop_pages/shop_clients.dart`
  - lista de clientes e conversa mockada
  - busca, cards e tela de chat usam o mesmo padrao visual do app
- `lib/shop_pages/shop_profile.dart`
  - hub de configuracoes do estabelecimento
  - acessa dados do estabelecimento, galeria, horarios, servicos, notificacoes, privacidade, ajuda e sobre
- `lib/shop_pages/shop_establishment_data.dart`
  - formulario mockado de dados do estabelecimento
- `lib/shop_pages/shop_gallery.dart`
  - galeria mockada de fotos com estado local
- `lib/shop_pages/shop_work_days.dart`
  - configuracao mockada de dias de funcionamento
- `lib/shop_pages/shop_work_hours.dart`
  - configuracao mockada de horarios de atendimento
- `lib/shop_pages/shop_service_duration.dart`
  - configuracao mockada de servicos, duracao e preco
- `lib/shop_pages/shop_notifications.dart`
  - preferencias mockadas de notificacao
- `lib/shop_pages/shop_privacy.dart`
  - preferencias mockadas de privacidade e seguranca
- `lib/shop_pages/shop_help.dart`
  - ajuda mockada do estabelecimento
- `lib/shop_pages/shop_about.dart`
  - informacoes mockadas sobre a experiencia de estabelecimento

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
- `lib/models/notificacao.dart`
  - modelo do feed de notificacoes in-app vindo do backend
- `lib/models/notificacao_preferencias.dart`
  - modelo das preferencias persistidas de notificacao

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
  - endpoints de notificacoes, contagem de nao lidas, leitura individual/em massa e preferencias
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
  - gera notificacao real para o outro participante quando uma mensagem e enviada
  - limpa mensagens expiradas diariamente preservando a ultima mensagem por conversa e aplicando graca de 5 dias pela ultima atividade
- `backend/src/main/java/com/duckhat/api/service/NotificacaoEventoService.java`
  - mantem o feed de notificacoes por usuario
  - aplica owner-check por usuario autenticado
  - gerencia preferencias persistidas de notificacoes
  - gera notificacoes automaticas de agenda e chat respeitando preferencias
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
- `database/migrations/V6__notification_feed_and_preferences.sql`
  - evolui `notificacao_eventos` para feed por usuario e cria `notificacao_preferencias`
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
  - notificacoes in-app e preferencias persistidas
- Mockados ou locais
  - busca textual e filtros da busca
  - resultados e mapa da busca
  - reviews e FAQ do estabelecimento
  - parte das subpaginas de perfil
  - minhas localizacoes no perfil
  - banner promocional e boa parte da home

## Regra de manutencao

Sempre que uma mudanca alterar comportamento, navegacao, botoes, integracao ou responsabilidade de arquivo, atualizar este documento junto com o codigo.
