from sqlalchemy import select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession

from core import logger
from models.user import User
from schemas.schemas_user import UserRequestCreate
from core.security import get_password_hash, verify_password

class UserDAO:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create_user(self, user: UserRequestCreate) -> User:
        """Создание пользователя"""
        try:
            hashed_password = get_password_hash(user.password)
            user_dict = user.model_dump()
            user_dict["password"] = hashed_password

            new_user = User(**user_dict)
            self.session.add(new_user)
            await self.session.flush()
            await self.session.commit()
            logger.info(f"Пользователь с ID {new_user.id} создан")
            return new_user
        except IntegrityError as e:
            await self.session.rollback()
            logger.warning(f"Ошибка: {e}")
            raise ValueError("User already exists")
        except SQLAlchemyError as e:
            await self.session.rollback()
            logger.error(f"Ошибка при создании пользователя: {e}")
            raise RuntimeError("Database error")

    async def get_user_by_phone(self, phone: str):
        stmt = select(User).where(User.phone == phone)
        result = await self.session.execute(stmt)
        return result.scalars().first()

    async def create_user_from_login(self, phone: str, password: str):
        user = User(
            first_name="Имя",
            last_name="Фамилия",
            phone=phone,
            password=password,
        )
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user
    
    async def get_users(self):
        logger.debug("Получение всех пользователей")
        try:
            stmt = select(User)
            result = await self.session.execute(stmt)
            users = result.scalars().all()
            logger.info(f"Найдено {len(users)} пользователей")

            return users
        except SQLAlchemyError as e:
            logger.error(f"Ошибка при получении пользователей: {e}")
            raise RuntimeError("Database error")