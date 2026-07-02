# dev-tips

## Поднятие всей инфраструктуры

### Пререквизиты

- **Docker** — все сервисы запускаются в контейнерах внутри сети `realty-net`
- **Go** — нужен только если собираете образы локально (каждый `server_setup.sh` делает `docker build`)
- Порты должны быть свободны: `5432`, `9092`, `9090`, `3004`, `9093`, `9094`, `9095`, `8080`, `9091`, `9096`

### Быстрый старт

```bash
cd dev-tips
chmod +x setup_all.sh psql_setup.sh kafka_setup.sh prometheus.sh grafana.sh
./setup_all.sh
```

Скрипт последовательно поднимает:

| Шаг | Что запускается | Адрес |
|-----|----------------|-------|
| 1 | PostgreSQL | `localhost:5432` |
| 2 | Kafka (KRaft) | `localhost:9092` |
| 3 | Prometheus | http://localhost:9090 |
| 4 | Grafana | http://localhost:3004 |
| 5 | realty-parser | http://localhost:9095 |
| 6 | flats-analyzer | http://localhost:9093 |
| 7 | subscription-handler | http://localhost:9094 |
| 8 | users-notifier | http://localhost:8080 (API), http://localhost:9091 (metrics) |
| 9 | reports-builder | http://localhost:9096 |

Grafana: логин `admin` / пароль `admin`.

### Запуск сервисов по отдельности

Инфраструктурные компоненты запускаются из `dev-tips/`:

```bash
bash dev-tips/psql_setup.sh
bash dev-tips/kafka_setup.sh
bash dev-tips/prometheus.sh
bash dev-tips/grafana.sh
```

Каждый сервис запускается из своей директории:

```bash
cd realty-parser      && bash server_setup.sh
cd flats-analyzer     && bash server_setup.sh
cd subscription-handler && bash server_setup.sh
cd users-notifier     && bash server_setup.sh
cd reports-builder    && bash server_setup.sh
```

### Пересборка и перезапуск только сервисов

Если инфраструктура (Postgres, Kafka, Prometheus, Grafana) уже поднята и нужно
просто пересобрать образы и перезапустить 5 сервисов (без клонирования репозиториев):

```bash
cd dev-tips
chmod +x start_services.sh
./start_services.sh
```

Скрипт ожидает, что директории `realty-parser`, `flats-analyzer`,
`subscription-handler`, `users-notifier`, `reports-builder` уже существуют рядом
с `dev-tips/`, и для каждой вызывает её `server_setup.sh` (docker build + пересоздание контейнера).

### Остановка всего

```bash
docker stop realty-postgres realty-kafka prometheus grafana \
  realty-parser flats-analyzer subscription-handler users-notifier reports-builder
```

### Применение миграций

`psql_setup.sh` применяет миграции автоматически после старта контейнера
(вызывает `apply_migrations.sh`), так что при обычном `./setup_all.sh` или
`./psql_setup.sh` ничего дополнительно делать не нужно.

Чтобы применить миграции вручную (например, если БД уже была поднята раньше):

```bash
cd dev-tips
chmod +x apply_migrations.sh
./apply_migrations.sh
```

Скрипт ожидает, что контейнер `realty-postgres` уже запущен. Он по очереди
применяет все `*.sql` файлы из `dev-tips/migrations/` в алфавитном порядке
(имена файлов начинаются с номера, например `001_create_flats_history.sql`).
Уже применённые миграции отслеживаются в таблице `schema_migrations` внутри
БД и повторно не выполняются.

### Синхронизация репозиториев

Скрипты `fetch_all.sh` и `push_all.sh` работают со всеми репозиториями сразу:
`dev-tips`, `realty-parser`, `flats-analyzer`, `subscription-handler`,
`users-notifier`, `reports-builder`.

#### fetch_all.sh — подтянуть изменения

```bash
cd dev-tips
chmod +x fetch_all.sh
./fetch_all.sh
```

Для каждого репозитория выполняет `git fetch --all` и `git pull origin main`.

#### push_all.sh — закоммитить и запушить изменения

```bash
cd dev-tips
chmod +x push_all.sh
./push_all.sh "commit message"
```

Коммит-сообщение передаётся первым аргументом и используется для всех
репозиториев. Скрипт обрабатывает только те репозитории, где есть
незакоммиченные изменения (`git status --porcelain` непустой): для них
выполняет `git add .`, `git commit -m "<message>"` и `git push origin main`.
Репозитории без изменений пропускаются.

### Токен Telegram-бота

Токен бота не хранится в `config.yaml` — сервисы `subscription-handler` и `users-notifier` читают его из файла на диске. Путь к файлу задаётся в конфиге:

```yaml
# subscription-handler/config.yaml
telegram:
  bot_token_file: "/etc/subscription-handler/bot_token"

# users-notifier/config.yaml
telegram:
  bot_token_file: "/etc/users-notifier/bot_token"
```

При старте каждый сервис логирует путь к файлу:

```
{"level":"info","msg":"loading bot token","file":"/etc/subscription-handler/bot_token"}
```

Перед первым запуском создайте файлы с токеном:

```bash
sudo mkdir -p /etc/subscription-handler /etc/users-notifier
sudo sh -c 'echo -n "<BOT_TOKEN>" > /etc/subscription-handler/bot_token'
sudo sh -c 'echo -n "<BOT_TOKEN>" > /etc/users-notifier/bot_token'
sudo chmod 640 /etc/subscription-handler/bot_token /etc/users-notifier/bot_token
```

Замените `<BOT_TOKEN>` на токен от [@BotFather](https://t.me/BotFather).

### Структура файлов

```
dev-tips/
  setup_all.sh          — запускает всё разом
  start_services.sh     — пересобирает и перезапускает только сервисы
  fetch_all.sh          — git fetch --all + git pull origin main во всех репозиториях
  push_all.sh           — git add + commit + push origin main во всех изменённых репозиториях
  apply_migrations.sh   — применяет SQL-миграции из migrations/ к БД
  migrations/            — SQL-миграции для realty-postgres
  psql_setup.sh         — PostgreSQL в Docker
  kafka_setup.sh        — Kafka (KRaft) в Docker, создаёт топик realty.flats
  prometheus.sh         — Prometheus с конфигом prometheus_config.yaml
  grafana.sh            — Grafana
  prometheus_config.yaml — конфиг скрейпинга метрик
```
