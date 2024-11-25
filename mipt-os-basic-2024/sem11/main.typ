
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "../theme/theme.typ": *
#import "../theme/bubbles.typ": *
#import "./utils.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Сетевое взаимодействие 2

    АКОС, МФТИ

    21 ноября, 2024
  ]
]

#show: enable-handout

#slide(background-image: none, background: white)[
  = Как выглядел наш TCP-сервер

  #v(0.5cm)

  #table(
    columns: (48%, 55%),
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    inset: (x, y) => {
      if x == 1 {
        (left: 15pt)
      } else {
        (right: 15pt, y: 20pt)
      }
    },
    [
      - Создаём сокет, связываем его с адресом через #codebox(lang: "c", "bind(...)");

      - Переводим сокет в режим сервера через #codebox(lang: "c", "listen(...)");

      - В цикле принимаем подключения через #codebox(lang: "c", "accept(...)"), обрабатываем их и закрываем через #codebox(lang: "c", "shutdown(...)") и #codebox(lang: "c", "close(...)").

      - *В чем проблема такого сервера?*
    ], [
      #set text(weight: "bold")
      #code(numbers: true, 
      ```c
      sock = socket(AF_INET, SOCK_STREAM, 0);

      // Какой адрес слушать
      bind(sock,(...*)&addr, sizeof(addr));

      // Перейти в режим сервера
      listen(sock, CONNECTION_QUEUE_LEN);

      while(server_is_running) {
        // Принять подключение
        int conn = accept(sock);
        // conn - сокет для общения с клиентом
        
        shutdown(conn, O_RDWR);
        close(conn);
      }
      close(sock);
      ```)
    ]
  )
]

#let draw-stage = (coord, stage, width: 4cm, height: 3cm) => {
    let color = cell-color(stage.at(1))

    cetz.draw.content(coord, box(width: width, height: height, stroke: 3pt + color.stroke-color, fill: color.background-color, radius: 10pt)[
    #set align(horizon + center)
    #set text(fill: black)
    #box[
      #set align(left)
      #lightcodebox(lang: "c", stage.at(0))
    ]
  ])
}

#let mark = (coord, dir: 0deg) => {
  let rel = (x: 5pt * calc.cos(dir), y: 5pt * calc.sin(dir))
  cetz.draw.line(coord, (rel: rel), mark: (end: ">", length: 10pt, width: 7pt), fill: black)
}

#slide(header: [Недостаток линейной схемы], background-image: none, place-location: horizon)[
  - #codebox(lang: "c", "accept()") вызывается в том же цикле, в котором происходит общение с клиентом.

  #align(center)[
    #v(0.5cm)
    #cetz.canvas(length: 1cm, {
      let stages = (
        ("accept()", blue), 
        ("read()\nwrite()", white),
        ("shutdown()", white),
        ("close()", white),
        ("accept()", blue)
      )

      let padding = 5.2

      for (i, stage) in stages.enumerate() {
        if i > 0 {
          mark(((i - 0.5) * padding, 0))
        }
        draw-stage((i * padding, 0), stage)
      }
    })
    #v(0.5cm)
  ]

  - Такой сервер не сможет поддерживать больше одного активного соединения.
]

#slide(header: [Обработка подключений с #codebox(lang: "c", "fork()")], background-image: none, place-location: horizon + center)[
  #align(center)[
    #v(0.5cm)
    #cetz.canvas(length: 1cm, {
      let stages = (
        ("accept()", blue), 
        ("fork()", white),
        ("accept()", blue),
        ("fork()", white),
        ("accept()", blue)
      )

      let padding = 5.2

      for (i, stage) in stages.enumerate() {
        if i > 0 {
          mark(((i - 0.5) * padding, 0))
        }
        draw-stage((i * padding, 0), stage)
      }

      for i in range(2) {
        let x = (i * 2 + 1) * padding
        mark((x, -2.25), dir: 270deg)
        let y = -5.5
        let st1 = "read()\nwrite()\nshutdown()\nclose()\nexit()"
        draw-stage((x, y), (st1, white), width: 5cm, height: 5cm)
      }
    })
    #v(0.5cm)
  ]
]

