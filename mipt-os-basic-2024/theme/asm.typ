
#let asmcolors-light = (
  instruction: rgb("871094"),
  register: rgb("00627A"),
  number: rgb("1750EB"),
  dwordptr: rgb("871094"),
  comment: rgb(139, 139, 139),
  label: rgb("0033B3"),
  constant: rgb("0033B3")
)

#let highlight(input, theme, no-mnemonic: false) = {
  let rules = (
      (regex("\#.*"), theme.comment),
      (regex("[a-zA-Z_][0-9a-zA-Z_]*:"), theme.label),
  )
  if not no-mnemonic {
    rules.push((regex("^\s*[a-z]+(\.[a-z]+)?"), theme.instruction))
  }
  rules += (
      // hexademicals
      (regex("0x[0-9a-zA-Z]+"), theme.number),
      // x86 r1-r15
      (regex("%?r[0-9]?[0-9]"), theme.register),
      // arm registers
      (regex("(x|w)[0-9]?[0-9]"), theme.register),
      // numbers
      (regex("[0-9]+"), theme.number),
      // ax, bc, cx, dx, si, di, bp, sp, ip and extensions
      (regex("%?([re]?(([abcd]x)|si|bp|sp|ip|di))"), theme.register),
      (regex("%?[abcd][lh]"), theme.register),
      (regex("(pc)|(x|wzr)"), theme.register),
      (regex("(([DQ]?WORD)|(BYTE)) PTR"), theme.dwordptr),
      (regex("[a-zA-Z_][0-9a-zA-Z_]*"), theme.constant)
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

#let asm(code) = {
  codebox(lang: "asm", code)
}

#let lightasm(code, no-mnemonic: false) = {
  box(inset: 2pt, baseline: 2pt)[
    #set text(weight: "semibold")
    #highlight(code, asmcolors-light, no-mnemonic: no-mnemonic)
  ]
}

#let inlineasm(asm) = {
  set text(size: 1.2em)
  lightasm(asm)
}

#let register(name) = {
  set text(size: 1.2em, fill: asmcolors-light.register, weight: "bold")
  raw(name)
}

#let mnemonic(name) = {
  set text(size: 1.2em, fill: asmcolors-light.instruction, weight: "bold")
  raw(name)
}

#let lightasmtable(code, numbers: false, inset: auto) = {
    let lines = code.text.split("\n")
    let table-inset = (:)
    
    if inset != auto {
      table-inset.y = inset
    }


    table(
      columns: 2,
      align: (horizon + right, left),
      stroke: none,
      inset: table-inset,

      ..lines.enumerate().map(((i, line)) => {
        let number = if numbers {
          text(font: "Monaco", size: .6em, fill: luma(100))[
            #str(i + 1)
          ]
          h(0.5em)
        } else []

        if line.len() > 0 {
          line = lightasm(line)
        } else {
          line = hide(lightasm("x"))
        }

        (number, line)
      }).flatten()
    )
}