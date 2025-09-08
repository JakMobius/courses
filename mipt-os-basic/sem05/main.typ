
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4"
#import "../theme/theme.typ": *
#import "../theme/asm.typ": *
#import "./utils.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Ассемблер (AArch64)

    АКОС, МФТИ

    10 октября, 2024
  ]
]

#show: enable-handout

#slide(background-image: none)[
  #place(horizon + center)[
    #set text(weight: "semibold")
    #let header-index = 3
    #table(
      inset: (x, y) => {
        if y == 0 { (bottom: 18pt) }
        else if (y == header-index) { (top: 18pt, bottom: 18pt)  }
        else { 8pt }
      },
      columns: 2,
      align: (x, y) => {
        if y == 0 or y == header-index { left }
        else if x == 0 { right }
        else { left }
      },
      stroke: (x, y) => {
        if x == 1 {
          return (left: 3pt + gray)
        } else {
          none
        }
      },

      table.cell(
        colspan: 2,
        [= Регистры AArch64 общего назначения:]
      ),
      register("x0-x30"), [64-битные регистры общего назначения],
      register("w0-w30"), [Их нижние половинки],
      table.cell(
        colspan: 2,
        [= Специальные регистры:],
      ),

      register("sp"), [Stack pointer],
      register("xzr"), [64-битный нулевой регистр],
      register("wzr"), [32-битный нулевой регистр],
      register("pc"), [Program counter],
      register("nzcv"), [Скрытый регистр флагов: переполнение, знак, обнуление.],
    )
  ]

  #place(center + bottom)[
    Двух- и однобайтных регистров, как в x86, нет.
  ]
]

#slide(background-image: none, place-location: horizon)[
  #let asm(str) = codebox(lang: "asm", str)

  #let codeboxes(arr) = {
    arr.split(" ").map(a => codebox("0x"+ a)).join(" ")
  }

  #let table-settings = (
    columns: (12cm, 24cm), 
    align: left, 
    inset: (x: 20pt, y: 7pt),
    stroke: (x, y) => {
      if(x == 0) {
        return (right: 2pt + gray)
      }
      return none
    }
  )

  #let asmtable(arr) = {
    arr.map(a => {
      (
        [#lightasm(a.at(0))], 
        {
          set text(fill: asmcolors-light.number, weight: "semibold")
          raw(a.at(1).split(" ").map(a => "0x" + a).join(" "))
        }
      )
    }).flatten()
  }

  #set text(size: 25pt)
  == #codebox("x86") : инструкции могут иметь разную длину

  #table(..table-settings,
    ..asmtable((
      ("nop", "90"),
      ("mov rbx, rax", "48 89 C3"),
      ("cmovg rax, r15", "49 0F 4F C7"),
      ("mov rax, 0xBADBADBEEF", "48 B8 EF BE AD DB BA 00 00 00")
    ))
  )
  
  == #codebox("AArch64") : все инструкции равнодлинные

  #table(..table-settings,
    ..asmtable((
      ("nop", "1F 20 03 D5"),
      ("mov x1, x0", "E0 03 01 AA"),
      ("csel x0, x15, x0, gt", "E0 C1 80 9A"),
    )),
    [*#raw("???")*], [*#raw("???")*]
  )
]

#slide(background-image: none)[
  #place(horizon)[
    #set text(size: 27pt)
    #let headerbox = (content, index: 0) => {
      set text(weight: "semibold", size: 40pt)
      box(
        stroke: 4pt + cell-color(palette.at(index)).stroke-color, fill: cell-color(palette.at(index)).background-color, inset: 25pt, radius: 20pt
      )[
        #content
      ]
    }
    #table(
      columns: (45%, 55%),
      rows: 2,
      align: (x, y) => {
        if y == 0 { return center + horizon }
        if x == 0 { return center + horizon }
        return left + horizon
      },
      stroke: (x, y) => {
        if y == 0 { return none }
        if x == 0 {
          return (right: 4pt + gray)
        }
        return none
      },
      inset: (x, y) => {
        if y == 0 { return (bottom: 40pt); }
        if x == 0 { return (right: 40pt); }
        return (left: 40pt)
      },
      [#headerbox("x86_64", index: 2)], [#headerbox("AArch64", index: 0)], [
        #lightasm("mov rax, 0xBADBADBEEF")
      ], [
        #lightasm("mov     x8, 0xBEEF")
        #lightasm("movk    x8, 0xDBAD, lsl 16")
        #lightasm("movk    x8, 0xBA,   lsl 32")
      ]
    );
    #v(2em)
  ]

  #place(bottom + center)[
    #set text(size: 24pt)
    В AArch64 #semibold([все инструкции 4-байтные]), поэтому загрузка длинных значений в регистры происходит #semibold([поэтапно]).
    #v(1em)
  ]
]

