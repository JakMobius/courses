
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4"
#import "../theme/theme.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Песочницы

    АКОС, МФТИ

    12 декабря, 2024
  ]
]

#show: enable-handout

#slide(background-image: none)[
  == #codebox(lang: "c", "prctl(PR_SET_SECCOMP, /* ... */)")
  
  #v(0.5cm)

  - Устанавливает настройки #codebox("seccomp") -- модуля Linux, позволяющего ограничивать доступ к системным вызовам.

  #v(0.5cm)

  == #codebox(lang: "c", "prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT)")

  #v(0.5cm)

  - Включает для текущего процесса режим seccomp, разрешающий только 4 системных вызова:

  #align(center)[
    #set text(size: 23pt, weight: "semibold")
    #table(
      row-gutter: 0cm,
      inset: 0cm,
      column-gutter: 0.5cm,
      columns: 4,
      stroke: none,
      codebox(lang: "c", "read(...)"),
      codebox(lang: "c", "write(...)"),
      codebox(lang: "c", "exit(...)"),
      codebox(lang: "c", "sigreturn(...)"),
    )
  ]

  - Любой другой системный вызов убьёт процесс через #lightcodebox("SIGKILL").

  - После включения #lightcodebox("SECCOMP_MODE_STRICT") нельзя отключить.
]

#slide(background: none, background-image: none)[
  #place(horizon + center)[
    #image("img/meme-background.jpg", width: 120%, height: 120%)
  ]
  #align(center)[
    #set text(size: 40pt, font: "Impact", stroke: 2pt + black, fill: white)
    А СЕЙЧАС МЫ БУДЕМ

    #v(1cm)

    #image("img/tape.png", height: 6cm)

    #v(1cm)

    ИЗОЛИРОВАТЬ КОД!
  ]
]

#slide(place-location: horizon + center)[
  #box(width: 20cm)[
    #set align(left)
    = Практичность #codebox("SECCOMP_MODE_STRICT") 
    
    #v(1cm)

    - Нельзя сделать #codebox("exec") -- он заблокирован;

    - Исполнять чужой код можно только вручную замаппив его в память;

    - Нельзя расширить перечень разрешенных системных вызовов;

    - *В общем, шляпа.* Поэтому 7 лет никто им не пользовался.
  ]
]

#slide[
  #place(horizon + center, dy: -2cm)[
    == Через 7 лет люди озадачились перехватом трафика
  ]
  #align(horizon + center)[
    #set text(size: 30pt)
    #codebox(lang: "bash", "sudo tcpdump")
  ]
]

#slide[
  #place(horizon + center, dy: -2cm)[
    == Трафика бывает очень много, его надо фильтровать
  ]
  #align(horizon + center)[
    #set text(size: 25pt)
    #codebox(lang: "bash", "sudo tcpdump dst 142.250.74.46")
  ]
  #place(horizon + center, dy: 2cm)[
    (Эта команда покажет только пакеты, адресованные серверу Google)
  ]
]

#slide[
  #place(horizon + center, dy: -2cm)[
    #box(width: 20cm)[
      #align(center)[
        = Проблема
      ]
      #set align(left)

      #v(1cm)

      - Пакетов может быть по-настоящему очень много. Вспомним DPDK, который отправляет пакет за 80 тактов.

      - Даже если фильтровать их быстро, передача пакета в userspace и обратно -- уже минимум тысяча тактов.
    ]
  ]
  
  #place(bottom + center, dy: -4cm)[
    #uncover((beginning: 2))[
      = Решение - BPF!
    ]
  ]
]

#slide(background-image: none)[
  = #codebox(lang: "c", "setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, filter, size)")

  - *Устаналивает BPF-фильтр на сокете*;

  - BPF (Berkeley Packet Filter) -- это байт-код, который исполняется в пространстве ядра;

  - Программа на BPF может отфильтровать пакет до его доставки в userspace.

  #uncover((beginning: 2))[
    = #codebox(lang: "c", "prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT)")

    - *Устанавливает BPF-фильтр на системные вызовы.*

    - Позволяет задавать сложные правила фильтрации;

    - Может взаимодействовать с #codebox(lang: "c", "ptrace()");

    - Позволяет блокировать, трассировать или модифицировать системные вызовы.
  ]
]

// Презентация не закончена, конец семестра, времени нет :(

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