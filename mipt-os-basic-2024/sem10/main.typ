
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "../theme/theme.typ": *
#import "../theme/bubbles.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Сетевое взаимодействие

    АКОС, МФТИ

    14 ноября, 2024
  ]
]

#show: enable-handout

#slide[
  #place(center, dy: 1cm)[
    == Как организовать IPC между процессами на разных компьютерах?
  ]
  #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 0), [
        #scale(x: -100%)[
          #image("img/doscomputer.png", width: 13cm)
        ]
      ])

      cetz.draw.content((15, 0), [
        #scale(x: 100%)[
          #image("img/doscomputer.png", width: 13cm)
        ]
      ])

      cetz.draw.content((7.5, 2.5), [
        #set text(size: 50pt, weight: "bold")
        ?
      ])

      cetz.draw.line((5, 1), (10, 1), stroke: (
        thickness: 3pt,
        paint: black,
        dash: "dashed"
      ), mark: (end: ">"))

      cetz.draw.line((5, 0), (10, 0), stroke: (
        thickness: 3pt,
        paint: black,
        dash: "dashed"
      ), mark: (start: ">"))
    })
  ]
]

#slide(background-image: none)[
  
  #table(
    columns: (50%, 50%),
    rows: 100%,
    stroke: none,
    align: horizon,
  [
    #set align(left)
    = Если компьютера два:
    
    #v(0.5em)

    - Пустить провод между ними

    - Передавать биты с одинаковой задержкой

    = Проблемы:

    #set list(marker: none)

    #v(0.5em)

    - #con() Данные бьются;
    - #con() Можно опоздать с чтением;
    - #con() А что, если процессов много?
    - #con() А если компьютеров не два?

  ], [
    #cetz.canvas(length: 1cm, {
      cetz.draw.catmull(
        (0, 0),
        (4, 0),
        (4, -3),
        (2, -6),
        (5, -7),
        stroke: 3pt + black)

      cetz.draw.content((0, 0), [
        #scale(x: -100%)[
          #image("img/doscomputer.png", width: 8cm)
        ]
      ])

      cetz.draw.content((5, -7), [
        #scale(x: 100%)[
          #image("img/doscomputer.png", width: 8cm)
        ]
      ])
    })
  ])
]

#slide(background-image: none)[
  #table(
    columns: (45%, 55%),
    rows: 100%,
    stroke: none,
    align: horizon,
  [
    #cetz.canvas(length: 1cm, {
      for i in range(10) {
        let x = calc.cos(i * calc.pi * 2 / 10)
        let y = calc.sin(i * calc.pi * 2 / 10)

        x *= 4
        y *= 4

        cetz.draw.content((x, y), [
          #scale(x: if x > 0 {100%} else {-100%})[
            #image("img/doscomputer.png", width: 3cm)
          ]
        ])
      }

      cetz.draw.content((0, 0), [
        #set text(weight: "bold", size: 50pt)
        ?
      ])
    })
  ], [
    = Почему в жизни всё сложнее:

    - Компьютеров в интернете много, попарно всех не соединить;

    - Даже на одном компьютере может быть открыто много подключений;

    - Сообщения должны быть адресованными;

    - Кто угодно, подключенный к сети, может мониторить передаваемые данные;

    - Данные могут портиться и приходить в неправильном порядке.
  ])
]