#slide(background-image: none)[
  = Работа с памятью
  #set block(spacing: 18pt)

  #headerbox("x86_64")[
    #v(0.5em)
    Многие инструкции принимают аргументы из памяти:
    
    #text(size: 20pt)[
      #table(
        columns: 1,
        stroke: none,
        inset: (x: 15pt), 
        lightasm("mov rax, [rbx]"),
        lightasm("add rax, [rbx + 8]"),
        lightasm("xor [rbx + 8], rax")
      )
    ]

    Это называется "#link("https://en.wikipedia.org/wiki/Register–memory_architecture")[*Архитектура регистр-память*]".
  ]

  #headerbox("AArch64")[
    #v(0.5em)
    Все инструкции работают *только с регистрами*. Для работы с памятью используются специальные инструкции:

    #text(size: 20pt)[
      #table(columns: 2, stroke: (x, y) => {
        if x == 0 {
          return (right: 3pt + gray)
        } 
      }, inset: (x: 15pt), 
        lightasm("ldr x0, [x1]"), [#lightasm("load")#text(size: 18pt)[, из памяти в регистр]],
        lightasm("str x0, [x1]"), [#lightasm("store")#text(size: 18pt)[, из регистра в память]]
      )
    ]

    Это называется "*Архитектура регистр-регистр*" (или #link("https://en.wikipedia.org/wiki/Load–store_architecture")[*load-store*]).
  ]
]

#slide(header: [Зачем это всё?], background-image: none, place-location: horizon)[
  #table(
    columns: (50%, 50%),
    align: (x, y) => {
      if y == 0 { return center + bottom }
      return center + top
    },
    stroke: (x, y) => {
      if y == 0 { return (bottom: 3pt + gray) }
      return none
    },
    inset: 20pt,
  [
    #set text(size: 30pt)
    #lightasm("add rax, [rbx + 8]")
  ], [
    #box[
      #set text(size: 30pt)
      #set align(left)
      #set list(marker: none)
      - #lightasm("ldr x0, [x1]")
      - #lightasm("add x0, x0, 8")
    ]
  ], [
    *Инструкций меньше*, но процессор всё равно разбивает их на простые операции.
  ], [
    Инструкций больше, но *процессор~проще*
  ])

  - *Сокращённый набор инструкций* и load-store архитектура упрощает ядро.

  - *Инструкции фиксированного размера* проще декодировать.

  - Проще ядро - *выше эффективность*.
]

#slide(background-image: none)[
  = Больше упрощений!
  #let instr(content) = {
    box(width: 100%, stroke: (right: 3pt + gray), inset: (right: 10pt, y: 3pt), content)
  }
  #let cross(content) = {
    cetz.canvas(length: 1cm, {
      let lx = -2
      let rx = 2
      cetz.draw.content((0, 0.1), content)
      cetz.draw.set-style(stroke: 5pt + black)
      cetz.draw.line((lx - .02, 1.02), (rx + .02, -1.02))
      cetz.draw.line((rx + .02, 1.02), (lx - .02, -1.02))
      cetz.draw.set-style(stroke: 4pt + red)
      cetz.draw.line((lx, 1), (rx, -1))
      cetz.draw.line((rx, 1), (lx, -1))
    })
  }
  #place(horizon)[
    #text(size: 40pt)[
      #table(
        columns: (50%, 50%),
        stroke: none,
        align: center,
        [#cross(lightasm("push rax"))], [#cross(lightasm("pop rax"))]
      )
    ]

    #align(center)[
      = Стек на AArch64 выровнен по 16 байт.

      #v(1em)

      #box(width: 20cm)[
        #set align(left)
        - Регистры - *до 8 байт*, #mnemonic("push") и #mnemonic("pop") реализовать не получится;

        - Сдвигать #register("sp") и записывать стек нужно вручную;

        - Адрес возврата тоже не запушить;

        - *Опять нужно переизобретать #mnemonic("call")?*
      ]
    ]
  ]
]

