
from easyocr.easyocr import Reader
from celery import Celery
import os

app = Celery(
    'computer-vision',
    broker=os.getenv('BROKER_URL'),
    backend='rpc://'
)

@app.task(name='image2text', bind=True, model=None)
def image2text(self, image) -> list[str]:
    if self.model is None:
        CURDIR = __file__.rpartition('/')[0]
        self.model = Reader(
            lang_list=['pt'],
            gpu=False,
            model_storage_directory=CURDIR,
            user_network_directory=CURDIR,
        )
    result = self.model.readtext(image)
    result = [text[1] for text in result]
    return result
