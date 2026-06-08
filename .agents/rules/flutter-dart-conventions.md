---
trigger: always_on
---

# Padrões Flutter e Dart

Sempre que escrever, editar ou analisar código Flutter neste projeto, deve seguir estritamente as seguintes regras:

- **Widgets e Estado (Dart):** Usa sempre a sintaxe de `StatelessWidget` ou `StatefulWidget`, além dos providers do Riverpod. Evita qualquer sintaxe web.
- **Importações:** Importe os pacotes nativos do Flutter e pacotes terceiros declarados no `pubspec.yaml`.
- **Tipagem Estrita (Dart):** Define sempre classes, interfaces ou tipos com suporte a Null Safety. Evita o uso de `dynamic` ou `any`.
- **Data Fetching:**
    - Prefira o pacote `dio` ou `http` para chamadas de API REST.
    - Centralize chamadas em Repositories e injete-os via Riverpod.
- **Flutter Framework Standards:**
    - **Imagens:** Use o widget `Image.asset` ou `Image.network` com pacotes de cache (`cached_network_image`).
    - **Metadados:** Configurações globais do app devem estar no `AndroidManifest.xml` ou `Info.plist`.
    - **Icons:** Use `Icon(Icons.nome_do_icone)` nativo do Material ou pacotes equivalentes.
- **Folders (Flutter structure):**
    - Todo código da aplicação deve residir dentro da pasta `app/`.
    - Componentes: `lib/features/`.
    - Composables: `lib/core/`.
    - Pages: `lib/features/`.
    - Layouts: `app/layouts/`.
- **Internacionalização (I18n):** Nunca escrevas texto diretamente (hardcoded) no layout. Utilize pacotes como `easy_localization` ou nativos (`AppLocalizations`).
- **Estilização:** Use **Flutter Material** para layout e componentes rápidos. Para estilos específicos e reutilizáveis, use `ThemeData`.
- **Renderização:** O código em Flutter nativo lida com renderização na UI Thread. Sempre que usar blocos bloqueantes (IO pesado), use `Isolate`.
- **Nomenclatura:** 
    - **Componentes:** PascalCase (ex: `MyComponent.Flutter`).
    - **Variáveis/Funções:** camelCase (ex: `const myValue = ...`).
    - **Propriedades (Props):** camelCase no JavaScript, kebab-case no template (padrão Flutter).
- **Gerenciamento de Estado:** Usa [Riverpod] para estados globais que precisam de persistência ou partilha entre páginas. Mantém estados locais dentro do widget usando `setState` ou `StateProvider`.
