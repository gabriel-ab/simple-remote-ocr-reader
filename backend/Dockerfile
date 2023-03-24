FROM python:3.10-slim
RUN pip install fastapi uvicorn[standard] easyocr python-multipart torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
ENV EASYOCR_MODULE_PATH=/home/app
WORKDIR /home/app
COPY model model/
COPY app.py .
EXPOSE 8000
CMD uvicorn app:app --host 0.0.0.0 --port 8000 --workers 1 --limit-max-requests 400