#let osi(from: 0, to: 7) = {
  let colors = (
    green.lighten(50%),
    green.lighten(50%),
    green.lighten(50%),
    yellow.lighten(50%),
    orange.lighten(50%),
    orange.lighten(50%),
    red.lighten(50%),
  )

  let cell(i, content) = {
    let fill = colors.at(i)
    let stroke = black
    let text-color = black

    if(i < from or i >= to) {
      fill = fill.desaturate(100%).transparentize(40%)
      stroke = stroke.rgb().desaturate(100%).transparentize(40%)
      text-color = black.rgb().desaturate(100%).transparentize(40%)
    }

    box(width: 100%, height: 100%, radius: 10pt, fill: fill, stroke: 2pt + stroke)[
      #set text(weight: "semibold", fill: text-color)
      #content
    ]
  }

  table(
    columns: (10cm),
    rows: 2cm,
    inset: (x: 20pt),
    align: horizon + center,
    row-gutter: 0.1cm,
    stroke: none,
    cell(0, [Прикладной уровень]),
    cell(1, [Уровень представления]),
    cell(2, [Сеансовый уровень]),
    cell(3, [Транспортный уровень]),
    cell(4, [Сетевой уровень]),
    cell(5, [Канальный уровень]),
    cell(6, [Физический уровень]),
  )
}

#slide(background-image: none)[
  #place(left + horizon)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((0, 0), (10, -16), [])
      cetz.draw.line((5, -15.8), (5, 0), stroke: 3pt + black, mark: (end: ">"))
    })
  ]
  #place(left + horizon)[
    #osi()
  ]

  #place(horizon + right)[
    #set align(left)
    #box(width: 16cm, inset: 1cm)[
      = Модель OSI

      Или *Open Systems Interconnection model*

      - Она разбивает большую и сложную задачу сетевого взаимодействия на маленькие и простые уровни.

      - Или показывает, как можно собрать интернет из куска меди и смекалки.
    ]
  ]
]

#slide(background-image: none)[
  #place(left + horizon)[
    #osi(from: 4, to: 7)
  ]

  #place(left + horizon)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 3pt + gray)
      cetz.draw.content((0, -1), (28, -15.2), [])
      cetz.draw.line((11, -1), (11, -15.2))

      cetz.draw.content((12, -1), (28, -15), [
        == Физический уровень
        Среда, через которую передаются данные. Медный кабель, оптоволокно, радиоволны, звуковые волны, что угодно. К одному каналу может быть подключено больше двух устройств, как в случае с Wi-Fi.

        == Канальный уровень
        Передача данных внутри одной сети через физическую среду. На этом уровне происходит обнаружение и исправление ошибок, коллизий, и разбиение данных на фреймы. (Ethernet, ARP, ...)

        == Сетевой уровень
        Маршрутизация данных между разными сетями (IPv4, IPv6, ICMP, ...)
      ])
    })
  ]
]

#let mac(addr) = {
  h(0.15em)
  colbox(color: red.lighten(70%), stroke: 2pt + red, inset: (x: 0.4em, y: 0.4em), baseline: 0.4em, [
    #set text(weight: "bold", fill: black)
    #if type(addr) == str {
      raw(addr)
    } else {
      addr
    }
  ])
  h(0.15em)
}

#let ip(addr) = {
  h(0.15em)
  colbox(color: blue.lighten(70%), stroke: 2pt + blue, inset: (x: 0.4em, y: 0.4em), baseline: 0.4em, [
    #set text(weight: "bold", fill: black)
    #if type(addr) == str {
      raw(addr)
    } else {
      addr
    }
  ])
  h(0.15em)
}