#slide(background-image: none, background: white)[
  = Простое решение -- по процессу на клиента

  #v(0.5cm)

  #table(
    columns: (43%, 1fr),
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    inset: (x, y) => {
      if x == 1 {
        (left: 30pt)
      } else {
        (right: 30pt, y: 20pt)
      }
    },
    [
      #set text(weight: "bold")
      #code(numbers: true, 
      ```c
      // ...

      while(server_is_running) {
        // Принять подключение
        int conn = accept(sock);
        
        if(fork() == 0) {
          // Работа с клиентом
          // в дочернем процессе

          shutdown(conn, O_RDWR);
          close(conn);
          exit(0);
        }
      }
      ```)
    ], [
      - #codebox(lang: "c", "fork()") -аемся каждое подключение, и работаем с клиентом в дочернем процессе. Следующий #codebox(lang: "c", "accept()") не будет ждать 
      #h(0.5cm) #colbox(color: green)[
        *Плюсы:*
      ]

      - Теперь мы можем обрабатывать несколько клиентов одновременно;

      - Очень простое решение.

      #h(0.5cm) #colbox(color: red)[
        *Минусы:*
      ]

      - Превращается в форк-бомбу при большом количестве клиентов;
    ]
  )
]

#slide(background-image: none)[
  = #codebox(lang: "c", "fork()") $arrow.r$ #codebox(lang: "c", "pthread_create()")
  #v(1cm)
  *Решение посложнее - создавать потоки вместо дочерних процессов.*

  #[
    #set list(marker: none)
    - #pro() Потоки создаются быстрее, чем процессы;
    - #pro() Потоки занимают меньше памяти;

    *Но придётся мириться со следующим:*

    - #con() Здесь уже не обойтись одним #lightcodebox(lang: "c", "if") -ом.
    - #con() C потоками приходят все проблемы многопоточности;
    - #con() Потоки не дают такой изоляции, как процессы. Уязвимость в логике работы с одним подключением может привести к утечке данных между клиентами.
  ]
]

#slide(background-image: none)[
  = Prefork model

  #place(horizon + center, dy: -0.7cm)[
    #v(0.5cm)
    #cetz.canvas(length: 1cm, {
      let stages = (
        ("accept()", blue),
        ("read()\nwrite()", white),
        ("...", white),
      )

      let padding = 5.2
      let vpadding = 3.3

      for j in range(4) {
        for (i, stage) in stages.enumerate() {
          if i > 0 {
            mark(((i - 0.5) * padding, -j * vpadding))
          }
          draw-stage((i * padding, -j * vpadding), stage)
        }
      }

      let fork-stage = ("fork()", white)

      draw-stage((-10, -1.5 * vpadding), fork-stage)
      mark((-7.5, -1 * vpadding), dir: 45deg)
      mark((-7.5, -2 * vpadding), dir: -45deg)

      draw-stage((-5, -0.5 * vpadding), fork-stage)
      mark((-2.5, 0 * vpadding), dir: 45deg)
      mark((-2.5, -1 * vpadding), dir: -45deg)

      draw-stage((-5, -2.5 * vpadding), fork-stage)
      mark((-2.5, -2 * vpadding), dir: 45deg)
      mark((-2.5, -3 * vpadding), dir: -45deg)
    })
    #v(0.5cm)
  ]

  #place(bottom, dy: -0.5cm)[
    Идея - создать все процессы заранее. Каждый процесс работает по линейной схеме.
  ]
]

#slide(background-image: none)[
  = TCP Handshake

  - Создание TCP-соединения происходит в три этапа.

  - Такая схема называется "трёхсторонним рукопожатием".

  - Этот процесс занимает время, поэтому придумали keepalive-соединения.

  #align(center)[
    #v(0.5cm)
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

      let step-size = 2.5cm
      let shift = 1cm
      let padding = 1cm
      let arrow-top-position = -1cm

      let draw-arrow(flip, y, tint, content) = {
        let fill-color = cell-color(tint).background-color
        let stroke-color = cell-color(tint).stroke-color

        let mark = if flip {
          (start: ">", length: 10pt, width: 10pt)
        } else {
          (end: ">", length: 10pt, width: 10pt)
        }

        let s1 = 0cm
        let s2 = 0cm

        if flip {
          s1 = shift
        } else {
          s2 = shift
        }

        cetz.draw.line(
          (client-x + padding, -step-size * y - s1 + arrow-top-position),
          (server-x - padding, -step-size * y - s2 + arrow-top-position),
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

      draw-arrow(false, 0, blue, `SYN`)
      draw-arrow(true, 1, red, `SYN, ACK`)
      draw-arrow(false, 2, blue, `ACK`)
    })
    #v(0.5cm)
  ]
]

