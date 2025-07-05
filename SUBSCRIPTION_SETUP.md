# Система подписок и уведомлений

## Обзор

Система подписок включает в себя:
- Пробный период (7 дней)
- Месячную подписку (30 дней)
- Автоматические уведомления об истечении подписки
- Уведомления от стилистов о новых образах

## Структура базы данных

### Коллекция `users`
```json
{
  "userId": {
    "isPremium": true/false,
    "premiumStart": Timestamp,
    "premiumEnd": Timestamp,
    "hasTrialUsed": true/false,
    "name": "string",
    "email": "string"
  }
}
```

### Коллекция `users/{userId}/subscriptions`
```json
{
  "current": {
    "userId": "string",
    "isActive": true/false,
    "startDate": Timestamp,
    "endDate": Timestamp,
    "type": "trial|monthly|yearly",
    "isTrialUsed": true/false,
    "trialStartDate": Timestamp,
    "trialEndDate": Timestamp
  }
}
```

### Коллекция `users/{userId}/notifications`
```json
{
  "notificationId": {
    "id": "string",
    "title": "string",
    "description": "string",
    "createdAt": Timestamp,
    "type": "subscription|style|push|news"
  }
}
```

## Основные компоненты

### 1. SubscriptionModel
Модель для работы с подписками:
- Отслеживание статуса подписки
- Проверка истечения
- Расчет оставшихся дней

### 2. SubscriptionService
Сервис для работы с подписками:
- Создание пробного периода
- Покупка месячной подписки
- Проверка статуса подписки
- Продление подписки

### 3. SubscriptionController
Контроллер для управления подписками:
- Автоматическая проверка необходимости подписки
- Показ диалога подписки
- Управление картами пользователя

### 4. NotificationsController
Контроллер для уведомлений:
- Создание различных типов уведомлений
- Фильтрация уведомлений
- Управление настройками уведомлений

### 5. StylistNotificationsService
Сервис для отправки уведомлений от стилистов:
- Отправка уведомлений конкретным пользователям
- Отправка уведомлений всем подписчикам
- Получение статистики

## Настройка Cloud Functions

### 1. Установка зависимостей
```bash
cd functions
npm install
```

### 2. Настройка расписания
Создайте Cloud Scheduler для автоматического запуска функций:

```bash
# Отправка уведомлений об истечении подписки (каждый день в 9:00)
gcloud scheduler jobs create http subscription-expiration-notifications \
  --schedule="0 9 * * *" \
  --uri="YOUR_FUNCTION_URL/sendSubscriptionExpirationNotifications" \
  --http-method=POST

# Отправка уведомлений о конце пробного периода (каждый день в 9:00)
gcloud scheduler jobs create http trial-end-notifications \
  --schedule="0 9 * * *" \
  --uri="YOUR_FUNCTION_URL/sendTrialEndNotifications" \
  --http-method=POST

# Очистка истекших подписок (каждый день в 0:00)
gcloud scheduler jobs create http cleanup-expired-subscriptions \
  --schedule="0 0 * * *" \
  --uri="YOUR_FUNCTION_URL/cleanupExpiredSubscriptions" \
  --http-method=POST
```

### 3. Развертывание функций
```bash
firebase deploy --only functions
```

## Использование

### 1. Проверка необходимости подписки
```dart
final subscriptionController = Get.put(SubscriptionController());

// Автоматически проверяется при входе пользователя
// Если подписка нужна, показывается диалог
```

### 2. Создание пробного периода
```dart
await subscriptionController.startTrialPeriod();
await notificationController.addTrialStartNotification();
```

### 3. Покупка подписки
```dart
await subscriptionController.purchaseMonthlySubscription();
await notificationController.addPaymentSuccessNotification();
```

### 4. Отправка уведомления от стилиста
```dart
final stylistService = StylistNotificationsService();

// Всем подписчикам
await stylistService.sendOutfitNotificationToAllSubscribers(
  stylistName: 'Анна Стилист',
  outfitName: 'Вечерний образ',
  description: 'Элегантный образ для вечернего мероприятия'
);

// Конкретным пользователям
await stylistService.sendOutfitNotificationToUsers(
  userIds: ['user1', 'user2'],
  stylistName: 'Анна Стилист',
  outfitName: 'Вечерний образ'
);
```

## Правила безопасности Firestore

### Для коллекции `users`
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /subscriptions/{subscriptionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /notifications/{notificationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /cards/{cardId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Мониторинг и аналитика

### 1. Логирование
Все операции логируются в Firebase Console:
- Создание подписок
- Отправка уведомлений
- Ошибки

### 2. Аналитика
Отслеживайте метрики:
- Количество активных подписчиков
- Конверсия пробного периода
- Открываемость уведомлений

### 3. Оповещения
Настройте оповещения для:
- Ошибок в Cloud Functions
- Падения конверсии
- Проблем с платежами

## Тестирование

### 1. Тестирование подписок
```dart
// Тест пробного периода
await subscriptionService.startTrialPeriod();
final subscription = await subscriptionService.getCurrentSubscription();
assert(subscription?.type == 'trial');
assert(subscription?.remainingDays == 7);

// Тест покупки подписки
await subscriptionService.purchaseMonthlySubscription();
final subscription = await subscriptionService.getCurrentSubscription();
assert(subscription?.type == 'monthly');
assert(subscription?.remainingDays == 30);
```

### 2. Тестирование уведомлений
```dart
// Тест уведомления от стилиста
await stylistService.sendOutfitNotification(
  userId: 'testUserId',
  stylistName: 'Тест Стилист',
  outfitName: 'Тестовый образ'
);

final notifications = await notificationService.fetchNotifications('testUserId');
assert(notifications.any((n) => n.type == 'style'));
```

## Поддержка

При возникновении проблем:
1. Проверьте логи в Firebase Console
2. Убедитесь в правильности правил безопасности
3. Проверьте настройки Cloud Functions
4. Обратитесь к документации Firebase 