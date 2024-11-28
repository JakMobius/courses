
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "../theme/theme.typ": *
#import "./utils.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Сетевое взаимодействие 3

    АКОС, МФТИ

    28 ноября, 2024
  ]
]

#show: enable-handout

#slide(background-image: none)[
  #align(center)[
    #set text(size: 25pt)
    = HTTP/1.1
    #v(1cm)
    #cetz.canvas(length: 1cm, {

      let softred = cell-color(red).background-color
      let redstroke = cell-color(red).stroke-color
      let softblue = cell-color(blue).background-color
      let bluestroke = cell-color(blue).stroke-color
      
      let client-x = 0cm
      let server-x = 10.4cm
      let block-width = 8cm
      let block-height = 8cm

      cetz.draw.content((client-x - block-width / 2, -block-height / 2), box(width: block-width, height: block-height, fill: softblue, stroke: 3pt + bluestroke, radius: 10pt)[
        #align(horizon + center)[
          #image("img/doscomputer.png", height: 5cm)
        ]
        #align(center,)[
          #set text(fill: bluestroke, size: 25pt, weight: "semibold")
          Клиент
        ]
      ])

      cetz.draw.content((server-x + block-width / 2, -block-height / 2), box(width: block-width, height: block-height, fill: softred, stroke: 3pt + redstroke, radius: 10pt)[
        #align(horizon + center)[
          #image("img/server.png", height: 5cm)
        ]
        #align(center)[
          #set text(fill: redstroke, size: 25pt, weight: "semibold")
          Сервер
        ]
      ])

      let step-size = 1.6cm
      let shift = 1cm
      let padding = 1cm
      let arrow-top-position = -1cm

      let draw-arrow(flip, y, tint, content) = {
        let fill-color = cell-color(tint).background-color
        let stroke-color = cell-color(tint).stroke-color

        let mark = (length: 10pt, width: 10pt)
        if flip != true {
          mark.start = ">"
        }
        if flip != false {
          mark.end = ">"
        }

        cetz.draw.line(
          (client-x + padding, -step-size * y + arrow-top-position),
          (server-x - padding, -step-size * y + arrow-top-position),
          stroke: 3pt + stroke-color,
          mark: mark,
          fill: stroke-color,
          name: "arrow")

        cetz.draw.content("arrow.mid", angle: "arrow.end", [
          #set align(horizon + center)
          #box(inset: (x: 20pt, y: 10pt), radius: 10pt, stroke: 3pt + stroke-color, fill: fill-color)[
            #set text(fill: stroke-color, size: 30pt)
            *#content*
          ]
        ])
      }

      draw-arrow(true, 0, blue, `Запрос 1`)
      draw-arrow(false, 1, red, `Ответ 1`)
      draw-arrow(true, 2, blue, `Запрос 2`)
      draw-arrow(false, 3, red, `Ответ 2`)


      cetz.draw.content(
        ((client-x + server-x) / 2, -step-size * 4 + arrow-top-position))[
          #set text(size: 40pt)
          $dots.c$
      ]
    })
    #v(0.5cm)
  ]

  - *Запросы блокирующие:* сервер не может отвечать на следующий запрос, пока не ответил на текущий. По крайней мере, если соединение одно.
]

