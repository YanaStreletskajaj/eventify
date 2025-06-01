from pathlib import Path
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parent.parent.parent
ENV_FILE = BASE_DIR / '.env'


class Settings(BaseSettings):
    # Настройки API
    api_host: str = Field(..., env="api_host")
    api_port: int = Field(..., env="api_port")

    # Настройки базы данных
    postgres_user: str
    postgres_password: str
    postgres_db: str
    postgres_host: str
    postgres_port: int

    # Авторизация
    secret_key: str
    algorithm: str
    access_token_expire_minutes: int

    def get_db_url(self) -> str:
        return (
            f"postgresql+asyncpg://{self.postgres_user}:"
            f"{self.postgres_password}@{self.postgres_host}:"
            f"{self.postgres_port}/{self.postgres_db}"
        )

    model_config = SettingsConfigDict(
        env_file=ENV_FILE,
        env_file_encoding="utf-8",
        extra="forbid"
    )


settings = Settings()