#slide(background-image: none)[
  = Ethernet и #mac([MAC-адреса]) (Media Access Control address)

  - Ethernet - самый распространенный протокол канального уровня;
  - MAC-адрес - уникальный 6-байтный идентификатор сетевого интерфейса;
  - В Ethernet адресатами сообщений выступают MAC-адреса.

  #v(0.5cm)
  #align(center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 3pt + black)

      let addresses = ("1A", "2B", "3C", "4D", "5E")

      cetz.draw.content((10, 0.7), [*Коаксиальный кабель*])
      cetz.draw.line((-2, 0), (22, 0), mark: (start: "x", end: "x", length: 25pt))
      for i in range(3) {
        let x = i * 20 / 2
        cetz.draw.line((x, 0), (x, -2))
        cetz.draw.content((x, -3.5), [
          #image("img/doscomputer.png", width: 5cm)
        ])
        cetz.draw.circle((x, 0), radius: 5pt, fill: gray)
        cetz.draw.content((x, -1), [
          #mac("00:00:00:00:00:" + addresses.at(i))
        ])
      }

      cetz.draw.bezier((3, -4.2), (3.3, -5.7), (4, -4.5), name: "c1", stroke: none)
      cetz.draw.bezier((13, -4.2), (13.3, -5.7), (14, -4.5), name: "c2", stroke: none)
      cetz.draw.bezier((23, -4.2), (23.3, -5.7), (24, -4.5), name: "c3", stroke: none)

      draw-small-bubbles("c1", count: 3, radius-b: 0.6)
      draw-small-bubbles("c2", count: 3, radius-b: 0.6)
      draw-small-bubbles("c3", count: 3, radius-b: 0.6)
      draw-bubble(-3, -8, 6, 2, seed: 42)
      cetz.draw.content((0, -7), [
        *Привет, #mac("3С")!*
      ])

      draw-bubble(-3 + 10, -8, 6, 2, seed: 43)
      cetz.draw.content((10, -7), [
        *Это не мне*
      ])

      draw-bubble(-3 + 20, -8, 6, 2, seed: 59)
      cetz.draw.content((20, -7), [
        *Это мне!*
      ])
    })
  ]
]

#slide(background-image: none)[
  = Когда перестало хватать коаксиального кабеля
  
  - В игру вступил *коммутатор (switch)*;
  - У каждого устройства свой Ethernet-кабель к коммутатору.
  - Коммутатор пересылает сообщения по MAC-адресам;
  - Чаще всего коммутаторами выступают роутеры (маршрутизаторы) у вас дома.
  - Несмотря на слово "маршрут", это пока всё ещё канальный уровень.

  #align(center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 3pt + black)

      let addresses = ("1A", "2B", "3C", "4D", "5E")

      cetz.draw.line((0, 0.5), (8, 0.5))
      cetz.draw.line((12, 0.5), (20, 0.5))

      for i in range(3) {
        let x = i * 20 / 2
        cetz.draw.line((x, 0.5), (x, -2))
        cetz.draw.content((x, -3.5), [
          #image("img/doscomputer.png", width: 5cm)
        ])
        cetz.draw.content((x, -1), [
          #mac("00:00:00:00:00:" + addresses.at(i))
        ])
      }

      cetz.draw.bezier((3, -4.2), (3.3, -5.7), (4, -4.5), name: "c1", stroke: none)
      cetz.draw.bezier((13, -4.2), (13.3, -5.7), (14, -4.5), name: "c2", stroke: none)
      cetz.draw.bezier((23, -4.2), (23.3, -5.7), (24, -4.5), name: "c3", stroke: none)

      draw-small-bubbles("c1", count: 3, radius-b: 0.6)
      draw-small-bubbles("c2", count: 3, radius-b: 0.6)
      draw-small-bubbles("c3", count: 3, radius-b: 0.6)
      draw-bubble(-3, -8, 6, 2, seed: 42)
      cetz.draw.content((0, -7), [
        *Привет, #mac("3С")!*
      ])

      draw-bubble(-3 + 10, -8, 6, 2, seed: 67)
      cetz.draw.content((-3 + 10, -6), (rel: (6, -2)), [
        #set align(horizon + center)
        #box(inset: 10pt)[
          *Я даже ничего не услышал...*
        ]
      ])

      draw-bubble(-3 + 20, -8, 6, 2, seed: 59)
      cetz.draw.content((20, -7), [
        *Это мне!*
      ])

      cetz.draw.content((10, 0.5), [
        #box(inset: 13pt, fill: white, stroke: black + 3pt, radius: 10pt)[
          *Коммутатор*
        ]
      ])
    })
  ]
]

