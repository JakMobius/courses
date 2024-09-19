
#import "@preview/cetz:0.2.2"
#import "@preview/polylux:0.3.1": pause
#import "./floats.typ": *

#let byte-colors = array.range(8).map((i) => {
  color.hsv(i * 45deg + 240deg, 100%, 100%)
})

#let float-mantissa-color = byte-colors.at(0)
#let float-exponent-color = byte-colors.at(1)
#let float-sign-color = byte-colors.at(2)

#let is-bit-set(number, bit) = {
  let mask = int.bit-lshift(1, bit)
  int.bit-and(mask, number) != 0
}

#let get-bit-array(number, length: 8) = {
  let result = ()

  for i in range(length) {
    result.push(is-bit-set(number, length - i - 1))
  }

  result
}

#let get-bit-length(number) = {
  let length = 0
  while number != 0 {
    number = int.bit-rshift(number, 1)
    length += 1
  }
  length
}

#let to-string-base-2(number, bits: none, fraction: 0) = {

  if bits == none {
    bits = get-bit-length(number)
  }
  let result = get-bit-array(number, length: bits).map(int).map(str)
  if fraction != 0 {
    if fraction < bits {
      result.slice(0, count: bits - fraction).join("") + "." + result.slice(bits - fraction).join("")
    } else {
      "0." + "0" * (fraction - bits) + result.join("")
    }
  } else {
    result.join("")
  }
}

#let cell-color(active: true, base-color: none) = {

  if base-color == none {
    base-color = blue
  }

  let background-color = color.mix((base-color, 20%), (white, 80%))
  let stroke-color = color.mix((base-color, 50%), (black, 50%))

  if active {
    (
      base-color: base-color,
      text-color: black,
      neg-text-color: red,
      background-color: background-color,
      stroke-color: stroke-color
    )
  } else {
    (
      base-color: base-color,
      text-color: luma(100),
      neg-text-color: luma(100),
      background-color: background-color,
      stroke-color: stroke-color
    )
  }
}

#let cell(x, y, size, content) = {
    cetz.draw.content((x * size.x, y * size.y), ((x + 1) * size.x, (y + 1) * size.y), padding: 0)[
      #content
    ]
  }

#let cellbox(theme, content) = {
  box(
    fill: theme.background-color, width: 100%, height: 100%, stroke: 1pt + theme.stroke-color
  )[#content]
}

#let draw-text-cell(x, y, grid-size, scale: (x: 1, y: 1), text-align: center, content) = {
  let size = (x: grid-size.x * scale.x, y: grid-size.y * scale.y)
  x /= scale.x
  y /= scale.y
  cell(x, y, size, {
    align(text-align + horizon, {
      set text(fill: black, weight: "black", size: 40pt)
      
      [#content]
    })
  })
}

#let draw-bits-boxes(x, y, cell-size, bit-array, theme, callback) = {
  for (i, bit) in bit-array.enumerate() {     
    let colors = theme(i, bit)
    
    cell(x + i, y, cell-size, {
      cellbox(colors, {
        align(center + horizon, {
          callback(i, bit)
        })
      })
    })
  }
}

