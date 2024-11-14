
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "../theme/theme.typ": *
#import "../theme/asm.typ": *
#import "./utils.typ": *
#import "./3d.typ": *
#import "../theme/bubbles.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Введение в многопоточное программирование

    АКОС, МФТИ

    31 октября, 2024
  ]
]

#show: enable-handout

#slide(background-image: none)[
  #let header(content) = {
    set text(fill: white, weight: "bold")
    box(baseline: 0.2em + 5pt, inset: 0.2em + 7pt, fill: luma(80), content, radius: 10pt)
  }

  #let items(content) = {
    set block(spacing: 1em)
    set list(marker: none)
    box(inset: (left: 10pt, y: 5pt), stroke: (left: 3pt + gray))[
      #content
    ]
  }

  #text(size: 40pt, weight: "bold")[
    #block(below: 20pt)[
      Напомним:
    ]
  ]

  #set text(size: 20pt, weight: "regular")

  #set block(spacing: 0pt)

  #header([Что такое поток?])

  #items[
    - *Поток - это единица планирования процессорного времени.*

    - Поток является *частью процесса*.
    
    - Потоки могут *выполняться независимо* друг от друга.
  ]

  #header([Что у всех потоков общее?])

  #items[
    - *Почти всё:* адресное пространство, набор дескрипторов, и прочее.
  ]

  #header([Что у потока своё?])

  #items[
    - *Контекст выполнения*, *стек*, и всякие настройки...
  ]
]

#slide(header: [Многопоточно стреляем себе в ногу], background-image: none)[
  #let softblue = cell-color(blue).background-color
  #let softred = cell-color(red).background-color
  #place(horizon + center)[
    #table(
      columns: (13cm, 13cm),
      align: center,
      column-gutter: 1.0cm,
      row-gutter: 1.0cm,
      stroke: none,
      [
        #set text(size: 25pt, weight: "semibold")
        #box(stroke: 3pt + black, fill: white, radius: 10pt, clip: true)[
          #place(top + right)[
            #box(inset: (y: 12pt, x: 17pt), stroke: (left: 3pt + black, bottom: 3pt + black), radius: (bottom-left: 10pt), fill: softred)[
              === Поток 1
            ]
          ]
          #box(inset: (left: 20pt, y: 60pt))[
            #code(numbers: true,
              ```cpp
              while(true) {
                strcpy(MSG, "......");
              }
              ```
            )
          ]
        ]
      ], [
        #set text(size: 25pt, weight: "semibold")
        #box(stroke: 3pt + black, fill: white, radius: 10pt, clip: true)[
          #place(top + right)[
            #box(inset: (y: 12pt, x: 17pt), stroke: (left: 3pt + black, bottom: 3pt + black), radius: (bottom-left: 10pt), fill: softred)[
              === Поток 2
            ]
          ]
          #box(inset: (left: 20pt, y: 60pt))[
            #code(numbers: true,
              ```cpp
              while(true) {
                strcpy(MSG, "@@@@@@");
              }
              ```
            )
          ]
        ]
      ],
      table.cell(colspan: 2)[
        #set text(size: 25pt, weight: "semibold")
        #box(stroke: 3pt + black, fill: white, radius: 10pt, clip: true)[
          #place(right)[
            #box(height: 2.3cm, inset: (x: 30pt), stroke: (left: 3pt + black), fill: softblue)[
              === Главный поток
            ]
          ]
          #box(inset: (left: 20pt, y: 20pt))[
            #code(numbers: true,
              ```cpp
              while(i < 100000) puts(MSG);
              ```
            )
          ]
        ]
      ]
    )
  ]

  #place(center + bottom, dy: -0.5cm)[
    = Что выведется?
  ]
]

