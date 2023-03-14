FROM python:3.10-slim
RUN pip install fastapi uvicorn easyocr python-multipart torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
COPY . .
CMD uvicorn app.main:app