#slide(background-image: none)[
  = HTTP: Keepalive

  - В старом HTTP каждый запрос - новое соединение. Сайты стали состоять из большого количества мелких файлов, и это стало проблемой.

  - HTTP/1.1 даёт отправлять несколько запросов через одно соединение. Это называется keepalive-соединением. (HTTP-заголовок -- #lightcodebox("Connection: keepalive"))

  #align(center)[
    #v(0.5cm)
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

      draw-arrow(none, 0, white, `Handshake`)
      draw-arrow(true, 1, blue, `GET /cat`)
      draw-arrow(false, 2, red, `200 OK ...`)
      draw-arrow(true, 3, blue, `GET /dog`)
      draw-arrow(false, 4, red, `200 OK ...`)
    })
    #v(0.5cm)
  ]
]

#slide(background-image: none)[
  #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      let x0 = 0
      let x1 = 36
      let jitter = 0.1

      cetz.draw.content((x0, 0), (x1, -22), [])

      let bubbles = generate-bubble-wall(x0, -10, x1, -10, 17)
      
      let points = bubbles-to-path(bubbles)
      cetz.draw.merge-path(close: true, fill: white, stroke: 3pt + black, {
        cetz.draw.hobby(..points, stroke: 3pt + black)
        cetz.draw.line((), (x1, 0), (x0, 0))
      })

      cetz.draw.bezier((23, -14.5), (20, -13), (20, -14.5), fill: none, stroke: none, name: "bubbles")
      draw-small-bubbles("bubbles", count: 4, fill: white)

      cetz.draw.content((27, -15.5), [
        #image("img/server.png", height: 6cm)
      ])
    })
  ]

  #place(dy: 1cm)[
    - Keepalive-соединение может *долго не делать ничего полезного*.

    - Выделять под каждое такое соединение поток или процесс -- дорого.

    - В линейной или prefork-модели это жестко ограничивает количество клиентов.

    - *Как быть?*
  ]

  #place(bottom, dy: -2cm, dx: 1cm)[
    #uncover((beginning: 2))[
      #set text(size: 23pt, weight: "bold")
      #box(inset: 20pt, baseline: 20pt, radius: 10pt, stroke: 3pt + green, fill: green.lighten(70%))[Решение -- мультиплексоры!]
    ]
  ]
]

#slide(background-image: none)[
  = Мультиплексор

  #v(1cm)

  - Интерфейс, позволяющий получать события от нескольких дескрипторов.

  - Помогает, если у вас много сокетов, и запрос может прилететь от любого из них.

  #place(center + bottom, dy: 1cm)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 0), (31, -10), [])
      let pxsize = 0.08cm

      for i in range(3) {
        let offset = 0
        if i == 1 {
          offset = -8
        }
        cetz.draw.content(((25 + offset) * pxsize, -16 * pxsize - i * 40 * pxsize))[
          #scale(x: -100%)[
            #image("img/halfpipe.png", height: 32 * pxsize)
          ]
        ]
      }

      cetz.draw.content((110 * pxsize, -14 * pxsize - 1 * 40 * pxsize))[
          #image("img/explosion.png", height: 48 * pxsize)
        ]

      cetz.draw.content((140 * pxsize, -55 * pxsize))[
        #image("img/bullet.png", height: 14 * pxsize)
      ]

      let col_a(content) = text(fill: rgb("38761d"), content)
      let col_b(content) = text(fill: rgb("990000"), content)
      let col_c(content) = text(fill: rgb("1155cc"), content)

      cetz.draw.content((208 * pxsize, -28 * pxsize), [
        #image("img/speech-bubble-large.png", height: 19 * 2 * pxsize)
        #place(horizon + center, dy: -0.4cm)[
          #set text(size: 18pt, font: ("Super Mario Bros. NES"))
          #col_a("GET")#col_b(" /cat ")#col_c("HTTP/1.1")
        ]
      ])

      cetz.draw.content((355 * pxsize, -60 * pxsize), [
        #image("img/halfpipe.png", height: 32 * pxsize)
      ])

      cetz.draw.content((325 * pxsize, -64 * pxsize), [
        #image("img/target.png", height: 136  * pxsize)
      ])
    })
  ]
]

