
#import "@preview/polylux:0.4.0": *
#import "@preview/cetz:0.3.4"
#import "../theme/theme.typ": *
#import "../theme/asm.typ": *
#import "./utils.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Ассемблер (x86)

    АКОС, МФТИ

    02 октября, 2025
  ]
]

#show: enable-handout

#slide(header: [Архитектура фон Неймана], place-location: horizon + center)[
  #cetz.canvas(length: 1cm, {
    let globalBounds = ((-12, 5), (12, -5))
    cetz.draw.content(..globalBounds, [])

    let processorBounds = ((-5,  5),     (5,   -5))
    let aluBounds       = ((-4,  4),     (4,    1.25))
    let cuBounds        = ((-4,  -0.5),  (4,   -4))

    let memBounds       = ((-12,  5),    (-8,  -5))
    let inputBounds     = ((8,    5),    (12,   0.5))
    let outputBounds    = ((8,   -0.5),  (12,  -5))

    let blueBox = (stroke: 3pt + cell-color(palette.at(0)).stroke-color, fill: cell-color(palette.at(0)).background-color, radius: 10pt)

    let blackBox = (stroke: 3pt + cell-color(black).stroke-color, fill: cell-color(black).background-color)

    cetz.draw.rect(..processorBounds, ..blueBox)
    cetz.draw.rect(..aluBounds, ..blackBox)
    cetz.draw.rect(..cuBounds, ..blackBox)
    cetz.draw.rect(..memBounds, ..blueBox)
    cetz.draw.rect(..inputBounds, ..blueBox)
    cetz.draw.rect(..outputBounds, ..blueBox)

    let content(bounds, content) = {
      cetz.draw.content(..bounds)[
        #set align(horizon + center)
        #set text(size: 25pt, weight: "bold")
        #content
      ]
    }

    content(cuBounds)[Управляющее устройство]
    content(aluBounds)[АЛУ]
    content(memBounds)[#rotate(-90deg)[Память]]
    content(inputBounds)[#rotate(-90deg)[Ввод]]
    content(outputBounds)[#rotate(-90deg)[Вывод]]

    cetz.draw.set-style(mark: (end: ">"), stroke: 10pt + black, fill: none)

    cetz.draw.line((-5.5, -2), (-7.5, -2));
    cetz.draw.line((-7.5, -3), (-5.5, -3));

    cetz.draw.bezier((7.5, 2.5), (6.5, -2), (6, 2.5), (8, -2), mark: none);
    cetz.draw.line((6.5, -2), (5.5, -2));
    cetz.draw.line((5.5, -3), (7.5, -3));

    cetz.draw.line((-0.5, -0.25), (-0.5, 1));
    cetz.draw.line((0.5,  1), (0.5,  -0.25));
  })
]

#slide(background-image: none, place-location: horizon + center)[
  #text(size: 40pt, weight: "bold")[
    🔗 #link("https://nandgame.com")[nandgame.com]
  ]
  
  *Игра про создание своего процессора из реле*
]

#slide(background-image: none)[
  = С чем работает процессор?

  #set par(spacing: 10pt)

  #set list(marker: none)
  - #pro() С *тривиальными инструкциями*, закодированными в бинарном виде;
  - #pro() С *8-, 16-, 32-, 64-битными числами* (иногда до 512 бит);
  - #pro() С *адресами памяти* (опять же, в виде чисел).
  - #pro() *Со стеком* (регистр для указателя на стек #codebox("sp"), инструкции #codebox("push") / #codebox("pop")).

  = С чем не работает процессор?

  - #con() *Структуры, классы, строки* -- всё это абстракции над адресами памяти;
  - #con() *Массивы данных*. Каждый элемент нужно обрабатывать отдельно.
  - #con() *Функции, методы, исключения*. Всё, что есть -- это стек;

  *Задача процессора* -- уметь очень быстро выполнять простые инструкции, из которых уже можно составлять сложные программы.
]

