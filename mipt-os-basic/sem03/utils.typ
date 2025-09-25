#let palette = array.range(8).map((i) => {
  color.hsv(i * 45deg + 240deg, 100%, 100%)
})

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

#let largecell(color, content) = [
  #let color = cell-color(color)
  #box(
    radius: 10pt, fill: color.background-color, stroke: 3pt + color.stroke-color, inset: 30pt,
  )[
    #set text(fill: black)
    #content
  ]
]