#slide(background-image: none)[
  #place(horizon + left)[
    #let terminal(content) = {
      box(baseline: 20pt, inset: 20pt, fill: luma(250), content, radius: 20pt, stroke: 3pt + black)
    }

    #terminal[
      #set text(fill: green, weight: "black", size: 24pt)
      #raw("$ ./a.out | sort -u")
      #set text(fill: green, weight: "black", size: 16pt)
      ```
      .................... ....................
      .................... ....................
      .................... ....................
      .................... ....................
      ................@@@@ @@@@................
      ...............@@@@@ @@@@@...............
      ..............@@@@@@ @@@@@@..............
      ............@@@@@@@@ @@@@@@@.............
      ...........@@@@@@@@@ @@@@@@@@@...........
      .........@@@@@@@@@@@ @@@@@@@@@@..........
      ........@@@@@@@@@@@@ @@@@@@@@@@@@@.......
      .......@@@@@@@@@@@@@ @@@@@@@@@@@@@@@.....
      ......@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@....
      .....@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@...
      ....@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@..
      ...@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@.
      ..@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@
      .@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@
      ```
    ]

    #place(center + horizon, dy: -1.8cm, dx: 1cm)[
      #image("img/spider.png", width: 2.5cm)
    ]
  ]

  #place(left)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 0), (26, -13), [])
      cetz.draw.bezier((8.5, -4.5),  (15.4, -3), (12, -2), name: "bubbles")

      draw-small-bubbles("bubbles", count: 8, fill: white)
      draw-bubble(17, -3, 8, -6, fill: white);

      cetz.draw.content((17, -3), (rel: (8, -6)), [
        #set align(center + horizon)
        #set text(size: 25pt, weight: "bold")
        #set par(leading: 0.5em)
        UB моё, UB...
      ])

      cetz.draw.content((16, -13), (rel: (10, -6)), [
        #set align(center)
        = Как это исправить?
      ])
    })
  ]
]

#slide(header: [#codebox("mutex")], background-image: none)[
  *Примитив синхронизации*, позволяющий гарантировать выполнение участка кода только *одним потоком* одновременно. (дословно - #[*mut*]ually #[*ex*]clusive)

  *Имеет две операции*: #codebox("lock") и #codebox("unlock"). Иногда их называют #codebox("acquire") и #codebox("release")

  #v(1em)

  #set align(center)
  #cetz.canvas(length: 1cm, {
    cetz.draw.set-style(stroke: 5pt + black)

    cetz.draw.line((0, -2), (4, -2))
    cetz.draw.arc((4, -2), radius: 1, start: 90deg, delta: -90deg)
    cetz.draw.arc((5, -3), radius: 1, start: 180deg, delta: 30deg, mark: (end: "circle", length: 0.4, width: 0.4))

    cetz.draw.merge-path({
      cetz.draw.line((0, -6), (4, -6))
      cetz.draw.arc((4, -6), radius: 1, start: -90deg, delta: 90deg)
      cetz.draw.arc((5, -5), radius: 1, start: 180deg, delta: -90deg)
      cetz.draw.arc((15, -4), radius: 1, start: 90deg, delta: -90deg)
      cetz.draw.arc((16, -5), radius: 1, start: 180deg, delta: 90deg)
      cetz.draw.line((), (22, -6))
    })

    cetz.draw.content((0, -0.5), (rel: (4, -1)), [
      #set align(center)
      = Поток 1
    ])

    cetz.draw.content((0, -4.5), (rel: (4, -1)), [
      #set align(center)
      = Поток 2
    ])

    let redstroke = cell-color(red).stroke-color
    let softred = cell-color(red).background-color

    let stroke = 4pt + redstroke
    let pat = pattern(size: (25pt, 25pt))[
      #let stroke = 3pt + redstroke
      #place(line(stroke: stroke, start: (0%, 0%), end: (100%, 100%)))
      #place(line(stroke: stroke, start: (-100%, 0%), end: (100%, 200%)))
      #place(line(stroke: stroke, start: (0%, -100%), end: (200%, 100%)))
    ]

    let draw-pattern(a, w1, h1, padding: 0.3, cut-size: (0, 0)) = {
      a = (a.at(0) + padding, a.at(1) - padding)
      w1 -= padding * 2
      h1 -= padding * 2

      let pattern-size = (
        w1 / 2 - cut-size.at(0) / 2,
        h1 / 2 - cut-size.at(1) / 2
      )

      let b = (a.at(0) + pattern-size.at(0), a.at(1) - pattern-size.at(1))
      let w2 = w1 - pattern-size.at(0) * 2
      let h2 = h1 - pattern-size.at(1) * 2

      cetz.draw.line(
        a, 
        (rel: (w1, 0)), (rel: (0, -h1)), 
        (rel: (-w1, 0)), (rel: (0, h1)),
        b,
        (rel: (0, -h2)), (rel: (w2, 0)), 
        (rel: (0, h2)), (rel: (-w2, 0)),
        fill: pat, stroke: none
      )
    }

    cetz.draw.content((6, -1), (rel: (9, -2)), {
      box(width: 100%, height: 100%, stroke: stroke, fill: softred, {
        set align(horizon + center)
        set text(fill: redstroke)
        [*Критическая секция*]
      })
    })

    cetz.draw.content((6, -5), (rel: (9, -2)), {
      box(width: 100%, height: 100%, stroke: stroke, inset: 10pt, fill: softred)
    })

    draw-pattern((6, -1), 9, 2, cut-size: (7.3, 1))
    draw-pattern((6, -5), 9, 2)

    cetz.draw.line((6, -7.5), (6, -8), (6.2, -8), stroke: 3pt + black)
    cetz.draw.line((15, -7.5), (15, -8), (15.2, -8), stroke: 3pt + black)

    cetz.draw.content((6.5, -7), (10, -9), [
      #set align(horizon)
      #set text(weight: "bold")
      #codebox("lock")
    ])
    cetz.draw.content((15.5, -7), (19, -9), [
      #set align(horizon)
      #set text(weight: "bold")
      #codebox("unlock")
    ])
  })
]

