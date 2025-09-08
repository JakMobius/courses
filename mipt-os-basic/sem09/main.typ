
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4"
#import "../theme/theme.typ": *
#import "utils.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Межпроцессное взаимодействие

    АКОС, МФТИ

    07 ноября, 2024
  ]
]

#show: enable-handout

#slide(background-image: none)[
  #align(center)[
    #set text(weight: "bold", size: 30pt)
    Зачем передавать данные между процессами?
  ]

  #place(horizon + center, dy: 1cm)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((-11, 0), (11, 0), [])

      let spread = 5cm

      cetz.draw.content((-spread - 5cm, 0), (rel: (5, 5)), [
        #let size = 5cm
        #let stroke-width = 4pt
        // Icons and names usage guidelines require clear space around the logo to be at least 25% of the logo size itself, adding in total 50% to the image size.
        // As 50% / 150% is 1/3, the image should cover at most 2/3 of the container space.
        // See https://code.visualstudio.com/brand

        #box(width: 100%, height: 100%, fill: white, radius: 10pt, stroke: stroke-width + gray)[
          #set align(horizon + center)
          #image("img/vscode.svg", width: (size - stroke-width) * 2/3)
        ]
      ])

      cetz.draw.content((spread, 0), (rel: (8, 5)), [
        #box(width: 100%, height: 100%, fill: white,  radius: 10pt, stroke: 4pt + gray)[
          #set align(center + horizon)
          #set text(size: 50pt, weight: "semibold")
          #raw("clangd")
        ]
      ])

      cetz.draw.content((-spread - 5cm, 0), (rel: (5, 5)))[
        #place(center + top, dy: -1cm)[
          *Ваша IDE*
        ]
      ]

      cetz.draw.content((spread, 0), (rel: (8, 5)))[
        #place(center + top, dy: -1cm)[
          *Language Server*
        ]
      ]

      let arrow-len = 4.5
      let arrow-y1 = -1
      let arrow-y2 = -4
      let arrow-curveness = 0.0
      let arrow-stroke-width = 6pt
      let stoke-width = 3pt

      cetz.draw.bezier((-arrow-len, arrow-y1), (arrow-len, arrow-y1), (0, arrow-y1 + arrow-curveness), stroke: arrow-stroke-width + black, mark: (end: ">", length: 10pt, width: 10pt, fill: black))

      cetz.draw.bezier((arrow-len, arrow-y2), (-arrow-len, arrow-y2), (0, arrow-y2 - arrow-curveness), stroke: arrow-stroke-width + black, mark: (end: ">", length: 10pt, width: 10pt, fill: black))

      let vscodebox(lang: none, code) = {
        set text(weight: "bold")
        box(fill: white, inset: 15pt, baseline: 15pt, radius: 10pt, stroke: stoke-width + black)[
          #raw(code, lang: lang)
        ]
      }

      let code-displacement-y = 0
      let code-displacement-x = 0.3

      cetz.draw.content((-code-displacement-x, arrow-y1 - code-displacement-y), [
        #set text(size: 22pt)
        #vscodebox("itn x = fib(3);")
      ])

      cetz.draw.content((code-displacement-x, arrow-y2 + code-displacement-y), [
        #set text(size: 22pt)
        #vscodebox(lang: "c", "itn x = fib(3);")
      ])

      cetz.draw.content((-code-displacement-x - 5, 0), (rel: (10, -2)))[
        #place(center + top, dy: -1cm)[
          *Сырой текст*
        ]
      ]

      cetz.draw.content((code-displacement-x - 5, -6.5), (rel: (10, -2)))[
        #place(center + top, dy: -1cm)[
          #box[
            #set align(left)
            - *Подсветка кода*;
            - *Выделение ошибок*;
            - *Автодополнение*;
            - *...*
          ]
        ]
      ]

      tilde-line(-2.8 + code-displacement-x, arrow-y2 - code-displacement-y - 0.45, 3);
    })
  ]

  #place(center + bottom)[
    *Например, чтобы подсвечивать код в IDE.* Хотя это встречается везде.
  ]
]

#slide(background-image: none, background: white)[
  = Можно общаться через файл:
  #v(0.5cm)

  #table(
    columns: (50%, 50%),
    stroke: none,
    align: horizon,
    inset: (right: 20pt, left: 18pt),
    [
      #set text(weight: "bold")
      #code(numbers: true,
      ```c
      int send(const char* msg) {
        int len = strlen(msg);
        return write(file, msg, len);
      }
      ```
      )
    ],[
      #set text(weight: "bold")
      #code(numbers: true,
      ```c
      void receive(char* buf, int len) {
        int res = 0;
        while(true) {
          res = read(file, buf, len);
          if (res != 0) break;
          sleep(1);
        }
        return res;
      }
      ```
      )
    ]
  )
  #set text(size: 22pt)
  #table(
    stroke: none, 
    columns: (50%, 50%),
    align: center,
    [*Отправка сообщения*],
    [*Приём сообщения*]
  )

  #place(bottom, dy: -0.5cm)[
    #set text(size: 22pt)
    #colbox(color: blue, inset: (x: 13pt, y: 10pt))[Вопрос] #h(0.3em) Чем плох такой подход?
  ]
]