#slide(header: [Что такое инструкция?], background-image: none, context {
  let asm-text = "mov rbx, rax"
  let asm = {
    set text(weight: "semibold", size: 40pt)

    highlight(asm-text, asmcolors-light)
  }
  let asm-width = measure(asm).width.cm()
  let char-width = asm-width / asm-text.len()

  place(center + horizon, {
    cetz.canvas(length: 1cm, {
      let storke-width = 3pt
      cetz.draw.content((-5, 2), (asm-width + 5, 2), {});
      cetz.draw.content((0, 0), (asm-width, 0), asm)
      cetz.draw.set-style(stroke: storke-width)
      let options = (
        char-width: char-width,
      )

      underline(0, 3, 2, content: [
        #semibold([Мнемоника]) (название операции)
      ], ..options)
      underline(4, 7, 1, content: [
        #semibold([Первый операнд])
        ], ..options)
      underline(9, 12, 0, content: [
        #semibold([Второй операнд])
      ], ..options)
    })
  })

  place(bottom + center, {
    set text(size: 25pt, weight: "semibold")
    [Для процессора она выглядит как #codebox("48 89 C3")]
  })
})

#slide(header: [Что такое инструкция?], background-image: none, context {
  let asm-text = "lea rax, [rbx + rcx * 2 + 7]"
  let asm = {
    set text(weight: "semibold", size: 40pt)

    highlight(asm-text, asmcolors-light)
  }
  let asm-width = measure(asm).width.cm()
  let char-width = asm-width / asm-text.len()

  place(center + horizon, {
    cetz.canvas(length: 1cm, {
      let storke-width = 3pt
      cetz.draw.content((-5, 2), (asm-width + 5, 2), {});
      cetz.draw.content((0, 0), (asm-width, 0), asm)
      cetz.draw.set-style(stroke: storke-width)
      let options = (
        char-width: char-width,
        content-right-anchor: 20,
      )

      underline(0, 3, 2, content: [
        #semibold([Мнемоника]) (название операции)
      ], ..options)
      underline(4, 7, 1, content: [
        #semibold([Первый операнд])
        ], ..options)
      underline(9, 28, 0, content: [
        #semibold([Все еще второй операнд])
      ], ..options)
    })
  })

  place(bottom + center, {
    set text(size: 25pt, weight: "semibold")
    [Для процессора она выглядит как #codebox("48 8D 44 4B 07")]
  })
})

#slide(header: [Наборы инструкций], background-image: none)[
  #set text(size: 20pt)
  #place(horizon)[
    == #codebox("x86 (x86_64)")

    - Наиболее распространённый на *настольных компьютерах* / ноутбуках;
    
    - Использует *CISC* - Complex Instruction Set.

    == #codebox("arm(v1 ... v8)")

    - Живёт на *большинстве телефонов*, роутеров, во встраиваемых системах;

    - Cейчас захватывает и настольный рынок (Apple M1, Snapdragon X);

    - Использует *RISC* - Reduced Instruction Set.
  ]

  #place(bottom + center)[
    Еще есть MIPS и PowerPC , но их мы не затронем.
  ]
]

#slide(background-image: none)[
  #let asm(str) = codebox(lang: "asm", str)

  #let codeboxes(arr) = {
    arr.split(" ").map(a => codebox("0x"+ a)).join(" ")
  }

  #let table-settings = (
    columns: (12cm, 10cm), 
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
  === #codebox("CISC") : инструкции могут иметь разную длину

  #table(..table-settings,
    ..asmtable((
      ("nop", "90"),
      ("mov rbx, rax", "48 89 C3"),
      ("cmovg rax, r15", "49 0F 4F C7"),
    ))
  )
  
  === #codebox("RISC") : все инструкции равнодлинные

  #table(..table-settings,
    ..asmtable((
      ("nop", "1F 20 03 D5"),
      ("mov x1, x0", "E0 03 01 AA"),
      ("csel x0, x15, x0, gt", "E0 C1 80 9A"),
    ))
  )
]

#focus-slide[
  #text(size: 40pt)[*x86*]
]

