#!/usr/bin/env bash
# Script de exemplo para rodar o app com as integrações Google (Places + Sign-In).
#
# COMO USAR:
#   1. Copie este arquivo para `run_ios.sh` (que é ignorado pelo git):
#        cp run_ios.example.sh run_ios.sh
#   2. Preencha as chaves abaixo no run_ios.sh.
#   3. Rode:  ./run_ios.sh            (usa o 1º simulador/dispositivo)
#             ./run_ios.sh <device>   (id ou nome do device, ex.: "iPhone 16e")
#
# Onde obter cada chave (Google Cloud Console):
#   - GOOGLE_MAPS_API_KEY        → chave da Places API (New) / Maps SDK
#   - GOOGLE_SERVER_CLIENT_ID    → OAuth Client ID do tipo *Web* (validado pelo backend no /Usuario/login/google)
#   - GOOGLE_IOS_CLIENT_ID       → OAuth Client ID do tipo *iOS* (bundle com.example.app)
#                                  Lembre de registrar o REVERSED_CLIENT_ID em ios/Runner/Info.plist (CFBundleURLTypes)
#   - ENABLE_MAPS=true           → ativa o mapa embutido (requer chave nativa do Maps SDK no AppDelegate/AndroidManifest)

set -e

GOOGLE_MAPS_API_KEY="SUA_CHAVE_MAPS"
GOOGLE_SERVER_CLIENT_ID="SEU_WEB_CLIENT_ID.apps.googleusercontent.com"
GOOGLE_IOS_CLIENT_ID="SEU_IOS_CLIENT_ID.apps.googleusercontent.com"

DEVICE="${1:-}"
DEVICE_ARG=()
[ -n "$DEVICE" ] && DEVICE_ARG=(-d "$DEVICE")

flutter run "${DEVICE_ARG[@]}" \
  --dart-define=GOOGLE_MAPS_API_KEY="$GOOGLE_MAPS_API_KEY" \
  --dart-define=GOOGLE_SERVER_CLIENT_ID="$GOOGLE_SERVER_CLIENT_ID" \
  --dart-define=GOOGLE_IOS_CLIENT_ID="$GOOGLE_IOS_CLIENT_ID"
  # --dart-define=ENABLE_MAPS=true
