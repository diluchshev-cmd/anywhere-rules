# Anywhere Routing Rule Sets (Russia / Runetfreedom)

Наборы правил маршрутизации в нативном формате `.arrs` для клиента [Anywhere](https://github.com/NodePassProject/Anywhere) (iOS / iPadOS / macOS), сконвертированные из базы [runetfreedom/russia-v2ray-rules-dat](https://github.com/runetfreedom/russia-v2ray-rules-dat).

Правила автоматически синхронизируются через GitHub Actions дважды в сутки.

---

## 🌍 СЦЕНАРИЙ 1: Вы находитесь ВНЕ России (Доступ к сайтам РФ)

Если вы за границей, ваш основной интернет должен работать быстро и напрямую (**DIRECT**), а через российский прокси (**RU Proxy**) должны открываться только государственные сайты, банки, стриминги и сервисы, требующие IP РФ.

### Рекомендуемые наборы:

| Набор | Что входит | Куда направить в Anywhere | Импорт в 1 клик | Прямая ссылка |
|---|---|---|---|---|
| **`RuServices.arrs`** ⭐ *(Рекомендуется)* | **Только сервисы с гео-блоком:** Госуслуги, Налоговая, Мос.ру, Банки (Сбер, Т-Банк, ВТБ, Альфа), РЖД, Аэрофлот, Кинопоиск, Иви, ТВ, Авито и др. (~250 доменов) | **Ваш RU Прокси** | [**Импортировать**](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuServices.arrs) | [`RuServices.arrs`](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuServices.arrs) |
| **`RuAll.arrs`** | **Вообще все сайты РФ:** все домены зон `.ru`, `.рф`, `.su` + сервисы РФ на других доменах (VK, Дзен, Mail.ru и др.) | **Ваш RU Прокси** | [**Импортировать**](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuAll.arrs) | [`RuAll.arrs`](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuAll.arrs) |
| **`RuGeoIP.arrs`** | **Все российские IP-подсети:** ~25 000 диапазонов IP РФ (полезно, если мобильные приложения банков обращаются по прямым IP) | **Ваш RU Прокси** | [**Импортировать**](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuGeoIP.arrs) | [`RuGeoIP.arrs`](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuGeoIP.arrs) |

---

## 🛡️ СЦЕНАРИЙ 2: Вы находитесь В России (Обход блокировок)

Если вы находитесь в РФ и хотите открывать заблокированные ресурсы через зарубежный прокси:

| Набор | Что входит | Куда направить в Anywhere | Импорт в 1 клик | Прямая ссылка |
|---|---|---|---|---|
| **`RuBlocked.arrs`** | Полный список заблокированных доменов (~75 000 доменов) | **Зарубежный Proxy** | [**Импортировать**](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuBlocked.arrs) | [`RuBlocked.arrs`](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked.arrs) |
| **`RuBlocked_Community.arrs`** | Только основные заблокированные сервисы (Instagram, X, Discord, AI, трекеры) | **Зарубежный Proxy** | [**Импортировать**](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuBlocked_Community.arrs) | [`RuBlocked_Community.arrs`](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked_Community.arrs) |
| **`RuBlocked_IP.arrs`** | Список заблокированных IP-адресов (~88 000 правил) | **Зарубежный Proxy** | [**Импортировать**](https://diluchshev-cmd.github.io/anywhere-rules/import.html?link=https%3A%2F%2Fraw.githubusercontent.com%2Fdiluchshev-cmd%2Fanywhere-rules%2Fmain%2FRuBlocked_IP.arrs) | [`RuBlocked_IP.arrs`](https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuBlocked_IP.arrs) |

---

## ⚙️ Пошаговая настройка в Anywhere для тех, кто за границей

1. В Anywhere добавьте ваш **Российский прокси** в список серверов / узлов.
2. Откройте **Settings** -> **Routing Rules** (Правила маршрутизации).
3. Добавьте правило **`RuServices`** (или **`RuAll`**):
   - Либо кликните по ссылке **Импортировать** выше.
   - Либо нажмите **+** и вставьте URL:
     `https://raw.githubusercontent.com/diluchshev-cmd/anywhere-rules/main/RuServices.arrs`
4. В поле назначения для этого правила выберите **ваш Российский сервер/прокси**.
5. Убедитесь, что для остального трафика (Default Policy) стоит **DIRECT**:
   - Весь ваш обычный трафик (YouTube, Google, локальные сайты) пойдёт напрямую без задержек.
   - Все Госуслуги, банки и российские сервисы пойдут через ваш российский сервер!
