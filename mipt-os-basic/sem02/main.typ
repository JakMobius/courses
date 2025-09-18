
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4"
#import "../theme/theme.typ": *
#import "./utils.typ": *
#import "./floats.typ": *
#import "./encodings.typ"

#show: theme

#title-slide[
    #align(horizon + center)[
      = Представление данных в компьютере

      АКОС, МФТИ

      18 сентября, 2025
    ]
  ]

#show: enable-handout

#slide(header: [Как работают целые числа], place-location: center+horizon)[
  #draw-number-bits(137)
]

#slide(header: [Целочисленные типы в C])[
  - #codebox(lang: "c", "char") : *1 байт* (или #codebox(lang: "c", "CHAR_BIT") бит) данных;
  - #codebox(lang: "c", "short") и #codebox(lang: "c", "int") : не менее *16 бит* данных;
  - #codebox(lang: "c", "long") : не менее *32 бит* данных;
  - #codebox(lang: "c", "long long") : не менее *64 бит* данных.

  == Типы фиксированной длины (#codebox(lang: "c", "#include <stdint.h>")):

  - #codebox(lang: "c", "int8_t") и #codebox(lang: "c", "uint8_t") : строго *8 бит*;
  - #codebox(lang: "c", "int16_t") и #codebox(lang: "c", "uint16_t") : строго *16 бит*;
  - #codebox(lang: "c", "int32_t") и #codebox(lang: "c", "uint32_t") : строго *32 бита*;
  - #codebox(lang: "c", "int64_t") и #codebox(lang: "c", "uint64_t") : строго *64 бита*.
]

#slide(header: [Как работают знаковые числа], background-image: none)[
  #place(center+horizon)[
    #draw-number-bits(-23, signed: true)
  ]

  #place(bottom)[
    #set list(marker: none)
    - #colbox(color: gray)[⚠️] : Любое отрицательное число начинается с #codebox("1") и наоборот;
    - #colbox(color: gray)[⚠️] : Конвертация знаковых типов друг к другу становится менее тривиальной.
  ]
]

#slide(header: [Знаковые и беззнаковые типы в C], background-image: none)[
  - #codebox(lang: "c", "char") : *не определено стандартом*.
  - #codebox(lang: "c", "short") , #codebox(lang: "c", "int") , #codebox(lang: "c", "long") и #codebox(lang: "c", "long long") : по умолчанию *знаковые*;
  - Любой из типов выше можно сделать:
    - *Знаковым* (напр., #codebox(lang: "c", "signed char"));
    - *Беззнаковым* (напр., #codebox(lang: "c", "unsigned int")).
  
  #uncover((beginning: 2))[
    == Типы фиксированной длины (#codebox(lang: "c", "#include <stdint.h>")):

    - #codebox(lang: "c", "int16_t") : *знаковое* 16-битное число;
    - #codebox(lang: "c", "uint16_t") : *беззнаковое* 16-битное число (#codebox("u") в начале от слова #codebox(lang: "c", "unsigned"));
  ]

  #uncover((beginning: 3))[
    #colbox(color: red)[⚠️] : Знаковые типы *нельзя переполнять* - в Си это UB. Беззнаковые -- можно.
  ]
]

#slide(header: [Как хранить длинные типы?], place-location: horizon)[
  
  = #codebox(lang: "c", "(uint16_t) 19847 = ")
  #draw-short(19847, endian: "big")

  #uncover((beginning: 2))[
    = Не будет ли проблем с такой схемой?...
  ]
]