#let impossible-register() = {
  let pat = tiling(size: (25pt, 25pt))[
    #let stroke = 2pt + color.gray
    #place(line(stroke: stroke, start: (0%, 0%), end: (100%, 100%)))
    #place(line(stroke: stroke, start: (-100%, 0%), end: (100%, 200%)))
    #place(line(stroke: stroke, start: (0%, -100%), end: (200%, 100%)))
  ]
  box(width: 100%, height: 100%, fill: pat)
}

#let register-size(content) = {
  set text(weight: "bold", fill: asmcolors-light.instruction)
  set align(right)
  raw(content)
}

#let regtable-settings = (
  columns: (4cm,) + (2.5cm,) * 8 + (4cm,),
  rows: (0.9cm) * 2,
  inset: (x, y) => {
    if x == 0 {
      16pt
    } else {
      8pt
    }
  },
  align: center,
  stroke: (x, y) => {
    if x > 0 and x <= 8 {
      2pt + black
    } else {
      none
    }
  }
)

#slide(background-image: none)[
  #set text(weight: "semibold")
  #table(
    inset: (x, y) => {
      if y == 0 { (bottom: 18pt) }
      else if (y == 10) { (top: 18pt, bottom: 18pt)  }
      else { 8pt }
    },
    columns: 2,
    align: (x, y) => {
      if y == 0 or y == 10 { left }
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
      [= 16-битные регистры общего назначения]
    ),
    register("ax"), [Accumulator],
    register("bx"), [Base index (для работы с массивами)],
    register("cx"), [Counter],
    register("dx"), [Accumulator extension],
    [#register("r8w") - #register("r15w")], [У этих даже названия нет, просто регистры],
    register("sp"), [Stack pointer],
    register("bp"), [Base pointer],
    register("si"), [Source index],
    register("di"), [Destination index],

    table.cell(
      colspan: 2,
      [= Специальные 16-битные регистры:],
    ),

    register("ip"), [Instruction pointer],
    register("flags"), [Скрытый регистр флагов: переполнение, чётность, знак, ...],
  )
]

#slide(header: [Вложенность регистров -- #register("ax")])[
  #place(horizon + center)[
    #set text(size: 25pt)
    #table(
      ..regtable-settings,
      register-size("uint64_t"),
      table.cell(colspan: 8, register("rax")),
      [],
      register-size("uint32_t"),
      table.cell(colspan: 4, impossible-register()),
      table.cell(colspan: 4, register("eax")),
      [],
      register-size("uint16_t"),
      table.cell(colspan: 6, impossible-register()),
      table.cell(colspan: 2, register("ax")),
      [],
      register-size("uint8_t"),
      table.cell(colspan: 6, impossible-register()),
      table.cell(colspan: 1, register("ah")),
      table.cell(colspan: 1, register("al")),
      []
    )
    #set text(size: 20pt)
    #semibold([
      Аналогично работают #register("bx"), #register("cx"), #register("dx")
      
      #register("sp"), #register("bp"), #register("si"), и #register("di"), не имеют вариантов с #register("h") в конце.

      #register("ip") в чистом виде не встречается, только #register("eip") и #register("rip").
    ])
  ]
]

#slide(header: [Вложенность регистров -- #register("r10")])[
  #place(horizon + center)[
    #set text(size: 25pt)
    #table(
      ..regtable-settings,
      register-size("uint64_t"),
      table.cell(colspan: 8, register("r10")),
      [],
      register-size("uint32_t"),
      table.cell(colspan: 4, impossible-register()),
      table.cell(colspan: 4, register("r10d")),
      [],
      register-size("uint16_t"),
      table.cell(colspan: 6, impossible-register()),
      table.cell(colspan: 2, register("r10w")),
      [],
      register-size("uint8_t"),
      table.cell(colspan: 7, impossible-register()),
      table.cell(colspan: 1, register("r10b")),
      []
    )
    #set text(size: 20pt)
    #semibold([Аналогично работают #register("r8") ... #register("r15")])
  ]
]

