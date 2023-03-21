FROM python:3.10-slim
RUN pip install fastapi uvicorn easyocr python-multipart torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
COPY . .
EXPOSE 8000
CMD uvicorn app:app --host 0.0.0.0 --port 8000