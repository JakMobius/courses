
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4"
#import "../theme/theme.typ": *
#import "../theme/asm.typ": *
#import "./utils.typ": *
#import "../theme/bubbles.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Процессы и потоки

    АКОС, МФТИ

    23 октября, 2025
  ]
]

#show: enable-handout

#let draw-core(x, y, size: 2, legs: 6, content: none) = {
  let offset = 0.4
  let leg-start = 0.2
  let leg-end = 0.3

  cetz.draw.content((x, y), {
    box(
      width: 1cm * size,
      height: 1cm * size,
      stroke: 5pt + black,
      radius: 5pt,
      content,
    )
  })

  cetz.draw.set-style(stroke: 4pt + luma(60), radius: 5pt)

  for leg-x in range(legs) {
    let x = x - size / 2 + offset + leg-x * (size - offset * 2) / (legs - 1)
    let y = y - size / 2

    cetz.draw.line((x, y - leg-start), (x, y - leg-end))
    cetz.draw.line((x, y + leg-start + size), (x, y + size + leg-end))
  }

  for leg-y in range(legs) {
    let x = x - size / 2
    let y = y - size / 2 + offset + leg-y * (size - offset * 2) / (legs - 1)

    cetz.draw.line((x - leg-start, y), (x - leg-end, y))
    cetz.draw.line((x + size + leg-start, y), (x + size + leg-end, y))
  }
}

#slide(background-image: none)[

  #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 0), (28, 14), [])

      let bubble-width = 8.5
      let bubble-height = 7

      draw-core(2.5, 5, legs: 10, size: 3, content: [
        #set align(horizon + center)
        = CPU
      ])
      cetz.draw.bezier((4, 7.5), (5.3, 9), (4, 9), fill: none, stroke: none, name: "bubbles")
      draw-small-bubbles("bubbles", count: 3)
      draw-bubble(6.8, 4.5, bubble-width, bubble-height, seed: 52)

      cetz.draw.content((7, 7.5), (rel: (bubble-width, bubble-height)), padding: 0cm, [
        #set align(center)
        #set text(size: 30pt, weight: "bold")
        Программа 1:
      ])

      cetz.draw.content((18, 7.5), (rel: (bubble-width, bubble-height)), padding: 0cm, [
        #set align(center)
        #set text(size: 30pt, weight: "bold")
        Программа 2:
      ])

      cetz.draw.content((7, 5), (rel: (bubble-width, bubble-height)), padding: 0cm, [
        #place(horizon + center)[
          #set text(size: 30pt)
          #lightasmtable(
            ```asm
            mov rdi, 1
            mov rdi, rax
            mov rax, 0x4
            syscall
            ...
            ```,
          )
        ]
      ])

      cetz.draw.content((18, 5), (rel: (bubble-width, bubble-height)), padding: 0cm, [
        #place(horizon + center)[
          #set text(size: 30pt)
          #lightasmtable(
            ```asm
            mov r10, 1
            push r10
            mov rdi, r10
            call 0x10c90
            ```,
          )
        ]
      ])

      cetz.draw.line(
        (7.5, 11),
        (7.5, 6),
        mark: (end: ">", width: 0.2cm, length: 0.3cm),
        stroke: (dash: "dashed", paint: gray, thickness: 4pt),
      )

      cetz.draw.bezier((22.5, 0.8), (22.5, 4.5), (24, 0.8), (22.5, 2.5), mark: (end: ">"), stroke: 5pt + black)
    })
  ]
  #place(bottom + center, dy: -1cm)[
    = Как запустить вторую программу?
  ]
]