#slide(background-image: none)[
  #set text(size: 25pt)
  #let header(content) = {
    box(inset: (x: 0pt, y: 15pt))[
      #text(size: 37pt, weight: "bold")[
        #content
      ]
    ]
  }
  #let smalltext(content) = {
    text(size: 16pt, weight: "bold", content)
  }
  #set par(spacing: 14pt)
  #table(
    columns: (14cm, 14cm),
    inset: (x: 20pt, y: 5pt),
    stroke: (x, y) => {
      if x == 0 and y != 0 and y != 4 {
        (right: 2pt + black)
      }
      none
    },
    align: (col, row) => {
      if row == 0 { center }
      else if row < 4 { left }
      else { left + top }
    },
    header([*Intel*]), header([*AT&T*]),
    lightasm("mov rax, 5"), lightasm("movq $5, %rbx"),
    lightasm("lea eax, [ecx + ebx * 2 + 7]"), lightasm("leal 7(%ecx, %ebx, 2), %eax"),
    lightasm("and DWORD PTR [eax], 7"), lightasm("andl $7, (%eax)"),
    v(0.5em), [],
    smalltext[
      - Порядок операндов: #codebox("куда") #sym.arrow.l #codebox("откуда");
      - Адреса: #codebox("[base + index * scale + offset]")
      - Битность инструкции обычно угадывается;
      - Если не угадывается, то есть директивы:
        - #codebox("BYTE PTR") - 1 байт
        - #codebox("WORD PTR") - 2 байта
        - #codebox("DWORD PTR") - 4 байт
        - #codebox("QWORD PTR") - 8 байт
    ], smalltext[
      - Порядок операндов: #codebox("откуда") #sym.arrow.r #codebox("куда")
      - Адреса: #codebox("offset(base, index, scale)")
      - Битность явно указывается суффиксом:
        - #codebox("b") - 1 байт
        - #codebox("w") - 2 байта
        - #codebox("l") - 4 байт
        - #codebox("q") - 8 байт
      - Перед каждым регистром #text(size: 1.2em, fill: asmcolors-light.register)[#raw("%")], перед каждым числом #text(size: 1.2em, fill: asmcolors-light.number)[#raw("$")]
    ])
]

#slide(header: [Базовые инструкции], background-image: none)[
  #set par(leading: 0pt)
  #set block(spacing: 0pt)
  #set list(marker: none)
  #let instr(content) = {
    box(width: 100%, stroke: (right: 3pt + gray), inset: (right: 10pt, y: 3pt), content)
  }
  #table(
    columns: (3cm, auto),
    align: (col, row) => {
      if col == 0 { center }
      else { left + top }
    },
    inset: ((right: 10pt, y: 3pt),(left: 10pt, top: 7pt)),
    stroke: none,
    instr(lightasm("mov")), [Перенести значение между регистрами / памятью.],
    instr(lightasm("lea")), [Загрузить адрес второго операнда в первый.],
    instr([
      - #lightasm("add")
      - #lightasm("sub")
      - #lightasm("and")...
    ]), [Арифметика / логика над значением в регистре / памяти.
    
    Работают как #codebox(lang: "c", "+="), #codebox(lang: "c", "-="), #codebox(lang: "c", "&="), #codebox(lang: "c", "|="), #codebox(lang: "c", "^="), #codebox(lang: "c", "~="), ... в Си.],
    instr(lightasm("neg")), [Поменять знак значения в регистре / памяти],
    instr([
      - #lightasm("imul")
      - #lightasm("mul")
    ]), [Знаковое / беззнаковое умножение.],
    instr([
      - #lightasm("idiv")
      - #lightasm("div")
    ]), [Знаковое / беззнаковое деление.],
    instr(lightasm("cmp")), [Математическое сравнение величин (результат в #lightasm("flags")).],
    instr(lightasm("test")), [Побитовое сравнение величин (результат в #lightasm("flags")).],
    instr([
      - #lightasm("push")
      - #lightasm("pop")
    ]), [Добавить / считать значение со стека.],
    instr(lightasm("jmp")), [Переход в другое место программы.],
    instr(lightasm("syscall")), [Системный вызов.]
  )
]

#slide(background-image: none, place-location: horizon + center)[
  = Минимальная корректная программа на ассемблере:

  #v(1em)
  
  #box(width: 15cm)[
    #set text(weight: "semibold", size: 30pt)

    #code(numbers: true, leading: 5pt,
      ```asm
      _main:
        mov rax, SYS_EXIT
        mov rdi, (код возврата)
        syscall
      ```
    )
  ]

  #v(1em)

  #box(width: 20cm)[
    #set align(left)
    - Выполняет *системный вызов* #codebox(lang: "c", "exit(int retval)");

    - *Номер* системного вызова передаётся в #register("rax");
    
    - *Аргумент* системного вызова передаётся в #register("rdi");

    - *Системный вызов* выполняется инструкцией #mnemonic("syscall").
  ]
]


