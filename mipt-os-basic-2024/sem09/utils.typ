
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

#let conpro(color, content) = {
  set text(fill: white, weight: "black", size: 20pt)
  box(
    baseline: 0.5em, width: 1.5em, height: 1.5em, radius: 5pt, fill: color,
  )[
    #align(center + horizon)[#content]
  ]
  h(0.5em)
}

#let pro() = conpro(green)[+]
#let con() = conpro(red)[-]

#let lightcodebox(type, lang: none) = {
  set text(weight: "bold", size: 1.1em)
  raw(lang: lang, type)
}