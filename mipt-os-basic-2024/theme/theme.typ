
#import "@preview/polylux:0.3.1": *
#import "@local/svg-emoji:0.1.0": setup-emoji

#let theme(content) = {
  set page(paper: "presentation-16-9")
  set text(font: "Roboto")

  // Fix list marker baseline
  show list.item: it => {
    let current-marker = if type(list.marker) == array {
      list.marker.at(0)
    } else {
      list.marker
    }
    let hanging-indent = measure(current-marker).width + .6em + .3pt
    set terms(hanging-indent: hanging-indent)
    if type(list.marker) == array {
      terms.item(current-marker, {
        // set the value of list.marker in a loop
        set list(marker: list.marker.slice(1) + (list.marker.at(0),))
        it.body
      })
    } else {
      terms.item(current-marker, it.body)
    }
  }
  set par(leading: 8pt)

  show: setup-emoji

  show link: this => {
    underline[#text(blue)[#this]]
  }

  content
}

#let enable-handout(content) = {
  if sys.inputs.at("handout", default: none) == "true" [
    #enable-handout-mode(true)
  ]

  content
}

#let m-dark-teal = rgb(9, 135, 181)
#let m-extra-light-gray = white.darken(2%)

#let slide-with-background(header: none, background-image-name: "board.svg", background-offset: 35%, place-location: none, content) = {
  set page(
    background: {
      place(
        center,
      )[
        #block(
          width: 100%, height: 100%, fill: gradient.radial(white, rgb(91%, 91.3%, 91.35%)),
        )
      ]

      if background-image-name != none {
        place(
          center,
        )[
          #move(dx: 0%, dy: background-offset)[
            #image(fit: "cover", background-image-name, width: 100%, height: 100%)
          ]
        ]
      }
    }, margin: (top: 30pt, left: 40pt, bottom: 15pt, right: 30pt),
  )

  polylux-slide[
    #set text(size: 25pt)

    #if header != none [
      = #header
    ]

    #set text(size: 19pt)

    #if place-location != none [
      #place(place-location)[
        #content
      ]
    ] else [
      #content 
    ]
  ]
}

#let title-slide(content, place-location: none) = {
  slide-with-background(background-image-name: "board.svg", background-offset: 35%, place-location: place-location)[
    #content
  ]
}

#let slide(header: none, background-image: "board-transparent.svg", place-location: none, content) = {
  slide-with-background(header: header, background-image-name: background-image, background-offset: 50%, place-location: place-location)[
    #content 
  ]
}

#let focus-slide(body) = {
  set page(fill: m-dark-teal, margin: 2em)
  set text(fill: m-extra-light-gray, size: 1.5em)
  logic.polylux-slide(align(horizon + center, body))
}

#let plain-slide(text) = {
  polylux-slide(text)
}

#let code(
  caption: none, // content of caption bubble (string, none)
  bgcolor: none, // back ground color (color)
  strokecolor: none, // frame color (color)
  hlcolor: none, // color to use for highlighted lines (auto, color)
  width: 100%, radius: 0pt, inset: 0pt, numbers: false, // show line numbers (boolean)
  numberstyle: auto, // style function to apply to line numbers (auto, style)
  firstnumber: 1, // number of the first line (integer)
  highlight: none, // line numbers to highlight (none, array of integer)
  leading: 0pt,
  content,
) = {
  if type(hlcolor) == "auto" {
    hlcolor = bgcolor.darken(10%)
  }
  if type(highlight) == "none" {
    highlight = ()
  }
  block(
    width: width, fill: bgcolor, stroke: strokecolor, radius: radius, inset: inset, clip: false, {
      // Draw the caption bubble if a caption was set
      if caption != none {
        style(
          styles => {
            let caption_block = block(
              width: auto, inset: inset, radius: radius, fill: bgcolor, stroke: strokecolor, h(.5em) + caption + h(.5em),
            )
            place(
              top + left, dx: 0em, dy: -(measure(caption_block, styles).height / 2 + inset), caption_block,
            )
          },
        )
        // skip some vertical space to avoid the caption overlapping with
        // the beginning of the content
        v(.6em)
      }

      let (columns, align, make_row) = {
        if numbers {
          // line numbering requested
          if type(numberstyle) == "auto" {
            numberstyle = text.with(font: "Monaco", size: .6em, fill: luma(100))
          }
          ((auto, 1fr), (right + horizon, left), e => {
            let (i, l) = e
            let n = i + firstnumber
            let n_str = numberstyle(str(n))
            (n_str + h(.5em), raw(lang: content.lang, l))
          })
        } else {
          ((1fr,), (left,), e => {
            let (i, l) = e
            raw(lang: content.lang, l)
          })
        }
      }
      table(
        stroke: none, 
        columns: columns, 
        rows: (auto,), 
        column-gutter: 0pt,
        row-gutter: leading, 
        inset: 5pt, align: (col, _) => align.at(col), fill: (c, row) => if (row / 2 + firstnumber) in highlight { hlcolor } else { none }, ..content
        .text
        .split("\n")
        .enumerate()
        .map(make_row)
        .flatten()
        .map(c => if c.has("text") and c.text == "" { " " } else { c }),
      )
    },
  )
}

#let white-box(content, inset: (x: 15pt, y: 10pt)) = {
  box(
    fill: rgb(240, 240, 240), inset: inset, radius: 10pt, content, stroke: 2pt + rgb(185, 186, 187),
  )
}

#let colbox(color: red, content) = {
  box(
    baseline: 0.2em + 4pt, inset: (x: 10pt, y: 10pt), radius: 5pt, fill: color,
  )[
    #set text(fill: white, font: "Roboto")
    #content
  ]
}

#let codebox(lang: none, prefix: none, content) = {
  box(
    baseline: 5pt + 0.1em, inset: (x: 2pt + 0.2em, y: 3pt + 0.2em), radius: 5pt, fill: rgb(60, 60, 60),
  )[
    #set text(baseline: -1pt)
    #if prefix != none [
      #prefix
    ]
    #set text(fill: white)
    #set raw(theme: "../theme/halcyon.tmTheme")
    #raw(lang: lang, content)
  ]
}

#let bash(code) = codebox(lang: "bash", prefix: text(fill: green)[`$`], code)

#let palette = array.range(8).map((i) => {
  color.hsv(i * 45deg + 240deg, 100%, 100%)
})