#slide(background-image: none)[
  = Почему мало одних MAC-адресов?

  #v(1cm)
  #table(
    columns: (40%, 1fr),
    stroke: (x, y) => {
      if x == 0 {
        return (right: 3pt + gray)  
      } else {
        return none
      }
    },
    inset: (x, y) => {
      if x == 0 {
        return (right: 20pt, top: 10pt)
      } else {
        return (left: 30pt, top: 10pt)
      }
    },
    [
    #set align(left)
    - Они закреплены за устройствами. По ним можно понять производителя и иногда модель устройства;

    - В локальных сетях это приемлемо, но если весь интернет знает ваш MAC-адрес, это не очень хорошо;

    - Даже в локальных сетях современные устройства используют случайные MAC-адреса, чтобы не светить свой настоящий.
  ], [
    В глобально-администрируемых адресах седьмой старший бит всегда `0`, а первые 3 байта - OUI-код производителя.

    #cetz.canvas(length: 1cm, {
      // cetz.draw.content((0, 0), (15, -3), [])
      cetz.draw.content((4, 0), (11, -2), [
        #set align(center)
        #set text(weight: "bold", size: 30pt)
        `14:F2:87:FA:FA:FA`
      ])
      cetz.draw.set-style(stroke: 3pt + black)
      cetz.draw.line((3.2, -0.8), (rel: (0, -0.2)), (7.2, -1), (rel: (0, 0.2)))
      cetz.draw.line((4, -1), (4, -2), (rel: (0.2, 0)))
      cetz.draw.content((4.5, -1.5), (rel: (12, -1)))[
        #set align(horizon)
        OUI-код производителя *Apple Inc.*
      ]
    })

    Случайные (локально администрируемые) адреса почти всегда имеют седьмой бит `1`.

    #cetz.canvas(length: 1cm, {
      // cetz.draw.content((0, 0), (15, -3), [])
      cetz.draw.content((4, 0), (11, -2), [
        #set align(center)
        #set text(weight: "bold", size: 30pt)
        `DA:D8:5C:76:C5:30`
      ])
      cetz.draw.set-style(stroke: 3pt + black)
      cetz.draw.line((3.2, -0.8), (rel: (0, -0.2)), (4.2, -1), (rel: (0, 0.2)))
      cetz.draw.line((3.7, -1), (3.7, -2), (rel: (0.2, 0)))
      cetz.draw.content((4.2, -1.5), (rel: (10, -1)))[
        #set align(horizon)
        `110110`*`1`*`0` в двоичной записи.
      ]
    })
  ])
]

#slide(background-image: none)[
  = #ip([IP-адрес]) (Internet Protocol address)

  - Адрес узла в сети. Используется на сетевом уровне.
  - Предназначение IP-адреса - идентифицировать не устройство, а узел сети.
  - IP-адрес не раскрывает производителя устройства.
  - Можно заменить устройство и оставить прежний IP-адрес.

  #v(0.5cm)

  #table(
    columns: (50%, 50%),
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    inset: (left: 30pt, y: 10pt),
    [
      #align(center)[
        == IPv4
      ]
    ], [
      #align(center)[
        == IPv6
      ]
    ], [
      #align(center)[
        #ip("192.168.10.10")
      ]
    ], [
      #align(center)[
        #ip("fe80:0:0:0:200:f8ff:fe21:67cf")
      ]
    ], [
      #set text(style: "italic")
      - 32 бита
      - 4.3 млрд адресов
      - Уже не хватает
    ], [
      #set text(style: "italic")
      - 128 бит
      - 340 ундециллионов адресов ( $ dot 10^36$)
      - Пока хватает
    ]
  )

  #v(0.5cm)

  - IP -- протокол маршрутизации.
]

