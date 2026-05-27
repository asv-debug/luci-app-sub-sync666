# luci-app-sub-syncv2

**luci-app-sub-syncv2** — это LuCI-модуль для OpenWrt, который добавляет Sub Sync прямо внутрь интерфейса Podkop.

После установки модуль открывается не отдельной страницей, а внутри стандартного пункта:

```text
Services → Podkop
```

Sub Sync позволяет добавлять подписки, загружать серверы из ссылок, очищать кэш серверов и синхронизировать найденные серверы для дальнейшего использования вместе с Podkop.

---

## Что это за модуль

`luci-app-sub-syncv2` — это интеграция Sub Sync для Podkop на OpenWrt.

Модуль предназначен для удобной работы с подписками прямо из LuCI-интерфейса Podkop. Он добавляет в Podkop дополнительные возможности для загрузки и обработки серверов из subscription-ссылок.

Основная идея модуля:

- не создавать отдельную страницу `Services → Sub Sync`;
- встроить Sub Sync прямо в `Services → Podkop`;
- сохранить родной Podkop;
- безопасно устанавливать и удалять модуль;
- при удалении автоматически возвращать Podkop в исходное состояние.

---

## Возможности

- Интеграция Sub Sync прямо в страницу Podkop
- Работа через стандартный LuCI-интерфейс OpenWrt
- Добавление subscription-ссылок
- Загрузка серверов из подписок
- Очистка кэша серверов
- Синхронизация найденных серверов
- Автоматическое создание резервной копии перед установкой
- Автоматическое восстановление родного меню Podkop при удалении
- Очистка LuCI cache после установки и удаления
- Автоматический перезапуск `rpcd` и `uhttpd`
- Безопасное удаление без поломки Podkop
- Родные JS-файлы Podkop не удаляются

---

## Требования

Перед установкой должен быть установлен и рабочий Podkop.

Требуется:

- OpenWrt
- LuCI
- Podkop
- Доступ роутера в интернет
- `wget`

---

## Установка

Выполнить на роутере через SSH:

```sh
wget -O- "https://raw.githubusercontent.com/kzolotarev95/luci-app-sub-syncv2/main/install.sh?v=$(date +%s)" | sh
```

После установки обновить страницу LuCI через:

```text
Ctrl+F5
```

Затем открыть:

```text
Services → Podkop
```

Sub Sync будет встроен прямо внутрь страницы Podkop.

---

## Удаление

Выполнить на роутере через SSH:

```sh
wget -O /tmp/subsync-uninstall.sh "https://raw.githubusercontent.com/kzolotarev95/luci-app-sub-syncv2/main/uninstall.sh?v=$(date +%s)" && sh /tmp/subsync-uninstall.sh
```

После удаления обновить страницу LuCI через:

```text
Ctrl+F5
```

Podkop будет восстановлен в обычное состояние.

---

## Что делает install.sh

Скрипт установки:

1. Проверяет, что роутер работает на OpenWrt.
2. Проверяет, что установлен Podkop.
3. Создаёт резервную копию перед установкой:

```text
/root/luci-app-sub-sync-before-install-YYYYMMDD-HHMMSS.tar.gz
```

4. Сохраняет родное меню Podkop:

```text
/usr/share/luci/menu.d/luci-app-podkop.json.bak.subsync
```

5. Устанавливает LuCI view Sub Sync:

```text
/www/luci-static/resources/view/sub_sync/sub_sync.js
```

6. Устанавливает backend-скрипт:

```text
/usr/bin/sub-sync
```

7. Создаёт ACL для LuCI/rpcd:

```text
/usr/share/rpcd/acl.d/luci-app-sub-sync.json
```

8. Создаёт рабочую директорию:

```text
/etc/sub-sync
```

9. Переключает route Podkop на интегрированный Sub Sync view:

```text
sub_sync/sub_sync
```

