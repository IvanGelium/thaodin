#!/bin/bash

GAME_NAME="Thaodin"

mkdir -p output

build_mac() {
    echo "🔨 Сборка для macOS..."
    odin build ./src -out:"output/${GAME_NAME}"
    echo "✅ Готово: output/${GAME_NAME}"
}

build_win() {
    echo "🔨 Сборка для Windows..."
    odin build ./src -target:windows_amd64 -subsystem:windows -out:"output/${GAME_NAME}.exe"
    echo "✅ Готово: output/${GAME_NAME}.exe"
}

case "$1" in
    -m)
        build_mac
        ;;
    -w)
        build_win
        ;;
    "")
        build_mac
        build_win
        ;;
    *)
        echo "❌ Ошибка: Неверный флаг!"
        echo "Использование:"
        echo "  ./build.sh      - Собрать обе версии"
        echo "  ./build.sh -m   - Собрать только для Mac"
        echo "  ./build.sh -w   - Собрать только для Windows"
        exit 1
        ;;
esac
