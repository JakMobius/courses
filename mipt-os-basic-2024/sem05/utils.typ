
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


#let underline(from, to, line, ..options) = {

  let opts = (
      char-width: 0.5,
      stroke-width: 3pt,
      line-height: 1.5,
      line-offset: 1,
      dy: -1.5,
      content: none,
      content-right-anchor: 15,
      content-func: (content) => {
        set align(horizon)
        set text(size: 20pt)
        content
      },
      ..options.named()
    )

  let hw = opts.stroke-width.cm() / 2;
  let x1 = opts.char-width * from;
  let x2 = opts.char-width * to;
  let anc = x1 + 0.5
  let height = line * opts.line-height + 1

  cetz.draw.line((x1 - hw, opts.dy), (x2 + hw, opts.dy))
  cetz.draw.line((x1, opts.dy), (x1, -1.3))
  cetz.draw.line((x2, opts.dy), (x2, -1.3))
  cetz.draw.line((anc, opts.dy), (anc, opts.dy - height))
  cetz.draw.line((anc + 0.5, opts.dy - height), (anc - hw, -1.5 - height))

  if (opts.content != none) {
    cetz.draw.content(
      (anc + 0.7, opts.dy - height + opts.line-height / 2),
      (opts.content-right-anchor, opts.dy - height - opts.line-height / 2),
      (opts.content-func)(opts.content))
  }
}

#let semibold(content) = {
  set text(weight: "semibold")
  content
}

#let headerbox = (arch, content) => {
  let index = 0
  if arch == "x86_64" {
    index = 2
  }
  let stroke-color = cell-color(palette.at(index)).stroke-color
  let fill-color = cell-color(palette.at(index)).background-color

  box(width: 100%, stroke: (right: 3pt + stroke-color, top: 3pt + stroke-color), clip: true, radius: (top-right: 10pt))[
    #box(inset: 10pt, width: 100%, content)
    #place(top + right)[
      #set align(horizon + center)
      #set text(weight: "semibold")
      #box(
        stroke: (left: 3pt + stroke-color, bottom: 3pt + stroke-color), fill: fill-color, inset: (x: 10pt), height: 1.2cm, radius: (bottom-left: 10pt), arch
      )
    ]
  ]
}