#slide(background-image: none)[
  #align(center)[
    #set text(size: 25pt)
    = HTTP/2.0
    #v(1cm)
    #cetz.canvas(length: 1cm, {

      let softred = cell-color(red).background-color
      let redstroke = cell-color(red).stroke-color
      let softblue = cell-color(blue).background-color
      let bluestroke = cell-color(blue).stroke-color
      
      let client-x = 0cm
      let server-x = 10.4cm
      let block-width = 8cm
      let block-height = 8cm

      cetz.draw.content((client-x - block-width / 2, -block-height / 2), box(width: block-width, height: block-height, fill: softblue, stroke: 3pt + bluestroke, radius: 10pt)[
        #align(horizon + center)[
          #image("img/doscomputer.png", height: 5cm)
        ]
        #align(center,)[
          #set text(fill: bluestroke, size: 25pt, weight: "semibold")
          Клиент
        ]
      ])

      cetz.draw.content((server-x + block-width / 2, -block-height / 2), box(width: block-width, height: block-height, fill: softred, stroke: 3pt + redstroke, radius: 10pt)[
        #align(horizon + center)[
          #image("img/server.png", height: 5cm)
        ]
        #align(center)[
          #set text(fill: redstroke, size: 25pt, weight: "semibold")
          Сервер
        ]
      ])

      let step-size = 1.6cm
      let shift = 1cm
      let padding = 1cm
      let arrow-top-position = -1cm

      let draw-arrow(flip, y, tint, content) = {
        let fill-color = cell-color(tint).background-color
        let stroke-color = cell-color(tint).stroke-color

        let mark = (length: 10pt, width: 10pt)
        if flip != true {
          mark.start = ">"
        }
        if flip != false {
          mark.end = ">"
        }

        cetz.draw.line(
          (client-x + padding, -step-size * y + arrow-top-position),
          (server-x - padding, -step-size * y + arrow-top-position),
          stroke: 3pt + stroke-color,
          mark: mark,
          fill: stroke-color,
          name: "arrow")

        cetz.draw.content("arrow.mid", angle: "arrow.end", [
          #set align(horizon + center)
          #box(inset: (x: 20pt, y: 10pt), radius: 10pt, stroke: 3pt + stroke-color, fill: fill-color)[
            #set text(fill: stroke-color, size: 30pt)
            *#content*
          ]
        ])
      }

      draw-arrow(true, 0, blue, `Запрос 1`)
      draw-arrow(true, 1, blue, `Запрос 2`)
      draw-arrow(true, 2, blue, `Запрос 3`)
      draw-arrow(false, 3, red, `Ответы`)

      cetz.draw.content(
        ((client-x + server-x) / 2, -step-size * 4 + arrow-top-position))[
          #set text(size: 40pt)
          $dots.c$
      ]
    })
    #v(0.5cm)
  ]

  - Мультиплексирует несколько запросов в рамках одного соединения.

  - Клиент может отправить много запросов и задавать приоритет их обработки. (Например, сначала загрузить текст, а потом шрифты, картинки, и т.д)
]

#slide(background-image: none)[
  - Обычно сервер примерно знает, какие ресурсы запросит клиент в будущем. Отправляя HTML-страницу, можно сразу начать отправлять картинки, стили, и скрипты, которые на ней есть.

  - Это называется *Server Push*, и это тоже фича HTTP/2.0.

  #let message(side, color, content) = [
    #align(side)[
      #box(inset: (x: 5pt), fill: color, radius: 10pt)[
        #content
      ]
    ]
  ]

  #let msgtext(content) = [
    #box(inset: (right: 5pt, left: 5pt, y: 15pt), baseline: 15pt)[
      #set text(fill: white, size: 20pt, font: "TT Norms Pro")
        #content
    ]
  ]

  #let file(stroke-color) = [
    #box(baseline: 0.6cm, inset: (y: 7pt, left: 2pt))[
      #cetz.canvas(length: 1cm, {
        cetz.draw.scale(0.65)
        cetz.draw.circle((0, 0), radius: 1, fill: white, stroke: none)
        cetz.draw.set-style(stroke: stroke-color + 3pt)
        cetz.draw.scale(x: 0.37, y: 0.45)
        cetz.draw.line((-1, -1), (1, -1))
        cetz.draw.line((0, 1), (0, -0.6))
        cetz.draw.line((-1, 0.2), (0, -0.6), (1, 0.2))
      })
    ]
  ]

  #place(center + bottom, dy: 1.15cm)[
    #let leftcol = rgb(44, 45, 46)
    #let rightcol = rgb(66, 107, 168)

    #box(width: 20cm)[
      #set block(spacing: 5pt)
      #message(left, leftcol, [
        #msgtext[Привет, а что у тебя в index.html?]
      ])
      #v(0.4cm)
      #message(right, rightcol, 
      [
        #msgtext[Я рад, что ты спросил]
      ])
      #message(right, rightcol, [
        #file(rightcol)
        #msgtext[index.html]
      ])
      #message(right, rightcol, [
        #file(rightcol)
        #msgtext[script.js]
      ])
      #message(right, rightcol, [
        #file(rightcol)
        #msgtext[style.css]
      ])
      #message(left, leftcol, [
        #msgtext[Остановись, я веб-краулер...]
      ])
    ]
  ]
]

