
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "@preview/suiji:0.3.0": *
#import "../theme/theme.typ": *
#import "./utils.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Виртуальная память

    АКОС, МФТИ

    17 октября, 2024
  ]
]

#show: enable-handout

#focus-slide[
  #text(size: 25pt)[*Как разные процессы используют одни и те же адреса?*]
]

#slide(header: [В былые времена...])[
  #place(right + horizon, dx: 2cm, dy: -1.5cm)[#image(width: 13cm, "doscomputer.png")]

  #place(horizon, dy: -0.5cm)[
    16-битные компьютеры на DOS использовали *сегменты*:

    - *#raw("CS")* - сегмент кода;
    - *#raw("DS")* - сегмент данных;
    - *#raw("SS")* - сегмент стека;
    - *#raw("ES")* - пользовательский сегмент;

    *Сегмент* в x86 - постоянное слагаемое к адресу.

    Разным процессам выдавались разные сегменты.

    *Современные компьютеры используют виртуальную адресацию.*
  ]
]

#slide(
  background-image: none,
  place-location: horizon + center)[
  #cetz.canvas(length: 1cm, {
    cetz.draw.content((0, 0), (30, -17), [])

    let virtual_bg = cell-color(blue).background-color;
    let virtual_stroke = cell-color(blue).stroke-color;
    let physical_bg = cell-color(red).background-color;
    let physical_stroke = cell-color(red).stroke-color;
    let arrow_color = gray;

    let virt_addr_pos(i) = {
      let section = 0
      if i >= 4 { section = 1 }
      if i >= 8 { section = 2 }
      if i >= 12 { section = 3 }
      return (3.75 + i * 1.15 + section * 2, -6)
    }

    let phys_addr_pos(i) = {
      return (3 + i * 1, -11.5)
    }

    cetz.draw.content((0, 0), (30, -8.5))[
      #box(width: 100%, height: 100%, fill: virtual_bg)
    ]
    cetz.draw.content((0, -8.5), (30, -17))[
      #box(width: 100%, height: 100%, fill: physical_bg)
    ]

    let rng = gen-rng(42)
    let used_phys_addrs = ()

    for i in range(17) {
      let phys_addr = -1;
      while phys_addr < 0 or phys_addr in used_phys_addrs {
        (rng, phys_addr) = integers(rng, low: 0, high: 25)
      }
      used_phys_addrs = used_phys_addrs + (phys_addr,)
      
      let a_pos = virt_addr_pos(i);
      let b_pos = phys_addr_pos(phys_addr);
      let c_pos = (a_pos.at(0), a_pos.at(1) - 1.5)
      let d_pos = (b_pos.at(0), b_pos.at(1) + 1.5)

      cetz.draw.bezier(a_pos, b_pos, c_pos, d_pos, stroke: 3pt + gray, mark: (end: ">"))
    }

    cetz.draw.content((0, 0), (30, -8.5))[
      #box(
        width: 100%, height: 100%, inset: 20pt,
      )[
        #align(left)[
          = Виртуальные адреса
        ]
        #let memdescr(content, pages) = {          
          return table.cell(colspan: pages)[
            #set text(size: 24pt, fill: black, weight: "bold")
            #raw(content)
          ]
        }
        #let addr(content, pages) = {
          return table.cell(colspan: pages)[
            #set text(size: 18pt, fill: blue, weight: "bold")
            #raw(content)
          ]
        }
        #let dots = {
          set text(size: 20pt, fill: black, weight: "black")
          $dots.h.c$
        }
        #place(horizon + center)[
          #table(
            columns: 21,
            rows: 3,
            align: (x, y) => {
              if y == 1 { horizon + center }
              else { left }
            },
            inset: (x, y) => {
              if y == 0 {
                (left: 5pt, bottom: 10pt, right: 20pt, top: 5pt)
              }
              else if y == 1 {
                (left: 20pt, right: 20pt, top: 20pt, bottom: 15pt)
              }
              else { (bottom: 7pt, left: 33pt) }
            },
            stroke: (x, y) => {
              let st = 3pt + virtual_stroke
              if y == 0 {
                if x == 0 { none }
                else {
                  (left: (dash: "dashed", paint: virtual_stroke))
                }
              }
              else if y == 1 {
                if x == 0 {
                  (right: st, top: st)
                } else{
                  (left: st, top: st)
                }
              } else {
                if x == 0 {
                  (right: st, bottom: st)
                } else{
                  (left: st, bottom: st)
                }
              }
            },
            // Top row without borders
            addr("", 1),
            addr("0x100000000", 4),
            addr("", 1),
            addr("0x100001000", 4),
            addr("", 1),
            addr("0x300000000", 4),
            addr("", 1),
            addr("0x7f0000000000", 5),

            // Bottom row with borders except left and right
            dots,
            memdescr("code", 4),
            dots,
            memdescr("data", 4),
            dots,
            memdescr("stack", 4),
            dots,
            memdescr("heap", 5)
          )
        ]
      ]
    ]

    // Нижняя часть: Физические адреса
    cetz.draw.content((0, -8.5), (30, -17))[
      #box(
        width: 100%, height: 100%, inset: 20pt
      )[
        #align(left)[
          #box(outset: 10pt, fill: physical_bg, radius: 5pt)[
            = Физические адреса
          ]
        ]
        
        #place(horizon + center)[
          // Add a blue dot to used physical address
          #show table.cell: it => {
            if (it.x - 1) in used_phys_addrs {
              set text(size: 100pt, fill: blue)
              sym.dot.c
            } else {
              none
            }
          }

          
          #table(
            rows: 1.5cm,
            columns: (1.5cm,) + (1cm,) * 25 + (1.5cm,),
            align: horizon + center,
            stroke: (x, y) => {
              let st = 3pt + physical_stroke
              if x == 0 {
                (top: st, right: st, bottom: st)
              } else {
                (top: st, left: st, bottom: st)
              }
            },
            [$dots.c.h$],
            ..([], ) * 25,
            [$dots.c.h$]
          )
        ]
      ]
    ]
  })

  #place(center + bottom)[
    #set block(spacing: 15pt)
    Адреса, которые используются процессами, называются *вирутуальными*.

    *Физический адрес* -- уже реальный индекс байта в оперативной памяти. 
  ]
]

