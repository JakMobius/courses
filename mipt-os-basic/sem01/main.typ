
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4"
#import "../theme/theme.typ": *
#import "./utils.typ": draw-compiler-lifecycle

#show: theme

#title-slide[
    #align(horizon + center)[
      = Базовые инструменты разработки

      АКОС, МФТИ

      11 сентября, 2025
    ]
  ]

#show: enable-handout

#slide[
  #let row(image-path, link-url, link-text) = [
    #white-box[
      #box(baseline: 7pt)[#image(image-path, width: 30pt)]
      #link(link-url)[#link-text]
    ]
  ]
  #align(center + horizon)[
    Ваш семинарист:

    #text(45pt)[Артем]

    Так и запишите.
  ]

  #place(bottom)[
    #row("img/mail.png", "klimov.aiu@phystech.edu")[*klimov.aiu\@phystech.edu*]
  ]
  #place(bottom + right)[
    #row("img/telegram.png", "t.me/prostokvasha")[*\@prostokvasha*]
  ]
]

#slide(header: [Ваши ассистенты:], place-location: horizon)[

  #box(stroke: (left: black + 4pt), inset: (x: 15pt, y: 15pt))[
    === Накорнеева Юлия Альбертовна
    #box(baseline: 7pt, image("img/telegram.png", width: 30pt))
    #link("t.me/yulianakorneeva")[
      *\@yulianakorneeva*
    ]
  ]
]

#plain-slide[
  #align(horizon + center)[
    #image("img/what-is-acos.jpeg", width: 80%)
  ]
]

#slide(
  header: [АКОС поможет вам глубже понимать вот это:], place-location: horizon + center,
)[
  #set text(size: 25pt)
  #cetz.canvas(
    length: 1cm, {
      import cetz.draw: *

      set-style(
        content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
      )

      let element(base-color, inner-text) = {
        let background-color = color.mix((base-color, 20%), (white, 80%))
        let stroke-color = color.mix((base-color, 50%), (black, 50%))
        let text-color = stroke-color

        box(
          fill: background-color, radius: 20pt, width: 100%, height: 100%, stroke: 3pt + stroke-color,
        )[
          #align(center + horizon)[
            #text(fill: text-color, font: "Monaco", inner-text)
          ]
        ]
      }

      let width = 4
      let margin = 3
      let arr = (
        (text: "exe", color: blue), (text: "OS", color: red), (text: "Железо", color: black),
      )

      let x = 0

      set-style(mark: (symbol: ">"), stroke: 3pt + black)

      for step in arr {
        content((x, 4), (x + width, 0), padding: 0)[
          #element(step.color)[#step.text]
        ]

        if x != 0 {
          line((x - margin + 0.1, 2), (x - 0.1, 2))
        }

        x = x + width + margin
      }
    },
  )
]

#focus-slide[
  #text(size: 40pt)[*Мотивационный пример*]
]

#slide(header: [Общие утилиты], place-location: horizon)[
  - #bash("man") : мануалы по чему угодно;
    - #bash("man man") : мануалы по мануалам;
  - #bash("touch") : создать файл;
  - #bash("mkdir") : создать директорию;
  - #bash("pwd") : вывести текущую директорию.
  - #bash("cd") : сменить директорию;
  - #bash("ls") : вывести содержимое директории.
]

#slide(
  header: [Работа с файлами], place-location: horizon,
)[
  - #bash("nano") , #bash("micro") , #bash("vim") , #bash("emacs") : редакторы
    текста;
  - #bash("less") : быстрая навигация по файлу;
  - #bash("cat") : вывести содержимое файла;
  - #bash("grep") : найти какой-то текст в файле (директории);
  - #bash("find") : искать файлы по имени / дате создания / ...;
  - #bash("mv") : переместить / переименовать файл;
  - #bash("rm") : удалить файл / директорию.
]

#slide(header: [Что делает нас программистами], place-location: horizon)[
  - #bash("gcc") , #bash("clang") : компиляторы;
  - #bash("gdb") , #bash("lldb") : отладчики;
  - #bash("ld") : компоновщик;
  - #bash("strace") : перехватчик системных вызовов.
]

#focus-slide[
  #text(size: 40pt)[*Пользуйтесь консолью!*]

  #text(size: 20pt)[Это кажется неудобным только первый год.]
]

