# Todo App (Vue + FastAPI + PostgreSQL)

A simple fullstack todo application.

Supported services
- Frontend: Vue 3 + Vite (http://localhost:5173)
- Backend: FastAPI (http://localhost:8000)
- Database: PostgreSQL

Authentication
- Email/password sign in and registration
- JWT bearer auth for protected todo routes

Run (recommended): Docker Compose

```bash
docker compose up --build
```

This will build and start the database, backend, and frontend services defined in `docker-compose.yaml`.

Run locally (without Docker)

1) Database

If you have PostgreSQL installed locally:

```bash
psql -U postgres -c "CREATE DATABASE todo_db;"
```

Or run a temporary PostgreSQL container:

```bash
docker run -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=todo_db -p 5432:5432 -d postgres:15
```

2) Backend

```bash
cd backend
cp .env.example .env
python3 -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

If you are using Docker Compose, keep `backend/.env` pointed at the Compose service name:

```bash
DATABASE_URL=postgresql+psycopg2://postgres:postgres@database:5432/todo_db
```

3) Frontend

```bash
cd frontend
cp .env.example .env || true
npm install
npm run dev
```

Health and docs

- Backend health: `GET /health` (http://localhost:8000/health)
- FastAPI docs: http://localhost:8000/docs

Notes

- If you run services manually, ensure `backend/.env` contains the correct `DATABASE_URL` and `FRONTEND_ORIGIN` values.
- For production use, consider running the backend under a production server (gunicorn) and configuring proper secrets.

API endpoints

- `POST /api/auth/register` register and receive a JWT
- `POST /api/auth/login` sign in and receive a JWT
- `GET /api/auth/me` fetch the current authenticated user

- `GET /api/todos` list todos
- `POST /api/todos` create todo
- `PATCH /api/todos/{id}` update todo
- `DELETE /api/todos/{id}` delete todo
- `GET /health` health check