#slide(
  background-image: none,
  place-location: horizon + center)[
  #cetz.canvas(length: 1cm, {
    cetz.draw.content((0, 0), (30, -17), [])

    let virtual_bg = cell-color(blue).background-color;
    let virtual_stroke = cell-color(blue).stroke-color;
    let virtual_2_bg = cell-color(green).background-color;
    let virtual_2_stroke = cell-color(green).stroke-color;
    let physical_bg = cell-color(red).background-color;
    let physical_stroke = cell-color(red).stroke-color;
    let arrow_color = gray;

    let virt_addr_pos(i, offset) = {
      let section = 0
      if i >= 4 { section = 1 }
      if i >= 8 { section = 2 }
      if i >= 12 { section = 3 }
      return (offset + 3.75 + i * 1.15 + section * 2, -6)
    }

    let phys_addr_pos(i) = {
      return (3 + i * 1, -10.5)
    }

    cetz.draw.content((0, 0), (15, -7))[
      #box(width: 100%, height: 100%, fill: virtual_bg)
    ]
    cetz.draw.content((15, 0), (30, -7))[
      #box(width: 100%, height: 100%, fill: virtual_2_bg)
    ]
    cetz.draw.content((0, -7), (30, -17))[
      #box(width: 100%, height: 100%, fill: physical_bg)
    ]

    let rng = gen-rng(26)
    let used_phys_addrs = ()

    for i in range(2) {
      let phys_addr = -1;
      while phys_addr < 0 or phys_addr in used_phys_addrs {
        (rng, phys_addr) = integers(rng, low: 0, high: 25)
      }
      used_phys_addrs = used_phys_addrs + (phys_addr,)
      
      let a_pos = if i == 0 {
        (7, -5)
      } else {
        (23, -5)
      }
      let b_pos = phys_addr_pos(phys_addr);
      let c_pos = (a_pos.at(0), a_pos.at(1) - 1.5)
      let d_pos = (b_pos.at(0), b_pos.at(1) + 1.5)

      cetz.draw.bezier(a_pos, b_pos, c_pos, d_pos, stroke: 4pt + black, mark: (end: ">"))
    }

    cetz.draw.content((0, 0), (15, -7))[
      #box(
        width: 100%, height: 100%, inset: 20pt,
      )[
        #align(left)[
          = Процесс 1
        ]
        #place(horizon + center)[
          #set text(size: 30pt, fill: blue, weight: "bold")
          #raw("0x100001020")
        ]
      ]
    ]

    cetz.draw.content((15, 0), (30, -7))[
      #box(
        width: 100%, height: 100%, inset: 20pt,
      )[
        #align(left)[
          = Процесс 2
        ]
        
        #place(horizon + center)[
          #set text(size: 30pt, fill: blue, weight: "bold")
          #raw("0x100001020")
        ]
      ]
    ]

    // Нижняя часть: Физические адреса
    cetz.draw.content((0, -7), (30, -17))[
      #box(
        width: 100%, height: 100%, inset: 20pt
      )[
        #align(left)[
          #box(outset: 10pt, fill: physical_bg, radius: 5pt)[
            = Физические адреса
          ]
        ]
        
        #place(horizon + center)[
          #let dot-colors = (blue, green, none)
          
          #let rng = gen-rng(42)
          #let random_colors = integers(rng, low: 0, high: 3, size: 25).at(1)

          #show table.cell: it => {
            if it.x == 0 or it.x > 25 { return }
            let pos = used_phys_addrs.position((x) => x == it.x - 1)

            if pos == none {
              let num = random_colors.at(it.x - 2)
              if num < 2 {
                pos = num
              }
            }

            if pos != none {
              set text(size: 100pt, fill: dot-colors.at(pos))
              sym.dot.c
            } else {
              none
            }
          }

          
          #table(
            rows: 1.5cm,
            columns: (1.5cm,) + (1cm,) * 25 + (1.5cm,),
            align: horizon + center,
            stroke: (x, y) => {
              let st = 3pt + physical_stroke
              if x == 0 {
                (top: st, right: st, bottom: st)
              } else {
                (top: st, left: st, bottom: st)
              }
            },
            [$dots.c.h$],
            ..([], ) * 25,
            [$dots.c.h$]
          )
        ]
      ]
    ]
  })

  #place(center + bottom)[
    *Одинаковые виртуальные адреса могут указывать на разные физические.*
  ]
]