#slide[
  #place(center + horizon)[
    = Проблемы передачи данных через файл:
    #v(1cm)

    #box(width: 20cm)[
      #set align(left)
      #table(
        columns: 2,
        stroke: none,
        inset: (x, y) => {
          if x == 0 { (x: 2pt, y: 2pt) }
          else { (x: 5pt, y: 12pt) }
        },
        align: top + left,
        con(), [Поллинг *добавляет задержку* и *нагружает CPU*.],
        con(), [Реализовать без поллинга *сложно* (нужен *#raw("inotify")*).],
        con(), [Задействуем файловую систему -- *медленно*.],
        con(), [На скорость передачи будет влиять скорость диска, но даже с быстрым SSD это будет *медленно*.]
      )
    ]
  ]
]

#slide(background-image: none)[
  #set align(horizon)
  #table(
    columns: (60%, 1fr),
    align: horizon + center,
    stroke: none,
  [
    #cetz.canvas(length: 1cm, {
      let scheme-box(fill: none, stroke: black, content) = {
        box(
          width: 100%, 
          height: 100%, 
          fill: fill,
          stroke: 3pt + stroke, 
          radius: 10pt, 
          inset: 5pt, [
          #set align(horizon + center)
          #content
        ])
      }

      let softblue = cell-color(blue).background-color
      let bluestroke = cell-color(blue).stroke-color

      let softred = cell-color(red).background-color
      let redstroke = cell-color(red).stroke-color

      let rowsize = 3
      let colsize = 4
      let gutter-x = 3
      let gutter-y = 2

      cetz.draw.content((-1, 0.5), (colsize * 2 + gutter-x + 1, -rowsize - 1.7), [
        #let pat = tiling(size: (20pt, 20pt))[
          #let stroke = 6pt + red.transparentize(70%)
          #place(line(stroke: stroke, start: (0%, 0%), end: (100%, 100%)))
          #place(line(stroke: stroke, start: (-100%, 0%), end: (100%, 200%)))
          #place(line(stroke: stroke, start: (0%, -100%), end: (200%, 100%)))
        ]
        #box(width: 100%, height: 100%, fill: pat)
      ])

      cetz.draw.content((0, 0), (rel: (colsize * 2 + gutter-x, -rowsize)), [
        #scheme-box(fill: gray, stroke: black)[
          #set text(size: 30pt, weight: "bold")
          Диск
        ]
      ], name: "disk")

      cetz.draw.content((0, -rowsize - gutter-y), (rel: (colsize, -rowsize)), [
        #scheme-box(fill: softred, stroke: redstroke)[
          #set text(size: 30pt, weight: "bold")
          ОЗУ
        ]
      ], name: "ram1")

      cetz.draw.content((colsize + gutter-x, -rowsize - gutter-y), (rel: (colsize, -rowsize)), [
        #scheme-box(fill: softred, stroke: redstroke)[
          #set text(size: 30pt, weight: "bold")
          ОЗУ
        ]
      ], name: "ram2")

      cetz.draw.content((0, -rowsize * 2 - gutter-y * 2), (rel: (colsize, -rowsize)), [
        #scheme-box(fill: softblue, stroke: bluestroke)[
          #text(size: 35pt, weight: "black")[A]
        ]
      ], name: "proc1")

      cetz.draw.content((colsize + gutter-x, -rowsize * 2 - gutter-y * 2), (rel: (colsize, -rowsize)), [
        #scheme-box(fill: softblue, stroke: bluestroke)[
          #text(size: 35pt, weight: "black")[B]
        ]
      ], name: "proc2")

      cetz.draw.line(
        ("proc1.north", 20%, "ram1.south"),
        ("proc1.north", 80%, "ram1.south"),
        stroke: 7pt + black,
         mark: (end: ">"))

      cetz.draw.line(
        ("ram1.north", 20%, (rel: (0, gutter-y))),
        ("ram1.north", 80%, (rel: (0, gutter-y))),
        stroke: 7pt + black.lighten(40%),
         mark: (end: ">"))

      cetz.draw.line(
        ("ram2.north", 20%, (rel: (0, gutter-y))),
        ("ram2.north", 80%, (rel: (0, gutter-y))),
        stroke: 7pt + black.lighten(40%),
         mark: (start: ">"))

      cetz.draw.line(
        ("proc2.north", 20%, "ram2.south"),
        ("proc2.north", 80%, "ram2.south"),
        stroke: 7pt + black,
         mark: (start: ">"))

      cetz.draw.line(
        ("ram1.east", 20%, "ram2.west"),
        ("ram1.east", 80%, "ram2.west"),
        stroke: 7pt + black,
         mark: (end: ">"))

      cetz.draw.line(
        (colsize * 0.35, -rowsize - gutter-y / 2 + 0.4), 
        (colsize * 0.65, -rowsize - gutter-y / 2 - 0.4), 
        stroke: red + 4pt)
      cetz.draw.line(
        (colsize * 0.35, -rowsize - gutter-y / 2 - 0.4), 
        (colsize * 0.65, -rowsize - gutter-y / 2 + 0.4), 
        stroke: red + 4pt)

      cetz.draw.line(
        (colsize + gutter-x + colsize * 0.35, -rowsize - gutter-y / 2 + 0.4), 
        (colsize + gutter-x + colsize * 0.65, -rowsize - gutter-y / 2 - 0.4), 
        stroke: red + 4pt)
      cetz.draw.line(
        (colsize + gutter-x + colsize * 0.35, -rowsize - gutter-y / 2 - 0.4), 
        (colsize + gutter-x + colsize * 0.65, -rowsize - gutter-y / 2 + 0.4), 
        stroke: red + 4pt)
    })
  ], [
    #set align(left)
    = Давайте жить в ОЗУ!

    #h(1em)

    Нам не нужен диск как таковой. Можно срезать путь, если передавать данные напрямую, не покидая оперативную память.
  ])
]

