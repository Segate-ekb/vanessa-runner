<a id="markdown-автоматизация-повседневных-операций-1с-разработчика" name="автоматизация-повседневных-операций-1с-разработчика"></a>
# Автоматизация повседневных операций 1С разработчика

[![Chat on Telegram vanessa_opensource_chat](https://img.shields.io/badge/chat-Telegram-brightgreen.svg)](https://t.me/vanessa_opensource_chat)
[![GitHub release](https://img.shields.io/github/release/vanessa-opensource/vanessa-runner.svg)](https://github.com/vanessa-opensource/vanessa-runner/releases) 
[![Тестирование](https://github.com/vanessa-opensource/vanessa-runner/actions/workflows/testing.yml/badge.svg)](https://github.com/vanessa-opensource/vanessa-runner/actions/workflows/testing.yml)
[![Статус Порога Качества](https://sonar.openbsl.ru/api/project_badges/measure?project=vanessa-runner&metric=alert_status)](https://sonar.openbsl.ru/dashboard?id=vanessa-runner) 
[![Покрытие](https://sonar.openbsl.ru/api/project_badges/measure?project=vanessa-runner&metric=coverage)](https://sonar.openbsl.ru/dashboard?id=vanessa-runner)
[![Технический долг](https://sonar.openbsl.ru/api/project_badges/measure?project=vanessa-runner&metric=sqale_index)](https://sonar.openbsl.ru/dashboard?id=vanessa-runner)
[![Строки кода](https://sonar.openbsl.ru/api/project_badges/measure?project=vanessa-runner&metric=ncloc)](https://sonar.openbsl.ru/dashboard?id=vanessa-runner) 

<!-- [![Статус Порога Качества](https://sonar.openbsl.ru/api/project_badges/measure?project=vanessa-runner&metric=alert_status)](https://sonar.openbsl.ru/dashboard?id=vanessa-runner) [![Покрытие](https://sonar.openbsl.ru/api/project_badges/measure?project=vanessa-runner&metric=coverage)](https://sonar.openbsl.ru/dashboard?id=vanessa-runner) [![Строки кода](https://sonar.openbsl.ru/api/project_badges/measure?project=vanessa-runner&metric=ncloc)](https://sonar.openbsl.ru/dashboard?id=vanessa-runner) -->

<!-- TOC -->

- [Автоматизация повседневных операций 1С разработчика](#автоматизация-повседневных-операций-1с-разработчика)
  - [Описание](#описание)
- [Автоматизация повседневных операций 1С разработчика](#автоматизация-повседневных-операций-1с-разработчика-1)
- [Описание](#описание-1)
  - [Установка](#установка)
  - [Использование](#использование)
    - [Сборка обработок и конфигураций](#сборка-обработок-и-конфигураций)
    - [Примеры настройки и вызова](#примеры-настройки-и-вызова)
      - [1. Создание ИБ из последней конфигурации хранилища 1С, обновление в режиме Предприятия и первоначальное заполнение ИБ](#1-создание-иб-из-последней-конфигурации-хранилища-1с-обновление-в-режиме-предприятия-и-первоначальное-заполнение-иб)
      - [2. Вызов проверки поведения через Vanessa-ADD](#2-вызов-проверки-поведения-через-vanessa-add)
      - [3. Переопределение аргументов запуска](#3-переопределение-аргументов-запуска)
      - [Переопределение переменной окружения](#переопределение-переменной-окружения)
        - [Установка значения](#установка-значения)
      - [Шаблонные переменные](#шаблонные-переменные)
    - [Вывод отладочной информации](#вывод-отладочной-информации)
      - [Примеры](#примеры)
    - [Дополнительные обработки для режима 1С:Предприятие](#дополнительные-обработки-для-режима-1спредприятие)
    - [Дополнительная настройка различных команд](#дополнительная-настройка-различных-команд)
      - [Настройка синтаксической проверки](#настройка-синтаксической-проверки)
      - [Настройка режимов реструктуризации при обновлении конфигурации БД](#настройка-режимов-реструктуризации-при-обновлении-конфигурации-бд)

<!-- /TOC -->

<a id="markdown-описание" name="описание"></a>
## Описание
Автоматизация повседневных операций 1С разработчика
==

Описание
===

Консольное приложение проекта `oscript.io` для автоматизации различных операции для работы с `cf/cfe/epf` файлами, а также автоматизация  запуска сценариев поведения (BDD) и тестов из фреймворка [Vanessa-ADD](https://github.com/vanessa-opensource/add).

Предназначено для организации разработки 1С в режиме, когда работа в git идет напрямую с исходниками или работаем через хранилище 1С.

Позволяет обеспечить единообразный запуск команд "локально" и на серверах сборки `CI-CD`

<a id="markdown-установка" name="установка"></a>
## Установка

используйте пакетный менеджер `opm` из стандартной поставки дистрибутива `oscript.io`

```cmd
opm install vanessa-runner
```

при установке будет создан исполняемый файл `vrunner` в каталоге `bin` интерпретатора `oscript`.

После чего доступно выполнение команд через командную строку `vrunner <имя команды>`

<a id="markdown-использование" name="использование"></a>
## Использование

Ключ `help` покажет справку по параметрам.

```cmd
vrunner help
```

или внутри батника (**ВАЖНО**) через `call`
```cmd
call vrunner help
```

Основной принцип - запустили bat файл с настроенными командами и получили результат.

<a id="markdown-сборка-обработок-и-конфигураций" name="сборка-обработок-и-конфигураций"></a>
### Сборка обработок и конфигураций

Для сборки обработок необходимо иметь установленный oscript в переменной PATH и платформу выше 8.3.8

В командной строке нужно перейти в каталог с проектом и выполнить ```tools\compile_epf.bat```, по окончанию в каталоге build\epf должны появиться обработки.
Вся разработка в конфигураторе делается в каталоге build, по окончанию доработок запускаем ```tools\decompile_epf.bat```

Обязательно наличие установленного v8unpack версии не ниже 3.0.38 в переменной PATH.
  - Установку можно взять в релизах утилиты - https://github.com/e8tools/v8unpack/releases
  - Подробнее про утилиту v8unpack - https://github.com/e8tools/v8unpack

<a id="markdown-примеры-настройки-и-вызова" name="примеры-настройки-и-вызова"></a>
### Примеры настройки и вызова

<a id="markdown-1-создание-иб-из-последней-конфигурации-хранилища-1с-обновление-в-режиме-предприятия-и-первоначальное-заполнение-иб" name="1-создание-иб-из-последней-конфигурации-хранилища-1с-обновление-в-режиме-предприятия-и-первоначальное-заполнение-иб"></a>
#### 1. Создание ИБ из последней конфигурации хранилища 1С, обновление в режиме Предприятия и первоначальное заполнение ИБ


`1с-init.cmd` :

```bat
@rem Полная инициализация из репозитария, обновление в режиме Предприятия и начальное заполнение ИБ ./build/ibservice

@rem Пример запуска 1с-init.cmd storage-user storage-password

@chcp 65001

@set RUNNER_IBNAME=/F./build/ibservice

@call vrunner init-dev --storage --storage-name http:/repo-1c --storage-user %1 --storage-pwd %2

@call vrunner run --command "ЗапуститьОбновлениеИнформационнойБазы;ЗавершитьРаботуСистемы;" --execute $runnerRoot\epf\ЗакрытьПредприятие.epf

@call vrunner vanessa --settings tools/vrunner.first.json

@rem Если убрать комментарий из последней строки, тогда можно выполнять полный прогон bdd-фич
@rem @call vrunner vanessa --settings tools/vrunner.json
```

<a id="markdown-2-вызов-проверки-поведения-через-vanessa-add" name="2-вызов-проверки-поведения-через-vanessa-add"></a>
#### 2. Вызов проверки поведения через Vanessa-ADD

+ запуск `vrunner vanessa --settings tools/vrunner.json`
  + или внутри батника
    + `call vrunner vanessa --settings tools/vrunner.json`

+ vrunner.json:

```json
{
    "default": {
        "--ibconnection": "/F./build/ib",
        "--db-user": "Администратор",
        "--db-pwd": "",
        "--ordinaryapp": "0"
    },
    "vanessa": {
        "--vanessasettings": "./tools/VBParams.json",
        "--workspace": ".",
        "--additional": "/DisplayAllFunctions /L ru"
    }
}
```

+ VBParams.json

```json
{
    "ВыполнитьСценарии": true,
    "ЗавершитьРаботуСистемы": true,
    "ЗакрытьTestClientПослеЗапускаСценариев": true,
    "КаталогФич": "$workspaceRoot/features/01-СистемаУправления",
    "СписокТеговИсключение": [
        "IgnoreOnCIMainBuild",
        "FirstStart",
        "Draft"
    ],
    "КаталогиБиблиотек": [
        "./features/Libraries"
    ],
    "ДелатьОтчетВФорматеАллюр": true,
    "КаталогOutputAllureБазовый": "$workspaceRoot/build/out/allure",
    "ДелатьОтчетВФорматеCucumberJson": true,
    "КаталогOutputCucumberJson": "$workspaceRoot/build/out/cucumber",
    "ВыгружатьСтатусВыполненияСценариевВФайл": true,
    "ПутьКФайлуДляВыгрузкиСтатусаВыполненияСценариев": "$workspaceRoot/build/out/vbStatus.log",
    "ДелатьЛогВыполненияСценариевВТекстовыйФайл": true,
    "ИмяФайлаЛогВыполненияСценариев": "$workspaceRoot/build/out/vbOnline.log"
}
```

<a id="markdown-3-переопределение-аргументов-запуска" name="3-переопределение-аргументов-запуска"></a>
#### 3. Переопределение аргументов запуска

В случае необходимости переопределения параметров запуска используется схема приоритетов.

Приоритет в порядке возрастания (от минимального до максимального приоритета)
+ `env.json (в корне проекта)`
+ `--settings ../env.json (указание файла настроек вручную)`
+ `RUNNER_* (из переменных окружения)`
+ `--* (ключи командной строки)`

Описание:
+ На первоначальном этапе читаются настройки из файла настроек, указанного в ключе команды ```--settings tools/vrunner.json```
+ Потом, если настройка есть в переменной окружения, тогда берем из неe.
+ Если же настройка есть, как в файле json, так и в переменной окружения и непосредственно в командной строке, то берем настройку из командной строки.

Например:

<a id="markdown-переопределение-переменной-окружения" name="переопределение-переменной-окружения"></a>
#### Переопределение переменной окружения

<a id="markdown-установка-значения" name="установка-значения"></a>
##### Установка значения

  1. Допустим, в файле vrunner.json указана настройка
        ```json
        "--db-user":"Администратор"
        ```
        а нам для определенного случая надо переопределить имя пользователя,
        тогда можно установить переменную: ```set RUNNER_DBUSER=Иванов``` и в данный параметр будет передано значение `Иванов`

  2. Очистка значения после установки
        ```cmd
        set RUNNER_DBUSER=Иванов
        set RUNNER_DBUSER=
        ```
        в данном случае установлено полностью пустое значение и имя пользователя будет взято из tools/vrunner.json, если оно там есть.

  3. Установка пустого значения:
        ```cmd
        set RUNNER_DBUSER=""
        set RUNNER_DBUSER=''
        ```

        Если необходимо установить в поле пустое значение, тогда указываем кавычки и в параметр `--db-user` будет установлена пустая строка.

  4. Переопределение через параметры командной строки.

        Любое указание параметра в командной строке имеет наивысший приоритет.

<a id="markdown-шаблонные-переменные" name="шаблонные-переменные"></a>
#### Шаблонные переменные

При указании значений параметров внутри строки с параметром можно использовать шаблонные переменные.
Список таких переменных:

+ workspaceRoot - означает каталог текущего проекта
+ runnerRoot - означает каталог установки Vanessa-Runner
+ addRoot - означает каталог установки библиотеки Vanessa-ADD

<a id="markdown-вывод-отладочной-информации" name="вывод-отладочной-информации"></a>
### Вывод отладочной информации

Управление выводом логов выполняется с помощью типовой для oscript-library настройки логирования через пакет logos.

Основной лог vanessa-runner имеет название ``oscript.app.vanessa-runner``.

<a id="markdown-примеры" name="примеры"></a>
#### Примеры

Включение всех отладочных логов:

```bat
rem только для logos версии >=0.6
set LOGOS_CONFIG=logger.rootLogger=DEBUG

call vrunner <параметры запуска>
```

Если выводится сообщение про неправильные параметры командной строки:

```bat
set LOGOS_CONFIG=logger.oscript.lib.cmdline=DEBUG
call vrunner <параметры запуска>
```

Включит отладочный лог только для библиотеки cmdline, которая анализирует параметры командной строки.

<a id="markdown-дополнительные-обработки-для-режима-1спредприятие" name="дополнительные-обработки-для-режима-1спредприятие"></a>
### Дополнительные обработки для режима 1С:Предприятие

В папке epf есть несколько обработок, позволяющих упростить развертывание/тестирование для конфигураций, основанных на БСП.

+ Основной пример (см. ниже пример вызова) - это передача через параметры `/C` команды `"ЗапуститьОбновлениеИнформационнойБазы;ЗавершитьРаботуСистемы"` и одновременная передача через `/Execute "ЗакрытьПредприятие.epf"`.

  + При запуске с такими ключами подключается обработчик ожидания, который проверяет наличие формы с заголовком обновления и при окончании обновления завершает 1С:Предприятие. Данное действие необходимо для полного обновления информационной базы 1С:Предприятия, пока действует блокировка на фоновые задачи и запуск пользователей.

  + также выполняется отключение запроса при завершении работы программы для БСП-конфигураций

  + код запуска

```bat
  @call vrunner run --command "ЗапуститьОбновлениеИнформационнойБазы;ЗавершитьРаботуСистемы;" --execute $runnerRoot\epf\ЗакрытьПредприятие.epf
```

+ **ЗагрузитьРасширение** позволяет подключать расширение в режиме предприятия и получать результат ошибки. Предназначено для подключения в конфигурациях, основанных на БСП. В параметрах /C передается путь к расширению и путь к файлу лога подключения.

+ **ЗагрузитьВнешниеОбработки** позволяет загрузить все внешние обработки и подключить в справочник "Дополнительные отчеты и обработки", т.к. их очень много то первым параметром идет каталог, вторым параметром путь к файлу лога. Все обработки обновляются согласно версиям.

+ **СозданиеПользователей** позволяет создать первого пользователя-администратора, если в ИБ еще не существует пользователей. Администратор назначается роль `ПолныеПрава`, если она существует в ИБ.

  + также выполняется отключение запроса при завершении работы программы для БСП-конфигураций

  + код запуска для создания пользователя с именем `Администратор`

```bat
      @call vrunner run --command "СоздатьАдминистратора;Имя=Администратор;ЗавершитьРаботуСистемы" --execute $runnerRoot\epf\СоздатьПользователей.epf
```

<a id="markdown-дополнительная-настройка-различных-команд" name="дополнительная-настройка-различных-команд"></a>
### Дополнительная настройка различных команд

<a id="markdown-настройка-синтаксической-проверки" name="настройка-синтаксической-проверки"></a>
#### Настройка синтаксической проверки

Для управления режима синтаксической проверки рекомендуется использовать json-файл настройки.
Для его использования нужно
- установить путь к нему в параметре `VRUNNER_CONF`
- внутри json-файла нужно добавить секцию `syntax-check`
- список всех используемых параметров можно уточнить, выполнив команду `vrunner help syntax-check`
- ссылка на подготовленный файл [examples\example.env.json](./examples/example.env.json)
- также можно передавать параметры синтакс-проверки через командную строку
  - в этом случае режимы проверки должны быть указаны **последним** параметров ком.строки последовательно, через пробел
    -  например, `vrunner syntax-check --groupbymetadata --mode -ExtendedModulesCheck -Server -ThinClient -ExternalConnection`

Пример настройки в файле
```json
{
    "syntax-check": {
        "--groupbymetadata":true,
        "--exception-file":"",
        "--mode": [
            "-ExtendedModulesCheck",
            "-ThinClient",
             "-WebClient",
             "-Server",
             "-ExternalConnection",
             "-ThickClientOrdinaryApplication"
        ]
        // "-Extension" : "ИмяРасширения",
        // "-AllExtensions" : true
    }
}
```

<a id="markdown-настройка-режимов-реструктуризации-при-обновлении-конфигурации-бд" name="настройка-режимов-реструктуризации-при-обновлении-конфигурации-бд"></a>
#### Настройка режимов реструктуризации при обновлении конфигурации БД

Возможно использование специальных режимов реструктуризации `-v1` и `-v2`.

- В режиме командной строки
  - указываются ключи `--v1` и `--v2`. Важно: указать двойной знак `--`, а не одиночный!
  - 3 команды поддерживают эти ключи
    - `init-dev`
    - `update-dev`
    - `updatedb`
  - например, `vrunner updatedb --ibconnection /F./build/ibservice --uccode test --v2`
- в json-файле настройки
  - например,

```json
{
    "updatedb": {
        "--v2": true,
        "--uccode": "test"
    },
    "init-dev": {
        "--v2": true
    }
    },
    "update-dev": {
        "--v2": true
    }
}
```
