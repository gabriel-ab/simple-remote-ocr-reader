FROM python:3.10-slim
RUN pip install easyocr celery torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
COPY . .
CMD celery -A reader.py worker --concurrency=1 --pool=threads --queues=cv