#slide(background-image: none)[
  #place(center + horizon, dy: 1cm)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 0), (28, 10), [])

      let bubble-width = 11
      let bubble-height = 6

      let left-fill = cell-color(blue).background-color
      let right-fill = cell-color(red).background-color

      let left-stroke-color = cell-color(blue).stroke-color
      let right-stroke-color = cell-color(red).stroke-color

      let left-stroke = 3pt + left-stroke-color
      let right-stroke = 3pt + right-stroke-color

      draw-core(3, 3.1, content: [
        #set align(horizon + center)
        = 1
      ])
      cetz.draw.bezier((1.1, 3.9), (2.3, 6), (1.1, 6), fill: none, stroke: none, name: "bubbles")
      draw-small-bubbles("bubbles", count: 3, fill: left-fill, stroke: left-stroke)
      draw-bubble(3, 6, bubble-width, bubble-height, fill: left-fill, stroke: left-stroke)

      draw-core(16.7, 3.1, content: [
        #set align(horizon + center)
        = 2
      ])
      cetz.draw.bezier((14.7, 3.9), (15.9, 6), (14.7, 6), fill: none, stroke: none, name: "bubbles2")
      draw-small-bubbles("bubbles2", count: 3, fill: right-fill, stroke: right-stroke)
      draw-bubble(16.5, 6, bubble-width, bubble-height, fill: right-fill, stroke: right-stroke)

      cetz.draw.content((3, 6), (rel: (bubble-width, bubble-height)), padding: 0cm, [

        #place(horizon + center)[
          #set text(size: 30pt)
          #lightasmtable(
            ```asm
            mov rdi, 1
            mov rdi, rax
            mov rax, 0x4
            syscall
            ...
            ```,
          )
        ]
      ])

      cetz.draw.content((4.9, 1), (rel: (11, 3)), padding: 0cm, [
        #set align(left)
        #set text(size: 20pt)
        #set block(spacing: 12pt)
        == Первое ядро

        Работает с программой 1
      ])

      cetz.draw.content((18.7, 1), (rel: (11, 3)), padding: 0cm, [
        #set align(left)
        #set text(size: 20pt)
        #set block(spacing: 12pt)
        == Второе ядро

        Работает с программой 2
      ])

      cetz.draw.content((16.5, 6), (rel: (bubble-width, bubble-height)), padding: 0cm, [

        #place(horizon + center)[
          #set text(size: 30pt)
          #lightasmtable(
            ```asm
            mov r10, 1
            push r10
            mov rdi, r10
            call 0x10c90
            ...
            ```,
          )
        ]
      ])

      cetz.draw.line(
        (4.5, 11),
        (4.5, 7),
        mark: (end: ">", width: 0.2cm, length: 0.3cm),
        stroke: (
          dash: "dashed",
          paint: left-stroke-color.transparentize(50%),
          thickness: 4pt,
        ),
      )
      cetz.draw.line(
        (18, 11),
        (18, 7),
        mark: (end: ">", width: 0.2cm, length: 0.3cm),
        stroke: (
          dash: "dashed",
          paint: right-stroke-color.transparentize(50%),
          thickness: 4pt,
        ),
      )
    })
  ]
  #place(top + center)[
    #set text(weight: "bold", size: 30pt)
    Можно использовать несколько ядер!
  ]
  #place(bottom + center, dy: -0.3cm)[
    #set text(weight: "bold", size: 25pt)
    #uncover((beginning: 2))[
      Но ядер мало...
    ]
  ]
]

#slide(background-image: none)[
  #align(center)[
    = Можно ли выполнять две программы на одном ядре?
  ]

  #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 15), (28, 0), [])

      cetz.draw.content((12, 9.5), (rel: (4, 3)), [
        #set align(center)
        *Чередуя инструкции:*
      ])

      let bubble-width = 9
      let bubble-height = 5.5

      let left-fill = cell-color(blue).background-color
      let right-fill = cell-color(red).background-color

      let left-stroke-color = cell-color(blue).stroke-color
      let right-stroke-color = cell-color(red).stroke-color

      let left-stroke = 3pt + left-stroke-color
      let right-stroke = 3pt + right-stroke-color

      let interp(a, b, k) = {
        return a.enumerate().map(((i, x)) => (x * (1 - k) + b.at(i) * k))
      }

      cetz.draw.set-style(
        stroke: (
          dash: "dotted",
          paint: luma(30),
          thickness: 3pt,
        ),
      )

      for i in range(0, 4) {
        let base-y = 10.25
        let line-height = 1.14
        let y = base-y - i * line-height
        let y2 = y + line-height

        let a = (12, y)
        let b = (16, y)
        let b2 = (16, y2)

        cetz.draw.circle(interp(a, b, 0.1), fill: left-fill, stroke: left-stroke, radius: 0.15)
        cetz.draw.circle(interp(a, b, 0.9), fill: right-fill, stroke: right-stroke, radius: 0.15)

        cetz.draw.line(interp(a, b, 0.2), interp(a, b, 0.8), mark: (end: ">"))
        if i != 0 {
          cetz.draw.line(interp(b2, a, 0.2), interp(b2, a, 0.8), mark: (end: ">"))
        }
      }

      cetz.draw.set-style(mark: (:))

      draw-core(14, 3.5, content: [
        #set align(horizon + center)
        = 1
      ])

      cetz.draw.bezier((12, 3.5), (9, 3.4), (10, 2.5), fill: none, stroke: none, name: "bubbles")
      draw-small-bubbles("bubbles", count: 4, fill: left-fill, stroke: left-stroke)
      draw-bubble(2, 5.3, bubble-width, bubble-height, fill: left-fill, stroke: left-stroke)

      cetz.draw.bezier((16, 3.5), (18.9, 3.7), (18, 2.5), fill: none, stroke: none, name: "bubbles2")
      draw-small-bubbles("bubbles2", count: 4, fill: right-fill, stroke: right-stroke)
      draw-bubble(18, 5.3, bubble-width, bubble-height, fill: right-fill, stroke: right-stroke)

      cetz.draw.content((2, 5.3), (rel: (bubble-width, bubble-height)), padding: 0cm, [
        #place(horizon + center)[
          #set text(size: 30pt)
          #lightasmtable(
            ```asm
            mov rdi, 1
            mov rdi, rax
            mov rax, 0x4
            syscall
            ...
            ```,
          )
        ]
      ])

      cetz.draw.content((18, 5.3), (rel: (bubble-width, bubble-height)), padding: 0cm, [

        #place(horizon + center)[
          #set text(size: 30pt)
          #lightasmtable(
            ```asm
            mov r10, 1
            push r10
            mov rdi, r10
            call 0x10c90
            ...
            ```,
          )
        ]
      ])
    })
  ]

  #place(bottom + center, dy: -0.5cm)[
    #set text(weight: "bold", size: 25pt)
    Что пойдет не так?
  ]
]

