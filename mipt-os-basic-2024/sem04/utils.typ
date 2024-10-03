
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

#let highlight(input, theme) = {
  let rules = (
      (regex("^[a-z]+"), theme.instruction),
      // ax, bc, cx, dx, si, bp, sp, ip and extensions
      (regex("%?([re]?(([abcd]x)|si|bp|sp|ip))"), theme.register),
      (regex("%?[abcd][lh]"), theme.register),
      // x86 r1-r15
      (regex("%?r1?[0-9]"), theme.register),
      // arm registers
      (regex("x1?[0-9]"), theme.register),
      (regex("\$?((0x[0-9a-z]+)|[0-9]+)"), theme.number),
      (regex("(([DQ]?WORD)|(BYTE)) PTR"), theme.dwordptr),
    )

  let replace(string, rule, color) = {
    let result = ()
    for part in string {
      if type(part) == str {
        let matches = part.matches(rule).map(match => {
          // match
          text(fill: color, {raw(match.text)})
        })
        let parts = part.split(rule)
        matches.push(none)
        let append = parts.zip(matches).flatten().filter(a => a != none and a != "")
        result = (result, append).flatten()
        
      } else {
        result.push(part)
      }
    }
    return result
  }
  let finalize(string) = {
    return string.map(part => {
      if(type(part) == str) {
        return raw(part)
      }
      return part
    }).join()
  }

  let string = (input,)

  for rule in rules {
    string = replace(string, rule.at(0), rule.at(1))
  }
  finalize(string)
}

#let asmcolors-light = (
  instruction: rgb("871094"),
  register: rgb("00627A"),
  number: rgb("1750EB"),
  dwordptr: rgb("871094")
)

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
  set text(weight: "semibold", size: 20pt)
  content
}

#let asm(code) = {
  codebox(lang: "asm", code)
}

#let lightasm(code) = {
  box(inset: 2pt, baseline: 2pt)[
    #set text(weight: "semibold")
    #highlight(code, asmcolors-light)
  ]
}

#let inlineasm(asm) = {
  set text(size: 1.2em)
  lightasm(asm)
}