#slide(background-image: none)[

  = #codebox(lang: "c", "pipe(int fds[2])")

  == Создает неименованный канал (два парных дескриптора).

  - Байты, записанные во второй дескриптор, можно будет прочитать из первого;

  - Канал однонаправленный, имеет ограниченный размер буфера.

  #place(bottom + center, dy: 0.5cm)[
    #cetz.canvas(length: 1cm, {
      let pxsize = 0.15cm

      cetz.draw.content((-15, -10 * pxsize), (rel: (30, -3)))[
        #let pat = tiling(size: (16 * pxsize, 16 * pxsize))[
          #place(image("img/ground.png"))
        ]
        #box(width: 100%, height: 100%, fill: pat)
      ]
      cetz.draw.content((-60 * pxsize, 0))[
        #scale(x: -100%)[
          #image("img/mario.png", height: 16 * pxsize)
        ]
      ]
      cetz.draw.content((0, 0))[
        #image("img/pipe.png", height: 25 * pxsize)
      ]
      cetz.draw.content((60 * pxsize, -2 * pxsize))[
        #scale(x: -100%)[
          #image("img/runningmario2.png", height: 16 * pxsize)
        ]
      ]

      cetz.draw.content((-38 * pxsize, 20 * pxsize), [
        #image("img/speech-bubble.png", height: 19 * pxsize)
        #place(horizon + center, dy: -0.4cm)[
          #set text(weight: "bold", size: 25pt)
          #raw(lang: "c", "\"Hello, World!\\n\"")
        ]
      ])

      cetz.draw.content((38 * pxsize, 20 * pxsize), [
        #scale(x: -100%)[
          #image("img/speech-bubble.png", height: 19 * pxsize)
        ]
        #place(horizon + center, dy: -0.4cm)[
          #set text(weight: "bold", size: 25pt)
          #raw(lang: "c", "\"Hello, World!\\n\"")
        ]
      ])
    })
  ]
]

#slide(background: white, background-image: none)[
  = Общаемся через #strike("трубу") канал

  #v(1em)
  #set text(weight: "bold")
  #code(numbers: true, 
  ```c
  int pipefd[2] = {};
  pipe(pipefd);

  if(fork() != 0) {
    // Если мы - процесс-родитель, то кричим в трубу
    write(pipefd[1], "Friendly message\n", 18);
    wait(NULL);
  } else {
    // Если мы - процесс-ребёнок, то слушаем трубу:
    char buffer[32] = {};
    read(pipefd[0], buffer, 31);
    printf("Received %s", buffer); // "Received Friendly message\n"
  }
  
  close(pipefd[0]); // Дескрипторы каналов тоже нужно закрывать
  close(pipefd[1]);
  ```
  )
]

#slide[
  = Заменяем стандартный ввод/вывод

  == #codebox(lang: "c", "dup2(int fd, int new_fd)")
  *Копирует файловый дескриптор по номеру #lightcodebox("fd") в номер #lightcodebox("new_fd")*
  
  - Если целевой дескриптор уже существует, он будет предварительно закрыт.

  - Таким образом можно *перенаправлять потоки данных*.

  - Например, заменить стандартный вывод одного процесса на канал, ведущий в стандартный ввод другого процесса.

  - Еще есть #codebox(lang: "c", "dup(int fd)"). Это как #lightcodebox(lang: "c", "dup2") , но #lightcodebox("new_fd") выбирается системой.
]

#slide(background: white, background-image: none)[
  = Склеиваем ввод и вывод

  #v(0.5em)
  #set text(weight: "bold")
  #code(numbers: true, 
  ```c
  int pipefd[2] = {};
  pipe(pipefd);

  if(fork() != 0) {                  // Если мы - процесс-родитель:
    dup2(pipefd[1], STDOUT_FILENO); // - Подключаем STDOUT к началу канала;
    printf("FriendlyMessage\n");    // - Пишем в STDOUT (канал);
    fflush(stdout);                  // - Убеждаемся, что данные улетели
    wait(NULL);                      // - Ждем ребёнка;
  } else {                           // Если мы - процесс-ребёнок:
    dup2(pipefd[0], STDIN_FILENO);  // - Подключаем STDIN к концу канала;
    char buffer[32] = {};            //
    scanf("%31s", buffer);           // - Читаем STDIN (канал);
    printf("Received %s", buffer);   // - "Received FriendlyMessage\n";
  }
  
  close(pipefd[0]); // Дескрипторы каналов тоже нужно закрывать
  close(pipefd[1]);
  ```)
]