#let draw-bits-indicators(x, y, cell-size, bit-array, theme) = {
  let show-if-last(i, content) = {
    if i == bit-array.len() - 1 [#content]
  }

  for (i, bit) in bit-array.enumerate() {
    let colors = theme(i, bit)

    cell(x + i, y, cell-size, {
      set text(size: 40pt, weight: "black", fill: colors.text-color)

      align(center + horizon, {
        [#show-if-last(i)[#hide[#sub[2]]]#int(bit)#show-if-last(i)[#sub[2]]]
      })
    })
  }
}

#let draw-number-bits(number, fractional: 0, signed: false, bit-count: 8) = {
  let cell-size = (x: 2.2, y: 2)
  let real-number = int(number * calc.pow(2, fractional))
  let rows = (1.5, 0, -1.25)
  let bit-array = array.range(bit-count).map((bit) => {
    is-bit-set(real-number, bit-count - bit - 1)
  })
  let theme = (i, bit) => {
    let color = if bit { blue } else { black }
    cell-color(active: bit, base-color: color)
  }

  cetz.canvas(length: 1cm, {
    draw-text-cell(-1, rows.at(1), cell-size)[=]
    draw-text-cell(bit-count, rows.at(1), cell-size)[=]
    draw-text-cell(-1, rows.at(2), cell-size)[=]
    draw-text-cell(0, rows.at(0), (x: cell-size.x * bit-count, y: cell-size.y))[
      #set text(fill: black, weight: "black", size: 60pt)
      #number#sub[10] =
    ]

    draw-bits-indicators(0, rows.at(2), cell-size, bit-array, theme)
    draw-bits-boxes(0, rows.at(1), cell-size, bit-array, theme, (i, bit) => {
      set text(weight: "bold")
      let theme = theme(i, bit)
      let mask = calc.pow(2, bit-count - i - 1 - fractional)
      let negative = i == 0 and signed
      let color = if negative { theme.neg-text-color } else { theme.text-color }

      if negative [
        -#mask
      ] else [+#mask]
    })
  })
}

#let generate-float-theme(float) = {
  (i, bit) => {
    let base-color = if i == 0 {
      float-sign-color
    } else if i >= 1 and i < float.exponent-bits + 1 {
      float-exponent-color
    } else {
      float-mantissa-color
    }

    let color = cell-color(active: bit, base-color: base-color)

    if not bit {
      let pat = pattern(size: (20pt, 20pt))[
        #let stroke = 6pt + color.background-color
        #place(line(stroke: stroke, start: (0%, 0%), end: (100%, 100%)))
        #place(line(stroke: stroke, start: (-100%, 0%), end: (100%, 200%)))
        #place(line(stroke: stroke, start: (0%, -100%), end: (200%, 100%)))
      ]
      color.background-color = pat
    }

    color
  }
}

