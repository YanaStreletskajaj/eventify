from datetime import datetime
from typing import Annotated

from pydantic import BaseModel, Field, ConfigDict, UUID4


class UserRequestCreate(BaseModel):
    """Схема для создания пользователя (Request DTO)"""

    first_name: Annotated[str, Field(..., max_length=100, description="Имя пользователя")]
    last_name: Annotated[str, Field(..., max_length=100, description="Фамилия пользователя")]
    phone: Annotated[str, Field(..., max_length=20, description="Номер телефона")]
    password: Annotated[str, Field(..., max_length=255, description="Пароль пользователя")]


class UserResponse(BaseModel):
    """Схема для ответа на запрос пользователя (Response DTO)"""

    id: Annotated[UUID4, Field(..., description="Идентификатор пользователя")]
    first_name: Annotated[str, Field(..., max_length=100, description="Имя пользователя")]
    last_name: Annotated[str, Field(..., max_length=100, description="Фамилия пользователя")]
    phone: Annotated[str, Field(..., max_length=20, description="Номер телефона пользователя")]
    created_at: Annotated[datetime, Field(..., description="Дата и время создания пользователя")]
    updated_at: Annotated[datetime, Field(..., description="Дата и время последнего обновления пользователя")]

    model_config = ConfigDict(from_attributes=True)