#slide(background-image: none)[
  = ARP (Address Resolution Protocol)
 
  Протокол канального уровня, позволяющий получить MAC-адрес устройства по его IP-адресу.

  #align(center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 3pt + black)

      let addresses = ("1A", "2B", "3C", "4D", "5E")

      cetz.draw.line((0, 1.5), (8, 1.5))
      cetz.draw.line((12, 1.5), (20, 1.5))

      for i in range(3) {
        let x = i * 20 / 2
        cetz.draw.line((x, 1.5), (x, -2))
        cetz.draw.content((x, -3.5), [
          #image("img/doscomputer.png", width: 5cm)
        ])
        cetz.draw.content((x, 0), [
          #ip("192.168.0." + str(i))
        ])
        cetz.draw.content((x, -1.2), [
          #mac("00:00:00:00:00:" + addresses.at(i))
        ])
      }

      cetz.draw.bezier((3, -4.2), (3.3, -5.7), (4, -4.5), name: "c1", stroke: none)
      cetz.draw.bezier((13, -4.2), (13.3, -5.7), (14, -4.5), name: "c2", stroke: none)
      cetz.draw.bezier((23, -4.2), (24.3, -5.7), (24, -4.5), name: "c3", stroke: none)

      draw-small-bubbles("c1", count: 3, radius-b: 0.6)
      draw-small-bubbles("c2", count: 3, radius-b: 0.6)
      draw-small-bubbles("c3", count: 3, radius-b: 0.6)
      draw-bubble(-3, -9, 6, 3, seed: 42)
      cetz.draw.content((-3, -6), (rel: (6, -3)), [
        #set align(horizon + center)
        #box(inset: 10pt)[
          *Кто здесь* #ip("192.168.0.2")
        ]
      ])

      draw-bubble(-3 + 10, -9, 6, 3, seed: 67)
      cetz.draw.content((-3 + 10, -6), (rel: (6, -3)), [
        #set align(horizon + center)
        *Это не я*
      ])

      draw-bubble(-4 + 20, -9, 8, 3, seed: 59)
      cetz.draw.content((-4 + 20, -6), (rel: (8, -3)), [
        #set align(horizon + center)
        #box(inset: 10pt)[
          *Это я, мой MAC:* #mac("00:00:00:00:00:3C")
        ]
      ])

      cetz.draw.content((10, 1.5), [
        #box(inset: 13pt, fill: white, stroke: black + 3pt, radius: 10pt)[
          *Коммутатор*
        ]
      ])
    })
  ]
]

#slide(background-image: none)[
  #place(left + horizon)[
    #osi(from: 0, to: 4)
  ]

  #place(left + horizon)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 3pt + gray)
      cetz.draw.content((0, -1), (28, -15.2), [])
      cetz.draw.line((11, -1), (11, -15.2))

      cetz.draw.content((12, -1), (28, -15), [
        == Транспортный уровень
        Обеспечение нужного уровня надёжности и гарантий передачи данных. (TCP, UDP, SCTP, ...)

        == Сеансовый уровень
        Установление, поддержание и закрытие сеанса связи. (RPC, SOCKS)

        == Уровень представления
        Преобразование двоичных данных в нужный формат. Например, перекодировка текста в байты.

        == Прикладной уровень
        Приложения, которые используют сеть. Например, браузеры (HTTP), почтовые клиенты (POP3, IMAP, SMTP), мессенджеры.
      ])
    })
  ]
]

#slide(background-image: none)[
  #place(horizon + center, dy: -1cm)[
    #align(center)[
      = Транспортные протоколы 
    ]
    #v(1cm)

    #set align(left)
    #table(
      columns: (50%, 50%),
      stroke: (x, y) => {
        if x == 0 {
          (right: 3pt + gray)
        } else {
          none
        }
      },
      align: top,
      inset: (x: 30pt, y: 10pt),
      [
        *TCP (Transmission Control Protocol)*

        - Надёжно передаёт данные;

        - Подтверждает получение;

        - Гарантирует порядок получения;

        - Подтормаживает.
      ], [
        *UDP (User Datagram Protocol)*

        - Сообщения могут теряться;

        - Сообщения могут перемешаться;

        - Сообщения могут дублироваться;

        - Но доходят быстро.
      ]
    )
  ]

  #place(center + bottom)[
    _Я бы рассказал вам шутку про UDP, но боюсь, что она до вас не дойдёт._
  ]
]