#slide(background-image: none)[
  = Оператор #codebox("|") из вселенной #bash("bash")

  Превращает вывод предыдущей команды в ввод следующей команды.

  #table(
    columns: 2,
    stroke: (x, y) => {
      if x == 0 {(right: 3pt + gray)}
      else {(:)}
    },
    inset: (x, y) => {
      if x == 0 {(right: 20pt)}
      else {(left: 20pt)}
    },
    align: horizon + left,
    row-gutter: 5pt,
    bash("ps"), [Список всех процессов],
    bash("ps | grep java"), [Список всех процессов, содержащих #lightcodebox("java")],
    bash("cat file"), [Вывести содержимое файла],
    bash("cat file | sort"), [Вывести отсортированные строки файла],
    bash("cat file | sort -u"), [Вывести уникальные строки файла],
    bash("cat file | sort -u | wc -l"), [Посчитать уникальные строки файла],
  )

  *Под капотом он точно так же создаёт #lightcodebox("pipe") и делает #lightcodebox("dup2").* Это достаточно дорого.

  Поэтому вместо #bash("cat file | grep pattern") лучше написать #bash("grep pattern file") .
]

#slide(background-image: none)[

  #let marker(content, color) = {
    // set text(size: 1pt)
    colbox(color: color, inset: (x: 3pt, y: 3pt), baseline: 5pt)[
      #content
    ]
    h(0.2em)
  }
  #set list(marker: none)

  #let icons = (
    marker(image(width: 0.6cm, "img/check-circle.svg"), green),
    marker(image(width: 0.6cm, "img/clock-eight.svg"), orange),
    marker(image(width: 0.6cm, "img/exclamation-circle.svg"), red)
  )

  #place(horizon + center, dy: -1cm)[
    #table(
      columns: (50%, 50%),
      stroke: (x, y) => { 
        // if x == 0 and y != 0 {
        //   (right: 3pt + gray)
        // } else {
          (:)
        // }
      },
      align: (x, y) => {
        if y == 0 {
          horizon + center
        } else {
          left
        }
      },
      inset: (x, y) => {
        if y == 0 {
          (y: 20pt)
        } else if x == 1 {
          (left: 30pt)
        } else {
          (left: 20pt)
        }
      },
      row-gutter: 20pt,
      [= Чтение из #codebox("pipe")],
      [= Запись в #codebox("pipe")],
      [
        - *Данные есть:*
        - #icons.at(0) Прочитать их
      ], [
        - *Есть место, есть читатели:*
        - #icons.at(0) Записать данные в буфер канала
      ], [
        - *Данных нет*, *писатели есть*:
        - #icons.at(1) Ждать
      ], [
        - *Места нет, есть читатели:*
        - #icons.at(1) Ждать
      ], [
        - *Данных нет*, *писателей нет*:
        - #icons.at(2) Вернуть ноль
      ], [
        - *Читателей нет:*
        - #icons.at(2) Вернуть ошибку #lightcodebox("Broken Pipe")
      ],
    )
  ]

  #place(bottom + left)[
    #colbox(color: blue, inset: (x: 13pt, y: 10pt))[Задача] #h(0.3em) Придумайте, как можно поймать deadlock
  ]
]

#slide(background: white, background-image: none)[
  = Привет из многопоточки!

  Если дескриптор канала утечёт в другой процесс, то чтение может ждать вечно.

  #text(weight: "bold")[
    #code(numbers: true,
    ```c
    int pipefd[2] = {};
    pipe(pipefd);

    if (fork() == 0) { // Порождаем дочерний процесс
      execve(...);
      return -1;
    }

    write(pipefd[1], msg, sizeof(msg));
    close(pipefd[1]);

    char buffer[32] = {};
    // Этот read() будет ждать вечно, т.к pipefd[1] не закрыт в дочернем процессе
    while (read(pipefd[0], buffer, sizeof(buffer)) != 0);
    ``` 
    )
  ]

  *Мораль -- закрывайте дескрипторы!*
]

#slide(background-image: none)[
  = Настройки каналов

  == #codebox(lang: "c", "fcntl(fd, F_SETPIPE_SZ, 65536)");

  - Изменить размер буфера канала.

  == #codebox(lang: "c", "fcntl(fd, F_SETFL, old_flags | O_NONBLOCK)");

  - Запретить блокирующее чтение, даже если в буфере канала пусто.
  - Вместо ожидания #lightcodebox(lang: "c", "read()") вернёт ошибку и установит #lightcodebox(lang: "c", "errno = EWOULDBLOCK") .
  - Нужно получить старые флаги через #lightcodebox(lang: "c", "fcntl(fd, F_GETFL)") .

  == #codebox("PIPE_BUF")

  - Максимальный размер атомарной записи.
  - Записи большего размера могут быть разбиты на несколько.
  - Эта настройка изменяется перекомпиляцией ядра.
]