#slide(background-image: none)[
  = Как связать виртуальный адрес с физическим?

  == #codebox(lang: "c", "mmap(void *start, size_t len, int prot, int flags, int fd, off_t off)")

  #text(weight: "semibold")[
    #set list(marker: none)
    - #codebox(lang: "c", "void* start") -- Виртуальный адрес или #codebox("NULL") (кратно #codebox(lang: "c", "PAGE_SIZE"));
    - #codebox(lang: "c", "size_t len") -- Сколько байт связать (кратно #codebox(lang: "c", "PAGE_SIZE"));
    - #codebox(lang: "c", "int prot") -- Права доступа к памяти;
    - #codebox(lang: "c", "int flags") -- Нужно установить в #codebox(lang: "c", "MAP_ANONYMOUS") ;
    - #codebox(lang: "c", "int fd") -- Нужно установить в #codebox(lang: "c", "-1") ;
    - #codebox(lang: "c", "off_t off") -- Может быть любым.
  ]
  
  - Ядро выберет свободный физический адрес и свяжет его с виртуальным. Самому выбрать физический адрес нельзя.
  - #codebox(lang: "c", "malloc()") и #codebox(lang: "c", "calloc()") делают то же самое, когда им нужны новые страницы памяти.
  - Когда страницы больше не нужны, используйте #codebox(lang: "c", "munmap()").
]

