from easyocr.easyocr import Reader
from fastapi import FastAPI, File, Response
from fastapi.responses import HTMLResponse
import cv2 as cv
import numpy as np

model: Reader | None = None
def get_model():
    global model
    if model is None:
        model = Reader(
            lang_list=['pt'],
            gpu=False,
        )
    return model

def draw_predictions(image: np.ndarray, preds: np.ndarray) -> np.ndarray:
    if not preds:
        return image
    image = image.copy()
    bboxes, texts, probs = list(zip(*preds))
    bboxes = np.array(bboxes)[:, [0, 2]].astype(int)

    match image.shape[-1]:
        case 4: color = (0, 255, 0, 255)
        case 3: color = (0, 255, 0)
        case _: color = (100,)

    for i, [(top_left, bottom_right), text, prob] in enumerate(zip(bboxes, texts, probs), start=1):
        cv.rectangle(image, top_left, bottom_right, color, 2)
        top_left += (0, -14)
        cv.putText(image, text, top_left, cv.FONT_HERSHEY_PLAIN, 2, color, 2)
    return image


app = FastAPI()


@app.get('/', response_class=HTMLResponse)
def home():
    return '<h1>Leitor de Imagens</h1>'

@app.post('/read')
def read_image(image: bytes = File()) -> str:
    model = get_model()
    img = cv.imdecode(np.frombuffer(image, np.uint8), cv.IMREAD_GRAYSCALE)
    img = cv.adaptiveThreshold(img, 255, cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, 5, 2)
    results = model.readtext(img, )
    words = [word[1] for word in results] # type: ignore
    return ' '.join(words)

@app.post('/draw', responses={200: {'content': {'image/jpeg': {}}}})
def draw(image: bytes = File()) -> Response:
    model = get_model()
    img = cv.imdecode(np.frombuffer(image, np.uint8), cv.IMREAD_ANYCOLOR)
    results = model.readtext(img)
    painted = draw_predictions(img, results)
    return Response(cv.imencode('.jpg', painted)[1].tobytes(), media_type='image/jpeg')