#slide(background-image: none)[
  = #codebox(lang: "c", "pthread_mutex_t")

  *Реализация мьютекса в библиотеке #codebox("pthread")*

  #table(columns: 2,
    align: horizon,
    inset: (x, y) => {
      if  x == 0 { (left: 10pt, right: 20pt)}
      else {(left: 20pt, right: 20pt, y: 0pt)}
    },
    stroke: (x, y) => {
      if x == 0 and y != 6 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    row-gutter: 8pt,
    codebox(lang: "c", "pthread_mutex_init(...)"), [*Конструктор*;],
    codebox(lang: "c", "pthread_mutex_destroy(...)"), [*Деструктор*;],
    codebox(lang: "c", "pthread_mutex_lock(...)"), [Захватить с ожиданием;],
    codebox(lang: "c", "pthread_mutex_trylock(...)"), [Захватить немедленно или вернуть #codebox(lang: "c", "EBUSY") ;],
    codebox(lang: "c", "pthread_mutex_unlock(...)"), [Отпустить мьютекс.],
  )

  #box(width: 100%, inset: 10pt, stroke: 3pt + black, radius: 10pt, fill: white)[
    #set text(weight: "bold")
    #code(numbers: true,
    ```c
    pthread_mutex_lock(&lock);

    // Эта строчка исполнится не более чем одним потоком одновременно

    pthread_mutex_unlock(&lock); 
    ```
    )
  ]
]

#slide(background-image: none)[
  = Задача об обедающих философах

  #table(
    columns: (11.5cm, auto),
    rows: 13cm,
    stroke: none,
    align: horizon,
    [
      #set align(horizon + left)
      #box[
        #set align(center)
        #image("img/dining_philosophers.png", width: 10cm)
        #text(fill: gray, size: 14pt)[
          Автор #link("https://commons.wikimedia.org/wiki/File:An_illustration_of_the_dining_philosophers_problem.png")[#text(fill: gray)[иллюстрации]]: Benjamin D. Esham
        ]
      ]
    ],
    [
      #box(stroke: (left: 3pt + gray), inset: (left: 25pt, y: 10pt), [
        - *Философы сидят за круглым столом* и едят бесконечную лапшу.

        - Каждый философ может либо есть, либо размышлять произвольное время.

        - Чтобы начать есть, философу нужно взять *две вилки*.

        - Число вилок равно числу философов.

        - *Как нужно брать вилки, чтобы не возникло взаимоблокировки?*
      ])
    ]
  )
]

