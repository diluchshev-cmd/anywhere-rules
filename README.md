# Anywhere Routing Rule Sets (Russia / Runetfreedom)

Автоматически обновляемые наборы правил маршрутизации в нативном формате `.arrs` для клиента [Anywhere](https://github.com/NodePassProject/Anywhere) (iOS / iPadOS / macOS), сконвертированные из базы [runetfreedom/russia-v2ray-rules-dat](https://github.com/runetfreedom/russia-v2ray-rules-dat).

Правила автоматически синхронизируются через GitHub Actions дважды в сутки.

---

## Доступные наборы правил

| Набор | Тип | Кол-во правил | Рекомендуемая политика | Описание |
|---|---|---|---|---|
| **`RuBlocked.arrs`** | Домены (Suffix) | ~74,700 | **Proxy** | Популярные заблокированные в РФ ресурсы (Antifilter Community + Re:filter). Рекомендуется как основной список. |
| **`RuBlocked_Community.arrs`** | Домены (Suffix) | ~480 | **Proxy** | Компактный список только ключевых сервисов (Instagram, X/Twitter, Discord, AI, LinkedIn и др.). |
| **`RuBlocked_IP.arrs`** | IP CIDR | ~88,500 | **Proxy** | Список заблокированных IP-адресов и подсетей. |
| **`RuBlocked_IP_Community.arrs`** | IP CIDR | ~910 | **Proxy** | Облегченный список заблокированных IP-подсетей сообщества. |
| **`RuInside.arrs`** | Домены (Suffix) | ~180 | **DIRECT** | Госуслуги, Банки (Сбер, Т-Банк, ВТБ, Альфа), РЖД, Почта, маркетплейсы для прямого подключения в обход VPN. |

---

## Быстрый импорт в Anywhere

### Способ 1: В приложении Anywhere по ссылке на Raw-файл
1. Откройте **Anywhere** на устройстве.
2. Перейдите в **Settings** (Настройки) -> **Routing Rules** (Правила маршрутизации).
3. Нажмите **+** (или **Add Rule Set**).
4. Вставьте ссылку на нужный Raw-файл:
   - `RuBlocked`: `https://raw.githubusercontent.com/<ВАШ_ЛОГИН>/<РЕПОЗИТОРИЙ>/main/RuBlocked.arrs`
   - `RuInside`: `https://raw.githubusercontent.com/<ВАШ_ЛОГИН>/<РЕПОЗИТОРИЙ>/main/RuInside.arrs`
5. Назначьте политику (для `RuBlocked` выберите вашу прокси-группу, для `RuInside` — `DIRECT`).

### Способ 2: Через Deep Link (в один клик)
Если в настройках репозитория включён **GitHub Pages** (Settings -> Pages -> Branch: `main`), вы можете открывать ссылки прямо в Safari:
```text
https://<ВАШ_ЛОГИН>.github.io/<РЕПОЗИТОРИЙ>/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2F<ВАШ_ЛОГИН>%2F<РЕПОЗИТОРИЙ>%2Fmain%2FRuBlocked.arrs
```
Либо через протокол Anywhere:
```text
anywhere://add-rule-set?link=https://raw.githubusercontent.com/<ВАШ_ЛОГИН>/<РЕПОЗИТОРИЙ>/main/RuBlocked.arrs
```

---

## Структура репозитория

- `RuBlocked.arrs`, `RuBlocked_Community.arrs`, `RuBlocked_IP.arrs`, `RuInside.arrs` — готовые файлы правил.
- `import.html` — страница-редирект для быстрого добавления правил через браузер в Anywhere.
- `generate.py` / `generate.ps1` — скрипты конвертации из исходников runetfreedom.
- `.github/workflows/update.yml` — GitHub Action для автоматического обновления правил по расписанию.