#let col_a(content) = text(fill: rgb("38761d"), content)
#let col_b(content) = text(fill: rgb("990000"), content)
#let col_c(content) = text(fill: rgb("1155cc"), content)
#let col_header(content) = text(fill: rgb("bf9000"), content)
#let col_value(content) = text(fill: rgb("009688"), content)
#let col_empty(content) = text(fill: luma(100), content)

#slide(background-image: none)[
  = HTTP (HyperText Transfer Protocol)

  - Протокол прикладного уровня;
  - Используется веб-серверами и браузерами для загрузки веб-страниц;
  - Строится поверх TCP;
  - Работает по принципу "запрос-ответ".
  - Не шифрует данные;

  #place(bottom + center, dy: -1cm)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 4pt + black)

      cetz.draw.content((0, 0), (27, 0), [])

      cetz.draw.content((3, -3), [
        #set align(center)
        #scale(x: -100%)[
          #image("img/doscomputer.png", height: 6cm)
        ]
        *Ваш компьютер*
      ])

      cetz.draw.content((22, -3), [
        #set align(center)
        #image("img/server.png", height: 6cm)
        *HTTP-сервер*
      ])

      cetz.draw.line((6.5, -1), (rel: (12, 0)), mark: (end: ">"))
      cetz.draw.line((6.5, -3), (rel: (12, 0)), mark: (start: ">"))

      cetz.draw.content((12.5, -1), [
        #box(width: 10cm, stroke: 3pt + black, fill: white, inset: 15pt, radius: 10pt)[
          #set align(center)
          #set text(font: "Courier New", size: 18pt, weight: "bold")
          #col_a("GET") #col_b("/index.htm") #col_c("HTTP/1.1")
        ]
      ])

      cetz.draw.content((12.5, -3), [
        #box(width: 10cm, stroke: 3pt + black, fill: white, inset: 15pt, radius: 10pt)[
          #set align(center)
          #set text(font: "Courier New", size: 18pt, weight: "bold")
          #col_c("HTTP/1.1") #col_a("200") #col_b("OK") ...
        ]
      ])

      cetz.draw.content((12.5, 0.5), [
        *Запрос*
      ])

      cetz.draw.content((12.5, -4.5), [
        *Ответ*
      ])
    })
  ]
]

#slide(background-image: none)[
  #table(
    columns: (50%, 50%),
    stroke: (x, y) => {
      if x == 1 {
        (left: 3pt + gray)
      } else {
        none
      }
    },
    inset: (x: 20pt, y: 10pt),
    table.cell(colspan: 2)[
      #box(inset: (y: 10pt))[
        = Протокол HTTP:
      ]
    ],
    [
      // #set align(center)
      *Запрос:*
    ],
    [
      // #set align(center)
      *Ответ:*
    ], [
      #set block(spacing: 10pt)
      #set text(font: "Courier New", size: 18pt, weight: "bold")
      #col_a("Метод") #col_b("URI") #col_c("HTTP/Версия")

      #col_header("Заголовок:") #col_value("Значение заголовка")

      #col_empty("(empty line)")

    ], [
      #set block(spacing: 10pt)
      #set text(font: "Courier New", size: 18pt, weight: "bold")

      #col_c("HTTP/Версия") #col_a("Код ответа") #col_b("Пояснение")

      #col_header("Заголовок:") #col_value("Значение заголовка")
      
      #col_empty("(empty line)")

      #col_empty("(response body)")
    ],
    table.cell(colspan: 2)[
      #box(inset: (y: 10pt))[
        = Пример:
      ]
    ],[
      // #set align(center)
      *Запрос:*
    ],[
      // #set align(center)
      *Ответ:*
    ],[
      #set block(spacing: 10pt)
      #set text(font: "Courier New", size: 18pt, weight: "bold")
      #col_a("GET") #col_b("/index.html") #col_c("HTTP/1.1")

      #col_header("Cookie:") #col_value("session=15")

      #col_empty("(empty line)")
    ], [
      #set block(spacing: 10pt)
      #set text(font: "Courier New", size: 18pt, weight: "bold")

      #col_c("HTTP/1.1") #col_a("200") #col_b("OK")
      
      #col_header("Content-Type:") #col_value("text/html")

      #col_header("Set-Cookie:") #col_value("session=16")

      #col_empty("(empty line)")

      #col_empty("<h1>Hello, World!</h1>")
    ]
  )

  #place(bottom + left, dy: -0.5cm, dx: 0.5cm)[
    *#link("http.cat")[🔗 http.cat]*
  ]
]