#let draw-float-scheme(header, float) = {

  let cell-size = (x: 2.2, y: 2)
  let rows = (1.5, 0, -1.25)
  let bit-array = float-bits(float)
  let padding = 0.5 / cell-size.x
  let float-theme = generate-float-theme(float)

  let float-denominator = int.bit-lshift(1, float.exponent-bits - 1) - 1

  cetz.canvas(length: 1cm, {
    draw-text-cell(-3 - padding, rows.at(1), cell-size, scale: (x: 3, y: 1), text-align: right)[
      \= $1$
    ]
    draw-text-cell(bit-array.len() + padding, rows.at(1), cell-size, scale: (x: 3, y: 1), text-align: left)[
      $ dot 2 ^ (-#float-denominator)$ =
    ]

    draw-text-cell(-1, rows.at(2), cell-size)[=]
    draw-text-cell(0, rows.at(0), (x: cell-size.x * bit-array.len(), y: cell-size.y))[
      #set text(fill: black, weight: "black", size: 60pt)
      #header
    ]

    draw-bits-indicators(0, rows.at(2), cell-size, bit-array, float-theme)
    draw-bits-boxes(0, rows.at(1), cell-size, bit-array, float-theme, (i, bit) => {
      set text(weight: "bold", size: 30pt)

      if i == 0 {
        [$dot -1$]
      } else if i >= 1 and i < float.exponent-bits + 1 {
        let exponent-i = i - 1
        let power = calc.pow(2, float.exponent-bits - exponent-i - 1)
        
        [$dot 2 ^ #(power)$]
      } else {
        let mantissa-i = i - 1 - float.exponent-bits
        let denominator = calc.pow(2, mantissa-i + 1)
        [$+1 / #denominator$]
      }
    })
  })
}

#let draw-float-inline(float) = {
  let cell-size = (x: 1, y: 1)
  let bit-array = float-bits(float)
  let float-theme = generate-float-theme(float)

  box(baseline: 0.2em + 4pt, {
    cetz.canvas(length: 1.5em, {
      draw-bits-boxes(0, 0, cell-size, bit-array, float-theme, (i, bit) => {
        set text(fill: float-theme(i, bit).text-color)
        [*#int(bit)*]
      })
    })
  })
}

#let draw-short(number, endian: "little") = {
  let bits = 16
  let bytes = 2

  let cell-size = (x: 1.7, y: 2)

  let real-byte(byte) = {
    if(endian == "little") {
      int(bytes - byte - 1)
    } else {
      byte
    }
  }

  let bit-position(bit) = {
    bit + int(bit / 8) * 0.2 / cell-size.x
  }

  cetz.canvas(length: 1cm, {
    for i in array.range(bits) {
      let x0 = bit-position(i)
      let byte = bytes - int(i / 8) - 1
      let bit = calc.rem(i, 8)
      let real-bit = real-byte(byte) * 8 + (7 - bit)

      let bit-set = is-bit-set(number, real-bit)

      let base-color = if bit-set {
        byte-colors.at(real-byte(byte))
      } else {
        black
      }

      let theme = cell-color(active: bit-set, base-color: base-color)

      cell(x0, 0, cell-size, {
        cellbox(theme, {
          align(center + horizon, {
            set text(fill: theme.text-color, size: 25pt, weight: "black")
            [#{real-bit}]
          })
        })
      })
    }
  
    for (index, desc) in ((1, "Младший байт"), (0, "Старший байт")) {
      let x = bit-position(real-byte(index) * 8) * cell-size.x
      let y = -2.5

      cetz.draw.stroke(2pt)

      cetz.decorations.flat-brace(
        (x, y), 
        (x + cell-size.x * 8, y), 
        flip: true
      )

      cetz.draw.content((x, y), (x + cell-size.x * 8, y + cell-size.y), padding: 0, {
        align(center + horizon)[*#desc*]
      })
    }
  })
}

#let draw-simple-bits(bits, endian: "little") = {
  let max-bits = 64
  let bytes = int(bits / 8)

  let cell-size = (x: 0.3, y: 1)

  let real-byte(byte) = {
    if(endian == "little") {
      int(bytes - byte - 1)
    } else {
      byte
    }
  }

  let bit-position(bit) = {
    bit * cell-size.x + int(bit / 8) * 0.2
  }

  cetz.canvas(length: 1cm, {
    for i in array.range(bits) {
      let x0 = bit-position(i)
      let byte = bytes - int(i / 8) - 1
      let bit = calc.rem(i, 8)
      let real-bit = real-byte(byte) * 8 + (7 - bit)

      let theme = cell-color(base-color: byte-colors.at(real-byte(byte)))

      // Можно было использовать тут #cellbox, но мы их
      // рисуем 112 штук на каждый слайд, и это начинает
      // подтормаживать 
      cetz.draw.stroke(theme.stroke-color)
      cetz.draw.fill(theme.background-color)
      cetz.draw.rect((x0, 0), (x0 + cell-size.x, -cell-size.y))
    }

    if bits < max-bits {
      let x0 = bit-position(bits)
      let x1 = bit-position(max-bits - 1) + cell-size.x

      cetz.draw.content((x0, 0), (x1, cell-size.y), padding: 0)[
        #cellbox(cell-color(base-color: black))[
          #align(center + horizon)[
            *Свободно*
          ]
        ]
      ]
    }
  })
}

#let draw-float-formula(float) = {
  let wrap-in-box(base-color, content) = {
    let theme = cell-color(base-color: base-color)
    h(2pt)
    box(
      fill: theme.background-color, inset: 5pt, stroke: 1pt + theme.stroke-color, baseline: 0.2em,
    )[
      #set text(fill: theme.text-color)
      #content
    ]
    h(2pt)
  }

  let is-normalized = float-is-normalized(float)

  let float-denominator = int.bit-lshift(1, float.exponent-bits - 1) - 1 - (1 - int(is-normalized))

  $-1^(#wrap-in-box(float-sign-color)[#int(float.sign)]) dot 2^(#wrap-in-box(float-exponent-color)[#to-string-base-2(float.exponent, bits: float.exponent-bits)]#sub[2] - #float-denominator)$
    $ dot #int(is-normalized).#wrap-in-box(float-mantissa-color)[#to-string-base-2(float.mantissa, bits: float.mantissa-bits)]#sub[2]$
}

#let math-tint-box(content) = {
  h(0.25em)
  box(
    baseline: 0.1em + 5pt, inset: (x: 8pt, y: 8pt), radius: 5pt, fill: rgb(60, 60, 60),
  )[
    #set text(fill: white)
    #content
  ]
  h(0.25em)
}