#slide[
  = Что ещё поменяли в HTTP/2.0?

  #v(1cm)

  - *Протокол стал бинарным.* Напомним, HTTP/1.1 был текстовым.

  - *Сжимаются заголовки* в запросах и ответах.

  - #link("https://en.wikipedia.org/wiki/HTTP/2#Encryption")[Браузеры поддерживают его только как HTTPS], хотя стандарт этого не требует.
]

#focus-slide[
  #set text(size: 30pt)
  = Шифрование
]

#slide(background-image: none)[
  = Зачем вообще нужно шифрование?

  #v(0.5cm)

  - Ваши сообщения в канале (Wi-Fi, Ethernet, ...) могут подслушивать.

  - Ваши сообщения могут быть изменены кем-то по пути.

  - Кто угодно может выдать своё сообщение за ваше.

  #place(bottom + center, dy: 1cm)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 0), (26, -3), [])

      cetz.draw.line((2, 0), (18, 0), stroke: (
        dash: "dashed",
        thickness: 3pt,
        paint: gray
      ))

      cetz.draw.line((7, 0), (7, -6), (10, -6), stroke: (
        dash: "dashed",
        thickness: 3pt,
        paint: gray
      ))

      cetz.draw.content((0, 0), [
        #image("img/cat-sending.png", height: 6cm)
      ])

      cetz.draw.content((11, -5), [
        #image("img/spy-cat.png", height: 4cm)
      ])

      cetz.draw.content((20, 0), [
        #scale(x: -100%)[
          #image("img/cat-sending.png", height: 6cm)
        ]
      ])

      let label(color, name, descr) = {
        box(inset: (x: 20pt, y: 12pt), fill: cell-color(color).background-color, stroke: 3pt + cell-color(color).stroke-color, radius: 10pt)[
          #set text(fill: cell-color(color).stroke-color)
          #set align(center)
          #set block(spacing: 10pt)
          #text(size: 25pt)[
            *#name*
          ]

          #text(size: 14pt)[
            _#(descr)_
          ]
        ]
      }

      cetz.draw.content((0, -4.5), [
        #label(blue, "Алиса", "Отправитель")
      ])

      cetz.draw.content((11, -1.5), [
        #label(red, "Ева", "Злостный злот")
      ])

      cetz.draw.content((20, -4), [
        #label(blue, "Боб", "Получатель")
      ])
    })
  ]
]

#slide(place-location: horizon)[
  = Проблема передачи ключа

  #v(0.5cm)

  - Допустим, мы умеем шифровать сообщение каким-то паролем (ключом).

  - Как Алисе и Бобу договориться о пароле так, чтобы Ева его не узнала?

  - Передать пароль в открытую нельзя, иначе Ева его подслушает.

  #uncover((beginning: 2))[

    - Для этого существует *алгоритм Диффи-Хеллмана*.
  ]
]

