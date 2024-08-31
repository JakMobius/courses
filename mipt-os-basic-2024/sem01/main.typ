// Get Polylux from the official package repository
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "../theme/theme.typ": *
#import "@local/svg-emoji:0.1.0": setup-emoji
#import "@preview/cades:0.3.0": qr-code

#set page(paper: "presentation-16-9")
#set text(font: "Roboto")

// Fix list marker baseline
#show list.item: it => {
  let current-marker = if type(list.marker) == array {
    list.marker.at(0)
  } else {
    list.marker
  }
  let hanging-indent = measure(current-marker).width + .6em + .3pt
  set terms(hanging-indent: hanging-indent)
  if type(list.marker) == array {
    terms.item(
      current-marker,
      {
        // set the value of list.marker in a loop
        set list(marker: list.marker.slice(1) + (list.marker.at(0),))
        it.body
      },
    )
  } else {
    terms.item(current-marker, it.body)
  }
}
#set par(leading: 8pt)

#show: setup-emoji

#show link: this => {
  underline[#text(blue)[#this]]
}

#title-slide[
  #align(horizon + center)[
    = АКОС

    МФТИ

    05 сентября, 2024
  ]
]

#let white-box(content, inset: (x: 15pt, y: 10pt)) = {
  box(
    fill: rgb(240, 240, 240), inset: inset, radius: 10pt, content, stroke: 2pt + rgb(185, 186, 187),
  )
}

#slide[
  #align(center + horizon)[
    Ваш семинарист:

    #uncover((beginning: 2))[#text(45pt)[Артем]]

    #uncover((beginning: 2))[Так и запишите.]
  ]

  #uncover((beginning: 3))[
    #place(bottom)[
      #white-box[
        #box(baseline: 7pt)[#image("img/mail.png", width: 30pt)]
        #link("klimov.aiu@phystech.edu")
      ]
    ]
    #place(bottom + right)[
      #white-box[
        #box(baseline: 7pt)[#image("img/telegram.png", width: 30pt)]
        #link("t.me/prostokvasha")[
          #"@prostokvasha"
        ]
      ]
    ]
  ]
]

#slide(header: [Ваши ассистенты:], place-location: horizon)[

  #box(stroke: (left: black + 4pt), inset: (x: 15pt, y: 15pt))[
    === Морозов Артемий Андреевич
    #box(baseline: 7pt, image("img/telegram.png", width: 30pt))
    #link("t.me/tokreal")[
      #"@tokreal"
    ]
  ]

  #box(stroke: (left: black + 4pt), inset: (x: 15pt, y: 15pt))[
    === Бояров Алексей Алексеевич
    #box(baseline: 7pt, image("img/telegram.png", width: 30pt))
    #link("t.me/simpleus")[
      #"@simpleus"
    ]
  ]
]

#plain-slide[
  #align(horizon + center)[
    #image("img/what-is-acos.jpeg", width: 80%)
  ]
]

#slide(header: [АКОС поможет вам глубже понимать вот это:], place-location: horizon + center)[
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

#let shell(lang: none, prefix: text(fill: green)[`$`], content) = {
  box(
    baseline: 0.2em + 4pt, inset: (x: 8pt, y: 8pt), radius: 5pt, fill: rgb(60, 60, 60),
  )[
    #if prefix != none [
      #prefix
    ]
    #set text(fill: white)
    #set raw(theme: "../theme/halcyon.tmTheme")
    #raw(lang: lang, content)
  ]
}

#slide(header: [Общие утилиты], place-location: horizon)[
  - #shell(lang: "bash", "man") : мануалы по чему угодно;
    - #shell(lang: "bash", "man man") : мануалы по мануалам;
  - #shell(lang: "bash", "touch") : создать файл;
  - #shell(lang: "bash", "mkdir") : создать директорию;
  - #shell(lang: "bash", "pwd") : вывести текущую директорию.
  - #shell(lang: "bash", "cd") : сменить директорию;
  - #shell(lang: "bash", "ls") : вывести содержимое директории.
]

#slide(header: [Работа с файлами], place-location: horizon)[
  - #shell(lang: "bash", "nano") , #shell(lang: "bash", "micro") , #shell(lang: "bash", "vim") , #shell(lang: "bash", "emacs") : редакторы
    текста;
  - #shell(lang: "bash", "less") : быстрая навигация по файлу;
  - #shell(lang: "bash", "cat") : вывести содержимое файла;
  - #shell(lang: "bash", "grep") : найти какой-то текст в файле (директории);
  - #shell(lang: "bash", "find") : искать файлы по имени / дате создания / ...;
  - #shell(lang: "bash", "mv") : переместить / переименовать файл;
  - #shell(lang: "bash", "rm") : удалить файл / директорию.
]

#slide(header: [Что делает нас программистами], place-location: horizon)[
  - #shell(lang: "bash", "gcc") , #shell(lang: "bash", "clang") : компиляторы;
  - #shell(lang: "bash", "gdb") , #shell(lang: "bash", "lldb") : отладчики;
  - #shell(lang: "bash", "ld") : компоновщик;
  - #shell(lang: "bash", "strace") : перехватчик системных вызовов.
]

