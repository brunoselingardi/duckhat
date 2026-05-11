# Estabelecimento Publico Fase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** refatorar a pagina publica do estabelecimento para receber `prestadorId`, carregar servicos reais e consumir um perfil publico hibrido no front sem depender de mocks espalhados.

**Architecture:** a `ServicePage` vira uma pagina orientada por identidade real do prestador. Um adaptador central combina perfil publico, servicos do catalogo e fallbacks temporarios, enquanto os widgets visuais passam a receber apenas dados prontos para renderizacao.

**Tech Stack:** Flutter, flutter_test, arquitetura atual do app DuckHat, `DuckHatApi`, modelos Dart existentes.

---

### Task 1: Fechar o contrato de dados da pagina publica

**Files:**
- Modify: `lib/models/estabelecimento_publico.dart`
- Test: `test/estabelecimento_publico_test.dart`

- [ ] **Step 1: Escrever teste para o contrato de dados minimo**

```dart
test('parses public provider profile from API payload', () {
  final perfil = EstabelecimentoPublico.fromJson({
    'id': 12,
    'nome': 'DuckHat Studio',
    'telefone': '62999990000',
    'endereco': 'Av. Central, 100',
    'descricaoPublica': 'Cortes e cuidados para todos os estilos.',
    'horarioAtendimento': 'Segunda a sexta 9h - 20h',
    'imagemCapa': 'https://cdn.example.com/capa.jpg',
    'imagemLogo': 'https://cdn.example.com/logo.jpg',
  });

  expect(perfil.id, 12);
  expect(perfil.nome, 'DuckHat Studio');
  expect(perfil.imagemCapa, 'https://cdn.example.com/capa.jpg');
  expect(perfil.imagemLogo, 'https://cdn.example.com/logo.jpg');
});
```

- [ ] **Step 2: Rodar o teste para garantir que cobre o contrato**

Run: `flutter test test/estabelecimento_publico_test.dart`
Expected: PASS

- [ ] **Step 3: Ajustar o modelo se necessario para suportar o contrato**

```dart
class EstabelecimentoPublico {
  final int id;
  final String nome;
  final String? telefone;
  final String? endereco;
  final String? descricaoPublica;
  final String? horarioAtendimento;
  final String? imagemCapa;
  final String? imagemLogo;
}
```

- [ ] **Step 4: Rodar o teste novamente**

Run: `flutter test test/estabelecimento_publico_test.dart`
Expected: PASS

### Task 2: Introduzir a carga hibrida da pagina publica

**Files:**
- Create: `lib/components/service/service_profile_fallbacks.dart`
- Modify: `lib/pages/service.dart`
- Modify: `lib/services/duckhat_api.dart`
- Test: `test/service_page_test.dart`

- [ ] **Step 1: Escrever teste para a nova assinatura da pagina**

```dart
await tester.pumpWidget(
  const MaterialApp(home: ServicePage(prestadorId: 2)),
);

expect(find.byType(ServicePage), findsOneWidget);
```

- [ ] **Step 2: Rodar o teste e confirmar falha se a assinatura ainda nao existir**

Run: `flutter test test/service_page_test.dart`
Expected: FAIL with constructor mismatch or missing required argument

- [ ] **Step 3: Criar fallbacks centralizados para o prestador conhecido**

```dart
const fallbackEstabelecimentos = {
  2: EstabelecimentoPublico(
    id: 2,
    nome: 'Barbie Dream Barber',
    telefone: '5562999990001',
    endereco: 'Av. DuckHat, 120 - Setor Bueno',
    descricaoPublica: '...',
    horarioAtendimento: 'Segunda a sexta 9h - 20h | Sabado 9h - 18h',
    imagemCapa: 'assets/barbie.jpg',
    imagemLogo: 'assets/barbielogo.jpg',
  ),
};
```

- [ ] **Step 4: Refatorar `ServicePage` para receber `prestadorId` e carregar dados**

```dart
class ServicePage extends StatefulWidget {
  final int prestadorId;

  const ServicePage({super.key, required this.prestadorId});
}
```

- [ ] **Step 5: Criar metodo de carga do perfil publico no app**

