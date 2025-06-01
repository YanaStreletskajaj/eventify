from pydantic import BaseModel, Field
from datetime import datetime
from uuid import UUID
from typing import Optional

from pydantic import BaseModel, Field, ConfigDict, UUID4

class EventCreate(BaseModel):
    name: str
    location: Optional[str] = None
    start_time: datetime
    end_time: datetime
    repeat_interval: Optional[str] = None
    reminder_interval: Optional[str] = None
    notes: Optional[str] = None

    model_config = ConfigDict(from_attributes=True,  json_encoders={UUID: str})

class EventResponse(EventCreate):
    id: UUID
    created_by: UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True,  json_encoders={UUID: str})