#slide(header: [Как работал #mnemonic("call") на x86_64], background-image: none)[
  #set text(weight: "semibold", size: 30pt)
  #place(center + horizon)[
    #table(
      columns: (12cm, 12cm),
      align: horizon,
      stroke: none,
      
      lightasmtable(
        ```asm
          # Вызов функции  
          lea rax, [rip + X]
          push rax
          jmp _my_func
        ```
      ),
      lightasmtable(
        ```asm
          # Выход из функции
          pop rax
          jmp rax
        ```
      )
    )
  ]
]

#slide(header: ["Эквивалентный" код на AArch64], background-image: none)[
  #place(center + horizon, dy: -1cm)[
    #set text(size: 30pt)
    #table(
      columns: (12cm, 12cm),
      align: horizon,
      stroke: none,
      
      lightasmtable(
        ```asm
          # Вызов функции  
          adr x30, 12
          str x30, [sp, -16]!
          b _my_func
        ```
      ),
      lightasmtable(
        ```asm
          # Выход из функции
          ldr x30, [sp], 16
          br x30
        ```
      )
    )
  ]

  #uncover((beginning: 2))[
    #place(bottom, dy: -1cm)[
      #set text(size: 20pt)
      - Сдвиг #register("pc") *всегда будет по 16 байт* (размер инструкций фиксирован);

      - Но наш аналог #lightasm("push x30") *теряет 8 байт стека* (из-за выравнивания по 16 байт).
    ]
  ]
]

#slide(header: [Вспомним про стековый фрейм], background-image: none)[
   
  #headerbox("x86_64")[
    #place(horizon + center)[
      #set text(size: 25pt, weight: "semibold")
      #cetz.canvas(length: 1cm, {
        cetz.draw.content((-15, 6.5), (15, -1.6), []);

        cetz.draw.set-style(stroke: 3pt)

        cetz.draw.rect(
          (-15, 5), 
          (15, 2.85),
          fill: blue.desaturate(95%),
          stroke: none
        )

        cetz.draw.rect(
          (-15, 1.8), 
          (15, -0.27),
          fill: blue.desaturate(95%),
          stroke: none
        )

        cetz.draw.line(
          (3.5, 5), 
          (3.5, 2.85),
          flip: false,
          stroke: white + 4pt,
        )

        cetz.draw.line(
          (3.5, 1.8), 
          (3.5, -0.27),
          flip: false,
          stroke: white + 4pt,
        )

        cetz.draw.content((4.5, 5), (15, 2.85))[
          #set align(horizon)
          #raw("Создание фрейма")
        ]
        cetz.draw.content((4.5, 1.8), (15, -0.27))[
          #set align(horizon)
          #raw("Очистка фрейма")
        ]
      })
    ]
  
    #text(size: 25pt)[
      #lightasmtable(numbers: true,
        ```asm
        _my_func:
          push rbp
          mov rbp, rsp
          # ...
          mov rsp, rbp
          pop rbp
          ret  
        ```
      )
    ]
  ]

  - В начале вызванной процедуры происходит *ещё один* #mnemonic("push") ;

  - Перед возвратом происходит *ещё один* #mnemonic("pop") ;

  - Каждый такой #mnemonic("push") и #mnemonic("pop") в AArch64 *потерял бы лишние 8 байт стека*.
]

#focus-slide[
  #text(size: 40pt)[*Можно ли не терять стек?*]
]

