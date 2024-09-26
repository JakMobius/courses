#let byte-colors = array.range(8).map((i) => {
  color.hsv(i * 45deg + 240deg, 100%, 100%)
})

#let cell-color(base-color: none) = {

  if base-color == none {
    base-color = blue
  }

  let background-color = color.mix((base-color, 20%), (white, 80%))
  let stroke-color = color.mix((base-color, 50%), (black, 50%))

  (
    base-color: base-color,
    background-color: background-color,
    stroke-color: stroke-color
  )
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