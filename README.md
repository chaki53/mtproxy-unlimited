# MTProxy Unlimited

**[EN]** Telegram MTProxy server **without the 16 secret limit**. Supports up to **10,000 secrets** in a single container.

**[RU]** Telegram MTProxy сервер **без лимита в 16 секретов**. Поддерживает до **10 000 секретов** в одном контейнере.

---

## Credits / Благодарности

This project is based on the official [Telegram MTProxy](https://github.com/TelegramMessenger/MTProxy) source code.  
The only modification is the removal of the hardcoded 16-secret limit (`assert(ext_secret_cnt < 16)` in `net/net-tcp-rpc-ext-server.c`).

Проект основан на официальном исходном коде [Telegram MTProxy](https://github.com/TelegramMessenger/MTProxy).  
Единственное изменение — снятие хардкод-лимита в 16 секретов (`assert(ext_secret_cnt < 16)` в `net/net-tcp-rpc-ext-server.c`).

---

## Problem / Проблема

**[EN]** The official `telegrammessenger/proxy` Docker image has a hardcoded limit of **16 secrets**. If you try to add more — the container crashes with `Assertion 'ext_secret_cnt < 16' failed`. This makes it impossible to serve more than 16 proxy users from a single instance.

**[RU]** Официальный Docker-образ `telegrammessenger/proxy` имеет хардкод-лимит в **16 секретов**. При попытке добавить больше — контейнер падает с ошибкой `Assertion 'ext_secret_cnt < 16' failed`. Это делает невозможным обслуживание более 16 пользователей прокси с одного инстанса.

## Solution / Решение

**[EN]** We compile MTProxy from the official source with the limit raised from 16 to 10,000 (configurable via `MAX_SECRETS` build arg). Everything else remains identical to the official version.

**[RU]** Мы компилируем MTProxy из официальных исходников с лимитом 10 000 вместо 16 (настраивается через `MAX_SECRETS` build arg). Всё остальное идентично официальной версии.

---

## Quick Start / Быстрый старт

### 1. Clone / Клонирование

```bash
git clone https://github.com/chaki53/mtproxy-unlimited.git
cd mtproxy-unlimited
```

### 2. Extract required file / Извлечь необходимый файл

```bash
chmod +x setup-hello.sh
./setup-hello.sh
```

### 3. Build / Сборка

```bash
# Default limit: 10,000 secrets / Лимит по умолчанию: 10 000
docker build -t mtproxy-unlimited .

# Custom limit / Свой лимит (например 500)
docker build -t mtproxy-unlimited --build-arg MAX_SECRETS=500 .
```

### 4. Run / Запуск

```bash
# Single secret / Один секрет
docker run -d \
  --name mtproxy \
  --restart always \
  -p 443:443/tcp \
  --dns 8.8.8.8 \
  -e "SECRET=$(openssl rand -hex 16)" \
  mtproxy-unlimited

# Multiple secrets / Несколько секретов
docker run -d \
  --name mtproxy \
  --restart always \
  -p 443:443/tcp \
  --dns 8.8.8.8 \
  -e "SECRET=aabb00112233445566778899aabbccdd,11223344556677889900aabbccddeeff" \
  mtproxy-unlimited
```

### Or use Docker Compose / Или через Docker Compose

```bash
SECRET=$(openssl rand -hex 16) docker compose up -d
```

---

## One-liner / Установка одной командой

```bash
git clone https://github.com/chaki53/mtproxy-unlimited.git && \
cd mtproxy-unlimited && \
chmod +x setup-hello.sh && ./setup-hello.sh && \
docker build -t mtproxy-unlimited . && \
docker run -d --name mtproxy --restart always \
  -p 443:443 --dns 8.8.8.8 \
  -e "SECRET=$(openssl rand -hex 16)" \
  mtproxy-unlimited
```

---

## Environment Variables / Переменные окружения

| Variable | Default | EN | RU |
|----------|---------|----|----|
| `SECRET` | random | Comma-separated 32-char hex secrets | Секреты через запятую (32 hex символа) |
| `WORKERS` | 2 | Worker threads count | Количество рабочих потоков |

## Build Arguments / Аргументы сборки

| Argument | Default | EN | RU |
|----------|---------|----|----|
| `MAX_SECRETS` | 10000 | Maximum number of secrets | Максимальное количество секретов |

---

## How it works / Как это работает

**[EN]**
1. Takes the official [MTProxy C source code](https://github.com/TelegramMessenger/MTProxy)
2. Patches `assert(ext_secret_cnt < 16)` → `assert(ext_secret_cnt < 10000)`
3. Compiles from source inside Docker (multi-stage build)
4. Runs with a clean Debian Bullseye runtime

**[RU]**
1. Берёт официальный [исходный код MTProxy на C](https://github.com/TelegramMessenger/MTProxy)
2. Патчит `assert(ext_secret_cnt < 16)` → `assert(ext_secret_cnt < 10000)`
3. Компилирует из исходников внутри Docker (multi-stage сборка)
4. Запускается на чистом Debian Bullseye

---

## Connection / Подключение

Each secret generates a proxy link / Каждый секрет генерирует ссылку:

```
tg://proxy?server=YOUR_IP&port=443&secret=dd<YOUR_SECRET>
```

---

## Performance / Производительность

| Secrets | RAM | CPU | Status |
|---------|-----|-----|--------|
| 16 | ~10 MB | minimal | official limit |
| 50 | ~12 MB | minimal | tested |
| 200 | ~15 MB | minimal | tested |
| 500+ | ~20 MB | low | expected |

MTProxy is very lightweight. Each secret adds negligible overhead.  
MTProxy очень лёгкий. Каждый дополнительный секрет добавляет незначительную нагрузку.

---

## Integration / Интеграция

**[EN]** This image is designed to work with MTProxy management APIs that dynamically add/remove secrets and restart the container.

**[RU]** Этот образ предназначен для работы с API управления MTProxy, которые динамически добавляют/удаляют секреты и перезапускают контейнер.

---

## Donate / Поддержать

If you find this useful / Если проект оказался полезен:

**USDT (TRC20):** `TBbjLKDNooR3GBs8BybiY2pZCSPrXWMaPm`

---

## License / Лицензия

Based on [Telegram MTProxy](https://github.com/TelegramMessenger/MTProxy) — GPL-2.0

Original code: Copyright Telegram  
Modification: removal of the 16-secret hardcoded limit