#let cellpos = (i) => { i * 3cm }
#let cellright = (i) => { cellpos(i) + 2.5cm / 2 }
#let cellleft = (i) => { cellpos(i) - 2.5cm / 2 }
#let cellmid = (a, b) => { (cellleft(a) + cellright(b)) / 2 }

#let callstep = (palette, insn, i, black: false, width: 1.0) => {
  let width = 2.5cm + (3cm) * (width - 1)

  cetz.draw.content((cellleft(i), 1.5), (cellleft(i) + width, -1.5))[
    #box(width: 100%, height: 100%, fill: palette.background-color, stroke: 3pt + palette.stroke-color, radius: 10pt)[
      #set align(horizon + center)
      #if type(insn) == str {
        if black {
          set text(size: 1.2em, fill: luma(150), weight: "bold")
          raw(insn)
        } else {
          mnemonic(insn)
        }
      } else {
        if black {
          set text(fill: luma(150))
          insn
        } else {
          insn
        }
      }
    ]
  ]
}

#slide(header: [Этапы вызова функции в x86_64])[
  #let outer = cell-color(palette.at(1))
  #let inner = cell-color(palette.at(5))
  #let body = cell-color(palette.at(0))  
  
  #align(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((cellleft(0), 4), (cellright(7), -5), [])
      
      callstep(outer, "push", 0)
      callstep(outer, "jmp", 1)
      callstep(inner, "push", 2)
      callstep(body, [*Тело функции*], 3.3, width: 1.4)
      callstep(inner, "pop", 5)
      callstep(outer, "pop", 6)
      callstep(outer, "jmp", 7)

      cetz.draw.set-style(stroke: 3pt)
      cetz.decorations.flat-brace((cellleft(0), 2), (cellright(1), 2))
      cetz.draw.content((cellmid(0, 1), 3), [#mnemonic("call")])

      cetz.decorations.flat-brace((cellleft(6), 2), (cellright(7), 2))
      cetz.draw.content((cellmid(6, 7), 3), [#mnemonic("ret")])

      cetz.draw.set-style(mark: (start: ">"))
      cetz.draw.bezier((cellmid(2, 2), -2), (cellmid(3, 3), -4), (cellmid(2, 2), -3), (cellmid(3, 3), -3))
      cetz.draw.bezier((cellmid(5, 5), -2), (cellmid(4, 4), -4), (cellmid(5, 5), -3), (cellmid(4, 4), -3))
      
      cetz.draw.content((cellmid(2, 5) - 3.5cm, -4.5), (cellmid(2, 5) + 3.5cm, -6.5), [
        #set align(center)
        *Создание / очистка стекового фрейма*
      ])

      cetz.draw.set-style(stroke: 2pt + black, fill: black, mark: (start: none, end: ">"))
      cetz.draw.line((cellright(2) + 0.3cm, 0), (cellleft(3.5) - 0.9cm, 0))

      cetz.draw.line((cellright(3.5) + 1.0cm, 0), (cellleft(5) - 0.2cm, 0))
    })
  ]
]

#slide[
  #let push = cell-color(palette.at(1))
  #let pop = cell-color(palette.at(1))
  #let unneeded = (
    stroke-color: luma(150),
    background-color: none
  )
  
  #align(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((cellleft(0), 4), (cellright(7), -5), [])
      
      callstep(push, "push", 0)
      callstep(unneeded, "jmp", 1, black: true)
      callstep(push, "push", 2)
      callstep(unneeded, [*Тело функции*], 3.3, width: 1.4, black: true)
      callstep(pop, "pop", 5)
      callstep(pop, "pop", 6)
      callstep(unneeded, "jmp", 7, black: true)

      cetz.draw.set-style(stroke: 2pt + black, fill: black, mark: (start: none, end: ">"))
      cetz.draw.line((cellright(2) + 0.3cm, 0), (cellleft(3.5) - 0.9cm, 0))

      cetz.draw.line((cellright(3.5) + 1.0cm, 0), (cellleft(5) - 0.2cm, 0))
    })
  ]

  #place(center + horizon, dy: 3cm)[
    *Проблема:* каждый #mnemonic("push") использует только половину 16-байтной ячейки стека.

    *Что, если склеить вместе два #mnemonic("push") и два #mnemonic("pop"), и использовать все 16 байт*?
  ]
]