#slide(background-image: none)[
  = Мультиплексоры в Linux

  #v(1cm)

  #place(center)[
    #box(width: 110%)[
      #table(
        columns: (33%,) * 3,
        stroke: (x, y) => {
          if x != 0 {
            (left: 3pt + gray)
          } else {
            none
          }
        },
        inset: (x, y) => {
          if y == 0 {
            (bottom: 10pt)
          } else {
            (top: 10pt, x: 15pt)
          }
        },
        align: left,
        [
          #set text(size: 30pt)
          #set align(center)
          #codebox(lang: "c", "select()")
        ],
        [
          #set text(size: 30pt)
          #set align(center)
          #codebox(lang: "c", "poll(...)")
        ],
        [
          #set text(size: 30pt)
          #set align(center)
          #codebox(lang: "c", "epoll")
        ],
        [
          - Самый старый мультиплексор в Linux;
          
          - Поддерживает до 1024 дескрипторов;

          - Требует перезаписывать маску наблюдаемых дескрипторов перед каждым вызовом.

          - Тормозит, если дескрипторов много;
        ],
        [
          - Поддерживает больше дескрипторов;

          - Позволяет отследить отключение клиента;

          - Даёт переиспользовать маску дескрипторов;

          - Всё ещё тормозит, если дескрипторов много.
        ],
        [
          - То же самое, что и #codebox(lang: "c", "poll()") , но позволяет получать список готовых к чтению/записи дескрипторов за $O(1)$;

          - Работает хорошо, но не кросс-платформенный.
        ]
      )
    ],
  ]

  #place(bottom + left, dx: -1cm)[
    #box(width: 33%)[
      #set align(center)
      #image("img/weak-doge.png", height: 2cm)
    ]
  ]

  #place(bottom + center)[
      #image("img/strong-doge-2.png", height: 3.3cm)
  ]

  #place(bottom + right, dx: 1cm)[
    #box(width: 33%)[
      #set align(center)
      #image("img/strong-doge.png", height: 4.5cm)
    ]
  ]
]

#slide(background-image: none)[
  = #codebox(lang: "c", "select(int n, fd_set *r, fd_set *w, fd_set *e, timeval *t)")

  *Блокируется до события на дескрипторах или до таймаута.*

  == #codebox(lang: "c", "int n")
  - Максимальное численное значение дескриптора + 1.
  - Ядро будет проверять дескрипторы от $0$ до $n - 1$.
  - Можно указать 1024, но вы замучаете ядро.

  == #codebox(lang: "c", "fd_set *readfds, *writefds, *exceptfds") `=`
  - Маски отслеживаемых дескрипторов: на чтение, на запись, и на ошибку.

  == #codebox(lang: "c", "timeval *timeout")
  - Максимальное время ожидания события.

  #lightcodebox("fd_set") - это структура, хранящая битовую маску. В ней есть место для 1024 битов, и это ограничение нельзя увеличить. Поэтому #codebox(lang: "c", "select()") не поддерживает дескрипторы с номером больше 1023.
]

#slide(background-image: none, background: none)[
  = Как использовать #codebox(lang: "c", "select()")
  #[
    #set text(weight: "bold")
    #code(numbers: true,
      ```c
      fd_set readfds;         // readfds - маска дескрипторов для чтения
      FD_ZERO(&readfds);
      FD_SET(sock1, &readfds);
      FD_SET(sock2, &readfds);
      // ... - Добавление остальных дескрипторов

      int result = select(MAX(sock1, sock2, ...) + 1, &readfds, NULL, NULL, NULL);
      if(result == -1) {
        // Ошибка
      } else if(result == 0) {
        // Таймаут
      } else {
        if(FD_ISSET(sock1, &readfds)) handle_data(sock1);
        if(FD_ISSET(sock2, &readfds)) handle_data(sock2);
        // ... - Проверка остальных дескрипторов
      }
      ```)
  ]
  #place(bottom, dy: -0.2cm)[
    _(Но лучше -- никак...)_
  ]
]

#slide(background-image: none)[
  = #codebox(lang: "c", "int poll(struct pollfd *fds, nfds_t nfds, int timeout)")

  *Блокируется до события на дескрипторах или до таймаута.*

  == #codebox(lang: "c", "struct pollfd *fds")
  - Указатель на массив структур #codebox(lang: "c", "pollfd"), описывающих дескрипторы и события, которые нужно отслеживать.

  == #codebox(lang: "c", "nfds_t nfds")
  - Количество элементов в массиве #codebox(lang: "c", "fds").

  == #codebox(lang: "c", "int timeout")
  - Максимальное время ожидания события в миллисекундах.
]