```dart
Future<EstabelecimentoPublico> carregarEstabelecimentoPublico(
  int prestadorId,
) async {
  try {
    return await DuckHatApi.instance.carregarEstabelecimentoPublico(prestadorId);
  } catch (_) {
    final fallback = fallbackEstabelecimentos[prestadorId];
    if (fallback != null) return fallback;
    rethrow;
  }
}
```

- [ ] **Step 6: Rodar o teste da pagina**

Run: `flutter test test/service_page_test.dart`
Expected: PASS

### Task 3: Tornar os widgets da pagina publicos e orientados por dados

**Files:**
- Modify: `lib/components/service/service_hero.dart`
- Modify: `lib/components/service/service_info_card.dart`
- Modify: `lib/components/service/service_experience_section.dart`
- Modify: `lib/components/service/service_gallery_section.dart`
- Modify: `lib/components/service/service_sections.dart`
- Modify: `lib/pages/service.dart`
- Test: `test/service_page_test.dart`

- [ ] **Step 1: Escrever teste para exibir nome dinamico**

```dart
expect(find.text('Barbie Dream Barber'), findsOneWidget);
```

- [ ] **Step 2: Rodar o teste para confirmar falha com dados ainda estaticos**

Run: `flutter test test/service_page_test.dart`
Expected: FAIL if widgets still depend on hardcoded data path

- [ ] **Step 3: Passar dados por props para hero, info card e secoes**

```dart
ServiceHero(
  imagePathOrUrl: perfil.imagemCapa,
  onBack: () => Navigator.pop(context),
)
```

- [ ] **Step 4: Trocar `Image.asset` por renderer que aceite asset ou URL**

```dart
Widget buildAdaptiveImage(String? source) {
  if (source == null || source.isEmpty) return const SizedBox.shrink();
  if (source.startsWith('http')) return Image.network(source, fit: BoxFit.cover);
  return Image.asset(source, fit: BoxFit.cover);
}
```

- [ ] **Step 5: Rodar o teste da pagina novamente**

Run: `flutter test test/service_page_test.dart`
Expected: PASS

### Task 4: Corrigir navegacao dos pontos internos conhecidos

**Files:**
- Modify: `lib/pages/search.dart`
- Modify: `lib/pages/search_results.dart`
- Modify: `lib/components/home/rebookcard.dart`
- Modify: `lib/pages/promotions.dart`
- Modify: `lib/services/search_intent.dart`
- Test: `test/search_page_test.dart`

- [ ] **Step 1: Escrever teste para manter a busca renderizando**

```dart
await tester.pumpWidget(const MaterialApp(home: SearchPage()));
expect(find.text('Barbeiro'), findsOneWidget);
```

- [ ] **Step 2: Rodar o teste existente da busca**

Run: `flutter test test/search_page_test.dart`
Expected: PASS

- [ ] **Step 3: Adicionar `prestadorId` opcional aos resultados internos demo**

```dart
SearchDemoPlace(
  id: 'duckhat-barbie-dream-barber',
  name: 'Barbie Dream Barber',
  hasInternalPage: true,
  prestadorId: 2,
)
```

- [ ] **Step 4: Trocar aberturas de `ServicePage()` para `ServicePage(prestadorId: ...)`**

```dart
Navigator.of(context).push(
  AppRoute(builder: (_) => const ServicePage(prestadorId: 2)),
);
```

- [ ] **Step 5: Rodar o teste da busca novamente**

Run: `flutter test test/search_page_test.dart`
Expected: PASS

### Task 5: Verificacao final do recorte

**Files:**
- Modify: `docs/funcionalidades-por-arquivo.md`

- [ ] **Step 1: Rodar os testes do recorte**

Run: `flutter test test/estabelecimento_publico_test.dart test/search_page_test.dart test/service_page_test.dart`
Expected: PASS

- [ ] **Step 2: Rodar analise estatica do app**

Run: `flutter analyze`
Expected: exit 0

- [ ] **Step 3: Atualizar documentacao curta do recorte**

```md
- ServicePage agora recebe prestadorId.
- Perfil publico usa camada hibrida com fallback centralizado.
- Pontos internos conhecidos deixam de abrir pagina sem contexto.
```