#slide[
  = #codebox(lang: "c", "mkfifo(const char* path, mode_t mode)")

  *Создаёт именованный канал.*
  
  - Именованный канал имеет путь. Его можно открыть через #lightcodebox(lang: "c", "open();")

  - Только один процесс может открыть #lightcodebox("fifo") на чтение;

  - Открытие #lightcodebox("fifo") *блокирующее*:
    - Открытие на чтение ждёт, пока появится писатель;
    - Открытие на запись ждёт, пока появится читатель.

  - Именованные каналы позволяют взаимодействовать любым процессам, имеющим доступ к этому пути, а не только родителю с детьми.
]

#focus-slide[
  #text(size: 40pt, weight: "bold")[
    Сигналы
  ]
]

#slide[
  = Сигнал

  *Простое асинхронное сообщение, которое можно отправить процессу.*

  - В сообщении хранится только номер сигнала - число от 1 до 64.

  - Сигнал может отправить как процесс, так и ядро.

  - Процесс, получивший сигнал, может отреагировать по-разному:

  #let sigtype(type) = {
    set text(weight: "bold")
    codebox(type)
  }
  #table(
    columns: 2,
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    align: horizon,
    inset: (x: 20pt, y: 0pt),
    row-gutter: 10pt,
    sigtype("Term"), [Завершить работу],
    sigtype("Core"), [Завершить работу и сгенерировать #link("https://ru.wikipedia.org/wiki/Дамп_памяти")[Core Dump]],
    sigtype("Ign"), [Проигнорировать сигнал],
    sigtype("Stop"), [Приостановить выполнение],
    sigtype("Cont"), [Возобновить выполнение],
  )
]

#slide(background-image: none)[
  #let sigtype(type) = {
    set text(weight: "bold", size: 1.1em)
    raw(type)
  }

  #table(
    rows: 1cm,
    columns: 3,
    align: (x, y) => {
      if y == 0 or x < 2 {
        center + horizon
      } else {
        left + horizon
      }
    },
    stroke: (x, y) => {
      if x != 0 and y != 0 {
        (left: 3pt + gray)
      } else {
        none
      }
    },
    inset: (x, y) => {
      if y == 0 {
        (x: 20pt, bottom: 15pt)
      } else {
        (x: 20pt, y: 2pt)
      }
    },
    [*Сигнал*], [*Действие*], [*Описание*],
    lightcodebox("SIGKILL"), sigtype("Term"), [Завершение работы (нельзя проигнорировать)],
    lightcodebox("SIGABRT"), sigtype("Core"), [Завершение работы (нельзя проигнорировать)],
    lightcodebox("SIGTERM"), sigtype("Term"), [Мягкое завершение работы],
    lightcodebox("SIGSEGV"), sigtype("Core"), [Ошибка сегментации],
    lightcodebox("SIGCHLD"), sigtype("Ign"), [Завершился дочерний процесс],
    lightcodebox("SIGSTOP"), sigtype("Stop"), [#lightcodebox("Ctrl+Z") (нельзя проигнорировать)],
    lightcodebox("SIGCONT"), sigtype("Cont"), [Возобновление работы],
    lightcodebox("SIGURG"), sigtype("Ign"), [Нужно прочитать что-то важное],
    lightcodebox("SIGINT"), sigtype("Term"), lightcodebox("Ctrl+C"),
    lightcodebox("SIGQUIT"), sigtype("Core"), lightcodebox("Ctrl+\\"),
    lightcodebox("SIGALRM"), sigtype("Term"), [Сработал таймер #codebox(lang: "c", "alarm()")],
    lightcodebox("SIGPIPE"), sigtype("Term"), [Получена ошибка #codebox("Broken Pipe")],
  )

  Это некоторые из существующих POSIX-сигналов.
]

#slide(background-image: none)[
  = #codebox(lang: "c", "alarm(unsigned int seconds)")
  
  *Заводит таймер, по истечении которого процесс получает сигнал #lightcodebox("SIGALRM")*

  - По умолчанию процесс завершит работу, получив #lightcodebox("SIGALRM"), но можно установить свой обработчик.

  - Вызов #codebox(lang: "c", "alarm(0)") отменяет таймер.
  #line(length: 100%, stroke: 3pt + gray)

  = #codebox(lang: "c", "abort()")

  *Провоцирует немедленное получение сигнала #lightcodebox("SIGABRT"). *

  - Вызывается, если сделать #lightcodebox(lang: "c", "assert(false)")
  - #lightcodebox("SIGABRT") делает Core Dump. Через это #lightcodebox(lang: "c", "abort()") может помогать в отладке.
]