#slide(background-image: none)[
  = #codebox(lang: "c", "struct pollfd")

  *Структура, описывающая дескриптор и события, которые нужно отслеживать.*

  #let enum-table(elements) = {
    table(
      columns: 3,
      stroke: (x, y) => {
        if x == 1 {
          (right: 3pt + gray)
        } 
      },
      inset: (x, y) => {
        if x == 1 {
          (x: 10pt, y: 2pt)
        } else if x == 2 {
          (left: 10pt, y: 2pt)
        } else {
          (:)
        }
      },
      row-gutter: 7pt,
      ..elements.map(x => {
        ([`|=`], lightcodebox(x.at(0)), x.at(1))
      }).flatten()  
    )
  }

  == #codebox(lang: "c", "int fd")
  - Дескриптор.

  == #codebox(lang: "c", "short events") `=`
  #enum-table((
    ("POLLIN", [Событие "есть данные для чтения";]),
    ("POLLOUT", [Событие "можно записывать данные";]),
    ("POLLERR", [Событие "ошибка на дескрипторе";]),
    ("POLLHUP", [Событие "положили трубку".]),
  ))

  - Битовая маска событий, которые нужно отслеживать.

  == #codebox(lang: "c", "short revents")
  - В этом поле ядро указывает события, которые на самом деле произошли.
]

#slide(background-image: none, background: none)[
  = Как использовать #codebox(lang: "c", "poll()")
  #[
    #set text(weight: "bold")
    #code(numbers: true,
      ```c
      struct pollfd fds[2] = {};   // Массив структур pollfd
      fds[0].fd = sock1;
      fds[0].events = POLLIN;
      fds[1].fd = sock2;
      fds[1].events = POLLIN;
      // ... - Добавление остальных дескрипторов

      int result = poll(fds, 2, -1);
      if(result == -1) {
        // Ошибка
      } else if(result == 0) {
        // Таймаут
      } else {
        if(fds[0].revents & POLLIN) handle_data(sock1);
        if(fds[1].revents & POLLIN) handle_data(sock2);
        // ... - Проверка остальных дескрипторов
      }
      ```)
  ]
]


#focus-slide[
  #text(size: 30pt)[
    = Осторожно!
  ]

  == Сейчас будет куча скучных слайдов про #codebox("epoll")
]

#slide(background-image: none)[
  = #codebox(lang: "c", "int epoll_create(int size)")

  *Создаёт новый epoll-дескриптор.*

  == #codebox(lang: "c", "int size")
  - Устаревший параметр, который игнорируется в современных версиях ядра.
  - Рекомендуется использовать #codebox(lang: "c", "epoll_create1()") вместо этого.

  #line(length: 100%, stroke: 3pt + gray)

  = #codebox(lang: "c", "int epoll_create1(int flags)")
  *Создаёт новый epoll-дескриптор с флагами*

  == #codebox(lang: "c", "int flags")
  - Флаги для создания epoll-дескриптора.
  - Например, #codebox(lang: "c", "EPOLL_CLOEXEC") для автоматического закрытия при #codebox(lang: "c", "exec()").
]

#slide(background-image: none)[
  = #codebox(lang: "c", "int epoll_ctl(int epfd, int op, int fd, epoll_event *event)")

  *Управляет событиями, отслеживаемыми epoll-дескриптором.*

  == #codebox(lang: "c", "int epfd")
  - epoll-дескриптор, созданный с помощью #lightcodebox(lang: "c", "epoll_create()") или #lightcodebox(lang: "c", "epoll_create1()").

  == #codebox(lang: "c", "int op")
  - Операция, которую нужно выполнить.
  - Может быть #codebox(lang: "c", "EPOLL_CTL_ADD"), #codebox(lang: "c", "EPOLL_CTL_MOD"), или #codebox(lang: "c", "EPOLL_CTL_DEL").

  == #codebox(lang: "c", "int fd")
  - Дескриптор файла, для которого нужно управлять событиями.

  == #codebox(lang: "c", "struct epoll_event *event")
  - Указатель на структуру, описывающую события, которые нужно отслеживать.
]