#slide(
  header: [Как работает GCC], place-location: horizon + center,
)[
  #cetz.canvas(
    length: 1cm, {
      import cetz.draw: *

      set-style(
        content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
      )

      let arr = (
        (text: "Исходный код", color: blue, width: 5), //
        (
          text: "Код без директив препроцессора", code: bash("gcc -E"), color: black, width: 7,
        ), //
        (text: "Ассемблерный код", code: bash("gcc -S"), color: black, width: 7), //
        (text: "Объектный файл", code: bash("gcc -c"), color: black, width: 5), //
        (text: "Исполняемый файл", color: blue, width: 6), //
      )

      draw-compiler-lifecycle(arr)
    },
  )
]

#slide(
  header: [Как работает Clang], place-location: horizon + center,
)[
  #cetz.canvas(
    length: 1cm, {
      import cetz.draw: *

      set-style(
        content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
      )

      let arr = (
        (text: "Исходный код", color: blue, width: 5), //
        (
          text: "Код без директив препроцессора", code: bash("clang -E"), color: black, width: 7,
        ), //
        (
          text: "Байткод LLVM", code: bash("clang -S -emit-llvm"), color: black, width: 9,
        ), //
        (text: "Объектный файл", code: bash("clang -c"), color: black, width: 5), //
        (text: "Исполняемый файл", color: blue, width: 6), //
      )

      draw-compiler-lifecycle(arr)
    },
  )
]