#slide(background-image: none)[
  = #codebox(lang: "c", "kill(pid_t pid, int sig)")

  *Отправляет сигнал процессу.* Тот случай, когда название сбивает с толку.

  == #codebox(lang: "c", "pid_t pid")
  - *Номер процесса, которому нужно отправить сигнал.*
  - #lightcodebox(" 0: ")Отправить сигнал своей группе процессов.
  - #lightcodebox("-1: ")Отправить сигнал всем, кому можно (кроме init-процесса).
  - #lightcodebox("-n: ")Отправить группе процессов с номером #lightcodebox("n")

  == #codebox(lang: "c", "int sig")
  - Номер отправляемого сигнала.
  - #lightcodebox("-0: ")Не отправлять сигнал, но проверить разрешения.

  == Сигналы можно отправлять:

  - Процессам с тем же пользователем
  - Если вы - суперпользователь, то кому угодно, кроме init-процесса
]

#slide(background-image: none, background: white)[
  = Как узнать, завершился ли процесс сигналом?

  #v(1em)

  #table(
    columns: (50%, 50%),
    stroke: none,
    [
      Системный вызов #lightcodebox(lang: "c", "waitpid(...)") записывает *битовую маску*, в которой закодирован статус возврата:

      == #codebox(lang: "c", "WIFEXITED(status)")

      - #lightcodebox(lang: "c", "true") при нормальном завершении;

      - Код возврата -- #lightcodebox(lang: "c", "WEXITSTATUS(status)").

      == #codebox(lang: "c", "WIFSIGNALED(status)")

      - #lightcodebox(lang: "c", "true") при завершении сигналом;

      - Номер сигнала -- #lightcodebox(lang: "c", "WTERMSIG(status)").
    ],
    text(weight: "bold")[
      #code(numbers: true,
      ```c
      int status = 0;
      waitpid(pid, &status, 0);

      if (WIFEXITED(status)) {
        // Процесс завершился нормально
        int retcode = WEXITSTATUS(status);
      }

      if (WIFSIGNALED(status)) {
        // Процесс был завершён сигналом
        int signum = WTERMSIG(status);
      }
      ```)
    ]
  )
]

#slide(background-image: none)[
  = #codebox(lang: "c", "sigaction(int sig, const sigaction* act, sigaction* oldact)")

  *Устанавливает обработчик #lightcodebox("act") на сигнал #lightcodebox("sig")*. Старый обработчик сохраняет в #lightcodebox("oldact")

  - #lightcodebox("oldact") может быть #lightcodebox(lang: "c", "NULL"), если он не нужен;

  - Собственный обработчик нельзя установить на #lightcodebox("SIGSTOP") и #lightcodebox("SIGKILL").

  = #codebox(lang: "c", "struct sigaction")

  *Структура, задающая обработчик. Её поля:*

  #[
    #set list(marker: none)
    - *#codebox(lang: "c", "void (*sa_handler) (int signo)")* - Указатель на функцию-обработчик сигнала;
    // - *#codebox(lang: "c", "void (*sa_sigaction) (int signo, siginfo_t *info, void *other)")*
    - *#codebox(lang: "c", "sigset_t sa_mask")* -- Какие сигналы блокировать при обработке этого сигнала.
    - *#codebox(lang: "c", "int sa_flags")* -- Флаги, о них позже.
    - *#codebox(lang: "c", "...")* -- _И ещё некоторые поля для Real-Time сигналов_
  ]

  - #lightcodebox("sa_handler") можно установить в #lightcodebox("SIG_DFL") или #lightcodebox("SIG_IGN"). Это #lightcodebox("default") и #lightcodebox("ignore").
]

#slide[
  = #codebox("sigset_t")

  *Набор сигналов.* Хранится как битовая маска. Не имеет конструктора и деструктора.

  #table(
    columns: 2,
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    align: horizon,
    inset: (x, y) => {
      if x == 1 {
        (x: 20pt)
      } else {
        (right: 20pt)
      }
    },
    row-gutter: 7pt,
    codebox(lang: "c", "sigemptyset(sigset_t* set);"), [Пустое множество],
codebox(lang: "c", "sigfillset(sigset_t* set);"), [Полное множество],
codebox(lang: "c", "sigaddset(sigset_t* set, int signum);"), [Добавить сигнал],
codebox(lang: "c", "sigdelset(sigset_t* set, int signum);"), [Удалить сигнал],
codebox(lang: "c", "sigismember(sigset_t* set, int signum);"), [Проверить наличие сигнала],
  )
]

#slide(background: white, background-image: none)[
  = Обрабатываем Ctrl+C
  #set text(weight: "bold")
  
  #code(numbers: true,
  ```c
  // Простейший обработчик
  void handler(int signum) {
    char message[] = "You've pressed Ctrl+C!\n";
    write(STDOUT_FILENO, message, sizeof(message));
  }

  int main() {
    // Инициализируем sigaction
    struct sigaction act = {};
    act.sa_handler = handler;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;

    // Устанавливаем обработчик на SIGINT
    sigaction(SIGINT, &act, NULL);
  }
  ```)
]

