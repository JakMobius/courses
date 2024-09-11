
#import "@preview/cetz:0.2.2"

#let draw-compiler-lifecycle(arr) = {
  let margin = -1.5
  let arrow-top = 5.5
  let arrow-bottom = 4.5
  let arrow-shortage = 1.4

  let anchor-prev = 0
  let x = 0
  let i = 0

  cetz.draw.set-style(mark: (end: ">"), stroke: 3pt + black)

  for step in arr {
    let background-color = color.mix((step.color, 20%), (white, 80%))
    let stroke-color = color.mix((step.color, 50%), (black, 50%))
    let text-color = stroke-color
    let has-code = step.at("code", default: none) != none
    let lower-boundary = 0

    if has-code {
      lower-boundary = 1.4
    }

    let y = 0

    if calc.rem(i, 2) == 0 {
      y = 6
    }

    cetz.draw.content(
      (x, y + 4), (x + step.width, y), padding: 0,
    )[
      #box(
        fill: background-color, radius: 20pt, width: 100%, height: 100%, stroke: 1pt + stroke-color,
      )
    ]

    cetz.draw.content(
      (x, y + 4), (x + step.width, y + lower-boundary), padding: 0,
    )[
      #set text(fill: text-color, size: 18pt)
      #box(
        width: 100%, height: 100%, inset: (left: 7pt, top: 7pt, right: 7pt, bottom: 0pt),
      )[
        #align(center + horizon)[
          #step.text
        ]
      ]
    ]

    if has-code {
      cetz.draw.content(
        (x, y + lower-boundary), (x + step.width, y), padding: 0,
      )[
        #set text(fill: text-color, font: "Monaco", size: 18pt)
        #box(
          width: 100%, height: 100%, inset: (left: 7pt, top: 0pt, right: 7pt, bottom: 7pt),
        )[
          #align(center + horizon)[
            #step.code
          ]
        ]
      ]
    }

    let anchor = x + step.width / 2 - arrow-shortage

    if x != 0 {
      if calc.rem(i, 2) == 0 {
        cetz.draw.line((anchor-prev, arrow-bottom), (anchor, arrow-top))
      } else {
        cetz.draw.line((anchor-prev, arrow-top), (anchor, arrow-bottom))
      }
    }

    anchor-prev = x + step.width / 2 + arrow-shortage

    x = x + margin + step.width
    i = i + 1
  }
}