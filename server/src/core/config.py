from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parent.parent.parent
ENV_FILE = BASE_DIR / '.env'


class ConfigBase(BaseSettings):
    """Базоввые настройки конфига"""

    model_config = SettingsConfigDict(
        env_file=ENV_FILE, env_file_encoding="utf-8", extra="ignore"
    )


class ApiConfig(ConfigBase):
    host: str
    port: int

    model_config = SettingsConfigDict(env_prefix="api_")


class DatabaseConfig(ConfigBase):
    user: str
    password: str
    db: str
    host: str
    port: int

    model_config = SettingsConfigDict(env_prefix="postgres_")


class Settings(BaseSettings):
    """Глобальные настройки"""

    api: ApiConfig = Field(default_factory=ApiConfig)
    database: DatabaseConfig = Field(default_factory=DatabaseConfig)

    def get_db_url(self) -> str:
        return (
            f"postgresql+asyncpg://{self.database.user}:"
            f"{self.database.password}@{self.database.host}:"
            f"{self.database.port}/{self.database.db}"
        )


settings = Settings()