#slide(header: [Что может пойти не так?], background-image: none, place-location: horizon)[

  #set text(size: 25pt)
  #code(numbers: true)[```c
    int main() {
      uint64_t my_long = 42;

      printf("%d\n", &my_long); // Что выведет?
    }
  ```]  
]

#slide( place-location: horizon)[
  
  #table(
    columns: 2,
    stroke: none,
    codebox(lang: "c", "uint8_t"),
    draw-simple-bits(endian: "big", 8),
    codebox(lang: "c", "uint16_t"),
    draw-simple-bits(endian: "big", 16),
    codebox(lang: "c", "uint32_t"),
    draw-simple-bits(endian: "big", 32),
    codebox(lang: "c", "uint64_t"),
    draw-simple-bits(endian: "big", 64),
  )

  #let theme = cell-color(base-color: blue)

  #colbox(color: gray)[⚠️] : *Младший
  #box(
    fill: theme.background-color, inset: 7pt, stroke: 1pt + theme.stroke-color, baseline: 0.1em + 5pt,
  )[
    #set text(fill: theme.text-color)
    синий
  ]
  байт оказывается в разных местах*.
]

#slide(header: [Сложности приведения типов], background-image: none, place-location: horizon)[

  #text(size: 25pt, {
    code(numbers: true)[```c
      uint8_t a_byte = 42;

      uint16_t a_16b = a_byte; // Перенесёт 42 во второй байт
      uint32_t a_32b = a_byte; // Перенесёт 42 в четвёртый байт
      uint64_t a_64b = a_byte; // Перенесет 42 в восьмой байт
    ```]
  })

  #colbox(color: gray)[⚠️] : В схеме Big-Endian *каждый целочисленный каст* требует *менять порядок байт*:
]

#slide(header: [Что, если хранить байты наоборот?], place-location: horizon)[
  
  = #codebox(lang: "c", "(uint16_t) 19847 = ")
  #draw-short(19847, endian: "little")
]

#slide(header: [Что, если хранить байты наоборот?], place-location: horizon)[
  
  #table(
    columns: 2,
    stroke: none,
    codebox(lang: "c", "uint8_t"),
    draw-simple-bits(8),
    codebox(lang: "c", "uint16_t"),
    draw-simple-bits(16),
    codebox(lang: "c", "uint32_t"),
    draw-simple-bits(32),
    codebox(lang: "c", "uint64_t"),
    draw-simple-bits(64),
  )

  #colbox(color: green)[✔] В такой схеме (Little-Endian) приведение целочисленных типов не требует перемещения байт.
]

#slide(background-image: none)[
  #set par(spacing: 12pt)
  #[
    #set list(marker: none)
    == Схема Big-Endian (BE, cначала старший байт)

    - #pro() Удобная для человека. Порядок бит как в десятичной записи;
    - #pro() Позволяет ускорять #codebox("strcmp") и #codebox("memcmp") ;
    - #con() Иногда сложнее приводить типы.

    == Схема Little-Endian (LE, cначала младший байт)

    - #pro() Легко кастуется туда-обратно;
    - #con() Чуть-чуть ломает мозг.
  ]

  == К чему пришли люди:

  - x86 всегда LE. ARM по умолчанию LE, но поддерживает оба варианта.

  - В Big-Endian вводятся двоичные литералы: #codebox(lang: "c", "0b1000000000000000 == 32768") , а не #codebox(lang: "c", "128");
  
  - А еще Big-Endian используется при передачи данных по сети.
]

#focus-slide[
  #text(size: 40pt)[*Дробные числа*]
]

#slide(header: [Дробные числа], place-location: center + horizon)[
  #draw-number-bits(fractional: 3, 10.675)

  = Несколько младших разрядов можно зарезервировать под дробную часть. Получится #codebox("fixed-point").
]

#slide(header: [Недостатки #codebox("fixed-point")], place-location: horizon)[
  #[
    #set list(marker: none)
    - #con() Для каждой задачи *нужно подбирать оптимальное количество дробных бит*.
    - #con() При неоптимальном порядке представление либо *теряет относительную точность*, либо *быстро переполнится*.
  ]

  #uncover((beginning: 2))[
    == К чему пришли люди:
    
    - Давайте *менять число дробных бит на ходу*;

    - Выделим несколько бит под *счётчик*;

    - Назовём это #emoji.sparkles #codebox("floating-point") #emoji.sparkles.
  ]
]

#slide(header: [#codebox("floating-point") в IEEE 754], background-image: none)[
  // #draw-float("FLOAT_MIN", 3, 4, float: float-from-bits((false, false, false, false, false, false, false, true), 3, 4))
  
  // #draw-float("Почти 1", 3, 4, float: float-from-bits((false, false, true, true, false, false, false, true), 3, 4))

  #place(center + horizon, {
    let float = float-from-string(str(calc.pi), 3, 4)
    draw-float-scheme([*$pi approx #float-value(float)$* = ], float) 
  })

  #place(center + bottom)[
    #set text(size: 25pt)
    (*Вообще, в IEEE 754 минимум 16 бит, но суть та же*)
  ]
]

#slide(background-image: none, place-location: horizon + center)[
  #set text(size: 30pt)
  🔗 #link(
    "https://www.h-schmidt.net/FloatConverter/IEEE754.html",
  )[*Интерактивная визуализация работы #codebox("float")*]
]

#slide(background-image: none, place-location: horizon + center)[
  
  #let float = float-from-string(str(calc.pi), 3, 4)

  #set text(size: 60pt)
  #draw-float-formula(float)

  #set text(size: 25pt)
  *На самом деле, двоичная аналогия этого:*

  #set text(size: 60pt)
  $1.616255 dot 10^(-35)$
]

#slide(background-image: none)[

  #let scale = 0.8

  #let draw-scale() = {
    cetz.draw.fill(black)

    for i in array.range(-16, 18, step: 2) {
      let x = i * scale

      cetz.draw.circle((x, -0.3), radius: 0.1)
      cetz.draw.content((x - 0.5, -0.5), (x + 0.5, -1.5), padding: 0, {
        align(center + horizon)[
          *#i*
        ]
      })
    }
  }

  = #codebox("fixed-point") (знаковый, 8 бит, 3-б. дробь)
  #cetz.canvas(length: 1cm, {
    draw-scale()
    for i in range(-128, 128) {
      let value = (i / 8) * scale
      cetz.draw.line((value, 0), (value, 1))
    }
  })

  #v(1em)
  = #codebox("floating-point") (3-б. экспонента, 4-б. мантисса)
  #cetz.canvas(length: 1cm, {
    draw-scale()
    for i in range(256) {
      let float = float-from-bits(get-bit-array(i), 3, 4)
      if not float-is-infinity(float) and not float-is-nan(float) {
        let value = float-value(float) * scale
        cetz.draw.line((value, 0), (value, 1))
      }
    }
  })

  #v(1em)
  #set list(marker: none)
  - #pro() Макс. погрешность на $(1, 15)$ стала *3%* против *5.6%*;
  - #con() *32 из 256 значений (12%)* уходят на служебные (#codebox("NaN"), #codebox("Inf")).
]

#slide(header: [Спец. значения #codebox("floating-point") в IEEE 754], background-image: none)[
  
  #place(horizon + center)[
    #set text(size: 25pt)
    #table(
      columns: 2,
      stroke: none,
      align: (right, center),
      codebox("+Inf"), draw-float-inline(float-infinity(false, 3, 4)),
      codebox("-Inf"), draw-float-inline(float-infinity(true, 3, 4)),
      codebox("qNaN"), draw-float-inline(float-nan(3, 4)),
      codebox("sNaN"), draw-float-inline(float-from-bits((false, true, true, true, false, true, false, false), 3, 4)),
      codebox("0"), draw-float-inline(float-zero(false, 3, 4)),
      codebox("-0"), draw-float-inline(float-zero(true, 3, 4))
    )
  ]

  #place(bottom)[
    - При нулевой экспоненте включается *денормализованный режим*. Он заменяет старшую единицу на ноль. Так сохраняется плотность значений близко к нулю.
  ]
]

#slide(header: [Сложение #codebox("floating-point")], place-location: center + bottom, background-image: none)[

  #let float-a-name = "4.5"
  #let float-a = float-from-string(float-a-name, 3, 4)
  #let float-b-name = "-4"
  #let float-b = float-from-string(float-b-name, 3, 4)

  #draw-float-add-slide(float-a-name, float-a, float-b-name, float-b)
]

#slide(header: [Сложение #codebox("floating-point") разных порядков], place-location: center + bottom, background-image: none)[

  #let float-a-name = "1.625"
  #let float-a = float-from-string(float-a-name, 3, 4)
  #let float-b-name = "4.5"
  #let float-b = float-from-string(float-b-name, 3, 4)

  #draw-float-add-slide(float-a-name, float-a, float-b-name, float-b)
]

  #slide(header: [Денормализованные #codebox("floating-point")], place-location: center + bottom, background-image: none)[

  #let float-a-name = "0.5"
  #let float-a = float-from-string(float-a-name, 3, 4)
  #let float-b-name = "-0.03125"
  #let float-b = float-from-string(float-b-name, 3, 4)

  #draw-float-add-slide(float-a-name, float-a, float-b-name, float-b)
]

#slide(header: [Умножение #codebox("floating-point")], place-location: center + bottom, background-image: none)[

  #let float-a = float-from-string(str(calc.pi), 3, 4)
  #let float-a-name = math.pi
  #let float-b = float-from-string(str(calc.e), 3, 4)
  #let float-b-name = [e]

  #draw-float-mul-slide(float-a-name, float-a, float-b-name, float-b)
]

#slide(header: [Round to nearest, tie to 0], background-image: none)[
  === Режим округления по умолчанию в большинстве процессоров.

  - Округляет до ближайшего представимого числа;
  - Если число находится ровно посередине, округляет в сторону младшего нуля:

  #align(center)[
    #set text(size: 24pt)
    #codebox(lang: "js", "0b0010") #math.arrow.r #codebox(lang: "js", "0b00")

    #codebox(lang: "js", "0b0110") #math.arrow.r #codebox(lang: "js", "0b10")
  ]

  === Другие режимы округления:

  - Round to nearest, tie away from 0
  - Round toward 0, или #math.plus.minus#calc.inf

  #colbox(color: gray)[⚠️] Округлять нужно *один раз, в самом конце*. Иначе нарвётесь на edge-кейсы.
]

#slide(header: [Размеры реальных #codebox("floating-point")], place-location: horizon + center)[

  #set text(size: 35pt)

  #let head(content) = {
    text(size: 30pt)[*#content*]
  }

  #let bits(content) = {
    text(size: 30pt)[#content]
  }

  #table(
    columns: 3,
    stroke: none,
    align: (right, center, center),
    inset: (x: 30pt, y: 15pt),
    table.header(
      head([]), head([Экспонента]), head([Мантисса])
    ),
    table.hline(),
    codebox(lang: "c", "float"), bits([*8* бит]), bits([*23* бита]),
    codebox(lang: "c", "double"), bits([*11* бит]), bits([*52* бита])
  )
]

#slide(header: [Further reading], background-image: none, place-location: horizon + center)[
  #set text(size: 30pt)
  🔗 #link(
    "https://dl.acm.org/doi/pdf/10.1145/93548.93557?download=false",
  )[*Как переводить строку в #codebox("float")*]

  🔗 #link(
    "https://dl.acm.org/doi/pdf/10.1145/93548.93559?download=false",
  )[*Как переводить #codebox("float") в строку*]
]

#focus-slide[
  #only("1")[
    #text(size: 40pt)[*НћЉЏЄћЇљЏ*]
  ]
  #only("2")[
    #text(size: 40pt)[*Кодировки*]
  ]
]

#let special-char-box(color: rgb(60, 60, 60), char) = {
  box(
    baseline: 0.1em + 5pt, inset: (x: 5pt, y: 5pt), radius: 3pt, fill: color,
  )[
    #set text(size: 15pt, baseline: -1pt, fill: white)
    #raw(char)
  ]
}

#let draw-ascii-table(codepage: none) = {
  let special-chars = ("NUL", "SOH", "STX", "ETX", "EOT", "ENQ", "ACK", "BEL", "BS", "TAB", "LF", "VT", "FF", "CR", "SO", "SI", "DLE", "DC1", "DC2", "DC3", "DC4", "NAK", "SYN", "ETB", "CAN", "EM", "SUB", "ESC", "FS", "GS", "RS", "US")

  let rows = if codepage == none { 8 } else { 16 }

  table(
    columns: array.range(17).map(i => 42pt),
    rows: array.range(rows + 1).map(i => 24pt),
    inset: 0pt,
    stroke: none,
    [], ..array.range(16).map(num => raw("0x" + str(num, base: 16))),
    table.hline(),
    table.vline(x: 1),
    ..array.flatten(array.range(rows).map((y) => {
      let row = "0x" + str(y * 16, base: 16)
      if y == 0 {
        row += "0"
      }
      return (raw(row), ..array(range(16)).map((x) => {
        let code = y * 16 + x
        if code < special-chars.len() {
          special-char-box(special-chars.at(code))
        } else if code == 32 {
          raw("␣")
        } else if code == 127 {
          special-char-box("DEL")
        } else if code >= 128 {
          let char = codepage.at(code - 128)
          if(type(char) == str) {
            raw(char)
          } else {
            special-char-box(color: char.at("color", default: rgb(60, 60, 60)), char.name)
          }
        } else {
          let str = str.from-unicode(code)
          raw(str)
        }
      }))
    }))
  )
}

#slide(place-location: horizon + center, background-image: none)[

  #draw-ascii-table()

  #align(center)[
    *Это ASCII-таблица.*

    #[*A*]merican #[*S*]tandard #[*C*]ode for #[*I*]nformation #[*I*]nterchange

    Кратно старше каждого в этой аудитории
  ]
]

#slide(place-location: horizon + center, background-image: none)[
  #set block(above: 14pt, below: 14pt)
  
  #draw-ascii-table(codepage: encodings.cp1251)

  *CP1251 - Наша, родная кодировка.*
]

#slide(place-location: horizon + center, background-image: none)[
  #set block(above: 14pt, below: 14pt)

  #draw-ascii-table(codepage: encodings.cp1256)

  *CP1256 - арабская кодировка.*
]

#slide(place-location: horizon + center, background-image: none)[
  #set block(above: 14pt, below: 14pt)

  #draw-ascii-table(codepage: encodings.cp437)

  *CP437 - стандартная кодировка IBM PC.* Также известна как Alt Codes
]

#slide(header: [Кодовая страница 437], place-location: horizon + left)[
  - #link("https://en.wikipedia.org/wiki/Code_page_437#Internationalization")[*Покрывает алфавиты нескольких языков*]: Английского, Немецкого и Шведского;

  - Содержит *символы национальных валют* (¢, £, ¥, ƒ, ₧);

  - Позволяет рисовать *таблички псевдографикой*;

  - *Очень пытается быть универсальной*, но нельзя объять необъятное.
]

#slide(place-location: center + horizon)[

  #box(width: 80%, height: 12cm)[
    #align(center)[
      #set block(above: 18pt, below: 18pt)
      Его Величество

      #text(size: 60pt, weight: "black")[Unicode]
    ]

    #align(left)[
      - Максимально полный стандарт;
      
      - Содержит *155 063* символов (по состоянию на 10 сент. 2024);

      - Постоянно расширяется;

      - *Как вместить его во всем привычную ASCII?*
    ]
    #v(2cm)
  ]
]

#slide(place-location: horizon + center, background-image: none)[
  #set block(above: 14pt, below: 14pt)

  #draw-ascii-table(codepage: encodings.utf8)

  *UTF-8.* Кодирует символы последовательностью от 1 до 4 байт.
]

#slide(header: [Кодировка UTF-8], background-image: none)[

  #let theme = (i, bit) => {
    let color = if bit == "1" { 
      blue 
    } else if bit == "0" { 
      black 
    } else {
      green
    }
    
    cell-color(active: true, base-color: color)
  }

  #let draw-bytes(bytes) = {

    let cell-size = (x: 0.85, y: 1)
  
    box(baseline: 0.3em, {
      cetz.canvas(length: 1cm, {
        for (i, byte) in bytes.split(" ").enumerate() {
          let bit-array = byte.codepoints()

          draw-bits-boxes((8 + 0.15) * i, 0, cell-size, bit-array, theme, (i, bit) => {
            let theme = theme(i, bit)
            let mask = calc.pow(2, bit-array.len() - i - 1)
            set text(weight: "bold", fill: theme.text-color)

            if bit == "*" {
              bit = ""
            }

            [#bit]
          })
        }
      })
    })
  }

  #place(horizon)[
    #draw-bytes("0*******") #h(7pt) -- Обычный ASCII-символ (7 бит, 128 символов)

    #draw-bytes("110***** 10******")

    #draw-bytes("1110**** 10****** 10******")

    #draw-bytes("11110*** 10****** 10****** 10******")
  ]

  #place(bottom)[
    - В зависимости от длины кода, используется разная кодировка.

    - Всего можно закодировать *1114111* символов.
  ]
]

#title-slide[
  #place(horizon + center)[
    = Спасибо за внимание!
  ]

  #place(
    bottom + center,
  )[
    // #qr-code("https://github.com/JakMobius/courses/tree/mipt-os-basic-2025/", width: 5cm)

    #box(
      baseline: 0.2em + 4pt, inset: (x: 15pt, y: 15pt), radius: 5pt, stroke: 3pt + rgb(185, 186, 187), fill: rgb(240, 240, 240),
    )[
      🔗 #link(
        "https://github.com/JakMobius/courses/tree/mipt-os-basic-2025/",
      )[*github.com/JakMobius/courses/tree/mipt-os-basic-2025\/*]
    ]
  ]
]

#floats-test()