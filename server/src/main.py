from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.v1.user import router as router_user
from api.v1 import auth
from core import settings
from api.v1 import event as event_router



app = FastAPI()
origins = [
    "*"  # Локальная сеть
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(router_user)
if __name__ == '__main__':
    import uvicorn

    uvicorn.run(app, host=settings.api.host, port=settings.api.port)

app.include_router(auth.router)

app.include_router(event_router.router)