#slide(header: [#codebox("condvar")], background-image: none)[
  *Примитив синхронизации для ожидания условия*. Работает в паре с мьютексом.

  - Дословно - #[*cond*]itional #[*var*]iable

  #v(1em)

  #align(center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 5pt + black)

      cetz.draw.line((-2, -2), (4, -2))
      cetz.draw.line((17, -2), (22, -2), mark: (end: ">"))
      cetz.draw.line((-2, -6), (5, -6))
      cetz.draw.line((8, -6), (9, -6))
      cetz.draw.line((12, -6), (15, -6))
      cetz.draw.line((16, -6), (22, -6), mark: (end: ">"))

      cetz.draw.content((-1, -0.5), (rel: (4, -1)), [
        #set align(center)
        = Поток 1
      ])

      cetz.draw.content((-1, -4.5), (rel: (4, -1)), [
        #set align(center)
        = Поток 2
      ])

      let bluestroke = cell-color(blue).stroke-color
      let softblue = cell-color(blue).background-color

      let redstroke = cell-color(red).stroke-color
      let softred = cell-color(red).background-color

      let stroke = 4pt + redstroke

      cetz.draw.content((4, -1), (rel: (13, -2)), {
        box(width: 100%, height: 100%, stroke: stroke, fill: softred, inset: 8pt, {
          set align(horizon + center)
          set text(fill: redstroke)
          place(box(width: 100%, height: 100%, fill: striked-pattern(redstroke)))
          box(fill: softred, inset: 7pt, {
            [*Ждет, пока*]
            set text(weight: "bold", size: 22pt)
            raw(" a != 3")
          })
        })
      })

      for i in range(3) {
        let x = 5 + i * 4
        cetz.draw.content((x, -5), (rel: (3, -2)), {
          box(width: 100%, height: 100%, stroke: 3pt + bluestroke, inset: 10pt, fill: softblue, {
            set align(horizon + center)
            set text(fill: bluestroke, weight: "bold", size: 22pt)
            raw("a = " + str(i + 1))
          })
        })
      }
    })
  ]

  #v(1em)

  - Саму переменную и условие ожидания *можно сделать любыми*.
]

#slide(background-image: none)[
  #let c(content) = {
    raw(lang: "c", content)
  }
  #let softblue = cell-color(blue).background-color
  #let bluestroke = cell-color(blue).stroke-color
  #let thread-width = 4cm
  
  #let capture-mutex(items) = {
    table.cell(rowspan: items.len(), {
      box(width: 4cm, fill: softblue, stroke: 3pt + bluestroke, inset: (x: 10pt, y: 5pt), {
        set align(center)
        table(columns: 1,
          stroke: none,
          inset: (x: 0pt, y: 4pt),
          align: horizon + center,
          ..items
        )
      })
    })
  }
  
  #let wait(rows, nocache: 0) = {
    let dotted-pattern = pattern(size: (thread-width, 30pt), {
      // Apparently, there is a bug in typst.
      // When using table with column-gutter, the cell background
      // pattern is shifted by the gutter value. It's probably because
      // the pattern is cached and not recalculated for each cell.
      // By adding nocache * 0.001pt to the coordinate, we force
      // the typst compiler to recalculate the pattern for each cell,
      // so the background pattern is drawn correctly.
      let x = 50% + nocache * 0.001pt
      place(line(stroke: (thickness: 3pt, paint: gray, dash: "dashed"), start: (x, 0%), end: (x, 100%)))
    })
    table.cell(rowspan: rows, fill: dotted-pattern, {})
  }
  #let scheme = (
    (
      c("lock()"),
      capture-mutex((c("a != \"key\""), c("wait()"))), none,
      wait(3), none, none,
      capture-mutex((c("a != \"key\""), c("wait()"),)), none,
      wait(3), none, none,
      capture-mutex((c("a == \"key\""), c("unlock()"),)), none,
    ), (
      [],
      c("lock()"),
      wait(1, nocache: 2),
      capture-mutex((
        c("a = \"foo\""),
        c("signal()"),
        c("unlock()")
      )), none, none
    ), (
      ..([],) * 4,
      c("lock()"),
      wait(3, nocache: 3), none, none,
      capture-mutex((
        c("a = \"key\""),
        c("signal()"),
        c("unlock()")
      )), none, none
    )
  )
  #let transpose(scheme) = {
    let result = ()
    let rows = 0
    for i in range(scheme.len()) {
      if rows < scheme.at(i).len() {
        rows = scheme.at(i).len()
      }
    }
    for i in range(rows) {
      for j in range(scheme.len()) {
        let element = scheme.at(j, default: ()).at(i, default: [])
        if element == none {
          continue
        }
        result.push(element)
      }
    }
    result
  }

  #table(
    columns: (auto, 1fr),
    rows: 1fr,
    inset: (x, y) => {
      if x == 1 {
        (left: 20pt)
      } else {
        (right: 20pt)
      }
    },
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    [
      #set text(weight: "bold")
      #table(
        columns: (thread-width,) * 3,
        stroke: (x, y) => {
          if y == 1 {
            (bottom: 3pt + gray)
          } else {
            none
          }
        },
        inset: (y: 5pt),
        align: horizon + center,
        column-gutter: (20pt, 0pt),
        [
          === Ожид.поток:
        ], table.cell(colspan: 2)[
          === Обновляющие потоки:
        ],
        [], [], [],
        [], [], [],
        ..transpose(scheme)
      )
    ],
    [
      #set block(spacing: 12pt)
      == Интерфейс condvar

      == #codebox(lang: "c", "wait()") :

      - *Заснуть*, освободив мьютекс. При пробуждении захватить мьютекс.

      - После пробуждения нужно перепроверить условие.
      == #codebox(lang: "c", "signal()") :
      
      - *Разбудить один* из ожидающих потоков.

      == #codebox(lang: "c", "broadcast()") :
      
      - *Разбудить все* ожидающие потоки.
    ]
  )

  #place(bottom + right)[
    #box(fill: softblue, stroke: bluestroke + 3pt, inset: (left: 10pt, right: 17pt, y: 12pt), {
      set text(weight: "semibold")
      [Синим выделены критические секции.]
    })
  ]
]