#slide(header: [Сокеты], background-image: none)[
  *Сокет* - двусторонний канал, который можно пустить через интернет.

  Сокеты имеют значительно больше настроек, чем обычные каналы. Они могут отправлять данные через TCP, UDP и кучу других протоколов.  Взаимодействие с сетью на низком уровне происходит с помощью сокетов.

  #place(center + bottom, dy: 0.5cm)[
    #cetz.canvas(length: 1cm, {
      let pxsize = 0.15cm

      let draw-ground(from, to) = {
        cetz.draw.content(
          (from.at(0) * pxsize * 16, from.at(1) * pxsize * 16),
          (to.at(0) * pxsize * 16, to.at(1) * pxsize * 16))[
          #let pat = pattern(size: (16 * pxsize, 16 * pxsize))[
            #place(image("img/ground.png"))
          ]
          #box(width: 100%, height: 100%, fill: pat)
        ]
      }
      
      cetz.draw.content((-89 * pxsize, 0))[
        #scale(x: 100%)[
          #image("img/runningmario2.png", height: 16 * pxsize)
        ]
      ]
      cetz.draw.content((-59 * pxsize, 0))[
        #image("img/halfpipe.png", height: 25 * pxsize)
      ]

      cetz.draw.content((88 * pxsize, -2 * pxsize))[
        #scale(x: -100%)[
          #image("img/runningmario2.png", height: 16 * pxsize)
        ]
      ]
      cetz.draw.content((58 * pxsize, 0))[
        #scale(x: -100%)[
          #image("img/halfpipe.png", height: 25 * pxsize)
        ]
      ]
    
      draw-ground((-7, -1), (7, 0))
      draw-ground((-2, 1), (2, -1))
      draw-ground((-2, 2), (2, 0))

      draw-ground((-3, 1), (-2, -1))
      draw-ground((-4, 0), (-3, -1))

      draw-ground((2, 1), (1, -1))
      draw-ground((3, 0), (2, -1))

      cetz.draw.content((0, -3 * pxsize))[
        #image("img/mario-internet.png", height: 48 * pxsize)
      ]

      cetz.draw.content((0, -3 * pxsize))[
        #image("img/globe.png", height: 32 * pxsize)
      ]
    })
  ]
]

#slide(background-image: none)[
  = #codebox(lang: "c", "socket(int domain, int type, int protocol)")

  *Создаёт сокет.*

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
        ([`=`], lightcodebox(x.at(0)), x.at(1))
      }).flatten()  
    )
  }

  == #codebox(lang: "c", "int domain") `=`
  #enum-table((
    ("AF_UNIX", [Локальный сокет (Unix-сокет). Живёт по пути в файловой системе.]),
    ("AF_INET", [IPv4-сокет, подключаемый по IPv4-адресу.]),
    ("AF_INET6", [IPv6-сокет, подключаемый по IPv6-адресу.]),
  ))

  == #codebox(lang: "c", "int type") `=`
  #enum-table((
    ("SOCK_STREAM", "Последовательное надёжное двусторонее соединение (обычно TCP)"),
    ("SOCK_DGRAM", "Ненадёжная отправка датаграм (обычно UDP)"),
    ("SOCK_RAW", "Работа с сетевым интерфейсом почти напрямую, без TCP / IP / UDP."),
  ))

  == #codebox(lang: "c", "int protocol")
  Выбор конкретного протокола. Чаще всего здесь 0, и ядро справляется с этим само.
]

