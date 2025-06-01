from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from core.auth import create_access_token, get_password_hash, verify_password
from database.session import get_session
from dao.user import UserDAO

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/register")
async def register(
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: AsyncSession = Depends(get_session)
):
    user_dao = UserDAO(session)
    existing_user = await user_dao.get_user_by_phone(form_data.username)
    if existing_user:
        raise HTTPException(status_code=400, detail="Пользователь уже существует")
    
    hashed = get_password_hash(form_data.password)
    await user_dao.create_user_from_login(phone=form_data.username, password=hashed)
    return {"message": "Регистрация прошла успешно"}

@router.post("/login")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: AsyncSession = Depends(get_session)
):
    user_dao = UserDAO(session)
    user = await user_dao.get_user_by_phone(form_data.username)
    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(status_code=401, detail="Неверный номер или пароль")
    
    token = create_access_token(data={"sub": user.phone})
    return {"access_token": token, "token_type": "bearer"}