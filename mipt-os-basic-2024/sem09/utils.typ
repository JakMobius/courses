
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

#let tilde-line(x0, y0, length) = {
  let char-width = 0.32

  let points = ()

  for i in range(length + 1) {
    points.push((x0 + (i + 0.0) * char-width, y0 - 0.05))
    points.push((x0 + (i + 0.5) * char-width, y0 + 0.05))
  }

  cetz.draw.catmull(..points, stroke: 2.5pt + red)
}