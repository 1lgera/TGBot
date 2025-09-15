#!/bin/sh
cd /app/src/controller || exit

if [ "$SERVICE" = "bot" ]; then
  exec python telegram.py
else
  exec python server.py
fi