#slide[
  = #codebox(lang: "c", "socketpair(int domain, int type, int protocol, int sv[2]);")

  *Создаёт пару связанных сокетов.*

  - Работает так же, как #codebox(lang: "c", "pipe()"), но создаёт *двунаправленный* канал;

  - Позволяет передавать дескрипторы между процессами;

  - В отличие от каналов, не подвержен проблеме блокировки #lightcodebox("read") при наследовании дескриптора.

  - #codebox(lang: "c", "socketpair(...)") эквивалентен созданию Unix-сокетов через #codebox(lang: "c", "socket(AF_UNIX, ...)").
]

#slide(background-image: none, background: white)[
  = Пишем TCP-клиент

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
      - После создания сокета нужно вызвать #codebox(lang: "c", "connect(...)"), чтобы подключиться к серверу.

      - Если подключение успешно, можно начинать общаться с сервером функциями #codebox(lang: "c", "read(...)") и #codebox(lang: "c", "write(...)").

      - Когда вы всё отправили, нужно вызвать #codebox(lang: "c", "shutdown(sock, SHUT_WR)"). Так вы скажете серверу, что вы закончили отправлять данные.

      - После #codebox(lang: "c", "shutdown(...)") можно закрывать сокет через #codebox(lang: "c", "close(sock)").
    ], [
      #set text(weight: "bold")
      #code(numbers: true, 
      ```c
      // Создание сокета
      sock = socket(AF_INET, SOCK_STREAM, 0);

      // Подключение сокета к ip-адресу
      connect(sock, (...*)addr, sizeof(addr));

      // Работа с сокетом
      read(sock, ...);
      write(sock, ...);

      // Закрытие подключения
      shutdown(sock, SHUT_WR); // На запись
      shutdown(sock, SHUT_RD); // На чтение

      // Закрытие сокета
      close(sock);
      ```)
    ])
]

#slide(background-image: none, background: white)[
  = #codebox(lang: "c", "connect(int socket, sockaddr *address, socklen_t len)")

  #table(
    columns: (48%, 60%),
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
      - Подключает сокет к серверу.

      - Второй аргумент - структура, содержащая адрес сервера и порт.

      - Чтобы получить адрес хоста, можно использовать функцию #codebox(lang: "c", "gethostbyname(\"google.com\")") или #codebox(lang: "c", "inet_addr(\"142.250.74.46\")").

      - При заполнении полей структуры не забудьте преобразовать их в сетевой порядок байт (обычно с помощью #codebox(lang: "c", "htons(...)")).
    ], [
      #set text(weight: "bold")
      #code(numbers: true, 
      ```c
      // ...

      struct hostent *host = NULL;

      host = gethostbyname(hostname);

      struct sockaddr_in address = {};
      address.sin_family = AF_INET;
      address.sin_port = htons(port);
      address.sin_addr = *(...*)host->h_addr;

      // Подключение сокета к ip-адресу
      connect(sock, (...*)&addr, sizeof(addr));

      // ...
      ```)
    ]
  )
]

#slide(background-image: none, background: white)[
  = Пишем TCP-сервер

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
      - Создаём сокет, как и в клиенте;

      - Связываем сокет с адресом сервера через #codebox(lang: "c", "bind(...)");

      - Переводим сокет в режим сервера через #codebox(lang: "c", "listen(...)");

      - Принимаем подключения через #codebox(lang: "c", "accept(...)");

      - После общения с клиентом закрываем соединение через #codebox(lang: "c", "shutdown(...)") и #codebox(lang: "c", "close(...)").
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