10. Удаляет отдельный пункт `Services → Sub Sync`, если он был.
11. Очищает LuCI cache.
12. Перезапускает:

```text
rpcd
uhttpd
```

---

## Что делает uninstall.sh

Скрипт удаления:

1. Создаёт резервную копию перед удалением:

```text
/root/luci-app-sub-sync-before-uninstall-YYYYMMDD-HHMMSS.tar.gz
```

2. Восстанавливает родное меню Podkop из:

```text
/usr/share/luci/menu.d/luci-app-podkop.json.bak.subsync
```

3. Возвращает route Podkop обратно на:

```text
podkop/podkop
```

4. Удаляет файлы Sub Sync:

```text
/usr/share/rpcd/acl.d/luci-app-sub-sync.json
/www/luci-static/resources/view/sub_sync
/usr/bin/sub-sync
/etc/sub-sync
/tmp/sub-sync*
/tmp/subsync-*
/tmp/luci-app-sub-sync*
```

5. Удаляет cron-задачи Sub Sync, если они были.
6. Очищает LuCI cache.
7. Перезапускает:

```text
rpcd
uhttpd
```

---

## Проверка после установки

Проверить route Podkop:

```sh
grep -n '"path"' /usr/share/luci/menu.d/luci-app-podkop.json
```

После установки должно быть:

```text
"path": "sub_sync/sub_sync"
```

Проверить файлы:

```sh
ls -la /www/luci-static/resources/view/sub_sync/sub_sync.js
ls -la /usr/bin/sub-sync
sh -n /usr/bin/sub-sync
```

---

## Проверка после удаления

Проверить route Podkop:

```sh
grep -n '"path"' /usr/share/luci/menu.d/luci-app-podkop.json
```

После удаления должно быть:

```text
"path": "podkop/podkop"
```

Проверить, что хвостов Sub Sync не осталось:

```sh
find /etc /usr/share/luci/menu.d /usr/share/rpcd/acl.d /www/luci-static/resources/view /tmp \
  \( -iname '*luci-app-sub-sync*' -o -iname '*sub-sync*' -o -iname '*subsync*' -o -iname '*sub_sync*' \) \
  2>/dev/null
```

Если команда ничего не выводит — Sub Sync удалён чисто.

---

## Логи

Полезная команда для проверки ошибок LuCI, Podkop и Sub Sync:

```sh
logread | grep -Ei 'sub-sync|subsync|sub_sync|podkop|rpcd|uhttpd|luci|NetworkError|403|404|SyntaxError|TypeError|validation|domain' | tail -n 160
```

Live-логи:

```sh
logread -f
```

---

## Откат

Перед установкой и удалением скрипты автоматически создают резервные копии в `/root`.

Пример отката из backup:

```sh
tar -xzf /root/luci-app-sub-sync-before-install-YYYYMMDD-HHMMSS.tar.gz -C /
rm -rf /tmp/luci-modulecache/* /tmp/luci-indexcache* /tmp/luci-sessions/* 2>/dev/null || true
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```

---

## Безопасность установки и удаления

Модуль не удаляет родные файлы Podkop:

```text
/www/luci-static/resources/view/podkop/podkop.js
/www/luci-static/resources/view/podkop/main.js
/www/luci-static/resources/view/podkop/settings.js
/www/luci-static/resources/view/podkop/section.js
```

При установке меняется только route меню Podkop, чтобы открыть интегрированный Sub Sync view.

При удалении route Podkop восстанавливается обратно.

---

## GitHub About

```text
Sub Sync integration for Podkop LuCI on OpenWrt. Adds subscription synchronization inside Services → Podkop with safe install/uninstall and automatic Podkop menu restore.
```

---

## Репозиторий

```text
https://github.com/kzolotarev95/luci-app-sub-syncv2
```

---

## Актуальный рабочий коммит

```text
13a3f7d Integrate Sub Sync into Podkop page safely
```
