
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "../theme/theme.typ": *
#import "./utils.typ": *

#show: theme

#title-slide[
    #align(horizon + center)[
      = Файловые системы

      АКОС, МФТИ

      26 сентября, 2024
    ]
  ]

#show: enable-handout

#focus-slide[
  #set block(above: 25pt, below: 25pt)
  #set text(size: 50pt)
  *Всё есть файл...*

  #uncover((beginning: 2))[
    #set text(size: 25pt)
    *...овый дескриптор*
  ]
]

#slide(place-location: center, background-image: none)[
  #let transparent = color.rgb(255, 255, 255, 0)
  #let left-color = cell-color(base-color: byte-colors.at(0))
  #let right-color = cell-color(base-color: byte-colors.at(3))
  #let box-options = (
    inset: (x: 25pt, y: 30pt),
    width: 12cm, 
    radius: 20pt
  )

  #grid(columns: 2, rows: (1.5cm, auto), column-gutter: 2cm, stroke: none, align: (column, row) => {
    if row == 0 { top + center } else { top + left }
  }, [
    = Встроенные
  ], [
    = Пользовательские
  ], [
    #align(center)[
      #box(
        fill: left-color.background-color, 
        stroke: 1pt + left-color.stroke-color, 
        ..box-options)[
        #align(left, [
          #set text(size: 25pt)
          #set list(marker: raw("="))
          - #codebox(lang: "c", "STDIN_FILENO")
          - #codebox(lang: "c", "STDOUT_FILENO")
          - #codebox(lang: "c", "STDERR_FILENO")
        ])
      ]
    ]

    - *Потоки консоли:* ввод, вывод, ошибки;

    - Почти всегда равны #codebox("0") , #codebox("1") и #codebox("2");

    - Но лучше использовать константы;

    - Их даже можно закрыть (но зачем?).
  ], [
    #align(center)[
      #box(
        fill: right-color.background-color, 
        stroke: 1pt + right-color.stroke-color, 
        ..box-options)[
        #align(left, [
            #set text(size: 25pt)
            #set list(marker: raw("="))
            - #codebox(lang: "c", "open(...)")
            - #codebox(lang: "c", "socket(...)")
            - #codebox(lang: "c", "accept(...)")
            - #codebox(lang: "c", "epoll(...)")
            - #codebox(lang: "c", "socketpair(...)") #super("*") 
            - #codebox(lang: "c", "signalfd(...)") , ...
        ])
      ]
    ]

    - Файлы, сеть, мультиплексеры,...;

    - Всё, что работает как поток данных.
  ])
]

#focus-slide[
  #text(size: 50pt)[
    *Почему не #codebox(lang: "c", "fopen(...)") ?*
  ]

  #uncover((beginning: 2))[
    #text(size: 25pt)[
      #place(center + bottom)[
        Потому что #codebox(lang: "c", "fopen(...)") возвращает #codebox(lang: "c", "FILE*"), а не дескриптор
      ]
    ]
  ]
]

#slide(header: [Папки -- тоже файлы?], background-image: none)[

  #place(horizon + center)[
    #set text(size: 30pt)

    #code(numbers: true, leading: 5pt,
      ```c
      int main() {
        int fd = open("/", O_RDONLY, 0);
        struct dirent ent = {};
        while(getdents64(fd, &ent, sizeof(ent)) > 0) {
            printf("%s\n", ent.d_name);
            lseek(fd, ent.d_off, SEEK_SET);
        }
      }
      ```
    )
  ]

  #uncover((beginning: 2))[
    #place(bottom + center)[
      #set text(size: 21pt)
      *Да, это тоже файловые дескрипторы.* А ещё это директории, а не папки.
    ]
  ]
]

#slide(header: [А если вызвать #codebox(lang: "c", "read(...)") на директорию?], background-image: none)[
  #place(horizon)[
    #text(size: 30pt)[
      #code(numbers: true, leading: 5pt,
        ```c
        int main() {
          int fd = open("/", O_RDONLY, 0);
          char buffer[16];
          if(read(fd, buffer, sizeof(buffer)) >= 0) {
            printf("%15s", buffer);
          } else perror("read");
        }
        ```
      )
    ]
  ]

  #place(bottom)[
    #uncover((beginning: 2))[
      #text(size: 25pt)[
        *Вывод:* #codebox("read: Is a directory") . *Причина:* #codebox(lang: "c", "read(...) == -EISDIR")
      ]
    ]
  ]
]

// Можно сказать, что можно расширить linux своим типом дескрипторов или системных вызовов

#slide(header: [Файловый дескриптор - это], place-location: horizon + left)[
  #let codeblocks(arr) = {
    arr.map(code => codebox(lang: "c", code)).join(" , ")
  }

  - *Число*, сопоставленное какому-то ресурсу.

  - Его можно понимать, как *"указатель" на виртуальный класс*.

  - *Разработчик должен помнить* типы дескрипторов. Это упрощают обёртки:

    - #codeblocks(("FILE", "fopen()", "fclose()", "fread()", "fwrite()", "fseek()")) , ... для файлов;

    - #codeblocks(("DIR", "opendir()", "closedir()", "readdir()", "seekdir()")) , ... для директорий;

    - *И практически ничего* для работы с сокетами / сигналами / pipe-ами.

  - Активные дескрипторы процесса можно увидеть в #codebox("/proc/<pid>/fd/")
]

