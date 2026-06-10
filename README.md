# Todo App (Vue + FastAPI + PostgreSQL)

A simple fullstack todo application.

Supported services
- Frontend: http://localhost:3000
- Backend: http://localhost:8001
- Database exposed on host: localhost:5432


Authentication
- Email/password sign in and registration
- JWT bearer auth for protected todo routes

Copy the .env file first

```bash
    cp ./backend/.env.example ./backend/.env
    cp ./frontend/.env.example ./frontend/.env
```


Run : Docker Compose

```bash
docker compose up --build

docker compose exec backend alembic upgrade head

```

This will build and start the database, backend, and frontend services defined in `docker-compose.yaml`.

The app will be running at http://localhost:3000