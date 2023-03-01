from fastapi import FastAPI
from pydantic import HttpUrl
from celery import Celery
from fastapi.templating import Jinja2Templates
import os

backend = Celery('computer-vision', os.getenv('BROKER_URL'))
app = FastAPI()


@app.get('/')
def home():
    return 'Agora vai'

@app.post('/image2text')
def image2text(image: HttpUrl) -> list[str]:
    backend.send_task()

@app.post('/get/')