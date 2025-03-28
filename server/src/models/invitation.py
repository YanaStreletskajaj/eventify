import uuid
from datetime import datetime
from typing import List, Optional

from sqlalchemy import (
    String,
    Integer,
    DateTime,
    ForeignKey,
    func,
)
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.base import Base
from event import Event
from user import User


class Invitation(Base):
    __tablename__ = "invitations"

    event_id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True),
        ForeignKey("events.id", ondelete="CASCADE"),
        nullable=False,
    )
    code: Mapped[str] = mapped_column(String(255), nullable=False)
    usage_limit: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    usage_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    expires_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    created_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        PG_UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )

    # Связи
    event: Mapped["Event"] = relationship("Event", back_populates="invitations")
    creator: Mapped[Optional["User"]] = relationship("User", back_populates="invitations_created")