#focus-slide[
  #text(size: 40pt)[*Пользуйтесь консолью!*]

  #text(size: 20pt)[Это кажется неудобным только первый год.]
]

#let draw-compiler-lifecycle(arr) = {
  let margin = -1.5
  let arrow-top = 5.5
  let arrow-bottom = 4.5
  let arrow-shortage = 1.4

  let anchor-prev = 0
  let x = 0
  let i = 0

  cetz.draw.set-style(mark: (end: ">"), stroke: 3pt + black)

  for step in arr {
    let background-color = color.mix((step.color, 20%), (white, 80%))
    let stroke-color = color.mix((step.color, 50%), (black, 50%))
    let text-color = stroke-color
    let has-code = step.at("code", default: none) != none
    let lower-boundary = 0

    if has-code {
      lower-boundary = 1.4
    }

    let y = 0

    if calc.rem(i, 2) == 0 {
      y = 6
    }

    cetz.draw.content(
      (x, y + 4), (x + step.width, y), padding: 0,
    )[
      #box(
        fill: background-color, radius: 20pt, width: 100%, height: 100%, stroke: 1pt + stroke-color,
      )
    ]

    cetz.draw.content(
      (x, y + 4), (x + step.width, y + lower-boundary), padding: 0,
    )[
      #set text(fill: text-color, size: 18pt)
      #box(
        width: 100%, height: 100%, inset: (left: 7pt, top: 7pt, right: 7pt, bottom: 0pt),
      )[
        #align(center + horizon)[
          #step.text
        ]
      ]
    ]

    if has-code {
      cetz.draw.content(
        (x, y + lower-boundary), (x + step.width, y), padding: 0,
      )[
        #set text(fill: text-color, font: "Monaco", size: 18pt)
        #box(
          width: 100%, height: 100%, inset: (left: 7pt, top: 0pt, right: 7pt, bottom: 7pt),
        )[
          #align(center + horizon)[
            #shell(lang: "bash", step.code)
          ]
        ]
      ]
    }

    let anchor = x + step.width / 2 - arrow-shortage

    if x != 0 {
      if calc.rem(i, 2) == 0 {
        cetz.draw.line((anchor-prev, arrow-bottom), (anchor, arrow-top))
      } else {
        cetz.draw.line((anchor-prev, arrow-top), (anchor, arrow-bottom))
      }
    }

    anchor-prev = x + step.width / 2 + arrow-shortage

    x = x + margin + step.width
    i = i + 1
  }
}

#slide(header: [Как работает GCC], place-location: horizon + center)[
  #cetz.canvas(
    length: 1cm, {
      import cetz.draw: *

      set-style(
        content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
      )

      let arr = (
        (text: "Исходный код", color: blue, width: 5), (
          text: "Код без директив препроцессора", code: "gcc -E", color: black, width: 7,
        ), (text: "Ассемблерный код", code: "gcc -S", color: black, width: 7), (text: "Объектный файл", code: "gcc -c", color: black, width: 5), (text: "Исполняемый файл", color: blue, width: 6),
      )

      draw-compiler-lifecycle(arr)
    },
  )
]

#slide(header: [Как работает Clang], place-location: horizon + center)[
  #cetz.canvas(
    length: 1cm, {
      import cetz.draw: *

      set-style(
        content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
      )

      let arr = (
        (text: "Исходный код", color: blue, width: 5), (
          text: "Код без директив препроцессора", code: "clang -E", color: black, width: 7,
        ), (
          text: "Байткод LLVM", code: "clang -S -emit-llvm", color: black, width: 9,
        ), (text: "Объектный файл", code: "clang -c", color: black, width: 5), (text: "Исполняемый файл", color: blue, width: 6),
      )

      draw-compiler-lifecycle(arr)
    },
  )
]

#slide(header: [Директивы препроцессора], place-location: horizon, background-image: none)[

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

  Макросы также можно определять флагами компилятора: #shell(lang: "bash", "gcc -D<MACRO_NAME>[=VALUE] ...")
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

#shell(prefix: none, "main.c:12: Fatal error: Cannot allocate memory")
]

#slide(header: [Исполняемые файлы], place-location: horizon)[
  Файл считается *исполняемым*, если он имеет права на исполнение. Linux *не
  смотрит на расширение*.

  Чтобы понять, как запускать файл, Linux смотрит на его начало:

  - #shell(prefix: none, "0x7f 0x45 0x4c 0x46") : магический заголовок ELF-файла;

  - #shell(prefix: none, "#!/usr/bin/python3") : shebang, указывает на интерпретатор;

  - Ни то, ни другое - файл запускается как шелл-скрипт.
]