#slide(header: [Как объединить два #mnemonic("push")?], background-image: none)[
  #let push = cell-color(palette.at(1))
  #let pop = cell-color(palette.at(1))
  #let jmp = cell-color(palette.at(0))
  #let unneeded = (
    stroke-color: luma(150),
    background-color: none
  )

  #let rest = {
    cetz.draw.content((cellleft(0), 2), (cellright(7), -2), [])
      
    callstep(unneeded, [*Тело функции*], 3.3, width: 1.4, black: true)
    callstep(unneeded, "double pop", 5, width: 2, black: true)
    callstep(unneeded, "jmp", 7, black: true)

    cetz.draw.set-style(stroke: 2pt + black, fill: black, mark: (start: none, end: ">"))
    cetz.draw.line((cellright(2) + 0.3cm, 0), (cellleft(3.5) - 0.9cm, 0))

    cetz.draw.line((cellright(3.5) + 1.0cm, 0), (cellleft(5) - 0.2cm, 0))
  }

  #align(horizon + center)[
    #cetz.canvas(length: 1cm, {
      rest

      callstep(push, "double push", 0, width: 2)
      callstep(jmp, "jmp", 2)
    })

    #align(horizon)[
      #box(height: 1em)[#line(stroke: 3pt, length: 40%)]
      #h(1em)
      #box(height: 1em)[Или]
      #h(1em)
      #box(height: 1em)[#line(stroke: 3pt, length: 40%)]
    ]

    #cetz.canvas(length: 1cm, {
      rest
      
      callstep(jmp, "jmp", 0)
      callstep(push, "double push", 1, width: 2)
    })
  ]

  #place(left + bottom)[
    #uncover((beginning: 2))[
      #colbox(color: green)[*Ответ: *] *Оба варианта сработают*, но верхний запретит функции без фрейма.
    ]
  ]
]

#slide(header: [Объединение #mnemonic("push") и #mnemonic("pop")], background-image: none)[
  #set text(size: 30pt)
  #place(center + horizon, dx: -1.5cm)[
    #table(
      columns: (15cm, 15cm),
      align: horizon + center,
      stroke: none,
      
      lightasmtable(
        ```asm
        _main:
          adr x30, 12
          str x30, [sp, -16]!
          b _my_func

          # ...
        ```
      ),
      lightasmtable(
        ```asm
        _my_func:
          str x29, [sp, -16]!
          mov x29, sp

          # Тело функции
          
          ldr x29, [sp], 16
          ldr x30, [sp], 16
          br x30
        ```
      )
    )
  ]
]

#slide(header: [Объединение #mnemonic("push") и #mnemonic("pop") -- шаг 1 / 2], background-image: none)[
  #set text(size: 30pt)
  #place(center + horizon, dx: -1.5cm)[
    #table(
      columns: (15cm, 15cm),
      align: horizon + center,
      stroke: none,
      
      lightasmtable(
        ```asm
        _main:
          adr x30, 8
          str x30, [sp, -16]!
          b _my_func

          # ...
        ```
      ),
      lightasmtable(
        ```asm
        _my_func:
          str x30, [sp, -16]!
          str x29, [sp, -16]!
          mov x29, sp

          # Тело функции
          
          ldr x29, [sp], 16
          ldr x30, [sp], 16
          br x30
        ```
      )
    )
  ]

  #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.set-style(stroke: 4pt + black)
      cetz.draw.content((-15, 10), (15, -10), [])
      cetz.draw.bezier((-1, 0.2), (2, 3.6), (2, 0.2), (0, 3.6))
      cetz.draw.line((2, 3.6), (2.5, 3.6), mark: (end: ">"))

      cetz.draw.set-style(stroke: none)
      cetz.draw.rect((-7.4, 2.3), (-6.5, 1.2), fill: green.transparentize(70%))
      cetz.draw.rect((3,    3.3), (13,   4.5), fill: green.transparentize(70%))
      cetz.draw.rect((-12,  1.2), (-2,   -0.1), fill: red.transparentize(70%))

    })
  ]
]

