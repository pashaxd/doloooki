# 🔐 Firebase Configuration Setup

## ⚠️ CRITICAL SECURITY WARNING

**НИКОГДА НЕ КОММИТЬТЕ В GIT СЛЕДУЮЩИЕ ФАЙЛЫ:**
- `lib/firebase_options.dart` - содержит API ключи
- `android/app/google-services.json` - Android конфигурация
- `ios/Runner/GoogleService-Info.plist` - iOS конфигурация  
- `serviceAccount.json` - сервисные ключи
- Любые миграционные скрипты с секретами

## 🚨 Если API ключи уже попали в Git

1. **НЕМЕДЛЕННО смените API ключи в Firebase Console:**
   - Перейдите в [Firebase Console](https://console.firebase.google.com)
   - Выберите ваш проект
   - Project Settings → General → Your apps
   - Пересоздайте конфигурацию для каждой платформы

2. **Удалите файлы из Git истории:**
   ```bash
   git filter-branch --index-filter 'git rm --cached --ignore-unmatch lib/firebase_options.dart' HEAD
   git filter-branch --index-filter 'git rm --cached --ignore-unmatch android/app/google-services.json' HEAD
   git filter-branch --index-filter 'git rm --cached --ignore-unmatch ios/Runner/GoogleService-Info.plist' HEAD
   ```

3. **Форсируйте пуш (ОСТОРОЖНО!):**
   ```bash
   git push --force-with-lease origin main
   ```

## 📝 Настройка для разработки

### Шаг 1: Скопируйте шаблон
```bash
cp lib/firebase_options_template.dart lib/firebase_options.dart
```

### Шаг 2: Замените плейсхолдеры
Откройте `lib/firebase_options.dart` и замените:
- `YOUR_WEB_API_KEY_HERE` → настоящий Web API key
- `YOUR_ANDROID_API_KEY_HERE` → настоящий Android API key  
- `YOUR_IOS_API_KEY_HERE` → настоящий iOS API key
- `YOUR_PROJECT_ID_HERE` → ID вашего проекта
- `YOUR_SENDER_ID_HERE` → Sender ID
- `YOUR_APP_ID_HERE` → App ID для каждой платформы

### Шаг 3: Настройка платформ

**Android:**
1. Скачайте `google-services.json` из Firebase Console
2. Поместите в `android/app/google-services.json`

**iOS:**
1. Скачайте `GoogleService-Info.plist` из Firebase Console  
2. Поместите в `ios/Runner/GoogleService-Info.plist`

## 🔒 Получение конфигурации

### Через Firebase CLI (рекомендуется):
```bash
firebase login
firebase use YOUR_PROJECT_ID
flutterfire configure
```

### Через Firebase Console:
1. Project Settings → General → Your apps
2. Выберите платформу (Web/Android/iOS)
3. Скачайте конфигурационные файлы

## 🚀 Настройка для продакшена

### Cloud Run/App Engine:
Firebase API ключи для web безопасны для клиентского кода.
Переменные окружения настраиваются через Firebase App Hosting.

### Mobile App Store:
Конфигурационные файлы встраиваются в приложение при сборке.

## ✅ Проверка безопасности

Убедитесь, что следующие файлы в `.gitignore`:
```
lib/firebase_options.dart
android/app/google-services.json  
ios/Runner/GoogleService-Info.plist
serviceAccount.json
*.log
```

## 📱 Контакты

При проблемах с настройкой обращайтесь к документации:
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com) 