#slide(background-image: none)[
  = #codebox(lang: "c", "struct epoll_event")

  *Структура, описывающая события, которые нужно отслеживать.*

  == #codebox(lang: "c", "uint32_t events")
  - Битовая маска событий, которые нужно отслеживать.

  #let enum-table(elements) = {
    table(
      columns: 3,
      stroke: (x, y) => {
        if x == 1 {
          (right: 3pt + gray)
        } 
      },
      inset: (x, y) => {
        if x == 1 {
          (x: 10pt, y: 2pt)
        } else if x == 2 {
          (left: 10pt, y: 2pt)
        } else {
          (:)
        }
      },
      row-gutter: 7pt,
      ..elements.map(x => {
        ([`|=`], lightcodebox(x.at(0)), x.at(1))
      }).flatten()  
    )
  }

  #enum-table((
    ("EPOLLIN", [Событие "есть данные для чтения";]),
    ("EPOLLOUT", [Событие "можно записывать данные";]),
    ("EPOLLERR", [Событие "ошибка на дескрипторе";]),
    ("EPOLLHUP", [Событие "положили трубку";]),
    ("EPOLLET", [Edge-Triggered режим. (Сработать при изменении состояния);]),
  ))

  == #codebox(lang: "c", "epoll_data_t data")
  - Пользовательские данные, связанные с дескриптором.
]

#slide(background-image: none)[
  = #codebox(lang: "c", "int epoll_wait(int epfd, epoll_event *events, int m, int t)")

  *Ожидает события на epoll-дескрипторе.*

  == #codebox(lang: "c", "int epfd")
  - epoll-дескриптор, созданный с помощью #lightcodebox(lang: "c", "epoll_create()") или #lightcodebox(lang: "c", "epoll_create1()").

  == #codebox(lang: "c", "struct epoll_event *events")
  - Указатель на массив, в который будут записаны произошедшие события.

  == #codebox(lang: "c", "int maxevents")
  - Максимальное количество событий, которые могут быть записаны в массив.

  == #codebox(lang: "c", "int timeout")
  - Таймаут ожидания события в миллисекундах. Если $-1$, то без таймаута.
]

#slide(background-image: none, background: none)[
  = Как использовать #codebox(lang: "c", "epoll")

  #[
    #set text(weight: "bold")
    #code(numbers: true,
      ```c
      int epfd = epoll_create1(0);
      if (epfd == -1) { /* Ошибка */ }

      struct epoll_event event { .events = EPOLLIN };
      event.data.fd = sock1;
      if (epoll_ctl(epfd, EPOLL_CTL_ADD, sock1, &event) == -1) { /* Ошибка */ }

      event.data.fd = sock2;
      if (epoll_ctl(epfd, EPOLL_CTL_ADD, sock2, &event) == -1) { /* Ошибка */ }
      // ... - Добавление остальных дескрипторов

      struct epoll_event events[MAX_EVENTS];
      int result = epoll_wait(epfd, events, MAX_EVENTS, -1);

      if (result == -1) { /* Ошибка */ }
      else for (int i = 0; i < result; i++)
          handle_data(events[i].data.fd);
      ```)
  ]
]

#slide(background-image: none)[
  = Ждём подключений и данные одновременно
  #v(1cm)
  - Если к вашему серверу кто-то пытается подключиться, мультиплексор сообщит об этом так, как будто на сокете есть данные для чтения.

  - Так можно одновременно ждать либо новые подключения, либо данные на существующих.
  #v(0.5cm)
  #align(center)[
    #box(inset: 20pt, width: 70%, radius: 10pt, stroke: 3pt + black, fill: white)[
      #set text(weight: "bold")
      #code(numbers: true,
        ```c
        // В случае с select():
        select(MAX_FD, &readfds, NULL, NULL, NULL);

        if(FD_ISSET(server_socket, &readfds)) {
          int new_connection = accept(server_socket);
          // ...
        }
        ```
      )
    ]
  ]
]

#slide(background-image: none)[
  = Как написать TCP-сервер с мультиплексингом

  #v(1cm)

  - Создать сокет, привязать его к порту. (#codebox(lang: "c", "socket()") , #codebox(lang: "c", "bind()"))
  - Перевести сокет в неблокирующий режим. (#codebox(lang: "c", "fcntl()") c флагом #lightcodebox(lang: "c", "O_NONBLOCK"))
  - Создать мультиплексор и добавить в него дескриптор сокета.
  - Вызвать #codebox(lang: "c", "listen()") на сокете, и начать слушать подключения.
  - *#codebox(lang: "c", "while(true):")*
    - Ожидать события на мультиплексоре.
    - Если событие на дескрипторе сокета, то доступно новое подключение. Нужно принять его (#codebox(lang: "c", "accept()")) и добавить в мультиплексор.
    - Если событие на дескрипторе подключения, то на нём появились данные, либо клиент отключился.
    - Если клиент отключился, то нужно закрыть соединение и удалить дескриптор из мультиплексора.
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