#slide(header: [Объединение #mnemonic("push") и #mnemonic("pop") -- шаг 2 / 2], background-image: none)[
  #set text(size: 30pt)
  #place(center + horizon, dx: -1.5cm)[
    #table(
      columns: (15cm, 15cm),
      align: horizon + center,
      stroke: none,
      
      lightasmtable(
        ```asm
        _main:
          adr x30, 8
          b _my_func

          # ...
        ```
      ),
      lightasmtable(
        ```asm
        _my_func:
          stp x29, x30, [sp, -16]!
          mov x29, sp

          # Тело функции
          
          ldp x29, x30, [sp], 16
          br x30
        ```
      )
    )
  ]

  #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((-15, 10), (15, -10), [])
      cetz.draw.set-style(stroke: none)
      cetz.draw.rect((1.7, 2.2), (14.3, 3.4), fill: green.transparentize(70%))
      cetz.draw.rect((1.7, -3.4), (14.3, -2.3), fill: green.transparentize(70%))
    })
  ]
]

#slide(header: [Объединение #mnemonic("push") и #mnemonic("pop") -- шаг 3 / 2], background-image: none)[
  #set text(size: 30pt)
  #place(center + horizon, dx: -1.5cm)[
    #table(
      columns: (15cm, 15cm),
      align: horizon + center,
      stroke: none,
      
      lightasmtable(
        ```asm
        _main:
          adr x30, 8
          b _my_func
          bl _my_func

          # ...
        ```
      ),
      lightasmtable(
        ```asm
        _my_func:
          stp x29, x30, [sp, -16]!
          mov x29, sp

          # Тело функции
          
          ldp x29, x30, [sp], 16
          br x30
          ret
        ```
      )
    )
  ]

  #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((-15, 10), (15, -10), [])
      cetz.draw.set-style(stroke: none)
      
      cetz.draw.rect((1.6, -4), (5.5, -2.8), fill: red.transparentize(70%))
      cetz.draw.rect((1.6, -5.2), (5.5, -4), fill: green.transparentize(70%))

      cetz.draw.rect((-10, 1.2),  (-4.2, 0), fill: red.transparentize(70%))
      cetz.draw.rect((-10, 2.4),  (-3.8, 1.2), fill: red.transparentize(70%))
      cetz.draw.rect((-10, 0),    (-3.8, -1.2), fill: green.transparentize(70%))
    })
  ]

  #place(bottom + center, dy: -0.2cm)[
    #set text(size: 20pt)
    #set block(spacing: 12pt)
    #mnemonic("bl") и #mnemonic("ret") устроены *значительно проще*, чем #mnemonic("call") и #mnemonic("ret") в x86.
    
    Они работают *только с регистрами*.
  ]
]

