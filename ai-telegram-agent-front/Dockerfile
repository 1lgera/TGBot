# ai-telegram-agent-front/Dockerfile

# ---- STAGE 1: Build the Flutter web app ----
FROM ghcr.io/cirruslabs/flutter:3.29.3 AS build

# Рабочая папка внутри контейнера
WORKDIR /app

# Копируем всё и билдим релизную версию для web
COPY . .

RUN flutter clean

# Копируем pubspec и зависимости, чтобы оптимизировать кеширование слоёв
COPY pubspec.* ./
RUN flutter pub get

RUN flutter build web --release

# ---- STAGE 2: Serve with Nginx ----
FROM nginx:alpine

# Удаляем дефолтный контент nginx (необязательно)
RUN rm -rf /usr/share/nginx/html/*

# Копируем собранные файлы из предыдущего шага
COPY --from=build /app/build/web /usr/share/nginx/html

# Открываем порт 8080
EXPOSE 8080

# Запуск nginx в фореграунд режиме
CMD ["nginx", "-g", "daemon off;"]
