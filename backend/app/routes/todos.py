from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.todo import Todo
from app.models.user import User
from app.security import get_current_user
from app.schemas.todo import TodoCreate, TodoRead, TodoUpdate

router = APIRouter(prefix="/api/todos", tags=["todos"])


@router.get("", response_model=list[TodoRead])
def list_todos(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[TodoRead]:
    _ = current_user
    todos = db.scalars(
        select(Todo).where(Todo.user_id == current_user.id).order_by(Todo.id.desc())
    ).all()
    return [TodoRead.model_validate(todo) for todo in todos]


@router.post("", response_model=TodoRead, status_code=status.HTTP_201_CREATED)
def create_todo(
    payload: TodoCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> TodoRead:
    _ = current_user
    todo = Todo(title=payload.title.strip(), user_id=current_user.id)
    db.add(todo)
    db.commit()
    db.refresh(todo)
    return TodoRead.model_validate(todo)


@router.patch("/{todo_id}", response_model=TodoRead)
def update_todo(
    todo_id: int,
    payload: TodoUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> TodoRead:
    _ = current_user
    todo = db.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Todo not found")
    if todo.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Todo not found")

    data = payload.model_dump(exclude_unset=True)

    if "title" in data and data["title"] is not None:
        todo.title = data["title"].strip()
    if "completed" in data and data["completed"] is not None:
        todo.completed = data["completed"]

    db.add(todo)
    db.commit()
    db.refresh(todo)
    return TodoRead.model_validate(todo)


@router.delete("/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_todo(
    todo_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    _ = current_user
    todo = db.get(Todo, todo_id)
    if not todo or todo.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Todo not found")

    db.delete(todo)
    db.commit()
    return None
