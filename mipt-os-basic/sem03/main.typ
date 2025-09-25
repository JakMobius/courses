
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4"
#import "../theme/theme.typ": *
#import "./utils.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Файловые системы

    АКОС, МФТИ

    25 сентября, 2025
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

#slide(place-location: center + horizon)[
  #box(width: 70%)[
    #set par(spacing: 40pt)
    #align(center)[
      #text(
        size: 60pt, weight: "black",
      )[
        #largecell(palette.at(3), [File Descriptor])
      ]
    ]

    #align(left)[
      #set par(spacing: 20pt)

      - *Ключевой примитив* интерфейса между программой и ядром.

      - Работает как *поток данных*, который можно читать и / или записывать.

      - Создаётся операционной системой при открытии файла, сокета, создании процесса, чего бы то ни было;

      - Обычное число.
    ]
  ]
]

#slide(
  place-location: center, background-image: none,
)[
  #let transparent = color.rgb(255, 255, 255, 0)
  #let left-color = cell-color(palette.at(0))
  #let right-color = cell-color(palette.at(3))
  #let box-options = (inset: (x: 25pt, y: 30pt), width: 12cm, radius: 20pt)

  #grid(
    columns: 2, rows: (1.5cm, auto), column-gutter: 2cm, stroke: none, align: (column, row) => {
      if row == 0 { top + center } else { top + left }
    }, [
      = Системные
    ], [
      = Создаваемые
    ], [
      #align(
        center,
      )[
        #box(
          fill: left-color.background-color, stroke: 1pt + left-color.stroke-color, ..box-options,
        )[
          #align(left, [
            #set text(size: 25pt)
            #set list(marker: raw("="))
            - #codebox(lang: "c", "STDIN_FILENO")
            - #codebox(lang: "c", "STDOUT_FILENO")
            - #codebox(lang: "c", "STDERR_FILENO")
          ])
        ]
      ]

      // #set text(size: 14pt)

      - *Потоки консоли:* ввод, вывод, ошибки;

      - Почти всегда равны #codebox("0") , #codebox("1") и #codebox("2");

      - Но лучше использовать константы;

      - Их даже можно закрыть (но зачем?).
    ], [
      #align(
        center,
      )[
        #box(
          fill: right-color.background-color, stroke: 1pt + right-color.stroke-color, ..box-options,
        )[
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

      - Файлы, сеть, мультиплексоры,...;
    ],
  )
]

#focus-slide[
  #text(size: 50pt)[
    *Почему не #codebox(lang: "c", "fopen(...)") ?*
  ]

  #uncover(
    (beginning: 2),
  )[
    #text(
      size: 25pt,
    )[
      #place(
        center + bottom,
      )[
        #codebox(lang: "c", "fopen(...)") возвращает #codebox(lang: "c", "FILE*"), а не
        дескриптор
      ]
    ]
  ]
]

