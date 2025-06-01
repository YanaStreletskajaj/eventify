from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from uuid import UUID
from fastapi import HTTPException, status

from dao.event import EventDAO
from schemas.schemas_event import EventCreate, EventResponse
from core.auth import get_current_user
from models.user import User
from database.session import get_session
import json

router = APIRouter(prefix="/events", tags=["Events"])

@router.post("/", response_model=EventResponse)
async def create_event(
    event_data: EventCreate,
    session: AsyncSession = Depends(get_session),
    user: User = Depends(get_current_user),
):
    dao = EventDAO(session)
    created_event = await dao.create_event(user.id, event_data)
    event_response = EventResponse.model_validate(created_event)

    return JSONResponse(
        content=json.loads(event_response.model_dump_json()),
        media_type="application/json",
        headers={"Content-Type": "application/json; charset=utf-8"},
    )


@router.get("/", response_model=list[EventResponse])
async def get_my_events(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    dao = EventDAO(session)
    events = await dao.get_events_by_user(current_user.id)
    event_responses = [EventResponse.model_validate(event) for event in events]

    return JSONResponse(
        content=[json.loads(e.model_dump_json()) for e in event_responses],
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_event(
    event_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    dao = EventDAO(session)
    event = await dao.get_event_by_id(event_id)

    if not event:
        raise HTTPException(status_code=404, detail="Событие не найдено")

    if event.created_by != current_user.id:
        raise HTTPException(status_code=403, detail="Доступ запрещён")

    await dao.delete_event(event)

@router.get("/{event_id}", response_model=EventResponse)
async def get_event_by_id(
    event_id: UUID,
    session: AsyncSession = Depends(get_session),
):
    dao = EventDAO(session)
    event = await dao.get_event_by_id(event_id)

    if event is None:
        raise HTTPException(status_code=404, detail="Событие не найдено")

    return JSONResponse(
        content=json.loads(EventResponse.model_validate(event).model_dump_json()),
        media_type="application/json",
        headers={"Content-Type": "application/json; charset=utf-8"},
    )

@router.post("/{event_id}/join")
async def join_event_by_id(
    event_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    dao = EventDAO(session)
    await dao.add_participant(current_user.id, event_id)
    return {"message": "Вы успешно присоединились к событию"}