#slide(header: [#emoji.sparkles Магические заголовки #emoji.sparkles], place-location: horizon + center)[
  #table(
    columns: (auto, auto), inset: (x: 20pt, y: 10pt), align: horizon, table.header([*Формат*], [*Заголовок*]), text(font: "Monaco")[.png], [#shell(prefix: none, "89 50 4E 47 0D 0A 1A 0A")], text(font: "Monaco")[.gif], [#shell(prefix: none, "GIF87a") , #shell(prefix: none, "GIF89a")], text(font: "Monaco")[.jpg, .jpeg], [#shell(prefix: none, "FF D8 FF")], text(font: "Monaco")[.rar], [#shell(prefix: none, "52 61 72 21 1A 07")], text(font: "Monaco")[.pdf], [#shell(prefix: none, "25 50 44 46 2D")],
  )

  #white-box[
    #link("https://en.wikipedia.org/wiki/List_of_file_signatures")
  ]
]

#let colbox(color: red, content) = {
    box(
    baseline: 0.2em + 4pt, inset: (x: 10pt, y: 10pt), radius: 5pt, fill: color,
  )[
    #set text(fill: white, font: "Roboto")
    #content
  ]
}

#slide(header: [Автоматизация сборки], place-location: horizon, background-image: none)[

  *Утилита #shell(lang: "bash", "make")*:
  - Отслеживает даты изменений файлов;
  - Пересобирает то, что устарело, пользуясь явным деревом зависимостей.

  #uncover((beginning: 2))[
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

#slide(header: [Автоматизация сборки], place-location: horizon, background-image: none)[

  *Утилита #shell(lang: "bash", "cmake")*:
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

#slide(header: [Рекомендации по написанию кода], place-location: horizon, background-image: none)[
  - Code Style может быть любым, главное - *консистентным*;

  #set par(leading: 12pt)

  #uncover((beginning: 1))[
    - #shell(lang: "bash", "clang-format") поможет следить за этим;
  ]

  #uncover((beginning: 2))[
    - За чем он *не* сможет следить:

      - За названиями переменных;
      - За освобождением памяти;
      - За обработкой ошибок;
      - За структурой кода;
      - За наличием комментариев в нетривиальных местах.
  ]

  #uncover((beginning: 3))[
    - Умные IDE и #shell(lang: "bash", "clang-tidy") могут помочь и с этим, но лучше следить самим;
  ]

  #uncover((beginning: 4))[
    - Постарайтесь не пользоваться нейросетями.
  ]
]

#slide(header: [Инструменты дебага], place-location: horizon)[
  #set image(width: 40pt);
  #set box(baseline: 15pt);

  #box[#image("img/weak-doge.png")] #shell(lang: "c", prefix: none, "printf(\"debug 374\\n\")") : конечно, способ;

  #set image(width: 60pt);

  #uncover((beginning: 2))[
    Но куда проще использовать:

    #box(baseline: 25pt, inset: (x: 10pt))[#image("img/strong-doge-2.png")] #shell(lang: "bash", "strace") : перехватчик системных вызовов;

    #box(baseline: 25pt, inset: (x: 10pt))[#image("img/strong-doge.png")] #shell(lang: "bash", "gdb") или #shell(lang: "bash", "lldb") : отладчики для пошагового выполнения программы.
  ]
]

#slide(header: [Как пользоваться gdb], place-location: horizon, background-image: none)[
  - Запуск отладочной консоли: #shell(lang: "bash", "gdb a.out");
    - #shell(prefix: none, lang: "bash", "run") : запустить программу;
    - #shell(prefix: none, lang: "bash", "break <where>") : поставить точку останова;
    - #shell(prefix: none, lang: "bash", "next") : выполнить следующую строку;
    - #shell(prefix: none, lang: "bash", "step") : войти в процедуру;
    - #shell(prefix: none, lang: "bash", "print <expression>") : вывести значение выражения;
    - #shell(prefix: none, lang: "bash", "quit") : выйти из gdb.
  - Команды можно сокращать: (#shell(prefix:none, "r") , #shell(prefix:none, "b") , #shell(prefix:none, "n") , #shell(prefix:none, "p") , #shell(prefix:none, "q"))
  - #link("https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf")[GDB cheat-sheet]
  #colbox(color: gray)[⚠️] Нужно сгенерировать отладочную информацию: #shell(lang: "bash", "gcc -g main.c");
]

#slide(header: [Как пользоваться strace], place-location: horizon, background-image: none)[
  - Запуск программы с помощью strace: #shell(lang: "bash", "strace ./a.out");
  - Основные команды:
    - #shell(lang: "bash", "strace -e trace=open,exec,... ./a.out") : фильтрация системных вызовов;
    - #shell(lang: "bash", "strace -e trace=file ./a.out") : отслеживать только работу с файлами;
    - #shell(lang: "bash", "strace -p <pid>") : подключиться к уже запущенному процессу;
    - #shell(lang: "bash", "strace -o output.txt ./a.out") : сохранить вывод в файл;
    - #shell(lang: "bash", "strace -c ./a.out") : собрать статистику по системным вызовам;
  - #link("https://strace.io/")[Strace docs]
]

#focus-slide[
  #text(size: 40pt)[*Интерактив*]
]
