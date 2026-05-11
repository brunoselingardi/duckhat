# Fase 1 da Pagina Publica de Estabelecimento

## Objetivo

Transformar a tela atual de estabelecimento em um template orientado por `prestadorId`, removendo a dependencia direta de `service_data.dart` como fonte principal e centralizando os fallbacks temporarios no front.

## Escopo desta fase

- Introduzir um contrato interno de dados para a pagina publica.
- Fazer a `ServicePage` receber `prestadorId`.
- Carregar servicos reais por `prestadorId`.
- Carregar dados publicos minimos do estabelecimento via camada de adaptacao no front.
- Permitir imagem de capa, logo e galeria por URL/caminho.
- Corrigir os pontos internos conhecidos que hoje abrem `ServicePage()` sem identidade.
- Manter busca externa e catalogo interno completo fora desta fase.

## Fora de escopo

- Upload real de imagens.
- Busca 100% integrada ao catalogo interno do backend.
- CRUD completo de perfil publico do prestador.
- Galeria persistida no backend.
- Slug publico.

## Estado atual resumido

- `ServicePage` ja busca servicos reais, mas usa `prestadorId` fixo vindo de `service_data.dart`.
- Hero, info card, experiencia, galeria, avaliacoes e FAQ seguem hardcoded.
- Busca e atalhos internos abrem `ServicePage()` sem contexto do prestador.
- Existe um modelo inicial `EstabelecimentoPublico` no Flutter e campos novos de perfil publico ja apareceram no backend em progresso.

## Decisao de arquitetura

O front passa a ter um contrato proprio de pagina publica, com uma camada de carga que combina:

- dados publicos do estabelecimento quando disponiveis;
- servicos reais do catalogo por `prestadorId`;
- fallbacks temporarios centralizados para campos ainda ausentes no backend.

Os widgets visuais deixam de conhecer mocks diretamente. O fallback continua existindo apenas em uma borda de adaptacao.

## Estrutura prevista

- `EstabelecimentoPublico`: dados publicos base do estabelecimento.
- `ServicePage`: recebe `prestadorId` e orquestra carga.
- repositório/adaptador de perfil publico: monta o estado da tela.
- componentes `service_*`: passam a receber dados por props.

## Fluxo da fase 1

1. Um ponto interno do app abre a pagina com `prestadorId`.
2. A pagina busca o perfil publico do estabelecimento.
3. A pagina busca servicos ativos desse `prestadorId`.
4. A UI renderiza hero, resumo, experiencia e galeria com base no perfil carregado.
5. Chat e agendamento usam o mesmo `prestadorId`.

## Estados esperados

- `loading`: enquanto carrega perfil e servicos.
- `erro`: falha ao obter dados publicos ou servicos.
- `sem servicos`: estabelecimento encontrado, mas sem servicos ativos.
- `sem dados publicos suficientes`: usa fallback centralizado apenas nesta fase.

## Validacao da fase 1

- A pagina abre com `prestadorId` explicito.
- Chat e agendamento usam o `prestadorId` recebido.
- A tela deixa de depender de textos/imagens hardcoded espalhados.
- O mock permanece apenas na camada de fallback temporario.
