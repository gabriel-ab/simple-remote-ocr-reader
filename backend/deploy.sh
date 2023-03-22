#!/bin/sh
gcloud run deploy easyocr-reader \
    --source=. \
    --cpu=1 \
    --max-instances=2 \
    --min-instances=1 \
    --platform=managed \
    --region=southamerica-east1 \
    --port=8000 \
    --timeout=25 \
    --allow-unauthenticated