#let float-column(var, constant, defined-float) = {
  let mantissa-bit-array = get-bit-array(defined-float.mantissa, length: defined-float.mantissa-bits)
  let exponent-bit-array = get-bit-array(defined-float.exponent, length: defined-float.exponent-bits)

  set block(above: 22pt, below: 22pt)
  set text(size: 25pt, weight: "bold")

  [
    $#math-tint-box[#var = #float-value(defined-float)]$
    #if type(constant) != str or float-value(defined-float) != float(constant) {
      $approx #constant$
    }
    
    $=$ #draw-float-formula(defined-float)

    #draw-float-inline(defined-float)
  ]
}

#let draw-float-add-slide(float-a-name, float-a, float-b-name, float-b) = {
  
  let sum-row(var-a, var-b) = {
    let mantissa-bits = float-a.mantissa-bits
    let exponent-bits = float-a.exponent-bits
    let sum = float-add(float-a, float-b)
    let float-denominator = int.bit-lshift(1, float-a.exponent-bits - 1) - 1
    
    let float-a-exponent = float-a.exponent + int(not float-is-normalized(float-a))
    let float-b-exponent = float-b.exponent + int(not float-is-normalized(float-b))

    let max-exponent = calc.max(float-a-exponent, float-b-exponent)

    let factors = [
      $2^(#to-string-base-2(max-exponent)#sub[2] - #float-denominator)$
    ]

    let mantissa-extra-bit = int.bit-lshift(1, mantissa-bits)
    let float-a-mantissa = float-get-full-mantissa(float-a)
    let float-b-mantissa = float-get-full-mantissa(float-b)
  
    let normalized-a-mantissa = shr-with-rounding(float-a-mantissa, max-exponent - float-a-exponent)
    let normalized-b-mantissa = shr-with-rounding(float-b-mantissa, max-exponent - float-b-exponent)

    if float-a.sign { normalized-a-mantissa = -normalized-a-mantissa }
    if float-b.sign { normalized-b-mantissa = -normalized-b-mantissa }

    let mantissa-sum = calc.abs(normalized-a-mantissa + normalized-b-mantissa)
    let mantissa-sum-length = get-bit-length(mantissa-sum)

    let maybe-power(exponent) = {
      if exponent < max-exponent {
        [$ dot 2 ^ #(exponent - max-exponent)$]
      }
    }

    let sign(float, plus: false) = {
      if float.sign == false and plus {
        [$+$]
      }
      if float.sign == true {
        [$-$]
      }
    }

    let maybe-approx = {
      let a-trimmed = int.bit-lshift(normalized-a-mantissa, max-exponent - float-a.exponent) != float-a-mantissa
      let b-trimmed = int.bit-lshift(normalized-b-mantissa, max-exponent - float-b.exponent) != float-b-mantissa

      if a-trimmed or b-trimmed {
        [$approx$]
      } else {
        [$=$]
      }
    }

    set block(above: 22pt, below: 22pt)
    set text(size: 25pt, weight: "bold")

    [$#math-tint-box[#var-a + #var-b =]$]

    pause

    [
      #factors
      $ dot (
        #sign(float-a)
        #to-string-base-2(float-a-mantissa, fraction: mantissa-bits)#sub[2] #maybe-power(float-a-exponent)
        #sign(float-b, plus: true)
        #to-string-base-2(float-b-mantissa, fraction: mantissa-bits)#sub[2] #maybe-power(float-b-exponent))$
    ]

    pause

    if float-a-exponent != float-b-exponent {
      $=$; parbreak(); $=$
      factors
      $ dot (
        #sign(float-a)
        #to-string-base-2(float-a-mantissa, fraction: mantissa-bits - float-a-exponent + max-exponent)#sub[2]
        #sign(float-b, plus: true)
        #to-string-base-2(float-b-mantissa, fraction: mantissa-bits - float-b-exponent + max-exponent)#sub[2])$
      
      pause
    } else {
      $#maybe-approx$

      parbreak()
    }

    [$#maybe-approx #sign(sum) $#factors$dot #to-string-base-2(mantissa-sum, fraction: mantissa-bits)#sub[2]$]
    pause
    $=$

    parbreak()

    $=$; draw-float-formula(sum); $#math-tint-box[\= #float-value(sum)]$; parbreak()
    draw-float-inline(sum)
  }

  cetz.canvas(length: 1cm, {
    let var-width = 11
    let var-offset = 7
    let var-height = 6

    let solution-width = var-offset * 2 + var-width
    let solution-height = 7

    cetz.draw.content((-var-offset - var-width / 2, 0), (-var-offset + var-width / 2, var-height), padding: 0, {
      float-column(math.sans("A"), float-a-name, float-a)
    })

    cetz.draw.content((var-offset - var-width / 2, 0), (var-offset + var-width / 2, var-height), padding: 0, {
      float-column(math.sans("B"), float-b-name, float-b)
    })

    cetz.draw.content((-solution-width / 2, -var-height), (solution-width / 2, -var-height - solution-height), padding: 0, {
      sum-row(math.sans("A"), math.sans("B"))
    })
  })
}

#let draw-float-mul-slide(float-a-name, float-a, float-b-name, float-b) = {
  
  let sum-row(var-a, var-b) = {
    let product = float-mul(float-a, float-b)
    let exponent-bits = float-a.exponent-bits
    let mantissa-bits = float-a.mantissa-bits
    let float-denominator = int.bit-lshift(1, exponent-bits - 1) - 1
    let mantissa-extra-bit = int.bit-lshift(1, mantissa-bits)
    let float-a-mantissa = int.bit-or(float-a.mantissa, mantissa-extra-bit)
    let float-b-mantissa = int.bit-or(float-b.mantissa, mantissa-extra-bit)
    let product-mantissa = int.bit-or(product.mantissa, mantissa-extra-bit)
    
    set block(above: 22pt, below: 22pt)
    set text(size: 25pt, weight: "bold")

    [$#math-tint-box[#var-a #sym.dot #var-b =]$]

    let maybe-plus(sign) = {
      if sign [+]
    }

    $-1^(#int(float-a.sign) #maybe-plus(not float-b.sign) #int(float-b.sign))$
    $dot 2^(
      #to-string-base-2(float-a.exponent, bits: exponent-bits)#sub[2] - #float-denominator
      #maybe-plus(float-b.exponent > 0)
      #to-string-base-2(float-b.exponent, bits: exponent-bits)#sub[2] - #float-denominator
    )$
    $dot #to-string-base-2(float-a-mantissa, fraction: mantissa-bits)#sub[2]$
    $dot #to-string-base-2(float-b-mantissa, fraction: mantissa-bits)#sub[2]$

    pause

    let zero-power-sum = calc.rem(int(float-a.sign) + int(float-b.sign), 2)
    let power-sum = float-a.exponent + float-b.exponent - float-denominator
    let mantissa-product = float-a-mantissa * float-b-mantissa

    $=$; parbreak(); $=$
    $-1^(#zero-power-sum)$
    $dot 2^(
      #to-string-base-2(power-sum)#sub[2] - #float-denominator
    )$
    $dot #to-string-base-2(mantissa-product, fraction: mantissa-bits * 2)#sub[2]$

    pause

    if mantissa-product == product-mantissa {
      $=$; parbreak(); $=$
    } else {
      $approx$; parbreak(); $approx$
    }

    draw-float-formula(product); $#math-tint-box[\= #float-value(product)]$; parbreak()
    draw-float-inline(product)
  }

  cetz.canvas(length: 1cm, {
    let var-width = 11
    let var-offset = 7
    let var-height = 6

    let solution-width = var-offset * 2 + var-width
    let solution-height = 7

    cetz.draw.content((-var-offset - var-width / 2, 0), (-var-offset + var-width / 2, var-height), padding: 0, {
      float-column(math.sans("A"), float-a-name, float-a)
    })

    cetz.draw.content((var-offset - var-width / 2, 0), (var-offset + var-width / 2, var-height), padding: 0, {
      float-column(math.sans("B"), float-b-name, float-b)
    })

    cetz.draw.content((-solution-width / 2, -var-height), (solution-width / 2, -var-height - solution-height), padding: 0, {
      sum-row(math.sans("A"), math.sans("B"))
    })
  })
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