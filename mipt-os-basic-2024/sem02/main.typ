
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "../theme/theme.typ": *
#import "./utils.typ": *
#import "./floats.typ": *

#show: theme

#title-slide[
    #align(horizon + center)[
      = Представление данных в компьютере

      АКОС, МФТИ

      19 сентября, 2024
    ]
  ]

#show: enable-handout

#if true [
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
      - #colbox(color: gray)[⚠️] : Конвертация знаковых типов друг к другу становится менее тривиальным.
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

#if true [

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
    #let float-a = float-from-string(str(calc.pi), 3, 4)
    #let float-a-name = math.pi
    #let float-b = float-from-string(str(calc.e), 3, 4)
    #let float-b-name = [e]

    #draw-float-add-slide(float-a-name, float-a, float-b-name, float-b)
  ]

  #slide(header: [Вычитание #codebox("floating-point")], place-location: center + bottom, background-image: none)[

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

#floats-test()