#slide[
  #place(horizon + center)[
    #box[
      #set text(size: 20pt)
      #set align(left)
      #set par(spacing: 10pt)
      = Что пойдет не так?

      #v(1em)
      - Программы будут портить друг другу *регистры*;
      #v(0.8em)

      - ...И *память* (вспомним про адресные пространства).

      #uncover((beginning: 2))[
        = Как это починить?

        #v(1em)

        - Возложить на ядро ответственность за *разделение ресурсов*.
      ]
    ]
  ]
]

#slide(background-image: none)[
  #place(horizon + center, dy: -0.5cm)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 15), (30, 0), [])

      let x0 = 0
      let x1 = 20
      let jitter = 0.1
      let jagged-border(x1, x2, y, peak-freq: 4) = {
        let points = ()
        let peaks = calc.floor((x2 - x1) * peak-freq)

        for i in range(0, peaks) {
          let x = x1 + i * (x2 - x1) / peaks
          let y = y + if calc.rem(i, 2) == 0 { jitter } else { -jitter }
          points.push((x, y))
        }

        if calc.rem(peaks, 2) == 0 {
          points.push((x2, y + jitter))
        } else {
          points.push((x2, y - jitter))
        }

        points
      }

      let draw-background(y1, y2, color, content) = {
        y1 += jitter
        y2 -= jitter
        let bg = cell-color(color).background-color
        let stroke = cell-color(color).stroke-color
        cetz.draw.rect((x0, y1), (x1, y2), fill: bg, stroke: none)
        cetz.draw.content((x0, y1), (x1, y2), [
          #set text(fill: stroke)
          #content
        ])
      }

      let draw-ripped-section(y1, y2, content) = {
        let path1 = jagged-border(x0, x1, y1)
        // let path2 = jagged-border(0, 30, y2).rev()
        let path2 = ((x1, y2), (x0, y2))
        let path = path1 + path2

        let bg = cell-color(black).background-color
        let stroke = cell-color(black).stroke-color

        cetz.draw.line(..path1, stroke: 5pt + stroke)
        cetz.draw.line(..path2, stroke: (thickness: 5pt, paint: stroke, dash: "solid"))

        cetz.draw.line(..path, close: true, fill: bg, stroke: none)
        cetz.draw.content((x0, y1), (x1, y2), content)
      }

      let row(left-content, right-content) = {
        grid(
          columns: (40%, 60%),
          rows: 100%,
          align: horizon + left,
          inset: (x, y) => {
            if x == 0 { (x: 20pt, y: 20pt) } else { (:) }
          },
          stroke: none,
          [
            #set text(size: 25pt, weight: "semibold")
            #left-content
          ],
          right-content,
        )
      }

      let userspace-height = 4
      let kernelspace-height = 2.5
      let y = 15

      let kernel-row = row(
        [
          Код ядра ОС
        ],
        [
          #box(inset: (x: 15pt))[
            #set text(size: 20pt)
            _Переключение контекста_
          ]
        ],
      )

      let userspace-row(header, asm) = {
        row(header, [
          #set text(size: 30pt)
          #lightasmtable(asm)
        ])
      }

      let rows = (
        (
          "userspace",
          blue,
          [
            #userspace-row([Контекст 1], ```asm
            mov rdi, 1
            mov rsi, rax
            ```)
          ],
        ),
        ("kernel",),
        (
          "userspace",
          red,
          [
            #userspace-row([Контекст 2], ```asm
            mov r10, 1
            push r10
            ```)
          ],
        ),
        ("kernel",),
        (
          "userspace",
          blue,
          [
            #userspace-row([Контекст 1], ```asm
            mov rax, 0x4
            syscall
            ```)
          ],
        ),
      )

      let y = 15
      for row in rows {
        if row.at(0) == "userspace" {
          draw-background(y, y - userspace-height, row.at(1), row.at(2))
          y -= userspace-height
        } else {
          y -= kernelspace-height
        }
      }

      y = 15
      for row in rows {
        if row.at(0) == "kernel" {
          draw-ripped-section(y, y - kernelspace-height, kernel-row)
          y -= kernelspace-height
        } else {
          y -= userspace-height
        }
      }

      let bubbles = generate-bubble-wall(x1 - 1.5, 15, x1 - 1.5, -5, 17)
      for (x, y, r) in bubbles {
        // cetz.draw.circle((x, y), radius: r, fill: white, stroke: 3pt + black)
      }
      let points = bubbles-to-path(bubbles)
      let gradient = gradient.radial(white, rgb(91%, 91.3%, 91.35%))
      cetz.draw.merge-path(close: true, fill: gradient, stroke: 3pt + black, {
        cetz.draw.hobby(..points, stroke: 3pt + black)
        cetz.draw.line((), (x1, -7), (30, -7), (30, 20))
      })

      draw-core(26, 0, size: 3, legs: 10, content: [
        #set align(horizon + center)
        #image("img/struggling-face.png", width: 80%, height: 80%)
      ])
      cetz.draw.bezier((23.5, 0.5), (20.2, 1), (20.2, 0.5), fill: none, stroke: none, name: "bubbles")
      draw-small-bubbles("bubbles", count: 4, fill: white)

      let y-int = 12
      let y-usr = 9.5

      cetz.draw.content((22, y-int), (rel: (6, 0)), name: "interrupts", [
        #set par(spacing: 10pt)
        #set align(top + left)
        #set block(spacing: 10pt)
        #set text(fill: luma(50), size: 20pt, weight: "semibold")
        #box(inset: 10pt)[
          Прерывания по~таймеру

          #v(0.1em)
          #text(size: 14pt)[
            _60 - 1000 раз / сек._
          ]
        ]
      ])

      cetz.draw.content((23, y-usr), (rel: (6, 0)), name: "userspace", [
        #set align(top + left)
        #set text(fill: luma(50), size: 20pt, weight: "semibold")
        #box(inset: 10pt)[
          Переходы в Userspace
        ]
      ])

      let draw-bezier(x0, y0, x1, y1, xd: 0) = {
        cetz.draw.merge-path(
          {
            cetz.draw.bezier((x1, y1), (x0, y0), (x0, y1), (x1, y0))
            if xd != 0 {
              cetz.draw.line((), (x0 + xd, y0))
            }
          },
          stroke: (dash: "dashed", paint: luma(100), thickness: 3pt),
        )
      }

      draw-bezier(20, 11, 22, y-int - 1)
      draw-bezier(20, 4.5, 22, y-int - 1)
      draw-bezier(21, 8.5, 23, y-usr - 1, xd: -1)
      draw-bezier(21, 2, 23, y-usr - 1, xd: -1)
    })
  ]
]

#slide(place-location: horizon + center)[
  #box[
    #text(size: 25pt)[
      = Как переключить контекст
    ]

    #v(2em)
    #set align(left)

    *1.* *Сохранить* в память контекст текущей программы;

    *2.* *Восстановить* из памяти контекст новой программы;

    *3.* Перейти в Userspace и *продолжить исполнение* новой программы.

    #align(center)[
      #v(0.5em)
      #line(length: 80%)
      #v(0.5em)
    ]

    - Происходит по прерыванию таймера;

    - *Позволяет одновременно запустить много программ на одном ядре*.
  ]
]

#slide[
  #place(horizon + center, dy: -0.5cm)[
    == Переходим к правильным терминам:
    #v(0.5em)
    #box(
      stroke: 3pt + cell-color(blue).stroke-color,
      fill: cell-color(blue).background-color,
      radius: 20pt,
      inset: (x: 40pt, top: 18pt, bottom: 40pt),
    )[
      #set text(size: 30pt, weight: "bold")
      Программа $arrow.r$ #colbox(inset: 15pt, color: rgb(60, 60, 60), baseline: 15pt, [
        Процесс
      ])

      #set align(left)
      #set text(size: 20pt, weight: "regular")

      - Имеет свой *номер* (PID)

      - Имеет свой *контекст выполнения*

      - Имеет своё *адресное пространство*

      - Имеет свой *набор дескрипторов*

      - Знает своего *родителя* и *пользователя*

      - _И еще много чего..._
    ]
  ]
]

#slide(background-image: none)[
  = Создаём процессы, как это делали наши отцы

  == #codebox(lang: "c", "fork()")

  - *Дублирует* текущий процесс, включая указатель на текущую инструкцию;

  - *Возвращается дважды*:
    - В созданном процессе возвращает #codebox(lang: "c", "0") ;
    - В родительском процессе возвращает номер (PID) созданного процесса.

  == #codebox(lang: "c", "exec(...)")

  - *Заменяет* текущий процесс на новый процесс по командной строке;

  - Имеет много вариаций: #codebox(lang: "c", "execl(...)"), #codebox(lang: "c", "execv(...)"), #codebox(lang: "c", "execve(...)") и т.д;

  - *Наследует настройки* родительского процесса: открытые дескрипторы, переменные окружения, рабочую директорию, маски сигналов и т.д.
]

#slide(background-image: none, place-location: horizon + center)[

  #text(weight: "bold", size: 25pt)[
    #set align(center)

    == #codebox(lang: "c", "fork()") + #codebox(lang: "c", "exec()")

    #box(width: 20cm, stroke: 3pt + black, inset: 20pt, radius: 20pt, fill: white)[
      #code(numbers: true, ```c
      if (fork() == 0) {
          // Здесь можно закрыть всё лишнее
          // И заместить себя другим процессом
          execl("/bin/bash", NULL);
      }

      // Здесь полезная работа родителя

      wait(NULL); // Ждём завершения потомка
      ```)
    ]

    ...или как написать свой #bash("bash") в 9 строк.
  ]
]

#slide[
  #set text(weight: "bold", size: 25pt)

  #place(horizon + center, dy: -5cm)[
    = А что, если...
  ]

  #place(horizon + center)[
    #box(width: 13cm, stroke: 3pt + black, inset: (x: 20pt, y: 40pt), radius: 20pt, fill: white)[
      #code(numbers: true, ```c
      while (true) {
        fork();
      }
      ```)
    ]
  ]

  #place(horizon + center, dy: 4.5cm)[
    === ...и отбежать на безопасное расстояние?
  ]
]

#slide(background-image: none)[
  = Создаём процессы модно

  == #codebox(lang: "c", "posix_spawn(pid_t* pid, char* file, /* whole lot of arguments */)")

  #v(0.5em)

  - Умно-хитро *создаёт новый процесс* по командной строке и исполняемому файлу.

  - Даёт *широкий набор настроек* для создаваемого процесса, например:

  #table(
    columns: 2,
    inset: (left: 20pt, right: 20pt, y: 0pt),
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    row-gutter: 10pt,
    align: horizon,
    codebox(lang: "c", "posix_spawnattr_setsigmask(...)"), [Настройка маски сигналов;],
    codebox(lang: "c", "posix_spawnattr_getpgroup(...)"), [Настройка группы процессов;],
    codebox(lang: "c", "posix_spawnattr_setschedparam(...)"), [Настройка параметров планирования;],
    codebox(lang: "c", "posix_spawn_file_actions_xxxxxx(...)"), [Открытие и закрытие дескрипторов.],
  )

  - *Быстрее, чем #codebox(lang: "c", "fork()") + #codebox(lang: "c", "exec()")* .
]

#slide(background-image: none)[
  = Дожидаемся процессов

  == #codebox(lang: "c", "waitpid(pid_t pid, int* status, int options)")

  *Ждёт завершения процесса* и возвращает статус завершения.

  #table(
    columns: 2,
    align: horizon,
    inset: (x, y) => {
      if x == 0 { (left: 10pt, right: 20pt) } else { (left: 20pt, right: 20pt) }
    },
    stroke: (x, y) => {
      if x == 0 and y != 2 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    rows: (1.3em, ),
    row-gutter: (8pt,) * 2 + (4pt,) * 3,
    codebox(lang: "c", "pid_t pid"), [*Процесс*, которого нужно дождаться. #codebox(lang: "c", "-1") = любой дочерний;],
    codebox(lang: "c", "int* status"),
    [Куда вернуть *статус завершения* процесса. Может быть #codebox(lang: "c", "NULL");],

    [#codebox(lang: "c", "int options") :], [#v(1.2em)],
    [#raw("|= ")#codebox(lang: "c", "WNOHANG")], [*Не ждать* дочерний процесс, если он ещё работает;],
    [#raw("|= ")#codebox(lang: "c", "WUNTRACED")], [Сработать на *остановку* процесса (#codebox("SIGSTOP")).],
    [#raw("|= ")#codebox(lang: "c", "WCONTINUED")], [Сработать на *возобновление* процесса (#codebox("SIGCONT")).],
  )
  #line(length: 100%)
  #set block(below: 10pt, above: 15pt)
  #codebox(lang: "c", "wait(status)") $equiv$ #codebox(lang: "c", "waitpid(-1, status, 0)") . И то, и то под капотом -- #codebox(lang: "c", "wait4(...)").

  #colbox(color: red)[⚠️] : *Ждать нужно каждого дочернего процесса*, иначе они станут зомби.
]

#slide(place-location: horizon + center, background-image: none)[
  #image("img/zombie.jpg")
]

#slide[
  = Статусы #codebox(lang: "c", "waitpid(...)")

  #colbox(color: gray)[⚠️] : Статус, который передаёт #codebox(lang: "c", "waitpid(...)") -- это *не код завершения процесса.*

  *Это битовая маска*, которую можно декодировать библиотечными функциями:

  #table(
    columns: 2,
    align: horizon,
    inset: (x, y) => {
      if x == 0 {
        (left: 20pt, right: 20pt)
      } else {
        (left: 20pt, right: 20pt, y: 0pt)
      }
    },
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    rows: (1.2em, ),
    row-gutter: 10pt,
    codebox(lang: "c", "WIFEXITED(status)"), [Процесс завершился *нормально*;],
    codebox(lang: "c", "WIFSTOPPED(status)"), [Процесс *приостановлен*;],
    codebox(lang: "c", "WIFCONTINUED(status)"), [Процесс *возобновлен*;],
    codebox(lang: "c", "WIFSIGNALED(status)"), [Процесс завершился *сигналом*;],
    codebox(lang: "c", "WEXITSTATUS(status)"), [Какой *код завершения* вернул процесс;],
    codebox(lang: "c", "WSTOPSIG(status)"), [Какой *сигнал* приостановил процесс;],
    codebox(lang: "c", "WTERMSIG(status)"), [Какой *сигнал* завершил процесс;],
  )
]

#focus-slide[
  #text(size: 30pt)[
    *Как использовать несколько ядер в одном процессе?*
  ]
]

#slide[
  #place(horizon + center, dy: -0.5cm)[
    #box(
      stroke: 3pt + cell-color(yellow).stroke-color,
      fill: cell-color(yellow).background-color,
      radius: 20pt,
      inset: (x: 40pt, top: 18pt, bottom: 40pt),
    )[
      #v(1em)
      #set text(size: 40pt, weight: "bold")
      Поток

      #set align(left)
      #set text(size: 20pt, weight: "regular")

      - Имеет свой *номер* (TID)

      - Имеет свой *контекст выполнения*

      - Имеет свой *стек*

      #line(length: 50%)

      - Является *частью процесса*

      - Почти всё *делит с другими потоками*

      - *Общее адресное пространство*

      - *Общий набор дескрипторов*
    ]
  ]
]

#slide(background-image: none)[
  = Зачем нужны потоки?

  #table(
    columns: (40%, 60%),
    align: left + horizon,
    stroke: (x, y) => {
      if x == 1 {
        return (left: 3pt + gray)
      }
    },
    inset: (x, y) => {
      if x == 1 {
        return (left: 20pt, top: 20pt)
      }
      return (top: 20pt)
    },
    [
      #align(center)[
        #cetz.canvas(length: 1cm, {
          cetz.draw.content((0, 0), (rel: (8, 8)), [
            #image("img/render.png")
          ])

          cetz.draw.content((0, 0), (rel: (8, 8)), [
            #grid(
              columns: (50%, 50%),
              rows: (50%, 50%),
              stroke: 5pt + black.transparentize(50%),
              align: horizon + center,
              ..range(4).map(i => [
                #set text(size: 50pt, fill: black.transparentize(50%), weight: "bold")
                #(i + 1)
              ])
            )
          ])
        })
      ]
    ],
    [
      *Потоки позволяют осуществлять параллельные вычисления внутри процесса.*

      - Например, для софтверного рендеринга:

        - Разделить картинку на несколько частей;

        - Каждую часть рендерить в своём потоке.

      #colbox(color: red)[⚠️] : *Потоки и процессы - не одно и то же!*
    ],
  )

  = #codebox(lang: "c", "pthread")

  - *Ваш инструмент* для создания потоков и контроля над ними.

  - Подключается через #codebox(lang: "c", "#include <pthread.h>") и флаг #codebox("-pthread") .
]

#slide(background-image: none)[
  == #codebox(lang: "c", "pthread_create(pthread_t*, pthread_attr_t*, f* function, void* arg);")

  *Конструктор структуры #codebox(lang: "c", "pthread_t")*

  #table(
    columns: 2,
    align: horizon,
    inset: (x, y) => {
      if x == 0 { (left: 10pt, right: 20pt) } else { (left: 20pt, right: 20pt, y: 0pt) }
    },
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    rows: (1.2em, ),
    row-gutter: 8pt,
    codebox(lang: "c", "pthread_t thread"), [*Структура*, которую нужно инициализировать],
    codebox(lang: "c", "const pthread_attr_t* attr"), [*Атрибуты* потока],
    codebox(lang: "c", "(void*)(*function)(void*)"), [*Entrypoint* потока],
    [#codebox(lang: "c", "void* arg") :], [*Аргумент* для entrypoint],
  )

  #line(length: 100%)

  #colbox(color: gray)[⚠️] : *Деструктора у #codebox(lang: "c", "pthread_t") нет,* только у атрибутов.
  - Поток уничтожится сам, когда выполнятся определённые условия.
]

#slide(background-image: none)[
  = Атрибуты потока -- #codebox(lang: "c", "pthread_attr_t")

  #table(
    columns: 2,
    align: horizon,
    inset: (x, y) => {
      if x == 0 { (left: 10pt, right: 20pt) } else { (left: 20pt, right: 20pt, y: 0pt) }
    },
    stroke: (x, y) => {
      if x == 0 and y != 6 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    rows: (1.2em, ),
    row-gutter: 8pt,
    codebox(lang: "c", "pthread_attr_init(...)"), [*Конструктор*;],
    codebox(lang: "c", "pthread_attr_destroy(...)"), [*Деструктор* (да, у атрибутов он есть);],
    codebox(lang: "c", "pthread_attr_setstacksize(...)"), [Запросить другой *размер стека*;],
    codebox(lang: "c", "pthread_attr_setguardsize(...)"), [Запросить другой *размер guard-секции*;],
    codebox(lang: "c", "pthread_attr_setstack(...)"), [Установить *собственный стек*;],
    codebox(lang: "c", "pthread_attr_setaffinity_np(...)"), [Настроить набор процессорных ядер;],
    box(inset: (y: 10pt))[_И еще много чего..._], [],
  )

  #line(length: 100%)

  Если вас устраивают *атрибуты по умолчанию*, можно передать #codebox(lang: "c", "NULL")

  Атрибуты можно освободить сразу после создания потока, либо переиспользовать.
]

#slide(background-image: none, place-location: horizon)[
  #table(
    columns: (50%, 50%),
    align: top + center,
    inset: (y: 20pt, x: 10pt),
    stroke: none,
    [
      #box(
        inset: 20pt,
        radius: 20pt,
        height: 8cm,
        stroke: 3pt + cell-color(blue).stroke-color,
        fill: cell-color(blue).background-color,
      )[
        == Неявное завершение работы

        #v(0.3em)
        #line(length: 100%, stroke: 3pt + cell-color(blue).stroke-color.transparentize(80%))
        #v(0.4em)
        #set align(left)
        #set block(spacing: 10pt)

        - *Поток завершил свою работу*, вернувшись из своей функции.
      ]
    ],
    [
      #box(
        inset: 20pt,
        radius: 20pt,
        stroke: 3pt + cell-color(red).stroke-color,
        fill: cell-color(red).background-color,
        height: 8cm,
      )[
        == Явное завершение работы

        #v(0.3em)
        #line(length: 100%, stroke: 3pt + cell-color(red).stroke-color.transparentize(80%))
        #v(0.4em)
        #set align(left)
        #set block(spacing: 10pt)

        - *Поток явно завершил работу*:
        #h(1em) #codebox(lang: "c", "pthread_exit(...)")

        #v(0.5cm)

        - *Другой поток отменил его*:
        #h(1em) #codebox(lang: "c", "pthread_cancel(...)")
      ]
    ],
  )

  *Поток освобождается*, когда он завершил свою работу и:

  - Либо его *дождался* другой поток через #codebox(lang: "c", "pthread_join(...)");
  - Либо его *пометили как отсоединённый* через #codebox(lang: "c", "pthread_detach(...)");
]

#let ub = content => {
  place(bottom)[
    #box(
      inset: (bottom: 20pt, top: 15pt),
      outset: (x: 40pt, bottom: 20pt),
      width: 100%,
      fill: red.desaturate(80%),
      stroke: (top: 3pt + red.darken(50%)),
    )[

      #content
    ]
  ]
}

#slide(background-image: none)[
  = #codebox(lang: "c", "pthread_join(pthread_t tid, void **status)")

  *Ждет завершения потока* и возвращает статус завершения.

  #table(
    columns: 2,
    align: horizon,
    inset: (x, y) => {
      if x == 0 { (left: 10pt, right: 20pt) } else { (left: 20pt, right: 20pt, y: 0pt) }
    },
    stroke: (x, y) => {
      if x == 0 and y != 2 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    row-gutter: (8pt,) * 2 + (4pt,) * 3,
    codebox(lang: "c", "pthread_t tid"), [*Поток*, которого нужно дождаться.],
    codebox(lang: "c", "void** status"),
    [Куда вернуть *статус завершения* процесса. Может быть #codebox(lang: "c", "NULL");],
  )

  #line(length: 100%)
  #set par(spacing: 15pt)

  - *#codebox(lang: "c", "pthread_join(...)") - аналог #codebox(lang: "c", "waitpid(...)") для потоков.*
  - *Если поток был отменён*, то вместо кода возврата вернётся #codebox("PTHREAD_CANCELED").
  - Пока вы не вызовете #codebox(lang: "c", "pthread_join(...)"), поток *не сможет освободиться*.

  #ub[
    #set par(spacing: 15pt)
    == #colbox(color: red)[⚠️] Осторожно, UB!
    - *После #codebox(lang: "c", "pthread_join(...)") поток уже освобождён.*
    - Работа с ним - *UB*
  ]
]

#slide(background-image: none)[
  = #codebox(lang: "c", "pthread_detach(pthread_t tid)")

  *Помечает поток как отсоединённый*. Ничего не ждёт.

  Отсоединенный поток освобождается из памяти *сразу по завершении работы*.

  #line(length: 100%)

  Если проще - #codebox(lang: "c", "pthread_detach(...)") $equiv$ #codebox(lang: "c", "pthread_join(...)") отложенного действия.

  Этим можно пользоваться, когда код возврата не нужен.

  #ub[
    #set par(spacing: 15pt)
    == #colbox(color: red)[⚠️] Осторожно, здесь тоже UB!
    - *После #codebox(lang: "c", "pthread_detach(...)") поток может освободиться в любой момент.*
    - Работа с ним - *UB*
  ]
]

#slide(background-image: none)[
  #ub-header[
    = #colbox(color: red)[⚠️] Кругом UB!
  ]

  *Не все стандартные функции любят, когда их используют многопоточно.* Например:

  #align(center)[
    #box(inset: 0pt)[
      #table(
        columns: 4,
        stroke: (x, y) => {
          if x != 0 {
            (left: 3pt + gray)
          } else {
            (:)
          }
        },
        row-gutter: 5pt,
        inset: (x: 15pt, y: 3pt),
        align: center + horizon,

        [#codebox(lang: "c", "crypt()")],
        [#codebox(lang: "c", "ctime()")],
        [#codebox(lang: "c", "encrypt()")],
        [#codebox(lang: "c", "dirname()")],

        [#codebox(lang: "c", "localtime()")],
        [#codebox(lang: "c", "rand()")],
        [#codebox(lang: "c", "strerror()")],
        [#codebox(lang: "c", "getdate()")],
      )
    ]
  ]

  #set par(spacing: 15pt)

  - *Функции могут иметь разную толерантность к многопоточности*. Например:

    - Быть безопасными, *но не на первом вызове*;
    - Быть безопасными, *но не на одинаковых объектах*;
    - Быть безопасными, *но только если окружение не меняется*;
    - И так далее.

  *Об этом подробно сказано в мануалах (#link("https://man7.org/linux/man-pages/man7/attributes.7.html")[man 7 attributes], #link("https://man7.org/linux/man-pages/man7/pthreads.7.html")[man 7 pthreads])*

  #place(bottom + center, dy: -0.2cm)[
    _Многопоточное программирование кишит UB, но об этом в следующий раз._
  ]
]



#outro-slide()
