#!/bin/bash

docker compose up --build

docker compose exec backend alembic upgrade head