#focus-slide[
  #text(size: 40pt, weight: "bold", [Как выразить вызов функции?])
]

#slide(background-image: none, place-location: horizon + center)[
  #set text(weight: "semibold", size: 30pt)
  #box(width: 20cm)[
    #code(leading: 5pt, numbers: true,
      ```c
      uint64_t global_var;

      void my_func() {
        // Делаем что-то полезное здесь
        global_var = 42;
      }

      void main() {
        my_func();
        __exit(global_var);
      }
      ```
    )
  ]
]

#slide(background-image: none, place-location: horizon + center)[
  #set text(weight: "semibold", size: 30pt)
  #box(width: 20cm)[
    #lightasmtable(numbers: true,
      ```asm
      # global_var = r10

      _my_func:
        mov r10, 42
        # return ...?

      _main:
        # _my_func() ...?

        mov rax, SYS_EXIT
        mov rdi, r10
        syscall
      ```
    )
  ]
]

#slide(header: [Вариант 1], background-image: none)[
  #set text(weight: "semibold", size: 30pt)
  #place(horizon + center)[
    #table(
      columns: (12cm, 12cm),
      align: horizon,
      stroke: none,
      
      lightasmtable(
        ```asm
          # Вызов функции  
          mov r10, rip
          add r10, 11
          jmp _my_func
        ```
      ),
      lightasmtable(
        ```asm
          # Выход из функции
          jmp r10
        ```
      )
    )
  ]
  #place(horizon + center)[
    #uncover((beginning: 2))[
      #cetz.canvas(length: 1cm, {
        cetz.draw.set-style(stroke: 5pt + black, mark: (end: ">"))
        cetz.draw.content((0, 0), (33.0, -12.2), {})
        cetz.draw.bezier((16, -2), (14, -5.5), (17, -5.5))
        cetz.draw.content((17, -1), [
          А так нельзя!
        ])
      })
    ]
  ]
  #place(center + bottom)[
    #set text(size: 20pt)
    #super[\*] Сдвиг не всегда будет 11 байт, размер инструкции #mnemonic("jmp") может отличаться
  ]
]

#slide(header: [Вариант 2 -- #mnemonic("lea")], background-image: none)[
  #set text(weight: "semibold", size: 30pt)
  #place(center + horizon)[
    #table(
      columns: (12cm, 12cm),
      align: horizon,
      stroke: none,
      
      lightasmtable(
        ```asm
          # Вызов функции  
          lea r10, [rip + 5]
          jmp _my_func
        ```
      ),
      lightasmtable(
        ```asm
          # Выход из функции
          jmp r10
        ```
      )
    )
  ]
  #place(horizon + center)[
    #uncover((beginning: 2))[
      #cetz.canvas(length: 1cm, {
        cetz.draw.set-style(stroke: 5pt + black, mark: (end: ">"))
        cetz.draw.content((0, 0), (30.0, -12.2), {})
        cetz.draw.bezier((15, -10), (19, -7.5), (19, -10))
        cetz.draw.content((8.5, -9.5), (22.5, -11.5), [
          #set align(left)
          #set par(spacing: 10pt)
          Так можно,

          но закончатся регистры
        ])
      })
    ]
  ]
  #place(center + bottom, dy: -20pt)[
    #set text(size: 20pt)
    #super[\*] И здесь, сдвиг не всегда будет 5 байт
  ]
]