#slide(background-image: none)[
  = Cоглашение о вызове

  #align(horizon)[
    #table(columns: 2,
      stroke: (x, y) => {
        if x == 0 {
          (right: gray + 3pt)
        }
        none
      },
      inset: (x: 10pt, y: 7pt),
      [#register("x0") - #register("x7")], [Передача *аргументов* и *возвращаемого значения*],
      [#register("x8")], [Указатель на возвращаемую структуру],
      [#register("x0") - #register("x15")], [*Caller-saved* - регистры],
      [#register("x16") - #register("x18")], [Intra-procedure-call corruptible registers. Проще говоря - *Caller-saved*.],
      [#register("x19") - #register("x28"), #register("sp")], [*Callee-saved* - регистры],
      [#register("x29")], [Frame pointer],
      [#register("x30")], [Link register, или *адрес возврата*],
    )

    *Аргументы* передаются через первые 8 регистров. Лишнее передаётся через стек.
  ]
]

#focus-slide[
  #text(size: 40pt)[*Флаги*]
]

#slide(header: [Регистр флагов AArch64], background-image: none, {
  set align(horizon + center)
  set text(size: 30pt)
  let color(i) = {
    if i < 4 {
      palette.at(0)
    } else {
      black
    }
  }

  box(baseline: 0.65cm + 2cm)[
    #table(
      columns: (1.6cm,) * 4 + (14cm,),
      rows: 2.0cm,
      fill: (x, y) => {
        if y == 1 { return none }
        cell-color(color(x)).background-color
      },
      stroke: (x, y) => {
        if y == 1 { return none }
        2pt + cell-color(color(x)).stroke-color
      },
      ..("N", "Z", "C", "V", [И еще 28 неиспользуемых бит]).map(a => {
        if(type(a) == str) {
          text(weight: "bold", raw(a))
        } else {
          text(size: 20pt, weight: "semibold")[
            #a
          ]
        }
      }),
      ..(
        [*Negative Condition Flag* -- результат меньше нуля],
        [*Zero Condition Flag* -- результат нулевой],
        [*Carry Condition Flag* -- результат беззнаково переполнился],
        [*Overflow Condition Flag* -- результат знаково переполнился],
      ).map(a => {
        set text(size: 16pt)
        set align(left)
        move(dx: 0.5cm)[
          #rotate(25deg)[
            #box(width: 17cm, height: 1cm)[
              #a
            ]
          ]
        ]
      })
    )
  ]
  h(0.8em)
  lightasm("=")
  register(" NZCV")
  h(2em)
  v(4cm)
})

#slide(background-image: none)[
  = Установка флагов

  - По умолчанию, инструкции *не меняют регистр флагов*;
  - Это делают только их *версии с суффиксом #mnemonic("s")*.
  - Исключения: #mnemonic("CMP") , #mnemonic("CMN") , #mnemonic("CCMP") , #mnemonic("CCMN") , #mnemonic("TST") -- всегда обновляют флаги.

  = Условные инструкции

  К некоторым инструкциям можно добавить #link("https://developer.arm.com/documentation/dui0801/a/Condition-Codes/Condition-code-suffixes?lang=en")[условный суффикс].

  #table(
    columns: (4cm, 6cm, 10cm, 8cm),
    align: (horizon + center,) * 3 + (left, ),
    stroke: (x, y) => {
      if x == 0 or x == 1 or x == 2 {
        (right: 2pt + gray)
      }
      none
    },
    inset: (x: 20pt, y: 3pt),
    [#mnemonic("EQ")],                  [#codebox("Z")],            [Равно, ноль],      [Обратный -- #mnemonic("NE")],
    [#mnemonic("CS"), #mnemonic("HS")], [#codebox("C")],            [Беззнаково >=],    [Обратный -- #mnemonic("CC"), #mnemonic("LO")],
    [#mnemonic("MI")],                  [#codebox("N")],            [Меньше нуля],      [Обратный -- #mnemonic("PL")],
    [#mnemonic("VS")],                  [#codebox("V")],            [Переполнение],     [Обратный -- #mnemonic("VC")],
    [#mnemonic("HI")],                  [#codebox("C && !Z")],      [Беззнаково >],     [Обратный -- #mnemonic("LS")],
    [#mnemonic("GE")],                  [#codebox("N == V")],       [Знаково >= ],      [Обратный -- #mnemonic("LT")],
    [#mnemonic("GT")],                  [#codebox("!Z && N == V")], [Знаково > ],       [Обратный -- #mnemonic("LE")],
  )
]

#slide(header: [Пример: подсчёт $3^n$], background-image: none)[
  #align(horizon + center)[
    #set text(size: 30pt)
    #lightasmtable(numbers: true,
      ```asm
      _pow3: 
        mov x8, 1
        tst x0, x0
        b.eq exit
        loop:
        add x8, x8, x8, lsl 1
        subs x0, x0, 1
        b.ne loop
        exit:
        mov x0, x8
        ret
      ```
    )
  ]
]

#focus-slide[
  #text(size: 40pt)[*Интерактив*]
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