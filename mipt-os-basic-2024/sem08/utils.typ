
#import "../theme/theme.typ": *
#import "@preview/cetz:0.2.2"


#let cell-color(base-color) = {
  if base-color == none {
    base-color = blue
  }

  let background-color = color.mix((base-color, 20%), (white, 80%))
  let stroke-color = color.mix((base-color, 50%), (black, 50%))

  (
    base-color: base-color, background-color: background-color, stroke-color: stroke-color,
  )
}

#let striked-pattern(stroke) = pattern(size: (25pt, 25pt))[
    #let stroke = 3pt + stroke
    #place(line(stroke: stroke, start: (0%, 0%), end: (100%, 100%)))
    #place(line(stroke: stroke, start: (-100%, 0%), end: (100%, 200%)))
    #place(line(stroke: stroke, start: (0%, -100%), end: (200%, 100%)))
  ]


#let ub = (content) => {
  place(bottom)[
    #box(
      inset: (bottom: 20pt, top: 15pt), 
      outset: (x: 40pt, bottom: 20pt), 
      width: 100%, 
      fill: red.desaturate(80%),
      stroke: (top: 3pt + red.darken(50%))
      )[

      #content
    ]
  ]
}