#slide(background-image: none)[
  = В чем проблема #codebox("condvar")?

  #place(horizon)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 5pt + black)

      cetz.draw.line((-2, -2), (4, -2))
      cetz.draw.line((17, -2), (22, -2), mark: (end: ">"))
      cetz.draw.line((-2, -6), (22, -6), mark: (end: ">"))

      cetz.draw.content((-1, -0.5), (rel: (4, -1)), [
        #set align(center)
        = Поток 1
      ])

      cetz.draw.content((-1, -4.5), (rel: (4, -1)), [
        #set align(center)
        = Поток 2
      ])

      let bluestroke = cell-color(blue).stroke-color
      let softblue = cell-color(blue).background-color

      let redstroke = cell-color(red).stroke-color
      let softred = cell-color(red).background-color

      let stroke = 4pt + redstroke

      cetz.draw.content((-3, 0), (rel: (1, 1)), {})

      cetz.draw.content((4, -1), (rel: (22, -2)), {
        box(width: 100%, height: 100%, stroke: stroke, fill: softred, inset: 8pt, {
          set align(horizon + left)
          set text(fill: redstroke)
          place(box(width: 100%, height: 100%, fill: striked-pattern(redstroke)))
          h(1em)
          box(fill: softred, inset: 7pt, {
            [*Ждет, пока*]
            set text(weight: "bold", size: 22pt)
            raw(" x != 'B'")
          })
        })
      })

      for i in range(3) {
        let x = 5 + i * 5
        cetz.draw.content((x, -5), (rel: (3.5, -2)), {
          box(width: 100%, height: 100%, stroke: 3pt + bluestroke, inset: 10pt, fill: softblue, {
            set align(horizon + center)
            set text(fill: bluestroke, weight: "bold", size: 22pt)
            if i == 1 {
              raw("x = 'B'")
            } else {
              raw("x = 'A'")
            }
          })
        })
      }

      cetz.draw.line((9.25, -3), (rel: (0, -5)), stroke: 5pt + redstroke)
      cetz.draw.line((19.25, -3), (rel: (0, -5)), stroke: 5pt + redstroke)

      cetz.draw.content((9.25, -9), [
        #box(width: 4.5cm, inset: 15pt, radius: 10pt, fill: softred, stroke: redstroke + 3pt)[
          #set align(center)
          *Проверка:*
          #text(size: 22pt, weight: "bold", fill: redstroke)[
            #raw("x != 'B'")
          ]
        ]
      ])

      cetz.draw.content((19.25, -9), [
        #box(width: 4.5cm, inset: 15pt, radius: 10pt, fill: softred, stroke: redstroke + 3pt)[
          *Проверка:*
          #text(size: 22pt, weight: "bold", fill: redstroke)[
            #raw("x != 'B'")
          ]
        ]
      ])
    })
  ]

  #place(bottom + center, dy: -0.5cm)[
    *Проверки могут происходить не сразу.* Это можети привести к #link("https://ru.wikipedia.org/wiki/Проблема_ABA")[*проблеме ABA*].
  ]
]

