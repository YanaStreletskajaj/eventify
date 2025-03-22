from sqlalchemy import select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession

from core import logger
from models.user import User
from schemas.schemas_user import UserRequestCreate


class UserDAO:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create_user(self, user: UserRequestCreate) -> User:
        """Создание пользователя"""
        try:
            new_user = User(**user.model_dump())
            self.session.add(new_user)
            await self.session.flush()
            await self.session.commit()
            logger.info(f"✔ Пользователь с ID {new_user.id} создан")
            return new_user
        except IntegrityError as e:
            await self.session.rollback()
            logger.warning(f"Ошибка: {e}")
            raise ValueError("User already exists")
        except SQLAlchemyError as e:
            await self.session.rollback()
            logger.error(f"❌ Ошибка при создании пользователя: {e}")
            raise RuntimeError("Database error")

    async def get_users(self):
        logger.debug("🔎 Получение всех заказов")
        try:
            stmt = select(User)
            result = await self.session.execute(stmt)
            users = result.scalars().all()
            logger.info(f"✅ Найдено {len(users)} заказов")

            return users
        except SQLAlchemyError as e:
            logger.error(f"❌ Ошибка при получении заказов: {e}")
            raise RuntimeError("Database error")