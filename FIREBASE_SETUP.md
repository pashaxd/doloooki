# 🔐 Firebase Configuration Setup

## ВАЖНО: Настройка API ключей Firebase

Ваши API ключи Firebase НЕ должны храниться в репозитории! Следуйте этим инструкциям для безопасной настройки.

## 🚨 Если API ключи уже попали в Git

1. **Смените API ключи в Firebase Console:**
   - Перейдите в [Firebase Console](https://console.firebase.google.com)
   - Выберите проект `dolooki-fb888`
   - Project Settings → General → Your apps
   - Пересоздайте конфигурацию для каждой платформы

2. **Очистите историю Git (если нужно):**
   ```bash
   git filter-branch --index-filter 'git rm --cached --ignore-unmatch lib/firebase_options.dart' HEAD
   ```

## 📝 Настройка для разработки

1. **Скопируйте шаблон:**
   ```bash
   cp lib/firebase_options_template.dart lib/firebase_options.dart
   ```

2. **Замените плейсхолдеры на настоящие ключи:**
   - Откройте `lib/firebase_options.dart`
   - Замените `YOUR_*_API_KEY_HERE` на настоящие API ключи из Firebase Console

3. **Для Android:**
   - Скачайте `google-services.json` из Firebase Console
   - Поместите в `android/app/google-services.json`

4. **Для iOS:**
   - Скачайте `GoogleService-Info.plist` из Firebase Console
   - Поместите в `ios/Runner/GoogleService-Info.plist`

## 🚀 Настройка для деплоя (Cloud Run)

Firebase API ключи для web-приложений считаются публичными и безопасны для использования в клиентском коде.

Переменные окружения уже настроены в Cloud Build через Firebase App Hosting:
- `FIREBASE_CONFIG`
- `FIREBASE_WEBAPP_CONFIG`

## ✅ Проверка

Убедитесь, что файлы с секретами НЕ попадают в Git:
```bash
git status --ignored
```

Должны быть проигнорированы:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist` 