#slide(header: [Таблицы страниц], place-location: horizon)[
  - *Хранят соответствие* виртуальных адресов физическим и *права доступа* к ним.

  - Модифицируются *только ядром*. Конвертацией адресов занимается *процессор*.

  - #codebox(lang: "c", "mmap()") просит ядро создать новую запись в таблице страниц.

  - Связаны *иерархически*, как директории и файлы.

  - Минимально адресует *страницу памяти* (обычно 4 КБ).

  - Таблицу страниц любого процесса можно увидеть в #codebox("/proc/PID/maps").
]

#let horizontal-bezier(a, b) = {
  cetz.draw.bezier((a.x, a.y), (b.x, b.y), (b.x, a.y), (a.x, b.y))
}

#let draw-page-table(position, values, more: true) = {
  let column-width = 2
  let index-node-height = 2.5
  let margin = 1.0

  let dirent-start = index-node-height + margin
  let dirent-height = 1.8 * values.len()
  if (more) {
    dirent-height += 1
  }

  let left = position.x - column-width / 2
  let right = position.x + column-width / 2

  cetz.draw.set-style(mark: (end: ">"), stroke: 5pt + black, fill: none)

  cetz.draw.content(
    (left, position.y - dirent-start), (right, position.y - dirent-start - dirent-height), padding: none, {
      set align(center)
      set block(spacing: 0pt)
      set text(size: 25pt)
      let colors = cell-color(palette.at(1))

      grid(
        rows: (1.8cm,) * values.len(), columns: 100%, align: horizon + center, stroke: 2pt + colors.stroke-color, fill: colors.background-color, ..values,
      )
      if (more) {
        text(size: 25pt)[*...*]
      }
    },
  )
}

#slide(background-image: none)[
= Конвертация виртуального адреса в x86 (PAE)

  #cetz.canvas(
    length: 1cm, {
    cetz.draw.set-style(
      content: (padding: .2), fill: gray.lighten(70%), stroke: gray.lighten(70%),
    )

    cetz.draw.content((0, -3), (28, -6), padding: none, {
      box(width: 100%, height: 100%, inset: (y: 10pt),{
        set text(size: 30pt, weight: "bold")
        text(fill: blue)[#raw("0x40401aaa")]
        raw(" = ")
        let num(i) = {
          text(fill: blue)[#raw(str(i))]
        }
        let index(i) = {
          raw("[")
          num(i)
          raw("]")
        }
        box(baseline: 1.25em,
          table(
            columns: 4,
            stroke: (x, y) => {
              if y == 0 {
                return (bottom: 2pt + black)
              }
            },
            inset: (x, y) => {
              if(y == 0) { return (bottom: 10pt)}
              else { return (top: 10pt)}
            },
            column-gutter: 10pt,
            align: horizon + center,

            num("01"), num("000000010"), num("000000001"), num("101010101010"),
            index(1), index(2), index(1), index("0xaaa")
          )
        )
      })
    })

    let indices = (1, 2, 1)
    let index-node-positions = (
      7.35,
      10.8,
      15.72,
      21.6,
    )

    let data = (
      (`[0]`, [*`[1]`*], `[2]`),
      (`[0]`, `[1]`, [*`[2]`*]),
      (`[0]`, [*`[1]`*], `[2]`),
    )

    for (i, pos) in index-node-positions.enumerate() {
      if i == 3 {
        continue
      }
      draw-page-table((x: pos, y: -4.5), data.at(i))
    }

    cetz.draw.content((x: index-node-positions.at(3) - 2.5, y: -7.75), (rel: (x: 5, y: -5)), {
      box(width: 100%, height: 100%, fill: cell-color(palette.at(0)).background-color, inset: 10pt, radius: 10pt, stroke: 2pt + cell-color(palette.at(1)).stroke-color)[
        #set text(size: 20pt, fill: black, weight: "bold")
        #align(horizon + center)[
          Физический адрес
        ]
      ]
    })

    cetz.draw.set-style(mark: (end: none))

    cetz.draw.line((0, -6.8), (7, -6.8), name: "root", stroke: luma(80) + 5pt)

    cetz.draw.content((name: "root", anchor: 50%), anchor: "south", padding: .4, [
      #text(size: 20pt, fill: luma(80))[*Регистр CR2*]
    ])

    for (i, dirent-index) in ((-1, none),) + indices.enumerate() {
      let position = index-node-positions.at(i)
      
      let end =   (x: index-node-positions.at(i + 1) - 0.5,   y: -6.8)
      let arrow = (x: end.x + 0.5, y: end.y - 0.5)
      let plus =  (x: end.x + 0.5, y: end.y)

      if i >= 0 {
        let start = (x: 1.2 + position,       y: -9 - 1.8 * dirent-index)
        let arc1 =  (x: 1.8 + position - 0.5, y: -9 - 1.8 * dirent-index)
        let arc2 =  (x: 1.8 + position,       y: -6.8 - 0.5)

        cetz.draw.merge-path({
          cetz.draw.line(start, arc1)
          cetz.draw.arc((), start: 270deg, delta: 90deg, radius: 0.5)
          cetz.draw.arc(arc2, start: 180deg, delta: -90deg, radius: 0.5)
          cetz.draw.line((), end)
        })
      }

      cetz.draw.line(arrow, (rel: (0, -0.7)))
      cetz.draw.line(arrow, (rel: (0, 1.6)))
      cetz.draw.content(plus, [
        #let fill-color = cell-color(blue).background-color
        #box(width: 1cm, height: 1cm, radius: 10pt, stroke: 5pt + black, fill: fill-color)[
          #set text(size: 30pt, weight: "black", baseline: -0.05em)
          #place(horizon + center)[
            #raw("+")
          ]
        ]
      ])
    }
  })
  #place(bottom + left)[
    #set block(spacing: 15pt)
    #set text(weight: "semibold")
    - Каждый уровень хранит #link("https://www.sandpile.org/x86/paging.htm")[кучу флажков]. Например о том, что адрес действителен;

    - Если нужно замаппить много памяти, можно опустить третий уровень;

    - Частоиспользуемые адреса кешируются в #link("https://ru.wikipedia.org/wiki/Буфер_ассоциативной_трансляции")[TLB].
  ]
]

