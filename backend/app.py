from easyocr.easyocr import Reader
from fastapi import FastAPI, File, Response
from fastapi.responses import HTMLResponse
import cv2 as cv
import numpy as np
import skimage.io as skio
import io

def _preprocess(img):
    img = cv.bilateralFilter(img, 9, 75, 75)
    img = cv.morphologyEx(img, cv.MORPH_CLOSE, cv.getStructuringElement(cv.MORPH_ELLIPSE, (5,5)))
    img = cv.morphologyEx(img, cv.MORPH_BLACKHAT, cv.getStructuringElement(cv.MORPH_RECT, (7,7)))
    img = cv.morphologyEx(img, cv.MORPH_ERODE, cv.getStructuringElement(cv.MORPH_ELLIPSE, (3,3)))
    img = cv.threshold(img, 30, 255, 0)[1]
    img = cv.morphologyEx(img, cv.MORPH_DILATE, cv.getStructuringElement(cv.MORPH_ELLIPSE, (3,8)))
    img = 255 - img
    return img


app = FastAPI()

model = Reader(
    lang_list=['pt'],
    gpu=False,
    model_storage_directory='backend/ai-models',
    user_network_directory='backend/ai-models',
)

@app.get('/', response_class=HTMLResponse)
def home():
    return '<h1>Leitor de Imagens</h1>'

@app.post('/preprocess',
          response_class=Response,
          responses={200: {'content': {'image/jpeg': {}}}})
def preprocess(image: bytes = File()):
    img = cv.imdecode(np.frombuffer(image, np.uint8), cv.IMREAD_GRAYSCALE)
    img = _preprocess(img)
    img_bytes = cv.imencode('.jpg', img)[1].tobytes()
    return Response(content=img_bytes, media_type="image/jpeg")

@app.post('/read')
def read_image(image: bytes = File()) -> str:
    img = cv.imdecode(np.frombuffer(image, np.uint8), cv.IMREAD_GRAYSCALE)
    img = _preprocess(img)
    results = model.readtext(img)
    words = [word[1] for word in results]
    return ' '.join(words)
