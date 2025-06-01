from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import or_, select
from sqlalchemy.orm import joinedload
from models.event import Event
from models.event_participant import EventParticipant
from schemas.schemas_event import EventCreate
from uuid import UUID


class EventDAO:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create_event(self, user_id: UUID, data: EventCreate) -> Event:
        new_event = Event(created_by=user_id, **data.model_dump())
        self.session.add(new_event)
        await self.session.commit()
        await self.session.refresh(new_event)
        return new_event
    
    async def get_events_by_user(self, user_id: UUID) -> list[Event]:
        result = await self.session.execute(
            select(Event)
            .outerjoin(EventParticipant, Event.id == EventParticipant.event_id)
            .where(
                or_(
                    Event.created_by == user_id,
                    EventParticipant.user_id == user_id
                )
            )
            .options(joinedload(Event.participants))
            .distinct()
        )
        return result.unique().scalars().all()
    
    async def get_event_by_id(self, event_id: UUID) -> Event | None:
        result = await self.session.execute(select(Event).where(Event.id == event_id))
        return result.scalar_one_or_none()

    async def delete_event(self, event: Event):
        await self.session.delete(event)
        await self.session.commit()

    async def get_event_by_id(self, event_id: UUID):
        query = select(Event).where(Event.id == event_id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()
    
    async def add_participant(self, user_id: UUID, event_id: UUID):
        query = select(EventParticipant).where(
            EventParticipant.user_id == user_id,
            EventParticipant.event_id == event_id,
        )
        result = await self.session.execute(query)
        existing = result.scalar_one_or_none()

        if existing is None:
            self.session.add(EventParticipant(user_id=user_id, event_id=event_id))
            await self.session.commit()