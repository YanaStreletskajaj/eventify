from datetime import datetime, timedelta
from typing import Optional
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer

from typing import Annotated
from dao.user import UserDAO
from sqlalchemy.ext.asyncio import AsyncSession
from core.config import settings
from core.security import get_password_hash, verify_password
from models.user import User
from database.session import get_session

# Секретный ключ и настройки токена
SECRET_KEY = "301751"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# Для авторизации по токену
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

# Контекст для хэша
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")




def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    session: AsyncSession = Depends(get_session)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        phone: str = payload.get("sub")
        if phone is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user_dao = UserDAO(session)
    user = await user_dao.get_user_by_phone(phone)
    if user is None:
        raise credentials_exception
    return user