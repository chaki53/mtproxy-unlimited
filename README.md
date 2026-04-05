<div align="center">

# :shield: MTProxy Unlimited

### Telegram MTProxy без лимита в 16 секретов

[![License: GPL-2.0](https://img.shields.io/badge/License-GPL%202.0-blue.svg)](https://www.gnu.org/licenses/gpl-2.0)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Telegram](https://img.shields.io/badge/Telegram-MTProxy-26A5E4?logo=telegram&logoColor=white)](https://telegram.org)
[![Max Secrets](https://img.shields.io/badge/Макс.%20секретов-10%20000-brightgreen)](https://github.com/chaki53/mtproxy-unlimited)

Telegram MTProxy сервер с поддержкой до **10 000 секретов** в одном контейнере.

---

**Оригинальный лимит: 16** :arrow_right: **Этот форк: 10 000** (настраивается)

</div>

---

## :bookmark_tabs: Содержание

- [Проблема](#проблема)
- [Решение](#решение)
- [Быстрый старт](#быстрый-старт)
- [Установка одной командой](#установка-одной-командой)
- [Настройки](#настройки)
- [Как это работает](#как-это-работает)
- [Производительность](#производительность)
- [Интеграция](#интеграция)
- [English](#english)

---

## :exclamation: Проблема

Официальный Docker-образ `telegrammessenger/proxy` имеет хардкод-лимит в **16 секретов**.
При попытке добавить больше — контейнер падает с ошибкой:

```
Assertion 'ext_secret_cnt < 16' failed
```

Это делает невозможным обслуживание более 16 пользователей прокси с одного инстанса.

## :white_check_mark: Решение

Компилируем MTProxy из [официальных исходников](https://github.com/TelegramMessenger/MTProxy) с лимитом **10 000** вместо 16.
Единственное изменение — одна строка в `net/net-tcp-rpc-ext-server.c`.
Всё остальное идентично официальной версии.

---

## :rocket: Быстрый старт

### 1. Клонирование

```bash
git clone https://github.com/chaki53/mtproxy-unlimited.git
cd mtproxy-unlimited
```

### 2. Извлечь необходимый файл

```bash
chmod +x setup-hello.sh
./setup-hello.sh
```

### 3. Сборка

```bash
# Лимит по умолчанию: 10 000 секретов
docker build -t mtproxy-unlimited .

# Свой лимит (например 500)
docker build -t mtproxy-unlimited --build-arg MAX_SECRETS=500 .
```

### 4. Запуск

```bash
# Один секрет
docker run -d \
  --name mtproxy \
  --restart always \
  -p 443:443/tcp \
  --dns 8.8.8.8 \
  -e "SECRET=$(openssl rand -hex 16)" \
  mtproxy-unlimited

# Несколько секретов
docker run -d \
  --name mtproxy \
  --restart always \
  -p 443:443/tcp \
  --dns 8.8.8.8 \
  -e "SECRET=aabb00112233445566778899aabbccdd,11223344556677889900aabbccddeeff" \
  mtproxy-unlimited
```

### Или через Docker Compose

```bash
SECRET=$(openssl rand -hex 16) docker compose up -d
```

---

## :zap: Установка одной командой

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

## :gear: Настройки

### Переменные окружения

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `SECRET` | случайный | Секреты через запятую (32 hex символа каждый) |
| `WORKERS` | 2 | Количество рабочих потоков |

### Аргументы сборки

| Аргумент | По умолчанию | Описание |
|----------|-------------|----------|
| `MAX_SECRETS` | 10000 | Максимальное количество секретов |

---

## :wrench: Как это работает

1. Берёт официальный [исходный код MTProxy на C](https://github.com/TelegramMessenger/MTProxy)
2. Патчит `assert(ext_secret_cnt < 16)` :arrow_right: `assert(ext_secret_cnt < 10000)`
3. Компилирует из исходников внутри Docker (multi-stage сборка)
4. Запускается на чистом Debian Bullseye

---

## :link: Подключение

Каждый секрет генерирует ссылку для подключения в Telegram:

```
tg://proxy?server=YOUR_IP&port=443&secret=dd<YOUR_SECRET>
```

---

## :bar_chart: Производительность

| Секретов | RAM | CPU | Статус |
|----------|-----|-----|--------|
| 16 | ~10 MB | минимальная | лимит оригинала |
| 50 | ~12 MB | минимальная | протестировано |
| 200 | ~15 MB | минимальная | протестировано |
| 500+ | ~20 MB | низкая | ожидаемо |

MTProxy очень лёгкий. Каждый дополнительный секрет добавляет незначительную нагрузку.

---

## :jigsaw: Интеграция

Этот образ предназначен для работы с API управления MTProxy, которые динамически добавляют/удаляют секреты и перезапускают контейнер.

---

## :star: Благодарности

Проект основан на официальном исходном коде [Telegram MTProxy](https://github.com/TelegramMessenger/MTProxy).
Единственное изменение — снятие хардкод-лимита в 16 секретов.

---

## :coffee: Поддержать

Если проект оказался полезен:

**USDT (TRC20):** `TBbjLKDNooR3GBs8BybiY2pZCSPrXWMaPm`

---

<details>
<summary><b>:gb: English</b></summary>

## Problem

The official `telegrammessenger/proxy` Docker image has a hardcoded limit of **16 secrets**.
If you try to add more — the container crashes with `Assertion 'ext_secret_cnt < 16' failed`.

## Solution

We compile MTProxy from the [official source](https://github.com/TelegramMessenger/MTProxy) with the limit raised from 16 to 10,000 (configurable via `MAX_SECRETS` build arg). Everything else remains identical.

## Quick Start

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

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SECRET` | random | Comma-separated 32-char hex secrets |
| `WORKERS` | 2 | Number of worker threads |

## Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `MAX_SECRETS` | 10000 | Maximum number of secrets |

</details>

---

## :page_facing_up: Лицензия

На основе [Telegram MTProxy](https://github.com/TelegramMessenger/MTProxy) — GPL-2.0

Оригинальный код: Copyright Telegram
Модификация: снятие лимита в 16 секретов
