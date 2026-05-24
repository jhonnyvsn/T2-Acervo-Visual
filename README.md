# Acervo Inteligente — App Flutter

Aplicativo Flutter para catalogação de objetos usando visão computacional com ML Kit, Firebase Authentication, Cloud Firestore e Firebase Storage.

---

## 📋 Pré-requisitos

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio instalado
- Emulador Android ou dispositivo físico Android
- Conta Firebase com projeto criado
- FlutterFire CLI instalado

> ⚠️ Este projeto funciona apenas em Android, pois utiliza câmera e funcionalidades nativas do ML Kit.

---

# 🔧 Setup — Passo a Passo

## 1. Clone / Extraia o projeto

```bash
cd t2-acervo-visual
flutter pub get
```

---

## 2. Configure o Firebase

### a) Instale o FlutterFire CLI (se ainda não tiver)

```bash
dart pub global activate flutterfire_cli
```

### b) Faça login no Firebase

```bash
firebase login
```

### c) Configure o projeto Firebase

```bash
flutterfire configure
```

Selecione seu projeto Firebase e a plataforma Android.

O comando irá gerar automaticamente:

```bash
lib/firebase_options.dart
```

---

## 3. Habilite os serviços no Firebase Console

No painel do Firebase, habilite:

- Authentication → Método E-mail/Senha
- Cloud Firestore
- Firebase Storage

---

# 🔐 Configuração do Firebase Authentication

No Firebase Console:

```text
Authentication → Sign-in method → Email/Password → Enable
```

---

# 🗄️ Configuração do Firestore

Crie a coleção:

```text
acervo
```

Os documentos serão criados automaticamente pelo app.

## Estrutura esperada do documento

| Campo | Tipo |
|---|---|
| uid | string |
| nome | string |
| rotuloML | string |
| fotoUrl | string |
| observacoes | string |

---

# ☁️ Configuração do Firebase Storage

Estrutura utilizada:

```text
acervo/{uid}/arquivo.jpg
```

As imagens serão enviadas automaticamente pelo aplicativo.

---

# 🔒 Regras do Firestore (desenvolvimento)

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /acervo/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

# 🔒 Regras do Firebase Storage (desenvolvimento)

```js
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    match /acervo/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

# 🤖 Dependências Utilizadas

## pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  google_mlkit_image_labeling: ^0.13.0
  image_picker: ^1.1.0
  permission_handler: ^11.3.0
```

---

# 📱 Configuração Android

## AndroidManifest.xml

Arquivo:

```text
android/app/src/main/AndroidManifest.xml
```

Adicione:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

---

## minSdkVersion

Arquivo:

```text
android/app/build.gradle
```

Configure:

```gradle
defaultConfig {
    minSdkVersion 21
}
```

> Necessário para funcionamento do `google_mlkit_image_labeling`.

---

# ▶️ Execute o app

```bash
flutter run
```

---

# 🗂️ Estrutura do Projeto

```text
lib/
├── main.dart
├── models/
│   └── item_acervo.dart
└── screens/
    ├── acervo_screen.dart
    ├── auth_screen.dart
    ├── classificar_screen.dart
    └── salvar_screen.dart

android/
ios/
linux/
macos/
test/
web/
windows/

pubspec.yaml
firebase.json
README.md
```

---

# 📸 Fluxo do Aplicativo

## Tela 1 — Login / Cadastro

- Login com e-mail e senha
- Cadastro de novos usuários
- Firebase Authentication
- Validação de formulário
- Logout disponível após autenticação

---

## Tela 2 — Meu Acervo

- Lista em tempo real usando `StreamBuilder`
- Filtragem por `uid`
- Exibição de:
  - Foto
  - Nome
  - Rótulo identificado pelo ML Kit
- Exclusão com confirmação (`AlertDialog`)
- Botão flutuante para adicionar novo item

---

## Tela 3 — Classificar Item

- Captura pela câmera
- Seleção da galeria
- Permissão com `permission_handler`
- Classificação da imagem usando ML Kit
- Exibição dos rótulos e porcentagem de confiança

Exemplo:

```text
Plant — 91%
Food — 84%
Vehicle — 72%
```

---

## Tela 4 — Salvar Item

- Recebe foto e rótulos via navegação
- Formulário com validação
- Upload para Firebase Storage
- Salvamento no Firestore
- Indicador de progresso durante upload

---

# 🧠 Classificação de Imagem — ML Kit

```dart
final labeler = ImageLabeler(
  options: ImageLabelerOptions(
    confidenceThreshold: 0.5,
  ),
);

final inputImage = InputImage.fromFilePath(caminhoImagem);

final labels = await labeler.processImage(inputImage);
```

Cada rótulo possui:

| Campo | Descrição |
|---|---|
| label.label | Nome do objeto identificado |
| label.confidence | Valor entre 0.0 e 1.0 |

---

# ☁️ Upload de Imagem

```dart
Future<String> uploadFoto(
  String caminhoLocal,
  String uid,
) async {

  final arquivo = File(caminhoLocal);

  final ref = FirebaseStorage.instance
      .ref()
      .child(
        'acervo/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

  await ref.putFile(arquivo);

  return await ref.getDownloadURL();
}
```

---

# 🧩 Modelo de Dados

```dart
class ItemAcervo {
  final String id;
  final String uid;
  final String nome;
  final String rotuloML;
  final String observacoes;
  final String fotoUrl;

  ItemAcervo({
    required this.id,
    required this.uid,
    required this.nome,
    required this.rotuloML,
    required this.fotoUrl,
    this.observacoes = '',
  });

  factory ItemAcervo.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ItemAcervo(
      id: doc.id,
      uid: data['uid'],
      nome: data['nome'],
      rotuloML: data['rotuloML'],
      fotoUrl: data['fotoUrl'],
      observacoes: data['observacoes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nome': nome,
    'rotuloML': rotuloML,
    'fotoUrl': fotoUrl,
    'observacoes': observacoes,
  };
}
```

---

# ✅ Requisitos Técnicos Atendidos

| Requisito | Onde |
|---|---|
| 4 telas navegáveis | Auth → Acervo → Classificar → Salvar |
| Firebase Auth (login/cadastro/logout) | `auth_screen.dart` |
| StatefulWidget com setState (≥2) | `classificar_screen.dart`, `salvar_screen.dart` |
| Form + TextFormField + validação | Login/Cadastro e Salvar Item |
| StreamBuilder vinculado ao Firestore | `acervo_screen.dart` |
| Firestore add + delete | Tela de acervo |
| Upload para Firebase Storage | `salvar_screen.dart` |
| Exibição de imagem via URL | `Image.network()` |
| ML Kit — processImage() | `classificar_screen.dart` |
| Permissão de câmera | `permission_handler` |
| Captura/galeria com image_picker | `classificar_screen.dart` |
| Navegação com passagem de objeto | Classificar → Salvar |
| Classe Dart com fromDoc + toMap | `item_acervo.dart` |
| ListView.builder | Lista do acervo e rótulos |

---

# 👨‍💻 Integrantes do Grupo

- Nome do Integrante 1
- Nome do Integrante 2
- Nome do Integrante 3

---

# 🚀 Tecnologias Utilizadas

- Flutter
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Google ML Kit
- Image Picker
- Permission Handler
