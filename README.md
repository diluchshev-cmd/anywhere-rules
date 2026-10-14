# Anywhere Routing Rule Sets (Russia / Runetfreedom)

Автоматически обновляемые наборы правил маршрутизации в нативном формате `.arrs` для клиента [Anywhere](https://github.com/NodePassProject/Anywhere) (iOS / iPadOS / macOS), сконвертированные из базы [runetfreedom/russia-v2ray-rules-dat](https://github.com/runetfreedom/russia-v2ray-rules-dat).

Правила автоматически синхронизируются через GitHub Actions дважды в сутки.

---

## Доступные наборы правил

| Набор | Тип | Кол-во правил | Рекомендуемая политика | Прямая ссылка | Быстрый импорт в 1 клик |
|---|---|---|---|---|---|
| **`RuBlocked.arrs`** | Домены (Suffix) | ~74,700 | **Proxy** | [Скачать Raw](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked.arrs) | [Импортировать](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuBlocked.arrs) |
| **`RuBlocked_Community.arrs`** | Домены (Suffix) | ~480 | **Proxy** | [Скачать Raw](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked_Community.arrs) | [Импортировать](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuBlocked_Community.arrs) |
| **`RuBlocked_IP.arrs`** | IP CIDR | ~88,500 | **Proxy** | [Скачать Raw](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked_IP.arrs) | [Импортировать](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuBlocked_IP.arrs) |
| **`RuBlocked_IP_Community.arrs`** | IP CIDR | ~910 | **Proxy** | [Скачать Raw](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked_IP_Community.arrs) | [Импортировать](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuBlocked_IP_Community.arrs) |
| **`RuInside.arrs`** | Домены (Suffix) | ~180 | **DIRECT** (`routing = 1`) | [Скачать Raw](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuInside.arrs) | [Импортировать](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuInside.arrs) |

---

## Описание правил

1. **RuBlocked** — популярные заблокированные в РФ ресурсы (Antifilter Community + Re:filter). Рекомендуется как основной список для обхода блокировок.
2. **RuBlocked_Community** — облегченная версия только для ключевых заблокированных сайтов (Instagram, X/Twitter, Discord, AI-сервисы, LinkedIn, торренты).
3. **RuBlocked_IP** — список заблокированных IP-адресов и подсетей.
4. **RuInside** — государственные сервисы, Госуслуги, Банки (Сбер, Т-Банк, ВТБ, Альфа), РЖД, маркетплейсы, чтобы они шли напрямую без прокси (не выдавали капчи и ошибки «Доступ только из РФ»).

---

## Как импортировать в Anywhere

### Вариант 1: В 1 клик через Safari
Откройте страницу репозитория или нажмите ссылку **Импортировать** в таблице выше. Страница автоматически предложит открыть приложение Anywhere и добавить правило.

Либо используйте прямую ссылку URL scheme:
```text
anywhere://add-rule-set?link=https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked.arrs
```

### Вариант 2: Вручную в приложении Anywhere
1. Откройте **Anywhere**.
2. Перейдите в **Settings** -> **Routing Rules** -> нажмите **+** (или **Add Rule Set**).
3. Вставьте ссылку на файл:
   - Для заблокированных сайтов: `https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked.arrs`
   - Для прямого трафика РФ (Госуслуги, банки): `https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuInside.arrs`
4. Для `RuBlocked` выберите политику **Proxy** (или вашу группу прокси). Для `RuInside` политика **DIRECT** применится автоматически.