#slide(background: white)[
  == Корректное использование #codebox("condvar")

  #v(1em)
  #set text(weight: "bold")
  #table(
    stroke: (x, y) => {
      if(x == 0) {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    inset: (x, y) => {
      if y == 0 {
        if x == 0 {
          (bottom: 20pt)
        } else {
          (bottom: 20pt, left: 20pt)
        }
      } else {
        (y: 5pt)
      }
    },
    columns: (50%, 50%),
    align: horizon + center,
    [
      #code(numbers: true, ```c
      lock(&mutex);
      while(!condition) {
        wait(&condvar, &mutex);
      }
      
      /* Условие выполнено */

      unlock(&mutex);
      ```)
    ],
    [
      #code(numbers: true, ```c
      lock(&mutex);
      strcpy(a, "foo"); // Или key
      signal(&condvar);
      unlock(&mutex);
      ```)
    ],
    [
      Ожидание условия
    ],
    [
      Изменение переменной
    ]
  )

  #ub[
    = #colbox(color: red)[⚠️] Осторожно, Spurious wakeups!

    Иногда поток может проснуться сам, без вызова #codebox(lang: "c", "signal()") или #codebox(lang: "c", "broadcast()").
  ]
]

#slide(background-image: none)[
  = #codebox(lang: "c", "pthread_cond_t")

  *Реализация #codebox("condvar") в библиотеке #codebox("pthread")*

  #table(columns: 2,
    align: horizon,
    inset: (x, y) => {
      if  x == 0 { (left: 10pt, right: 20pt)}
      else {(left: 20pt, right: 20pt, y: 0pt)}
    },
    stroke: (x, y) => {
      if x == 0 and y != 6 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    row-gutter: 8pt,
    codebox(lang: "c", "pthread_cond_init(...)"), [*Конструктор*;],
    codebox(lang: "c", "pthread_cond_destroy(...)"), [*Деструктор*;],
    codebox(lang: "c", "pthread_cond_wait(...)"), [Освободить мьютекс и *ожидать сигнала*;],
    codebox(lang: "c", "pthread_cond_timedwait(...)"), [Аналогично, но с таймаутом;],
    codebox(lang: "c", "pthread_cond_signal(...)"), [*Разбудить один* ожидающий процесс.],
    codebox(lang: "c", "pthread_cond_broadcast(...)"), [*Разбудить все* ожидающие процессы.],
  )  
]

#slide[
  #set align(horizon + center)
  #box([
    #set align(top + left)

    #align(center)[
      #set text(size: 25pt);
      = Чем плохи блокировки?
    ]

    #v(1em)

    #set list(marker: none)
    - #con() *Накладные расходы на системные вызовы;*
    - #con() Можно долго ждать планировщик;
    - #con() Можно поймать deadlock.

    #align(center)[
      #set text(size: 25pt);
      #uncover((beginning: 2))[= Как обойтись без них?]
    ]

    #v(2em)
  ])
]

#focus-slide[
  #text(size: 40pt, weight: "bold")[
    Атомарные операции
  ]

  = и Lock-Free
]

#slide(header: [Атомарность], background-image: none)[
  *Это гарантия того, что операция будет выполнена целиком и неделимо*.

  #line(length: 100%)

  - Процессоры умеют атомарно работать с простыми типами. В x86 за это отвечает префикс #mnemonic("lock"). Например, так:

  #box(fill: white, inset: 20pt, stroke: 3pt + black, radius: 20pt)[
    #table(
      columns: 2,
      stroke: (x, y) => {
        if x == 0 {
          (right: 3pt + gray)
        } else {
          none
        }
      },
      inset: (x, y) => {
        if x == 0 {
          (right: 20pt, y: 2pt)
        } else {
          (left: 20pt, y: 2pt)
        }
      },
      row-gutter: 0.3cm,
      lightasm("lock add [ebx], ecx"), [
        Атомарно #lightasm("*(ebx) += ecx;")
      ],
      lightasm("lock xchg [ebx], ecx"), [
        Атомарно #lightasm("*(ebx)") *$arrows.rl$* #lightasm("ecx;", no-mnemonic: true)
      ],
      lightasm("lock cmpxchg [ebx], ecx"), [
        Атомарно
        #set text(weight: "bold")
        #raw(lang: "c", "if")#lightasm("(eax == *(ebx)) *(ebx)") *$arrows.rl$* #lightasm("ecx;", no-mnemonic: true)
      ]
    )
  ]

  - У некоторых инструкций префикс #mnemonic("lock") есть неявно. Например, у #mnemonic("xchg").

  - *Некоторые простые структуры данных можно сделать потокобезопасными с помощью лишь атомарных операций, без мьютексов и блокировок.*
]

#slide(header: "Атомарность в Си", background-image: none)[
  *Начиная с C11, переменные можно аннотировать как атомарные через #codebox(lang: "c", "_Atomic")*

  #table(columns: 2,
    align: horizon,
    inset: (x, y) => {
      if  x == 0 { (left: 10pt, right: 20pt)}
      else {(left: 20pt, right: 20pt, y: 0pt)}
    },
    stroke: (x, y) => {
      if x == 0 and y != 5 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    row-gutter: 6pt,
    codebox(lang: "c", "void atomic_init(A* obj, C desired)"), [Конструктор;],
    codebox(lang: "c", "C atomic_load(A* obj)"), [Атомарное чтение;],
    codebox(lang: "c", "void atomic_store(A* obj, C desired)"), [Атомарная запись;],
    codebox(lang: "c", "C atomic_exchange(A* obj, C desired)"), [Атомарно обменять значения;],
    codebox(lang: "c", "С atomic_add(A* obj, M desired)"), [Атомарное сложение;],
    [#box(inset: 3pt)[_И так далее..._]]
  )

  *Интерфейс к #lightasm("cmpxchg") на x86, или аналогичным инструкциям на других платформах:*
  - #codebox(lang: "c", "bool atomic_compare_exchange_weak(A* obj, C* expected, C desired)");
  - #codebox(lang: "c", "bool atomic_compare_exchange_strong(A* obj, C* expected, C desired)");

  *#codebox("weak") отличается от #codebox("strong") тем, что может дать ложный сбой. #link("https://en.cppreference.com/w/c/atomic/atomic_compare_exchange")[See docs].*
]

#slide(background: white, background-image: none)[
  = Неблокирующий стек
  *Основан на связном списке.* За кадром -- определения структур #codebox("node") и #codebox("stack").
  #place(horizon + center, dx: -1cm, dy: 0.3cm)[
    #table(
      stroke: none,
      columns: (14.5cm, 14.5cm),
      align: left + top,
      [
        #set text(weight: "bold")
        #code(numbers: true, ```c
        void push(_Atomic stack_t *s, node_t *node)
        {
            stack_t next = {};
            stack_t orig = atomic_load(s);
            do {
                node->next = orig.node;
                next.tag = orig.tag + 1;
                next.node = node;
            } while(
              !atomic_compare_exchange_weak(
              s, &orig, next))
        }
        ```)
      ],
      [
        #set text(weight: "bold")
        #code(numbers: true, ```c
        node *pop(_Atomic stack_t *s)
        {
            stack_t next = {};
            stack_t orig = atomic_load(s);
            do {
                if (orig.node == NULL)
                    return NULL;
                next.tag = orig.tag + 1;
                next.node = orig.node->next;
            } while(
              !atomic_compare_exchange_weak(
              s, &orig, next))
            return orig.node;
        }
        ```)
      ],
    )
  ]

  #place(center + bottom)[
    #set block(spacing: 10pt)
    *Lock-Free структуры писать сложно. Даже стек.*

    А Lock-Free очереди вообще посвящена #link("https://www.cs.rochester.edu/~scott/papers/1996_PODC_queues.pdf?")[научная работа].
  ]
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