#slide(background-image: none)[
  #ub-header[
    = #colbox(color: red)[⚠️] Не стреляйте сигнальной ракетницей по ногам.
  ]

  - Нужно помнить, что обработчики сигналов могут быть вызваны в любой момент, даже во время исполнения библиотечного кода.

  - Многие стандартные функции небезопасны при обработке сигналов. Например:

  #align(center)[
    #box(inset: 0pt)[
      #table(columns: 4,
        stroke: (x, y) => {
          if x != 0 {
            (left: 3pt + gray)
          } else {
            (:)
          }
        },
        row-gutter: 7pt,
        inset: (x: 15pt, y: 3pt),
        align: center + horizon,

        [#codebox(lang: "c", "malloc()")],
        [#codebox(lang: "c", "free()")],
        [#codebox(lang: "c", "printf()")],
        [#codebox(lang: "c", "fopen()")],
        [#codebox(lang: "c", "fread()")],
        [#codebox(lang: "c", "rand()")],
        [#codebox(lang: "c", "strerror()")],
        [#codebox(lang: "c", "perror()")],
      )
    ]
  ]

  - Список безопасных функций есть в #bash("man 7 signal-safety")
  
  - Для глобальных переменных, которые используются обработчиками, нужно использовать атомарные типы. Например, #codebox(lang: "c", "sig_atomic_t").

  - Если участок кода не хочется прерывать, можно временно заблокировать сигналы. Будет аналогично работе мьютекса.
]

#slide(header: [Блокировка сигналов])[
  
  Если заблокировать сигнал, процесс не заметит его получения до тех пор, пока не разблокирует его.

  - Сигналы блокируются системным вызовом #codebox(lang: "c", "sigprocmask(...)")

  - Заблокировать #lightcodebox("SIGSTOP") и #lightcodebox("SIGKILL") нельзя.

  == Зачем?

  Обработка сигналов прерывает исполнение. Можно временно заблокировать сигналы, чтобы обезопасить выполнение какой-то опасной секции кода.
]

#slide[
   = #codebox(lang: "c", "int sigprocmask(int how, sigset_t* set, sigset_t* old_set)")
  
  *Обновляет маску заблокированных сигналов.* Старую маску сохраняет в #lightcodebox("old_set").

  - #lightcodebox("old_set") может быть #lightcodebox("NULL"), если он не нужен.

  == #codebox(lang: "c", "int how") :

  #table(
    columns: 2,
    align: horizon,
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    inset: (x, y) => {
      if x == 0 {
        (right: 20pt, y: 0pt)
      } else {
        (left: 20pt, y: 0pt)
      }
    },
    row-gutter: 7pt,
    [`=` #codebox("SIG_SETMASK")],[Установить маску;],
    [`=` #codebox("SIG_BLOCK")], [Заблокировать из маски;],
    [`=` #codebox("SIG_UNBLOCK")],[Разблокировать из маски.],
  )
]

#slide(background-image: none)[
  = Как доставляются сигналы

  #v(1em)

  - Если процесс должен обработать сигнал, это фиксируется в битовой маске;

  - Маска может хранить факт получения сигнала, но не их количество;

  - Обработчик сигнала может вызваться с задержкой.

  - Если процесс получит два одинаковых сигнала быстрее, чем успеет их обработать, обработчик будет вызван один раз.

  #v(1em)

  #align(center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.line((-1, 2), (26, 2), mark: (end: ">", length: 10pt, width: 10pt), stroke: 3pt + black, fill: black)
      
      let softred = cell-color(red).background-color
      let redstroke = cell-color(red).stroke-color

      let softblue = cell-color(blue).background-color
      let bluestroke = cell-color(blue).stroke-color

      cetz.draw.content((4, 2), {
        box(width: 7.5cm, height: 2.5cm, fill: softred, stroke: 3pt + redstroke, radius: 10pt)[
          #set align(horizon + center)
          #lightcodebox(lang: "c", "kill(pid, SIGINT)")
        ]
      })

      cetz.draw.content((12.5, 2), {
        box(width: 7.5cm, height: 2.5cm, fill: softred, stroke: 3pt + redstroke, radius: 10pt)[
          #set align(horizon + center)
          #lightcodebox(lang: "c", "kill(pid, SIGINT)")
        ]
      })

      cetz.draw.content((21, 2), {
        box(width: 7.5cm, height: 2.5cm, fill: softblue, stroke: 3pt + bluestroke, radius: 10pt)[
          #set align(horizon + center)
          #lightcodebox(lang: "c", "sigint_handler()")
        ]
      })
    })
  ]

  - Даже если процесс получил разные сигналы, порядок их обработки не определён.

  - А еще эта маска не наследуется при #lightcodebox("fork"). Почему?
]