#slide(background-image: none)[
  = Алгоритм Диффи-Хеллмана

  #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.line((4, 0), (19, 0), stroke: (
        paint: gray,
        thickness: 3pt,
        dash: "dashed"
      ), mark: (start: ">", end: ">", length: 10pt, width: 10pt), fill: gray)
      
      cetz.draw.content((11.5, 0), [
        #set align(center)
        $P, G$ можно передать в открытую

        $P$ -- простое, $G$ -- его первообразный корень
      ])

      cetz.draw.content((0.5, 0), [
        #image("img/cat-sending.png", height: 6cm)
      ])

      cetz.draw.content((22.5, 0), [
        #scale(x: -100%)[
          #image("img/cat-sending.png", height: 6cm)
        ]
      ])  

      cetz.draw.line((0, -3), (0, -4), stroke: 3pt + gray)
      cetz.draw.line((23, -3), (23, -4), stroke: 3pt + gray)

      cetz.draw.content((-2, -4), (rel: (x: 10, y: -5)), [
        #box(inset: 10pt, fill: white, radius: 10pt, stroke: 3pt + gray)[
          #set text(size: 20pt, weight: "semibold")
          #code(numbers: true, ```c
          a = rand() % P;
          A = pow(G, a) % P;
          send(A);
          receive(&B);
          K = pow(B, a) % P;
          ```)
        ]
      ])

      cetz.draw.content((15, -4), (rel: (x: 10, y: -5)), [
        #box(inset: 10pt, fill: white, radius: 10pt, stroke: 3pt + gray)[
          #set text(size: 20pt, weight: "semibold")
          #code(numbers: true, ```c
          b = rand() % P;
          B = pow(G, b) % P;
          send(B);
          receive(&A);
          K = pow(A, b) % P;
          ```)
        ]
      ])

      let xa = 2.5
      let xb = 3.8
      let x2 = 14.5

      let xm1 = 10
      let xm2 = 13

      let col-a = blue
      let col-b = red

      cetz.draw.bezier((xa, -6.4), (x2, -7.1), (xm2, -6.4), (xm1, -7.1), stroke: 3pt + col-a, mark: (end: ">"))
      cetz.draw.bezier((x2, -6.4), (xb, -7.1), (xm1, -6.4), (xm2, -7.1), stroke: 3pt + col-b, mark: (end: ">"))
    })
  ]

  #place(bottom + center, dy: -0.5cm)[
    $K$ - секретный ключ. Ева не сможет его узнать, даже если подслушает $A, B, P$ и $G$.
  ]
]

#slide[
  = TLS (Transport Layer Security)

  #v(0.5cm)

  - Защитный протокол транспортного уровня, обеспечивающий шифрование и связанные с ним гарантии.

  - Использует алгоритм Диффи-Хеллмана для создания сеансового ключа.

  - Шифрует сообщения, используя этот ключ.

  - Позволяет проверить, что сервер -- тот, за кого себя выдаёт.

  - Позволяет проверить, что сообщение не было изменено по пути.

  - Установка TLS-сеанса производится отдельным хендшейком длиной в 4 раунда.
]

#slide(background-image: none, place-location: horizon)[
  #table(
    columns: (auto, 9cm),
    stroke: none,
    align: (left + horizon, right + horizon),
    [
      = HTTPS, или бутерброд из хендшейков

      #v(1cm)

      - Оригинальный HTTPS это HTTP over TLS. То есть между установкой TCP-соединения и передачей HTTP-запроса происходит установка сеанса TLS.

      - Разделение обязанностей между TCP и TLS приводит к тому, что нужно совершать два хендшейка.
      
      - Получается *семь* раундов обмена данными, чтобы загрузить страницу.

      - В HTTP/3.0 цепочку TCP + TLS заменили на протокол QUIC. Он умеет делать оба хендшейка за один раунд обмена данными.

      - HTTP/3.0 требует всего два раунда обмена вместо семи.
    ],
    table(
      columns: (1.5cm, auto),
      fill: (x, y) => {
        if x == 0 {
          return none
        }
        if y in (0, 2, 3, 5, 7) {
          return cell-color(blue).background-color
        }
        if y in (1, 4, 6, 8) {
          return cell-color(red).background-color
        }
      },
      stroke: (x, y) => {
        if x == 0 {
          return (right: 3pt + gray)
        }
        if y in (0, 2, 3, 5, 7) {
          return cell-color(blue).stroke-color
        }
        if y in (1, 4, 6, 8) {
          return cell-color(red).stroke-color
        }
      },
      column-gutter: 15pt,
      row-gutter: 10pt,
      inset: 10pt,
      align: (x, y) => {
        center + horizon
      },
      table.cell(rowspan: 3)[
        #rotate(-90deg)[TCP]
      ],
      [SYN],
      [SYN, ACK],
      [ACK],
      table.cell(rowspan: 4)[
        #rotate(-90deg)[TLS]
      ],
      [Hello],
      [Hello, Cert, SKEx],
      [CKEx, CCS, Fin],
      [CCS, Fin],
      table.cell(rowspan: 2)[
        #rotate(-90deg)[HTTP]
      ],
      [HTTP Request],
      [HTTP Response],
    )
  )
]

#slide(background-image: none)[
  = HTTP/3.0 и QUIC

  #v(0.5cm)

  #box(width: 18cm)[
    - QUIC -- это протокол, который объединяет TCP и TLS.

    - Хендшейк QUIC происходит за один раунд обмена данными.
  ]

  #box(width: 10cm)[
    - Кроме этого QUIC позволяет делать *асинхронное мультиплексирование* запросов.

    - #link("https://habr.com/ru/company/vk/blog/594633/")[Статья от VK]
  ]

  #place(right + top, dy: -0.3cm)[
    #box(height: 120%)[
      #table(
        columns: 2,
        stroke: none,
        align: bottom + center,
        rows: (auto, 1.3cm),
        row-gutter: 10pt, 
        column-gutter: 15pt,
        table(
          columns: (1.5cm, auto),
          fill: (x, y) => {
            if x == 0 {
              return none
            }
            if y in (0, 2, 3, 5, 7) {
              return cell-color(blue).background-color
            }
            if y in (1, 4, 6, 8) {
              return cell-color(red).background-color
            }
          },
          stroke: (x, y) => {
            if x == 0 {
              return (right: 3pt + gray)
            }
            if y in (0, 2, 3, 5, 7) {
              return cell-color(blue).stroke-color
            }
            if y in (1, 4, 6, 8) {
              return cell-color(red).stroke-color
            }
          },
          column-gutter: 15pt,
          row-gutter: 10pt,
          inset: 10pt,
          align: (x, y) => {
            center + horizon
          },
          table.cell(rowspan: 3)[
            #rotate(-90deg)[QUIC]
          ],
          [Init, Hello],
          [Init, Hello, Cert, Fin],
          [Fin],
          table.cell(rowspan: 2)[
            #rotate(-90deg)[HTTP]
          ],
          [HTTP Request],
          [HTTP Response],
        ),
        table(
          columns: (1.5cm, auto),
          fill: (x, y) => {
            if x == 0 {
              return none
            }
            if y in (0, 2, 3, 5, 7) {
              return cell-color(blue).background-color
            }
            if y in (1, 4, 6, 8) {
              return cell-color(red).background-color
            }
          },
          stroke: (x, y) => {
            if x == 0 {
              return (right: 3pt + gray)
            }
            if y in (0, 2, 3, 5, 7) {
              return cell-color(blue).stroke-color
            }
            if y in (1, 4, 6, 8) {
              return cell-color(red).stroke-color
            }
          },
          column-gutter: 15pt,
          row-gutter: 10pt,
          inset: 10pt,
          align: (x, y) => {
            center + horizon
          },
          table.cell(rowspan: 3)[
            #rotate(-90deg)[TCP]
          ],
          [SYN],
          [SYN, ACK],
          [ACK],
          table.cell(rowspan: 4)[
            #rotate(-90deg)[TLS]
          ],
          [Hello],
          [Hello, Cert, SKEx],
          [CKEx, CCS, Fin],
          [CCS, Fin],
          table.cell(rowspan: 2)[
            #rotate(-90deg)[HTTP]
          ],
          [HTTP Request],
          [HTTP Response],
        ),
        table.hline(stroke: 3pt + gray),
        [== HTTP/3.0],
        [== HTTP/2.0]
      )
    ]
  ]
]

#slide(background-image: none)[
  #place(horizon + center)[
    #image("img/quic-benchmark.png", height: 100%)
  ]
]

#slide(background-image: none)[
  = Переезд в Userspace

  #v(0.5cm)

  - QUIC работает поверх UDP и реализован в пространстве пользователя.

  - За счёт этого приложение может донастроить протокол под себя.

  - Переход в Userspace - это общий тренд в сетевых технологиях.

  #v(0.5cm)

  == DPDK (Data Plane Development Kit)

  - Переносит работу с сетью полностью в пространство пользователя.

  - Использует DMA (Direct Memory Access) для обращения к буферам сетевой платы.

  - Позволяет отправлять и принимать пакеты без переключений контекста.

  - Отправить или принять пакет можно за 80 тактов процессора.

  - Для сравнения, переключение контекста может занять 1000 тактов.
]

#focus-slide[
  #set text(size: 30pt)
  = Давайте что-нибудь сломаем

  #place(center + bottom, dy: 1.2cm)[
    #image("img/caboom.png", height: 6cm)
  ]

  #place(center + bottom, dx: 0.8cm, dy: 0.3cm)[
    #set text(font: "Impact", stroke: 1pt + black)
    KABOOM?
  ]
]

#slide(background-image: none)[
  = Syn Flood

  #v(0.5cm)

  - Denial-Of-Service (DoS)-Атака на TCP-сервер.

  - Атакующий отправляет много пакетов с флагом SYN и даже не ждёт ответа.

  - Сервер должен создать на каждый пакет новое соединение и ждать таймаута.

  - Очередь подключений переполняется и обычный клиент не может подключиться.

  #align(center)[
    #cetz.canvas(length: 1cm, {

      let softred = cell-color(red).background-color
      let redstroke = cell-color(red).stroke-color
      let softblue = cell-color(blue).background-color
      let bluestroke = cell-color(blue).stroke-color
      
      let client-x = 0cm
      let server-x = 10.4cm
      let block-width = 8cm
      let block-height = 8cm

      cetz.draw.content((client-x - block-width / 2, -block-height / 2), box(width: block-width, height: block-height, fill: softblue, stroke: 3pt + bluestroke, radius: 10pt)[
        #align(horizon + center)[
          #image("img/doscomputer.png", height: 5cm)
        ]
        #align(center,)[
          #set text(fill: bluestroke, size: 25pt, weight: "semibold")
          Клиент
        ]
      ])

      cetz.draw.content((server-x + block-width / 2, -block-height / 2), box(width: block-width, height: block-height, fill: softred, stroke: 3pt + redstroke, radius: 10pt)[
        #align(horizon + center)[
          #image("img/server.png", height: 5cm)
        ]
        #align(center)[
          #set text(fill: redstroke, size: 25pt, weight: "semibold")
          Сервер
        ]
      ])

      let step-size = 1.6cm
      let shift = 1cm
      let padding = 1cm
      let arrow-top-position = -1cm

      let draw-arrow(flip, y, tint, content) = {
        let fill-color = cell-color(tint).background-color
        let stroke-color = cell-color(tint).stroke-color

        let mark = (length: 10pt, width: 10pt)
        if flip != true {
          mark.start = ">"
        }
        if flip != false {
          mark.end = ">"
        }

        cetz.draw.line(
          (client-x + padding, -step-size * y + arrow-top-position),
          (server-x - padding, -step-size * y + arrow-top-position),
          stroke: 3pt + stroke-color,
          mark: mark,
          fill: stroke-color,
          name: "arrow")

        cetz.draw.content("arrow.mid", angle: "arrow.end", [
          #set align(horizon + center)
          #box(inset: (x: 20pt, y: 10pt), radius: 10pt, stroke: 3pt + stroke-color, fill: fill-color)[
            #set text(fill: stroke-color, size: 30pt)
            *#content*
          ]
        ])
      }

      draw-arrow(true, 0, blue, `SYN`)
      draw-arrow(true, 1, blue, `SYN`)
      draw-arrow(true, 2, blue, `SYN`)
      draw-arrow(true, 3, blue, `SYN`)
      draw-arrow(true, 4, blue, `SYN`)
    })
    #v(0.5cm)
  ]
]

#slide(background-image: none)[
  == GET Flood / POST Flood

  - Атака на HTTP-сервер. Атакующий отправлет много тяжелых запросов на сервер, чтобы перегрузить его. Для такой атаки нужно подобрать запрос, который будет занимать много ресурсов сервера.

  - От таких атак защищаются кешированием, капчей или CDN (Например, Cloudflare). 

  == Cache Bypassing

  - То же, что и GET / POST Flood, но запросы подбираются таким образом, чтобы сервер не мог их кешировать.

  == Reverse Bandwidth Attack

  - Перегрузка исходящего канала сервера. Например, много параллельных запросов на загрузку большого файла.

  == Low And Slow

  - Перегрузка сервера большим количеством медленных запросов. Если сервер создаёт по потоку или по процессу на каждое соединение, ему будет особенно больно.
]

#slide(background-image: none)[
  = Атаки на DNS

  #place(horizon)[
    - В 2016 году неизвестные хакеры #link("https://en.wikipedia.org/wiki/DDoS_attacks_on_Dyn")[атаковали DNS-сервер Dyn], который обслуживал многие крупные сервисы.

    - У них был большой ботнет из умных чайников, камер, и других IoT-устройств. Запросы отправлялись с нескольких десятков миллионов IP-адресов.

    - Пострадали #link("https://en.wikipedia.org/wiki/DDoS_attacks_on_Dyn#Affected_services")[не меньше 70] крупных сервисов.

    - Владельца сайта от атаки на DNS не спасёт никакая DDoS-защита.

    - В целом, можно заставить клиентов запомнить ваш IP-адрес. Ну, помним же мы номера телефонов...
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