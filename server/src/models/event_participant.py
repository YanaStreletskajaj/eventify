import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import Text, DateTime, ForeignKey, String, func, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID as PG_UUID

from database.base import Base
from event import Event
from user import User


class EventParticipant(Base):
    __tablename__ = "event_participants"

    event_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True),
        ForeignKey("events.id", ondelete="CASCADE"),
        nullable=False,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    attendance_status: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    __table_args__ = (
        UniqueConstraint("event_id", "user_id", name="event_participant_unique"),
    )

    # Связи
    event: Mapped["Event"] = relationship("Event", back_populates="participants")
    user: Mapped["User"] = relationship("User", back_populates="event_participations")