#slide(background-image: none)[
  = #codebox(lang: "c", "int signalfd(int fd, const sigset_t *mask, int flags);")

  *Отправлять сигналы в файловый дескриптор.*

  #table(
    columns: 2,
    align: horizon,
    stroke: (x, y) => {
      if x == 0 {
        (right: 3pt + gray)
      } else {
        none
      }
    },
    inset: (x, y) => {
      if x == 0 {
        (right: 20pt)
      } else {
        (left: 20pt)
      }
    },
    row-gutter: 9pt,
    codebox(lang: "c", "int fd"), [Какой дескриптор использовать. *-1*, чтобы создать новый.],
    codebox(lang: "c", "const sigset_t *mask"), [Какие сигналы отслеживать],
    codebox(lang: "c", "int flags"), [Флаги: #lightcodebox("SFD_NONBLOCK") и #lightcodebox("SFD_CLOEXEC")]
  )

  - Чтение файлового дескриптора #codebox("signalfd") по умолчанию заблокируется до сигнала.

  - Когда появятся сигналы для обработки, вы сможете читать структуры типа #codebox(lang: "c", "signalfd_siginfo") из этого дескриптора. В поле #codebox("ssi_signo") -- номер сигнала.

  - #codebox(lang: "c", "signalfd") доставит вам даже заблокированные сигналы. Их рекомендуется заблокировать, чтобы они не выполняли свои действия по умолчанию.

  - Использовать файловый дескриптор для обработки сигналов безопаснее, поскольку это не прерывает исполнение вашего кода.
]

#slide(background-image: none, background: white)[
  = Читаем сигналы из #codebox("signalfd")
  #set text(weight: "bold")
  #code(numbers: true,
  ```c
  int main() {
    sigset_t mask = {};
    sigemptyset(&mask);
    sigaddset(&mask, SIGINT);

    sigprocmask(SIG_BLOCK, &mask, NULL);

    int sfd = signalfd(-1, &mask, 0);

    while (true) {
      struct signalfd_siginfo  fdsi;
      ssize_t s = read(sfd, &fdsi, sizeof(fdsi));
      if (s != sizeof(fdsi)) return -1;

      if (fdsi.ssi_signo == SIGINT) printf("Got SIGINT\n");
    }
  }
  ```)
]

#slide(header: [Сигналы реального времени], background-image: none)[
  #set list(marker: none)
  *Обычные сигналы имеют ряд проблем*:
  
  - #con() Произвольный порядок доставки;
  - #con() Одинаковые сигналы могут склеиться в один;
  - #con() Позволяют передать только номер сигнала.

  *Сигналы реального времени решают их:*

  - #pro() Порядок доставки равен порядку отправки;
  - #pro() Поддерживают очередь сигналов одного типа;
  - #pro() Позволяют передать аргумент вместе с сигналом.

  Для собственных сигналов можно использовать номера от #codebox("SIGRTMIN") до #codebox("SIGRTMAX")
]

#slide(background-image: none)[
  = #codebox(lang: "c", "sigqueue(pid_t pid, int sig, sigval_t value)")

  *Отправляет сигнал реального времени*. Замена #codebox(lang: "c", "kill(pid_t pid, int sig)")

  - #codebox(lang: "c", "sigval_t value") - аргумент, который будет отпраавлен вместе с сигналом.

  - Аргумент -- #lightcodebox(lang: "c", "union") с двумя полями: #codebox(lang: "c", "int sival_int") и #codebox(lang: "c", "void *sival_ptr")

  #line(length: 100%, stroke: 3pt + gray)

  = Приём сигнала реального времени:

  - Нужно использовать поле #lightcodebox("sa_sigaction") вместо #lightcodebox("sa_handler") для указателя на обработчик. Такой обработчик должен принимать три аргумента:

  - *#codebox(lang: "c", "void (*sa_sigaction)(int signum, siginfo_t* info, void* ucontext)")*

  - Нужно указать флаг #lightcodebox("SA_SIGINFO") при установке обработчика.
]

#slide(background-image: none, background: white)[
  = Работа с сигналами реального времени

  #set text(weight: "bold")
  #code(numbers: true,
  ```c
  void handler(int signum, siginfo_t* info, void* ucontext) {
    sigval_t value = info->si_value;

    // Используем как хотим
    value.sival_int;
  }

  int main() {
    // Инициализируем sigaction
    struct sigaction act = {};
    act.sa_sigaction = handler;
    sigemptyset(&act.sa_mask);
    act.sa_flags = SA_SIGINFO;

    // Регистрируем обработчик
    sigaction(SIGRTMIN+1, &act, NULL);
  }
  ```)
]

#title-slide[
  #place(horizon + center)[
    = Спасибо за внимание!
  ]

  #place(
    bottom + center,
  )[
    // #qr-code("https://github.com/JakMobius/courses/tree/mipt-os-basic-2024/", width: 5cm)

    #box(
      baseline: 0.2em + 4pt, inset: (x: 15pt, y: 15pt), radius: 5pt, stroke: 3pt + rgb(185, 186, 187), fill: rgb(240, 240, 240),
    )[
      🔗 #link(
        "https://github.com/JakMobius/courses/tree/mipt-os-basic-2024/",
      )[*github.com/JakMobius/courses/tree/mipt-os-basic-2024/*]
    ]
  ]
]