#slide(
  header: [Директивы препроцессора], place-location: horizon, background-image: none,
)[

#code(numbers: true)[```c
    #define MACRO 42               // Определение макросов
    #include "my-header.h"         // Включение других файлов с кодом

    #ifdef WIN32                   // Проверка платформы
      #error Please, install Linux // Ошибки
    #endif

    #ifndef DEBUG                   // Условная компиляция
    void debug_function() { /* noop */ }
    #else
    void debug_function() { printf("debug_function called!\n"); }
    #endif
    ```]

Макросы также можно определять флагами компилятора: #bash("gcc -D<MACRO_NAME>[=VALUE] ...")
]

#slide(header: [Хитрости с препроцессором], background-image: none)[

#code(numbers: true)[```c
  #include <stdio.h>
  #include <stdlib.h>

  // Макрос для вывода ошибки c названием файла и номером строки:
  #define BAIL(message) { \
    printf("%s:%d: Fatal error: %s\n", __FILE__, __LINE__, message); \
    exit(1); }

  // Пример использования:
  int* allocate_int_array(int n) {
    int* result = (int*)calloc(n, sizeof(int));
    if(!result) BAIL("Cannot allocate memory");
    return result;
  }
  ```]

#codebox("main.c:12: Fatal error: Cannot allocate memory")
]

#slide(
  header: [Исполняемые файлы], place-location: horizon,
)[
  Файл считается *исполняемым*, если он имеет права на исполнение. Linux *не
  смотрит на расширение*.

  Чтобы понять, как запускать файл, Linux смотрит на его начало:

  - #codebox("0x7f 0x45 0x4c 0x46") : магический заголовок ELF-файла;

  - #codebox("#!/usr/bin/python3") : shebang, указывает на интерпретатор;

  - Ни то, ни другое - файл запускается как шелл-скрипт.
]

#slide(
  header: [#emoji.sparkles Магические заголовки #emoji.sparkles], place-location: horizon + center,
)[
  #let formats = (
    (".png", "89 50 4E 47 0D 0A 1A 0A"), (".gif", "GIF87a, GIF89a"), (".jpg, .jpeg", "FF D8 FF"), (".rar", "52 61 72 21 1A 07"), (".pdf", "25 50 44 46 2D"),
  )

  #let rows = formats.map(
    line => (
      text(font: "Monaco")[#line.at(0)], line.at(1).split(", ").map(code => codebox(code)).join(" , "),
    ),
  ).flatten()

  #table(
    columns: (auto, auto), inset: (x: 20pt, y: 10pt), align: horizon, table.header([*Формат*], [*Заголовок*]), ..rows,
  )

  #white-box[
    🔗 #link(
      "https://en.wikipedia.org/wiki/List_of_file_signatures",
    )[*wikipedia.org/wiki/List_of_file_signatures*]
  ]
]

#slide(
  header: [Автоматизация сборки: #bash("make")], place-location: horizon, background-image: none,
)[
  - Отслеживает даты изменений файлов;
  - Пересобирает то, что устарело, пользуясь явным деревом зависимостей.

  #uncover(
    (beginning: 2),
  )[
    *#colbox(color: green)[Плюсы:]*

    - Пересобирает только то, что нужно;
    - Гибкий, не привязан к компилятору, работает с произвольными командами.
  ]

  #uncover((beginning: 3))[
    *#colbox(color: red)[Минусы:]*

    - Нужно заморачиваться с зависимостями заголовков;
    - ...И с кроссплатформенностью;
    - Если заморочиться со всем, мейкфайл будет огромным.
  ]
]

#slide(
  header: [Автоматизация сборки: #bash("cmake")], place-location: horizon, background-image: none,
)[
  - Скриптоподобный язык для генерации схем сборки.

  #uncover((beginning: 2))[
    *#colbox(color: green)[Плюсы:]*

    - Знает особенности разных платформ;
    - Удобнее организована работа с библиотеками (vcpkg, pkg-config, ...);
    - Сам разбирается с зависимостями между заголовками.
  ]

  #uncover((beginning: 3))[
    *#colbox(color: red)[Минусы:]*

    - Нужно учить целый отдельный язык;
    - Менее гибкий.
  ]
]

#slide(
  header: [Рекомендации по написанию кода], place-location: horizon, background-image: none,
)[
  - Code Style может быть любым, главное - *консистентным*;

  #set par(leading: 12pt)

  #uncover((beginning: 1))[
    - #bash("clang-format") поможет следить за этим;
  ]

  #uncover((beginning: 2))[
    - За чем он *не* сможет следить:

      - За названиями переменных;
      - За освобождением памяти;
      - За обработкой ошибок;
      - За структурой кода;
      - За наличием комментариев в нетривиальных местах.
  ]

  #uncover(
    (beginning: 3),
  )[
    - Умные IDE и #bash("clang-tidy") могут помочь и с этим, но лучше следить самим;
  ]

  #uncover((beginning: 4))[
    - Постарайтесь не пользоваться нейросетями.
  ]
]

#slide(
  header: [Инструменты дебага], place-location: horizon,
)[
  #set image(width: 40pt);
  #set box(baseline: 15pt);

  #box[#image("img/weak-doge.png")] #codebox(lang: "c", "printf(\"debug 374\\n\")") :
  конечно, способ;

  #set image(width: 60pt);

  #uncover(
    (beginning: 2),
  )[
    Но куда проще использовать:

    #box(baseline: 25pt, inset: (x: 10pt))[#image("img/strong-doge-2.png")] #bash("strace") :
    перехватчик системных вызовов;

    #box(baseline: 25pt, inset: (x: 10pt))[#image("img/strong-doge.png")] #bash("gdb") или #bash("lldb") :
    отладчики для пошагового выполнения программы.
  ]
]

#slide(
  header: [Как пользоваться gdb], place-location: horizon, background-image: none,
)[
  - Запуск отладочной консоли: #bash("gdb ./a.out");
    - #codebox(lang: "bash", "run") : запустить программу;
    - #codebox(lang: "bash", "break <where>") : поставить точку останова;
    - #codebox(lang: "bash", "next") : выполнить следующую строку;
    - #codebox(lang: "bash", "step") : войти в процедуру;
    - #codebox(lang: "bash", "print <expression>") : вывести значение выражения;
    - #codebox(lang: "bash", "quit") : выйти из gdb.
  #let prefixes = ("r", "b", "n", "p", "q")
  - Команды можно сокращать: (#prefixes.map(p => codebox(p)).join(" , "));
  - #link(
      "https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf",
    )[🔗 *GDB cheat-sheet*].
  #colbox(color: gray)[⚠️] Нужно сгенерировать отладочную информацию: #bash("gcc -g main.c");
]

#slide(
  header: [Как пользоваться strace], place-location: horizon, background-image: none,
)[
  - Запуск программы с помощью strace: #bash("strace ./a.out");
  - Основные команды:
    - #bash("strace -e trace=open,exec,... ./a.out") : фильтрация системных вызовов;
    - #bash("strace -e trace=%file ./a.out") : отслеживать только работу с файлами;
    - #bash("strace -p <pid>") : подключиться к уже запущенному процессу;
    - #bash("strace -o output.txt ./a.out") : сохранить вывод в файл;
    - #bash("strace -c ./a.out") : собрать статистику по системным вызовам;

  - #link("https://strace.io/")[🔗 *Strace docs*]
]

#slide( 
  header: "Утечка памяти...",
  place-location: horizon
)[
  *...это потеря указателя на выделенную память:*

  #code[```c
    char* buffer = calloc(1024, 1);
    read(input, buffer, 1024);
    write(output, buffer, 1024);
    // free(buffer);
    buffer = NULL;
  ```]

  #uncover((beginning: 2))[

    *Менее очевидный пример:*

    #code[```c
      buffer = realloc(buffer, 2048);
    ```]

  ]
]

#slide(
  header: "Утечки файловых дескрипторов",
  place-location: horizon
)[
  #code[```c
    int file = open("input.txt", O_RDONLY);
    read(file, buffer, 1024);
    // close(file)
    file = open("output.txt", O_WRONLY);
    write(file, buffer, 1024);
  ```]

  *Открытые дескрипторы занимают память в ядре, так что это тоже утечка памяти.*
]

#slide(
  header: "Чем череваты утечки?",
  place-location: horizon
)[
  - *В утилите, которая работает недолго* - ничем, ресурсы освободятся при завершении программы;

  - *В долгоживущей программе (веб-сервер, игра, ...)* - рано или поздно ресурсы закончатся;

  - *В ядре* - вы повторите судьбу CrowdStrike;

  #uncover((beginning: 2))[

    - *В домашке по АКОСу* - бан.
  ]
]

#slide(
  header: [Поиск утечек памяти: #bash("valgrind")]
)[
  - Эмулирует процессор и следит за аллокациями;
  - Использование: #bash("valgrind your-awesome-program").

  #uncover(
    (beginning: 2),
  )[
    *#colbox(color: green)[Плюсы:]*

    - Находит много других проблем (например, чтение неинициализированной памяти).
  ]

  #uncover((beginning: 3))[
    *#colbox(color: red)[Минусы:]*

    - Очень медленный (замедляет в 10-100 раз);
    - Многопоточные программы становятся однопоточными.
  ]
]

#slide(
  header: [Поиск утечек памяти: LeakSanitizer],
  background-image: none,
)[
  - Санитайзер компилятора #bash("clang");
  - Встраивает код для отслеживания аллокаций прямо в исполняемый файл;
  - Использование: #bash("clang -fsanitize=leak").

  #uncover(
    (beginning: 2),
  )[
    *#colbox(color: green)[Плюсы:]*

    - Почти не замедляет программу;
    - Поддерживает многопоточность.
  ]

  #uncover((beginning: 3))[
    *#colbox(color: red)[Минусы:]*

    - Доступен только в #bash("clang");
    - Использует #codebox("ptrace()") $=>$ не работает под дебаггером, под #bash("strace") , и в некоторых контейнерах.
  ]
]

#slide(
  header: [#codebox("-fsanitize=")]
)[
  - #codebox("address") : поиск ошибок использования памяти (переполнения, use-after-free, ...);
  - #codebox("thread") : поиск гонок;
  - #codebox("undefined") : поиск неопределённого поведения;
  - #codebox("memory") : поиск использования неинициализированной памяти;
  - #codebox("leak") : поиск утечек памяти.

  #colbox(color: red)[⚠️] : *MemorySanitizer и LeakSanitizer доступны только в #bash("clang").*

  #colbox(color: red)[⚠️] : *Не все санитайзеры совместимы друг с другом*
]

#focus-slide[
  #text(size: 40pt)[*Интерактив*]
]

#title-slide[
  #place(horizon + center)[
    = Спасибо за внимание!
  ]

  #place(
    bottom + center,
  )[
    // #qr-code("https://github.com/JakMobius/courses/tree/mipt-os-basic-2025/", width: 5cm)

    #box(
      baseline: 0.2em + 4pt, inset: (x: 15pt, y: 15pt), radius: 5pt, stroke: 3pt + rgb(185, 186, 187), fill: rgb(240, 240, 240),
    )[
      🔗 #link(
        "github.com/JakMobius/courses/tree/mipt-os-basic-2025",
      )[*github.com/JakMobius/courses/tree/mipt-os-basic-2025*]
    ]
  ]
]