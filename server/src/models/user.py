from datetime import datetime

from sqlalchemy import (
    String,
    DateTime, func)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.base import Base
from event import Event
from event_participant import EventParticipant
from invitation import Invitation

class User(Base):
    __tablename__ = "users"

    first_name: Mapped[str] = mapped_column(String(100), nullable=False)
    last_name: Mapped[str] = mapped_column(String(100), nullable=False)
    phone: Mapped[str] = mapped_column(String(20), nullable=False, unique=True)
    password: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    # Связи
    events_created: Mapped[list["Event"]] = relationship(
        "Event", back_populates="creator", cascade="all, delete-orphan"
    )
    event_participations: Mapped[list["EventParticipant"]] = relationship(
        "EventParticipant", back_populates="user", cascade="all, delete-orphan"
    )
    invitations_created: Mapped[list["Invitation"]] = relationship(
        "Invitation", back_populates="creator"
    )
