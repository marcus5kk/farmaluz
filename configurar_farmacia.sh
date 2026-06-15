#!/bin/bash

# ============================================================
#  CONFIGURAR FARMÁCIA - Script de configuração automática
#  Uso: ./configurar_farmacia.sh
# ============================================================

echo "========================================"
echo "  Configurador de Farmácia - APK Builder"
echo "========================================"
echo ""

read -p "ID da farmácia (número do admin): " FARMACIA_ID
read -p "Nome da farmácia (ex: Farmaluz): " NOME_FARMACIA
read -p "Package name (ex: com.farmaluz.app): " PACKAGE_NAME
read -p "Cor principal em hex (ex: #E63946): " COR_PRINCIPAL
read -p "Cor de fundo em hex (ex: #F5F5F5): " COR_FUNDO

echo ""
echo "--- Confirmação ---"
echo "ID:        $FARMACIA_ID"
echo "Nome:      $NOME_FARMACIA"
echo "Package:   $PACKAGE_NAME"
echo "Cor:       $COR_PRINCIPAL"
echo "Fundo:     $COR_FUNDO"
echo ""
read -p "Confirmar? (s/n): " CONFIRMA

if [ "$CONFIRMA" != "s" ] && [ "$CONFIRMA" != "S" ]; then
  echo "Cancelado."
  exit 0
fi

# --- 1. Atualiza app_config.dart ---
echo ">> Atualizando app_config.dart..."
cat > lib/config/app_config.dart << EOF
class AppConfig {
  static const int farmaciaId = $FARMACIA_ID;
  static const String nomeFarmacia = "$NOME_FARMACIA";
  static const String apiBaseUrl = "https://api.appfarmacias.com.br";
  static const String corPrimaria = "$COR_PRINCIPAL";
  static const String corSecundaria = "#FFFFFF";
  static const String corFundo = "$COR_FUNDO";
}
EOF

# --- 2. Atualiza build.gradle.kts ---
echo ">> Atualizando build.gradle.kts..."
sed -i "s|namespace = \".*\"|namespace = \"$PACKAGE_NAME\"|g" android/app/build.gradle.kts
sed -i "s|applicationId = \".*\"|applicationId = \"$PACKAGE_NAME\"|g" android/app/build.gradle.kts

# --- 3. Cria a pasta e MainActivity.kt no package correto ---
echo ">> Criando MainActivity.kt no package correto..."
PACKAGE_PATH=$(echo $PACKAGE_NAME | tr '.' '/')
mkdir -p android/app/src/main/kotlin/$PACKAGE_PATH
cat > android/app/src/main/kotlin/$PACKAGE_PATH/MainActivity.kt << EOF
package $PACKAGE_NAME

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
EOF

# --- 4. Atualiza o nome do app no strings.xml ---
echo ">> Atualizando strings.xml..."
cat > android/app/src/main/res/values/strings.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$NOME_FARMACIA</string>
</resources>
EOF

# --- 5. flutter pub get ---
echo ">> Rodando flutter pub get..."
flutter pub get

# --- 6. Configura icone do app (flutter_launcher_icons) ---
echo ">> Verificando icone do app..."
if [ -f "assets/images/icone.png" ]; then
  echo ">> icone.png encontrado - configurando flutter_launcher_icons..."
  cat > flutter_launcher_icons.yaml << EOF
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/images/icone.png"
  min_sdk_android: 21
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/icone.png"
EOF
  echo ">> Gerando icones do app..."
  dart run flutter_launcher_icons
  echo ">> Icone do app configurado com sucesso!"
else
  echo ">> AVISO: assets/images/icone.png nao encontrado."
  echo ">> Para definir o icone do app, coloque o arquivo icone.png em assets/images/"
  echo ">> O arquivo deve ser quadrado, minimo 1024x1024px, formato PNG."
fi

echo ""
echo "========================================"
echo "  Pronto! Agora execute no terminal:"
echo "  flutter clean && flutter build apk --release"
echo "========================================"