#focus-slide[
  #text(size: 25pt)[*Что произойдет, если записи в таблице не существует?*]
]

#slide(header: "Page Fault", background-image: none)[
  #v(0.5em)
  *Исключение процессора*, возникающее при ошибке доступа к виртуальному адресу.
  #line(length: 100%)
  *Возникает, если:*
  - Ваша программа сделала #codebox(lang: "c", "*((int*)0) = 0") . Тогда ядро отправит вам #codebox("SIGSEGV");

  - Ядро *выгрузило* эту страницу из памяти *в своп*. Тогда ядро загрузит страницу обратно и вы ничего не заметите;

  - Ядро *лениво скопировало* эту страницу, а вы собрались её изменять. Тогда ядро создаст новую страницу и скопирует туда данные. (Copy-on-write).

  - Вы *переполнили стек*, замапленный с #codebox("MAP_GROWSDOWN"). Тогда ядро незаметно замаппит вам ещё памяти.

  - ...
]

#slide(
  background-image: none,
  place-location: horizon + center)[
  #cetz.canvas(length: 1cm, {
    cetz.draw.content((0, 0), (30, -17), [])

    let virtual_bg = cell-color(blue).background-color;
    let virtual_stroke = cell-color(blue).stroke-color;
    let physical_bg = cell-color(red).background-color;
    let physical_stroke = cell-color(red).stroke-color;
    let device_bg = cell-color(gray).background-color;
    let device_stroke = cell-color(gray).stroke-color;
    let arrow_color = gray;

    let virt_addr_pos(i) = {
      let section = 0
      if i >= 4 { section = 1 }
      if i >= 8 { section = 2 }
      if i >= 12 { section = 3 }
      if i >= 17 { section = 4 }
      return (3.3 + i * 0.955 + section * 1.35, -6)
    }

    let phys_addr_pos(i) = {
      return (1.7 + i * 0.5, -11.5)
    }

    cetz.draw.content((0, 0), (30, -8.5))[
      #box(width: 100%, height: 100%, fill: virtual_bg)
    ]
    cetz.draw.content((0, -8.5), (15, -17))[
      #box(width: 100%, height: 100%, fill: physical_bg)
    ]
    cetz.draw.content((15, -8.5), (30, -17))[
      #box(width: 100%, height: 100%, fill: device_bg)
    ]

    let rng = gen-rng(44)
    let used_phys_addrs = ()

    for i in range(17) {
      let phys_addr = -1;
      while phys_addr < 0 or phys_addr in used_phys_addrs {
        (rng, phys_addr) = integers(rng, low: 0, high: 25)
      }
      used_phys_addrs = used_phys_addrs + (phys_addr,)
      
      let a_pos = virt_addr_pos(i);
      let b_pos = phys_addr_pos(phys_addr);
      let c_pos = (a_pos.at(0), a_pos.at(1) - 1)
      let d_pos = (b_pos.at(0), b_pos.at(1) + 4.0)

      cetz.draw.bezier(a_pos, b_pos, c_pos, d_pos, stroke: 3pt + gray, mark: (end: ">"))
    }

    for i in range(17, 21) {
      let disk_position = (21, -11);
      let gpu_position = (25, -11);

      let a_pos = virt_addr_pos(i);
      let b_pos = if i < 19 { disk_position } else { gpu_position };
      let c_pos = (a_pos.at(0), a_pos.at(1) - 4)
      let d_pos = (b_pos.at(0), b_pos.at(1) + 2)

      cetz.draw.bezier(a_pos, b_pos, c_pos, d_pos, stroke: 3pt + gray, mark: (end: ">"))
    }

    cetz.draw.content((0, 0), (30, -8.5))[
      #box(
        width: 100%, height: 100%, inset: 20pt,
      )[
        #align(left)[
          = Виртуальные адреса
        ]
        #let memdescr(content, pages) = {          
          return table.cell(colspan: pages)[
            #set text(size: 24pt, fill: black, weight: "bold")
            #raw(content)
          ]
        }
        #let addr(content, pages) = {
          return table.cell(colspan: pages)[
            #set text(size: 18pt, fill: blue, weight: "bold")
            #raw(content)
          ]
        }
        #let dots = {
          set text(size: 20pt, fill: black, weight: "black")
          $dots.h.c$
        }
        #place(horizon + center)[
          #table(
            columns: 26,
            rows: 3,
            align: (x, y) => {
              if y == 1 { horizon + center }
              else { left }
            },
            inset: (x, y) => {
              if y == 0 {
                (left: 5pt, bottom: 10pt, right: 10pt, top: 5pt)
              }
              else if y == 1 {
                (left: 10pt, right: 10pt, top: 20pt, bottom: 15pt)
              }
              else { (bottom: 7pt, left: 28pt) }
            },
            stroke: (x, y) => {
              let st = 3pt + virtual_stroke
              if y == 0 {
                if x == 0 { none }
                else {
                  (left: (dash: "dashed", paint: virtual_stroke))
                }
              }
              else if y == 1 {
                if x == 0 {
                  (right: st, top: st)
                } else{
                  (left: st, top: st)
                }
              } else {
                if x == 0 {
                  (right: st, bottom: st)
                } else{
                  (left: st, bottom: st)
                }
              }
            },
            // Top row without borders
            addr("", 1),
            addr("0x100000000", 4),
            addr("", 1),
            addr("0x100001000", 4),
            addr("", 1),
            addr("0x300000000", 4),
            addr("", 1),
            addr("0x7f0000000000", 5),
            addr("", 1),
            addr("0x????", 4),

            // Bottom row with borders except left and right
            dots,
            memdescr("code", 4),
            dots,
            memdescr("data", 4),
            dots,
            memdescr("stack", 4),
            dots,
            memdescr("heap", 5),
            dots,
            memdescr("mmio", 4)
          )
        ]
      ]
    ]

    // Нижняя часть: Физические адреса
    cetz.draw.content((0, -8.5), (15, -17))[
      #box(
        width: 100%, height: 100%, inset: 20pt
      )[
        #align(left)[
          #box(outset: 10pt, fill: physical_bg, radius: 5pt)[
            = Физические адреса
          ]
        ]
        
        #place(horizon + center)[
          // Add a blue dot to used physical address
          #show table.cell: it => {
            if (it.x - 1) in used_phys_addrs {
              set text(size: 50pt, fill: blue)
              sym.dot.c
            } else {
              none
            }
          }

          
          #table(
            rows: 1.5cm,
            columns: (0.7cm,) + (0.5cm,) * 25 + (0.7cm,),
            align: horizon + center,
            stroke: (x, y) => {
              let st = 3pt + physical_stroke
              if x == 0 {
                (top: st, right: st, bottom: st)
              } else {
                (top: st, left: st, bottom: st)
              }
            },
            [$dots.c.h$],
            ..([], ) * 25,
            [$dots.c.h$]
          )
        ]
      ]
    ]

    cetz.draw.content((15, -8.5), (30, -17))[
      #box(
        width: 100%, height: 100%, inset: 20pt
      )[
        #align(left)[
          #box(outset: 10pt, fill: device_bg, radius: 5pt)[
            = Устройства
          ]
        ]
        
        #place(horizon + center)[
          #set text(weight: "bold", size: 20pt)
          #table(
            rows: 3cm,
            columns: (4cm, ) * 2 + (1cm, ),
            align: horizon + center,
            column-gutter: 0.5cm,
            stroke: none,
            box(stroke: 3pt + black, width: 100%, height: 100%, radius: 10pt)[Диск],
            box(stroke: 3pt + black, width: 100%, height: 100%, radius: 10pt)[GPU],
            [...]
          )
        ]
      ]
    ]
  })

  #place(center + bottom)[
    #set block(spacing: 15pt)
    #box(fill: luma(240), radius: 10pt, stroke: 1pt + black, inset: 10pt)[
      *Виртуальные адреса можно связать не только с памятью, но и с устройствами.*
    ]
  ]
]