#slide(
  header: [Папки -- тоже файлы?], background-image: none,
)[

#place(horizon + center)[
#set text(size: 30pt)

#code(numbers: true, leading: 5pt, ```c
      int main() {
        int fd = open("/", O_RDONLY, 0);
        struct dirent ent = {};
        while(getdents64(fd, &ent, sizeof(ent)) > 0) {
            printf("%s\n", ent.d_name);
            lseek(fd, ent.d_off, SEEK_SET);
        }
      }
      ```)
]

#uncover(
  (beginning: 2),
)[
  #place(bottom + center)[
    #set text(size: 21pt)
    *Да, это тоже файловые дескрипторы.* А ещё это директории, а не папки.
  ]
]
]

#slide(
  header: [А если вызвать #codebox(lang: "c", "read(...)") на директорию?], background-image: none,
)[
#place(horizon)[
#text(size: 30pt)[
#code(numbers: true, leading: 5pt, ```c
        int main() {
          int fd = open("/", O_RDONLY, 0);
          char buffer[16];
          if(read(fd, buffer, sizeof(buffer)) >= 0) {
            printf("%15s", buffer);
          } else perror("read");
        }
        ```)
]
]

#place(
  bottom,
)[
  #uncover(
    (beginning: 2),
  )[
    #text(
      size: 25pt,
    )[
      *Вывод:* #codebox("read: Is a directory") . *Причина:* #codebox(lang: "c", "read(...) == -EISDIR")
    ]
  ]
]
]

#slide(
  header: [Файловый дескриптор - это], place-location: horizon + left,
)[
  #let codeblocks(arr) = {
    arr.map(code => codebox(lang: "c", code)).join(" , ")
  }

  - *Число*, сопоставленное какому-то ресурсу.

  - Его можно понимать, как *"указатель" на виртуальный класс*.

  - *Разработчик должен помнить* типы дескрипторов. Это упрощают обёртки:

    - #codeblocks(("FILE", "fopen()", "fclose()", "fread()", "fwrite()", "fseek()")) ,
      ... для файлов;

    - #codeblocks(("DIR", "opendir()", "closedir()", "readdir()", "seekdir()")) , ...
      для директорий;

    - *И практически ничего* для работы с сокетами / сигналами / pipe-ами.

  - Активные дескрипторы процесса можно увидеть в #codebox("/proc/<pid>/fd/")
]

#slide(
  header: [#codebox(lang: "c", "open(char *path, int flags, mode_t mode)")], background-image: none,
)[
== Открыть (создать) файл (директорию).

== *#codebox(lang: "c", "int flags") :*
#set list(marker: `|=`)
- #codebox("O_RDONLY") : Открыть на *чтение*;
- #codebox("O_WRONLY") : Открыть на *запись*;
- #codebox("O_RDWR") : Открыть на *чтение и запись*;
- #codebox("O_TRUNC") : *Очистить* файл при открытии;
- #codebox("O_CREAT") : *Создать* файл, если его нет;
- #codebox("O_EXCL") : Сломаться, если файл уже есть.

== *#codebox(lang: "c", "mode_t mode")* : маска прав для создаваемого файла.
]

#slide(
  header: [Чтение и запись], background-image: none, place-location: horizon,
)[

  - Для этого служат самые известные системные вызовы:

  #[
    #set list(marker: none)
    - #codebox(lang: "c", "read(int fd, void* buf, size_t count)")
    - #codebox(lang: "c", "write(int fd, void* buf, size_t count)")
  ]

  - Существуют #codebox(lang: "c", "pread(...)") и #codebox(lang: "c", "pwrite(...)") ,
    которые *явно принимают позицию файла*.

  - Если хочется одновременно записать *несколько файлов*, можно использовать:

  #[
    #set list(marker: none)
    - #codebox(lang: "c", "readv(int fd, struct iovec *vector, int count)")
    - #codebox(lang: "c", "writev(int fd, struct iovec *vector, int count)")
  ]
]

#slide(
  header: [#codebox(lang: "c", "lseek(int fd, off_t offset, int whence)")], background-image: none,
)[
== Настройка позиции файла

== *#codebox(lang: "c", "int whence") :*

#set list(marker: `=`)
- #codebox("SEEK_SET") : Установить позицию на #codebox("offset") ;
- #codebox("SEEK_CUR") : Сдвинуть позицию на #codebox("offset") ;
- #codebox("SEEK_END") : Установить позицию в *конец* и сдвинуть на #codebox("offset") .

== #codebox(lang: "c", "lseek()") возвращает позицию в байтах от начала файла.
]

#slide(
  header: [#codebox(lang: "c", "fcntl(int fd, int cmd, long arg)")], 
  background-image: none,
)[
== Системный вызов управления дескрипторами.

== *#codebox(lang: "c", "int cmd") :*

#set list(marker: `=`)
- #codebox("F_SETFD") : Установить флаги дескриптора;
- #codebox("F_SETFL") : Установить флаги статуса;
- #codebox("F_SETLK") : Установить *блокировку* на файл;
- #codebox("F_DUPFD") : *Дублировать* дескриптор;
- #codebox("F_SETSIG") : Получить сигнал, когда будет доступно чтение / запись;
- #codebox("F_SETPIPE_SZ") : Настроить размер очереди.

== *#codebox(lang: "c", "long arg") :* аргумент, используется в #codebox("F_SET*") -- командах
]

#slide(
  header: [Какие флаги можно настраивать?], background-image: none,
)[
  == Флаги дескриптора (#codebox("F_SETFD")):
  - #codebox("FD_CLOEXEC") : автоматически закрыть файл при вызове #codebox(lang: "c", "exec()")
  - И всё, их ровно одна штука 🤷🏻‍♂️.
  == Полезные флаги статуса (#codebox("F_SETFL")):
  - #codebox("O_APPEND") : дописывать в конец файла, как в лог;
  - #codebox("O_NONBLOCK") : запретить блокирующий ввод/вывод;
  - #codebox("O_NOATIME") : не изменять время последнего доступа к файлу;
  == Бесполезные флаги статуса:
  - #codebox("O_ASYNC") : получать сигнал по доступности чтения/записи;
  - #codebox("O_DIRECT") : прямая запись, обход кеширования ядра;

]

#focus-slide[
  #text(size: 50pt)[
    *А что такое файл?*
  ]
]

#slide(
  header: [Файл -- это не путь!], background-image: none, place-location: horizon + center,
)[

  #let pathbox(content) = [
    #box(radius: 10pt, fill: rgb(60, 60, 60), inset: 20pt)[
      #set text(fill: white)
      #raw(content)
    ]
  ]

  #set block(above: 30pt, below: 30pt)

  #set text(size: 45pt)
  #pathbox("/home/you/test.txt")

  #set text(size: 25pt)
  *Может быть тем же файлом, что и:*

  #set text(size: 45pt)
  #pathbox("/home/you/test2.txt")
]

#slide(
  background-image: none, place-location: horizon + center,
)[
  #cetz.canvas(
    length: 1cm, {
      cetz.draw.set-style(
        content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
      )

      let box-options = (width: 100%, height: 100%, radius: 10pt, inset: 20pt)

      let largecodebox(lang: none, content) = {
        box(radius: 5pt, fill: rgb(60, 60, 60), width: 15cm, height: 1.5cm)[
          #set align(horizon + center)
          #set text(fill: white)
          #set raw(theme: "../theme/halcyon.tmTheme")
          #raw(lang: lang, content)
        ]
      }

      let background(color) = {
        box(
          fill: cell-color(color).background-color, width: 100%, height: 100%,
        )
      }

      let title(color, content) = {
        place(
          top + left,
        )[
          #box(
            inset: 15pt,
          )[
            #text(
              weight: "black", size: 30pt, fill: cell-color(color).stroke-color,
            )[
              #content
            ]
          ]
        ]
      }

      cetz.draw.content((0, 1), (30, -4), padding: none, {
        background(blue)
        title(blue, [Программа])

        place(horizon + center)[
          #box(..box-options)[
            #set text(size: 30pt)
            #set align(center)
            #largecodebox(lang: "c", "write(fd, \"Hi!\", 4);")
          ]
        ]
      })

      cetz.draw.content((0, -4), (30, -9), padding: none, {
        background(red)
        title(red, [Ядро])

        place(horizon + center)[
          #box(..box-options)[
            #set text(size: 30pt)
            #set align(center)
            #largecodebox(lang: "c", "process->fds[fd]->inum")
          ]
        ]
      })

      cetz.draw.content(
        (0, -9), (30, -16), padding: none, {
          background(black)
          title(black, [Диск])

          place(
            center + bottom,
          )[
            #box[
              #text(size: 50pt)[*...*]
              #h(1em)
              #box(
                baseline: 2.5cm,
              )[#grid(
                  rows: (3cm, 1cm), columns: (3cm,) * 8, row-gutter: 5pt, align: center + horizon, inset: 0pt, ..range(8).map(i => [
                    #box(width: 100%, height: 100%, stroke: 2pt + black)[
                      *Index Node*
                    ]
                  ]), ..range(8).map(i => [
                    #set text(size: 30pt, weight: "black")
                    #raw("[" + str(i + 48) + "]")
                  ]),
                )]
              #h(1em)
              #text(size: 50pt)[*...*]

              #v(1em)
            ]
          ]
        },
      )

      cetz.draw.set-style(mark: (end: ">"), stroke: 5pt + black, fill: none)

      let a = (x: 14, y: -2.5)
      let b = (x: 17, y: -5.5)
      let c = (x: 20, y: -7.5)
      let d = (x: 11, y: -11)

      cetz.draw.bezier((a.x, a.y), (b.x, b.y), (a.x, b.y), (b.x, a.y), name: "line1")
      cetz.draw.bezier((c.x, c.y), (d.x, d.y), (c.x, d.y), (d.x, c.y), name: "line2")

      cetz.draw.content((name: "line1", anchor: 30%), anchor: "south-west", padding: .4, [
        #text(size: 25pt)[*Дескриптор*]
      ])

      cetz.draw.content(("line2.mid"), anchor: "south", padding: .4, [
        #text(size: 25pt)[*Номер inode*]
      ])
    },
  )
]

#slide(
  place-location: center + horizon,
)[
  #box(
    width: 75%, height: 10cm,
  )[
    #align(center)[
      #set block(spacing: 40pt)
      #text(size: 60pt, weight: "black")[#largecell(black, [Index Node])]
    ]

    #align(
      left,
    )[
      - *Структура, которую обычно называют "файлом"*;

      - Хранится в длинном массиве на жестком диске;

      - *Знает*, где на жестком диске хранится *содержимое её файла*;

      - *Хранит число ссылок* на саму себя (как #codebox(lang: "cpp", "std::shared_ptr")).
    ]
  ]
]

#let draw-dir-ent(position, values, more: true) = {
  let column-width = 3.2
  let index-node-height = 2.5
  let margin = 1.0

  let dirent-start = index-node-height + margin
  let dirent-height = 1.8 * values.len()
  if (more) {
    dirent-height += 1
  }

  let left = position.x - column-width / 2
  let right = position.x + column-width / 2

  cetz.draw.set-style(mark: (end: ">"), stroke: 5pt + black, fill: none)

  cetz.draw.content(
    (left, position.y), (right, position.y - index-node-height), padding: none, {
      set align(horizon + center)
      let color = cell-color(black)
      box(
        width: 100%, height: 100%, fill: color.background-color, stroke: 2pt + color.stroke-color, radius: 10pt,
      )[
        *Index Node*
      ]
    },
  )

  cetz.draw.line(
    (position.x, position.y - index-node-height - 0.1), (position.x, position.y - index-node-height - margin + 0.1), stroke: 4pt + black,
  )

  cetz.draw.content(
    (left, position.y - dirent-start), (right, position.y - dirent-start - dirent-height), padding: none, {
      set align(center)
      set block(spacing: 5pt)
      set text(size: 25pt)
      let colors = cell-color(palette.at(1))

      grid(
        rows: (1.8cm,) * values.len(), columns: 100%, align: horizon + center, stroke: 2pt + colors.stroke-color, fill: colors.background-color, ..values,
      )
      if (more) {
        text(size: 30pt)[*...*]
      }
    },
  )
}

#let horizontal-bezier(a, b) = {
  cetz.draw.bezier((a.x, a.y), (b.x, b.y), (b.x, a.y), (a.x, b.y))
}

#slide(
  place-location: center + top, background-image: none,
)[
#cetz.canvas(
  length: 1cm, {
    cetz.draw.set-style(
      content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
    )

    let largecodebox(lang: none, content) = {
      let color = cell-color(blue)
      box(
        radius: 5pt, fill: color.background-color, width: 12cm, height: 1.7cm, stroke: 2pt + color.stroke-color,
      )[
        #set align(horizon + center)
        #set text(fill: black)
        #set raw(theme: "../theme/halcyon.tmTheme")
        #raw(lang: lang, content)
      ]
    }

    cetz.draw.content((0, -1), (30, -4), padding: none, {
      box(width: 100%, height: 100%)[
        #set text(size: 30pt)
        #set align(center)
        #largecodebox("/usr/bin/bash")
      ]
    })

    let indices = (3, 2, 2)
    let index-node-positions = range(4).map(x => 6 + x * 6)

    let data = (
      (`.`, `..`, `etc`, [*`usr`*]), (`.`, `..`, [*`bin`*], `share`), (`.`, `..`, [*`bash`*], `mkdir`), ("0x7f", "0x45", "0x4c", "0x46").map(a => codebox(a)),
    )

    for (i, pos) in index-node-positions.enumerate() {
      draw-dir-ent((x: pos, y: -4.5), data.at(i))
    }

    for (i, dirent-index) in indices.enumerate() {
      let position = index-node-positions.at(i)
      let index-node = (x: 4.25 + position, y: -5.75)
      let dirent = (x: 1.75 + position, y: -9 - 1.8 * dirent-index)

      horizontal-bezier(dirent, index-node)
    }

    cetz.draw.line((0, -5.75), (4.25, -5.75), name: "root", stroke: luma(80) + 5pt)

    cetz.draw.content((name: "root", anchor: 50%), anchor: "south", padding: .4, [
      #text(size: 20pt, fill: luma(80))[*Корень*]
    ])

    cetz.draw.set-style(mark: (end: none))
    cetz.decorations.flat-brace(
      (index-node-positions.at(0) - 2.5, -8), (index-node-positions.at(0) - 2.5, -8 - 1.8 * 4), flip: true, name: "brace",
    )

    cetz.draw.content("brace.content", anchor: "south", padding: 1.3, angle: 90deg, [
      #text(size: 25pt)[*Directory Entries*]
    ])
  },
)
]

#slide(place-location: center + horizon, background-image: none)[
  #box(width: 70%)[
    #set par(spacing: 40pt)
    #align(center)[
      #text(
        size: 60pt, weight: "black",
      )[
        #largecell(palette.at(1), [Directory Entry])
      ]
    ]

    #align(left)[
      #set par(spacing: 20pt)
      - Структура c *именем* и *адресом* Index Node;

      - Хранится внутри файла, который представляет собой директорию.
      
      - Каждая директория — это файл, содержащий массив Directory Entry. 

      *Специальные записи:*

      - #codebox(".") – ссылка на *текущую директорию*;

      - #codebox("..") – ссылка на *родительскую директорию*;
    ]
  ]
]

#slide(
  header: [Что, если на Index Node несколько ссылок?], background-image: none,
)[
  #place(
    horizon + center,
  )[
    #cetz.canvas(
      length: 1cm, {
        let dirs = (".", "..", "test1", "test2").map(raw)
        let file = ("H", "e", "l", "l").map(a => codebox(lang: "c", "'" + a + "'"))
        draw-dir-ent((x: 0, y: 0), dirs)
        cetz.draw.line((-6, -1.25), (-1.6, -1.25), name: "root", stroke: 5pt + luma(80))
        cetz.draw.content((name: "root", anchor: 50%), anchor: "south", padding: .4, [
          #text(size: 20pt, fill: luma(80))[*Корень*]
        ])

        let indicies = (2, 3)
        let index-node = (x: 10, y: -4)

        // Чтобы сдвинуть всё в центр
        cetz.draw.content((-6, 0), (16, 0), [])

        cetz.draw.set-style(mark: (end: none))

        let c = (x: 5, y: -5)
        let d = (x: 8.4, y: -1.25)

        for (i, dirent-index) in indicies.enumerate() {
          let dirent = (x: 1.75, y: -4.5 - 1.8 * dirent-index)

          let a = dirent
          let b = (x: c.x, y: a.y)

          cetz.draw.bezier((a.x, a.y), (c.x, c.y), (b.x, b.y))
        }

        cetz.draw.set-style(mark: (end: ">"), stroke: 5pt + black, fill: none)

        cetz.draw.bezier((c.x, c.y), (d.x, d.y), (c.x, d.y))

        draw-dir-ent((x: 10, y: 0), file)
      },
    )
  ]

  #place(
    center + bottom,
  )[
    #uncover(
      (beginning: 2),
    )[
      #text(
        size: 25pt, [Это называется *жесткая ссылка.* Так можно только с файлами.],
      )
    ]
  ]
]

#slide(
  background-image: none,
)[
  #let header = [= Задача: сколько ссылок у пустой директории?]
  #place(center + horizon, header)
]

#slide(
  background-image: none,
)[
  #let header = [= Задача: сколько ссылок у пустой директории?]
  #header

  #place(
    horizon + center,
  )[
    #cetz.canvas(
      length: 1cm, {
        let dirs = (".", "..", "dir").map(raw)
        let file = (".", "..").map(raw)
        draw-dir-ent((x: 0, y: 0), dirs, more: false)
        cetz.draw.line((-6, -1.25), (-1.6, -1.25), name: "root", stroke: 5pt + luma(80))
        cetz.draw.content((name: "root", anchor: 50%), anchor: "south", padding: .4, [
          #text(size: 20pt, fill: luma(80))[*Корень*]
        ])

        let indicies = (2, 3)
        let index-node = (x: 10, y: -4)

        // Чтобы сдвинуть всё в центр
        cetz.draw.content((-6, 0), (16, 0), [])

        cetz.draw.set-style(mark: (end: none))

        let dirent(x, y, left: false) = {
          let shift = if left { -1.75 } else { 1.75 }
          if (y == -1) {
            (x: shift + 10 * x, y: -1.25)
          } else {
            (x: shift + 10 * x, y: -4.5 - 1.8 * y)
          }
        }

        {
          let a = dirent(0, 2)
          let d = dirent(1, -1, left: true)

          cetz.draw.bezier((a.x, a.y), (d.x, d.y), (5, d.y), mark: (end: ">"))
        }

        for i in range(0, 2) {
          for j in range(0, 2 - i) {
            let a = dirent(i, j)
            let c = dirent(i, -1)
            let b = (x: a.x + j * 0.5 + 1.2, y: (a.y + c.y) * 0.5)

            cetz.draw.bezier((a.x, a.y), (c.x, c.y), (b.x, b.y), mark: (end: ">"))
          }
        }

        {
          let a = dirent(1, 1, left: true)
          let d = dirent(0, -1)

          cetz.draw.bezier((a.x, a.y), (d.x, d.y), (5, d.y), mark: (end: ">"))
        }

        draw-dir-ent((x: 10, y: 0), file, more: false)
      },
    )
  ]

  #place(bottom)[
    #colbox(color: green)[*Ответ: 2*]
  ]
]

#focus-slide[
  #set block(above: 25pt, below: 25pt)
  #text(size: 50pt)[
    *VFS*
  ]

  = Виртуальная файловая система
]

#slide(
  place-location: horizon,
)[
  - К системе может быть подключено *много накопителей*: диски, USB-носители, ...;

  - Каждый из них может иметь свою файловую систему;

  #set align(center)
  = *Как работать со всем сразу?*
]

#slide(
  header: [VFS - Обобщённый интерфейс для ФС.], place-location: horizon + center,
)[
#set align(center)
=== Можно думать об этом, как о виртуальном классе:

#v(1em)

#text(size: 25pt, weight: "bold")[
```cpp
      class ExFat: public virtual VFS { /* ... */ }
      class Fat32: public virtual VFS { /* ... */ }
      class NTFS:  public virtual VFS { /* ... */ }
      class FAT:   public virtual VFS { /* ... */ }
      class HFS:   public virtual VFS { /* ... */ }
      // ...
    ```
]

=== Теперь любую из этих файловых систем можно подключить к системе:

#text(size: 25pt, weight: "bold")[
```cpp
    void System::mount(VFS* filesystem, const char* path);
    ```
]
]

#slide(
  header: [#codebox("procfs") -- не файловая файловая система.], place-location: horizon,
)[
  #set list(marker: none)
  - #bash("cat /proc/meminfo") : информация о памяти;
  - #bash("cat /proc/cpuinfo") : информация о CPU;
  - #bash("cat /proc/version") : версия ядра;
  - #bash("cat /proc/schedstat") : информация от планировщика о каждом CPU;
  - #bash("cat /proc/filesystems") : информация о файловых системах.
  - #bash("cat /proc/<pid>/schedstat") : информация от планировщика о процессе;
  - #bash("ls /proc/<pid>/fd") : открытые файловые дескрипторы;

  *Эта файловая система тоже реализует интерфейс VFS.*
]

#slide(header: [Другие примеры], place-location: horizon + left)[
  == Системные:

  #set list(marker: none)
  - #codebox("sysfs") : содержит информацию об устройствах и драйверах;
  - #codebox("pipefs") : служит для создания и использования pipe-ов;
  - #codebox("ramfs") : использует оперативную память вместо диска;
  - #codebox("tmpfs") : как #codebox("ramfs") , но со сбросом на swap;
  
  == Общего назначения:

  - #codebox("ecryptfs") : хранит файлы в зашифрованном виде;
  - #codebox("unionfs") : объединяет несколько файловых систем вместе;
  - #codebox("overlayfs") : хранит разницу двух файловых систем
  ]

#slide(
  place-location: horizon + center,
)[
  #box(
    width: 90%, height: 70%,
  )[
    #set block(below: 25pt, above: 40pt)

    = *Как быть, если очень хочется свою ФС?*

    #v(1cm)

    #uncover((beginning: 2))[
      #text(size: 50pt, weight: "black")[FUSE]

      === Filesystem in userspace
    ]

    #uncover((beginning: 3))[
      #parbreak()
      #set align(left)
      #set list(marker: none)
      - #pro() *Избавляет от необходимости разрабатывать драйвер для ядра*;
      - #con() *Работает медленнее, чем встроенные в ядро файловые системы*.
    ]
  ]
]

#slide(
  place-location: horizon + center)[
  #cetz.canvas(length: 1cm, {

    let background(color) = {
      box(
        fill: cell-color(color).background-color, width: 100%, height: 100%,
      )
    }

    let title(color, content) = {
      place(
        top + left,
      )[
        #box(
          inset: 15pt,
        )[
          #text(
            weight: "black", size: 30pt, fill: cell-color(color).stroke-color,
          )[
            #content
          ]
        ]
      ]
    }

    cetz.draw.content((0, 0), (30, -8.5))[
      #background(blue)
      #title(blue, [Userspace])
    ]

    cetz.draw.content((0, -8), (30, -17))[
      #background(red)
      #title(red, [Ядро])
    ]

    cetz.draw.content((10.5, -1.5), (19.5, -6))[
      #let cell-color = cell-color(blue);
      #box(width: 100%, height: 100%, fill: cell-color.background-color, stroke: 3pt + cell-color.stroke-color, inset: 10pt)[
        #align(center + horizon)[
          #text(size: 30pt, fill: cell-color.stroke-color)[
            *Ваша программа*
          ]
        ]
      ]
    ]

    cetz.draw.content((5, -10), (25, -16))[
      #let cell-color = cell-color(red);
      #box(width: 100%, height: 100%, fill: cell-color.background-color, stroke: 3pt + cell-color.stroke-color, inset: 20pt)[
        #align(center + horizon)[
          #text(size: 30pt, fill: cell-color.stroke-color)[
            *Драйвер ФС в ядре*
          ]
        ]
      ]
    ]

    cetz.draw.set-style(content: (padding: .2), stroke: 10pt + black)
    cetz.draw.line((13.5, -6.5), (13.5, -9.5), mark: (end: ">", start: "<"))
    cetz.draw.line((16.5, -9.5), (16.5, -6.5), mark: (end: ">", start: "<"))
  })
]

#slide(
  place-location: horizon + center)[
  #cetz.canvas(length: 1cm, {

    let background(color) = {
      box(
        fill: cell-color(color).background-color, width: 100%, height: 100%,
      )
    }

    let title(color, content) = {
      place(
        top + left,
      )[
        #box(
          inset: 15pt,
        )[
          #text(
            weight: "black", size: 30pt, fill: cell-color(color).stroke-color,
          )[
            #content
          ]
        ]
      ]
    }

    cetz.draw.content((0, 0), (30, -8.5))[
      #background(blue)
      #title(blue, [Userspace])
    ]

    cetz.draw.content((0, -8), (30, -17))[
      #background(red)
      #title(red, [Ядро])
    ]

    cetz.draw.content((5.5, -2), (14.5, -6))[
      #let cell-color = cell-color(blue);
      #box(width: 100%, height: 100%, fill: cell-color.background-color, stroke: 3pt + cell-color.stroke-color, inset: 10pt)[
        #align(center + horizon)[
          #text(size: 30pt, fill: cell-color.stroke-color)[
            *Ваша программа*
          ]
        ]
      ]
    ]

    cetz.draw.content((15.5, -2), (24.5, -6))[
      #let cell-color = cell-color(blue);
      #box(width: 100%, height: 100%, fill: cell-color.background-color, stroke: 3pt + cell-color.stroke-color, inset: 10pt)[
        #align(center + horizon)[
          #text(size: 30pt, fill: cell-color.stroke-color)[
            *Userspace-драйвер*
          ]
        ]
      ]
    ]

    cetz.draw.content((5, -10), (25, -16))[
      #let cell-color = cell-color(red);
      #box(width: 100%, height: 100%, fill: cell-color.background-color, stroke: 3pt + cell-color.stroke-color, inset: 20pt)[
        #align(center + horizon)[
          #text(size: 30pt, fill: cell-color.stroke-color)[
            *Драйвер FUSE*
          ]
        ]
      ]
    ]

    cetz.draw.set-style(content: (padding: .2), stroke: 10pt + black)
    cetz.draw.line((13.5 - 5, -6.5), (13.5 - 5, -9.5), mark: (start: "<"))
    cetz.draw.line((16.5 - 5, -9.5), (16.5 - 5, -6.5), mark: (end: ">"))
    cetz.draw.line((13.5 + 5, -6.5), (13.5 + 5, -9.5), mark: (start: "<"))
    cetz.draw.line((16.5 + 5, -9.5), (16.5 + 5, -6.5), mark: (end: ">"))
  })
]

#focus-slide[
  #text(size: 50pt)[
    *Сеанс магии*
  ]
]

#slide(
  header: [И всё же, зачем?], place-location: horizon,
)[
  - #bash("sshfs") : проект сообщества, позволяет монтировать ФС через #bash("ssh");

  - Снижает поверхность атаки;

  - Позволяет монтировать *почти любые образы дисков*, не имея прав администратора.
]

#outro-slide()