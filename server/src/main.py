from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.v1.user import router as router_user
from core import settings


app = FastAPI()
origins = [
    "http://localhost",
    "http://localhost:5000",
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