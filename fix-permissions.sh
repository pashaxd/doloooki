#!/bin/bash

# Конфигурация Firebase
FIREBASE_CONFIG_FILE="firebase-config.json"
DATABASE_URL="https://dolooki-2c346-default-rtdb.firebaseio.com/"
PROJECT_ID="dolooki-2c346"

# Fix Cloud Run permissions for public access

echo "🔧 Fixing Cloud Run permissions..."

# Set your project details
SERVICE_NAME="doloooki"
REGION="europe-west4"

# Allow unauthenticated access
gcloud run services add-iam-policy-binding $SERVICE_NAME \
  --region=$REGION \
  --member="allUsers" \
  --role="roles/run.invoker" \
  --project=$PROJECT_ID

echo "✅ Permissions updated! Your app should now be publicly accessible." 