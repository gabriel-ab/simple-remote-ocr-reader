#!/bin/sh
gcloud run deploy easyocr-reader \
    --source=. \
    --cpu=1 \
    --memory=2600Mi \
    --max-instances=2 \
    --min-instances=1 \
    --concurrency=4 \
    --platform=managed \
    --port=8000 \
    --timeout=25 \
    --allow-unauthenticated \
    --region=southamerica-east1

