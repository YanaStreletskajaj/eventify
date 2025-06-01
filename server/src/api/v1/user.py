
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

from core.auth import get_current_user
from models.user import User

from core import logger
from dao.user import UserDAO
from database.session import get_session
from schemas.schemas_user import UserRequestCreate, UserResponse

router = APIRouter(prefix="/users", tags=["Users"])

@router.post("/", response_model=UserResponse, status_code=201, summary="Create a new user")
async def create_user(request: UserRequestCreate, session: AsyncSession = Depends(get_session)):
    user_dao = UserDAO(session)
    try:
        new_user = await user_dao.create_user(request)
        return UserResponse.model_validate(new_user)
    except ValueError as e:
        logger.warning(f"Ошибка создания пользователя: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError:
        logger.error("Ошибка БД при создании пользователя")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.get("/", response_model=list[UserResponse], status_code=200, summary="Get all users")
async def get_users(
    session: AsyncSession = Depends(get_session),
    current_user: str = Depends(get_current_user)                
    ):
        user_dao = UserDAO(session)
        try:
            users = await user_dao.get_users()
            return [UserResponse.model_validate(user) for user in users]
        except RuntimeError:
            logger.error("Ошибка БД при получение пользователей")
            raise HTTPException(status_code=500, detail="Internal server error")
        

@router.get("/me", response_model=UserResponse, summary="Получить текущего пользователя")
async def get_me(current_user: User = Depends(get_current_user)):
    return JSONResponse(
        content=UserResponse.model_validate(current_user).model_dump(mode="json"),
        media_type="application/json; charset=utf-8"
    )