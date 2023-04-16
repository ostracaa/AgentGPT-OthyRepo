#!/bin/bash
cd "$(dirname "$0")" || exit

echo -n "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"
read OPENAI_API_KEY

NEXTAUTH_SECRET=$(openssl rand -base64 32)

ENV="NODE_ENV=development\n\
NEXTAUTH_SECRET=$NEXTAUTH_SECRET\n\
NEXTAUTH_URL=http://localhost:3000\n\
OPENAI_API_KEY=$OPENAI_API_KEY\n\
DATABASE_URL=file:../db/db.sqlite\n"

printf $ENV > .env

if [ "$1" = "--docker" ]; then
  printf $ENV > .env.docker
  source .env.docker
  docker build --build-arg NODE_ENV=$NODE_ENV -t agentgpt .
  docker run -d --name agentgpt -p 3000:3000 -v $(pwd)/db:/app/db agentgpt
else
  printf $ENV > .env
  ./prisma/useSqlite.sh
  npm install
  npm run dev
fi