#slide(background-image: none)[
  = Как связать виртуальный адрес с файлом на диске?

  == #codebox(lang: "c", "mmap(void *start, size_t len, int prot, int flags, int fd, off_t off)")

  #set list(marker: none)
  #set text(weight: "semibold")
  #v(1em)

  - #codebox(lang: "c", "void* start") -- Виртуальный адрес или #codebox("NULL") (кратно #codebox(lang: "c", "PAGE_SIZE"));
  - #codebox(lang: "c", "size_t len") -- Сколько байт связать (кратно #codebox(lang: "c", "PAGE_SIZE"));
  - #codebox(lang: "c", "int prot") -- Права доступа к памяти;
  - #codebox(lang: "c", "int flags") -- Флаги;
  - #codebox(lang: "c", "int fd") -- Дескриптор открытого файла;
  - #codebox(lang: "c", "off_t off") -- Смещение в файле.

  #v(1em)

  В зависимости от флагов, запись в эти адреса будет влиять на файл на диске. При этом оперативная память может вообще не использоваться.
]

#slide(background-image: none)[
  = Флаги #codebox(lang: "c", "mmap()"):
  
  #set list(marker: raw("|="))
  #codebox(lang: "c", "int flags =")
  - #codebox(lang: "c", "MAP_SHARED") -- изменения будут видны другим процессам;
  - #codebox(lang: "c", "MAP_PRIVATE") -- изменения будут видны только текущему процессу;
  - #codebox(lang: "c", "MAP_ANONYMOUS") -- не связывать с файлом;
  - #codebox(lang: "c", "MAP_FIXED") -- использовать указанный адрес;
  - #codebox(lang: "c", "MAP_GROWSDOWN") -- выделить стек, растущий вниз;

  #set list(marker: raw("="))
  #codebox(lang: "c", "int prot")
  - #codebox(lang: "c", "PROT_READ") -- разрешить чтение выделенных адресов;
  - #codebox(lang: "c", "PROT_WRITE") -- разрешить запись выделенных адресов;
  - #codebox(lang: "c", "PROT_EXEC") -- разрешить исполнение выделенных адресов;
  - #codebox(lang: "c", "PROT_NONE") -- запретить всё.
]

#focus-slide[
  #set block(spacing: 30pt)
  #text(size: 50pt)[
    *Бонус*
  ]

  #text(size: 25pt)[
    *Используем видеопамять как оперативную память*
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