#slide(header: [#codebox(lang: "c", "open(char *path, int flags, mode_t mode)")], background-image: none)[
  == Открыть (создать) файл (директорию).

  == *#codebox(lang: "c", "int flags") :*
  #set list(marker: `|=`)
  - #codebox("O_RDONLY") : Открыть на чтение;
  - #codebox("O_WRONLY") : Открыть на запись;
  - #codebox("O_RDWR") : Открыть на чтение и запись;
  - #codebox("O_TRUNC") : Очистить файл при открытии;
  - #codebox("O_CREAT") : Создать файл, если его нет;
  - #codebox("O_EXCL") : Сломаться, если файл уже есть.

  == *#codebox(lang: "c", "mode_t mode")* : 9-битная маска прав для создаваемого файла.
]

#slide(header: [#codebox(lang: "c", "fcntl(int fd, int cmd, long arg)")], background-image: none)[
  == Системный вызов управления дескрипторами.

  == *#codebox(lang: "c", "int cmd") :*

  #set list(marker: `=`)
  - #codebox("F_SETFD") : Установить флаги дескриптора;
  - #codebox("F_SETFL") : Установить флаги статуса;
  - #codebox("F_SETLK") : Установить блокировку на файл;
  - #codebox("F_DUPFD") : Дублировать дескриптор;
  - #codebox("F_SETSIG") : Получить сигнал, когда будет доступно чтение / запись;
  - #codebox("F_SETPIPE_SZ") : Настроить размер очереди.

  == *#codebox(lang: "c", "long arg") :*  аргумент, используется в #codebox("F_SET*") - командах
]

#focus-slide[
  #text(size: 50pt)[
    *А что такое файл?*
  ]
]

#slide(header: [Файл - это не путь], background-image: none, place-location: horizon + center)[

  #set text(size: 45pt)
  #codebox("/home/you/first-file")

  #set text(size: 25pt)
  *Может быть тем же файлом, что и:*

  #set text(size: 45pt)
  #codebox("/home/you/second-file")
]

#slide(background-image: none)[  
  #place(top + center)[
    #cetz.canvas(
      length: 1cm, {
        cetz.draw.set-style(
          content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
        )

        let box-options = (
          width: 100%, height: 100%, radius: 10pt, inset: 20pt
          )

        cetz.draw.content((0, 0), (25, -4), padding: none, {
          // set text(font: "Monaco")
          box(
              fill: cell-color(base-color: blue).background-color, stroke: 1pt + cell-color(base-color: blue).stroke-color, ..box-options
          )[
            == Ваша программа

            #set text(size: 30pt)
            #set align(center)
            #codebox(lang: "c", "write(fd, \"Hi!\", 4);")
          ]
        })

        cetz.draw.content((0, -4.5), (25, -9), padding: none, {
          // set text(font: "Monaco")
          box(
              fill: cell-color(base-color: red).background-color, stroke: 1pt + cell-color(base-color: red).stroke-color, inset: 25pt, ..box-options
          )[
            == ОС

            #set text(size: 30pt)
            #set align(center)
            #codebox(lang: "c", "process->fds[fd]->inum")
          ]
        })

        cetz.draw.content((0, -4.5), (25, -9), padding: none, {
          // set text(font: "Monaco")
          box(
              fill: cell-color(base-color: red).background-color, stroke: 1pt + cell-color(base-color: red).stroke-color, inset: 25pt, ..box-options
          )[
            == ОС

            #set text(size: 30pt)
            #set align(center)
            #codebox(lang: "c", "proc[pid]->fds[fd]->inum")
          ]
        })

        cetz.draw.content((0, -9.5), (25, -15), padding: none, {
          // set text(font: "Monaco")
          box(
              fill: cell-color(base-color: black).background-color, stroke: 1pt + cell-color(base-color: black).stroke-color, inset: 25pt, ..box-options
          )[
            == Жесткий диск
            #place(center + horizon)[
              #text(size: 50pt)[*...*]
              #h(1em)
              #box(baseline: 0.8cm)[#grid(
                rows: 3cm,
                columns: (3cm,) * 8,
                stroke: 2pt + black,
                inset: 0pt,
                ..range(8).map(i => [
                  #set text(size: 30pt, weight: "black")
                  #raw("[" + str(i) + "]")
              ]))]
              #h(1em)
              #text(size: 50pt)[*...*]
            ]
          ] 
        })

        cetz.draw.set-style(mark: (symbol: ">"), stroke: 3pt + black)

        // cetz.draw.line((x - margin + 0.1, 2), (x - 0.1, 2))
      },
    )
  ]
]

#slide(header: [Index Node], background-image: none)[
  - Обычно *именно её понимают под понятием "файл"*.

]

#title-slide[
  #place(horizon + center)[
    = Спасибо за внимание!
  ]

  #place(
    bottom + center,
  )[
    // #qr-code("https://github.com/JakMobius/courses/tree/main/mipt-os-basic-2024", width: 5cm)

    #box(
      baseline: 0.2em + 4pt, inset: (x: 15pt, y: 15pt), radius: 5pt, stroke: 3pt + rgb(185, 186, 187), fill: rgb(240, 240, 240),
    )[
      🔗 #link(
        "https://github.com/JakMobius/courses/tree/main/mipt-os-basic-2024",
      )[*github.com/JakMobius/courses/tree/main/mipt-os-basic-2024*]
    ]
  ]
]