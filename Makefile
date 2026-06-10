up:
	docker compose up --build

migrate:
	docker compose exec backend alembic upgrade head

down:
	docker compose down