#slide(header: [Вариант 3 -- #mnemonic("lea") + #mnemonic("push")], background-image: none)[
  #set text(weight: "semibold", size: 30pt)
  #place(center + horizon)[
    #table(
      columns: (12cm, 12cm),
      align: horizon,
      stroke: none,
      
      lightasmtable(
        ```asm
          # Вызов функции  
          lea rax, [rip + 6]
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
  #place(center + bottom)[
    #set text(size: 20pt)
    #super[\*] Здесь тоже сдвиг может быть другой
  ]
]

#slide(header: [Вариант 4 -- а что, так можно было?], background-image: none)[
  #set text(weight: "semibold", size: 30pt)
  #place(center + horizon)[
    #table(
      columns: (12cm, 12cm),
      align: horizon,
      stroke: none,
      
      lightasmtable(
        ```asm
          # Вызов функции  
          call _my_func
        ```
      ),
      lightasmtable(
        ```asm
          # Выход из функции
          ret
        ```
      )
    )
  ]
]

#focus-slide[
  #text(size: 40pt)[*Соглашение о вызове*]

  #text(size: 20pt, weight: "semibold")[(Calling convention)]
]

#slide[
  #place(horizon + center)[
    = Что включает в себя соглашение о вызове?

    #v(2em)

    #box(width: 20cm)[
      #set align(left)

      - Где хранится *адрес возврата*;

      - Как передаются *аргументы* и возвращаемое значение;

      - Какие регистры можно *перезаписывать*, а какие надо *восстанавливать* перед выходом из функции;

      - Нужно ли *выравнивать стек* при вызове функции;

      - Как работают *системные вызовы*;
    ]
  ]
]

#slide(place-location: center + horizon, background-image: none)[
  #box(width: 100%, height: auto)[
    #align(center)[
      #set block(spacing: 20pt)
      #set par(spacing: 35pt)
      #text(
        size: 60pt, weight: "black",
      )[System V]
      
      *Calling Convention*
    ]

    #align(left)[
      - *Аргументы* передаются через #"rdi, rsi, rdx, rcx, r8, r9".split(", ").map(register).join(", ") ;

      - #codebox(lang: "c", "float") и #codebox(lang: "c", "double") - передаются через #register("xmm0") - #register("xmm7") ;

      - То, что не влезло, передаётся *через стек* -- справа налево;

      - Возвращаемое значение передается в #inlineasm("rax") (и в #inlineasm("rdx"), если не влезает);

      - #codebox(lang: "c", "float") и #codebox(lang: "c", "double") - возвращаются через #register("xmm0") - #register("xmm1") ;

      - *Стек выравнивается* по 16 байт перед вызовом;

      - #"rbx, rsp, rbp, r12, r13, r14, r15".split(", ").map(register).join(", ") нужно восстанавливать перед возвратом;

      - Номер системного вызова передается через #register("rax").
    ]
  ]
]

#focus-slide[
  #text(size: 40pt)[*Сеанс магии*]
]

#slide(header: [Регистр флагов], background-image: none, {
  set align(horizon + center)
  set text(size: 30pt)
  let color(i) = {
    let unused = (1, 2, 3, 6, 8, 10)
    if unused.find(a => a == i) == none {
      palette.at(0)
    } else {
      black
    }
  }

  box(baseline: 0.65cm + 2cm)[
    #table(
      columns: (1.6cm,) * 12,
      rows: 2.0cm,
      fill: (x, y) => {
        if y == 1 { return none }
        cell-color(color(x)).background-color
      },
      stroke: (x, y) => {
        if y == 1 { return none }
        2pt + cell-color(color(x)).stroke-color
      },
      ..("OF", "DF", "IF", "TF", "SF", "ZF", "-", "AF", "-", "PF", "-", "CF").map(a => text(weight: "bold", raw(a))),
      ..(
        [*Overflow Flag* -- знаковое переполнение],
        [*Direction Flag* -- управляющий флаг],
        [*Interrupt Enable Flag* -- системный флаг],
        [*Trap Flag* -- системный флаг],
        [*Sign Flag* -- знак последнего результата],
        [*Zero Flag* -- последний результат равен нулю],
        [],
        [*Auxiliary Carry Flag* -- переполнение нижнего слова],
        [],
        [*Parity Flag* -- последний результат был чётным],
        [],
        [*Carry Flag* -- беззнаковое переполнение],
      ).map(a => {
        set text(size: 16pt)
        set align(left)
        move(dx: 0.5cm)[
          #rotate(30deg)[
            #box(width: 15cm, height: 1cm)[
              #a
            ]
          ]
        ]
      })
    )
  ]
  h(0.8em)
  lightasm("=")
  register(" flags")
  h(2em)
  v(5cm)
  set text(size: 25pt)
  [*Но как им пользоваться, если он скрыт?*]
})

#slide(background-image: none)[
  = Условные переносы - #mnemonic("cmov**")
  #let instr(content) = {
    box(width: 100%, stroke: (right: 3pt + gray), inset: (right: 10pt, y: 3pt), content)
  }
  #let table-options = (columns: (3.0cm, auto),
      align: (col, row) => {
        if col == 0 { center }
        else { left + top }
      },
      inset: ((right: 10pt, y: 3pt),(left: 10pt, top: 7pt)),
      stroke: none)

  #{
    set par(leading: 0pt)
    set list(marker: none)
    table(
      ..table-options,
      instr(lightasm("cmovs")), [Перенести, если установлен *Sign Flag*],
      instr([
        - #lightasm("cmovz")
        - #lightasm("cmove")
      ]), [Перенести, если установлен *Zero Flag*],
      instr([
        - #lightasm("cmovp")
        - #lightasm("cmovpe")
      ]), [Перенести, если установлен *Parity Flag*],
      instr([
        - #lightasm("cmovns")
        - #lightasm("cmovnz")
        - #lightasm("cmovne")
        - #lightasm("cmovnp")
        - #lightasm("cmovpo")
      ]), [То же самое, но наоборот (если флаг *не* установлен)]
    )
  }

  = Условные переходы - #mnemonic("j**")

  #{
    set par(leading: 0pt)
    set list(marker: none)
    table(
      ..table-options,
      instr(lightasm("js")), [Перейти, если установлен *Sign Flag*],
      instr([#lightasm("jz"), #lightasm("je")]), [Перейти, если установлен *Zero Flag*],
      instr([#lightasm("jp"), #lightasm("jpo")]), [Перейти, если установлен *Parity Flag*],
    )
  }

  Ещё есть #mnemonic("cset**") - установить один байт в #inlineasm("0") или #inlineasm("1") в зависимости от флагов.
]

#slide(background-image: none)[
  = Больше условных переходов!

  #set par(spacing: 14pt)

  Представим, что мы вычли два числа: #inlineasm("sub rax, rbx"). Тогда:

  - #register("rax") >= #register("rbx") , если #inlineasm("СF = 0")
  - #register("rax") <= #register("rbx") , если #inlineasm("СF = 1")
  - #register("rax") == #register("rbx") , если #inlineasm("ZF = 0")

  А если числа были *знаковые*, то:

  - #register("rax") >= #register("rbx") , если #inlineasm("SF = OF")
  - #register("rax") <= #register("rbx") , если #inlineasm("SF != OF")

  Для этого придумали свои суффиксы:

  #let table-options = (columns: (3.0cm, auto),
      align: (col, row) => {
        if col == 0 { center }
        else { left + top }
      },
      inset: ((right: 10pt, y: 3pt),(left: 10pt, top: 7pt)),
      stroke: none)

  #let instr(content) = {
    box(width: 100%, stroke: (right: 3pt + gray), inset: (right: 10pt, y: 3pt), content)
  }

  #{
    set par(leading: 0pt)
    set list(marker: none)
    table(
      ..table-options,
      instr(lightasm("jge")), [Перейти, если *знаково больше или равно* (#inlineasm("SF = OF"))],
      instr(lightasm("ja")), [Перейти, если *беззнаково больше* (#inlineasm("CF = 1") и #inlineasm("ZF = 0"))],
      instr(lightasm("jl")), [Перейти, если *знаково меньше* (#inlineasm("SF != OF") и #inlineasm("ZF = 0"))],
    )
  }

  Но #mnemonic("sub") поменяет значение #register("rax"). #mnemonic("cmp") тоже вычитает, но оставляет все как есть.
]

#focus-slide[
  #text(size: 40pt)[*Интерактив*]
]

#slide(header: "Стековый фрейм", background-image: none)[
  #set text(weight: "semibold",size: 30pt)
  #code(numbers: true, leading: 5pt,
    ```c
    void merge_sort(int* arr, int n) {
      // Где хранить локальные переменные?
      int mid = n / 2;
      int left_size = mid, right_size = n - mid;

      // ...
      merge_sort(left, left_size);
      merge_sort(right, right_size);
      // ...
    }
    ```
  )
]

#slide(header: "Стековый фрейм", background-image: none)[
   #set text(weight: "semibold", size: 25pt)

   #place(horizon + center)[
    #cetz.canvas(length: 1cm, {
      cetz.draw.content((-15, 10), (15, -10), []);

      cetz.draw.set-style(stroke: 3pt)

      cetz.draw.rect(
        (-15, 5), 
        (15, 1.8),
        fill: blue.desaturate(95%),
        stroke: none
      )

      cetz.draw.rect(
        (-15, -3.5), 
        (15, -5.7),
        fill: blue.desaturate(95%),
        stroke: none
      )

      cetz.draw.line(
        (3.5, 5), 
        (3.5, 1.8),
        flip: false,
        stroke: white + 4pt,
      )

      cetz.draw.line(
        (3.5, -3.5), 
        (3.5, -5.7),
        flip: false,
        stroke: white + 4pt,
      )

      cetz.draw.content((4.5, 5), (15, 1.8))[
        #set align(horizon)
        #raw("Создание фрейма")
      ]
      cetz.draw.content((4.5, -3.5), (15, -5.7))[
        #set align(horizon)
        #raw("Очистка фрейма")
      ]
    })
  ]
  
  #code(numbers: true, leading: 5pt,
    ```asm
    _merge_sort:
      push rbp
      mov rbp, rsp
      sub rsp, 16 # 16 байт для фрейма
      # ...
      mov [rbp - 4], rax  # int mid = ...
      mov [rbp - 8], rax  # int left_size = ...
      mov [rbp - 12], rax # int right_size = ...
      # ...
      mov rsp, rbp
      pop rbp
      ret  
    ```
  )
]

#slide(header: "Стековый фрейм", background-image: none, place-location: horizon)[  

  - Если начинать каждую функцию с #inlineasm("push rbp") и #inlineasm("mov rbp, rsp"), то фреймы образуют односвязный список.

  - Итерируя по нему, дебаггеры могут показать бектрейс:

  #align(center)[
    #box(inset: 20pt, fill: rgb(17, 17, 17), radius: 20pt)[
      #image("img/debugger.png")
    ]
  ]
]

#slide(header: "Полезные ссылки", place-location: horizon + left)[
🔗 #link("https://godbolt.org")[*godbolt.org*] -- #text(weight: "semibold")[Онлайн-компилятор C / C++ в ассемблер;]

🔗 #link("https://defuse.ca/online-x86-assembler.htm#disassembly")[*online-x86-assembler*] -- #text(weight: "semibold")[Онлайн-компилятор ассемблера в машинный код x86;]

🔗 #link("https://nandgame.com")[*nandgame.com*] -- #text(weight: "semibold")[Игра про создание процессора из реле. Советую!]
]

#outro-slide()