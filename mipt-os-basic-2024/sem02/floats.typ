
#let get-bit-length(number) = {
  let length = 0
  while number != 0 {
    number = int.bit-rshift(number, 1)
    length += 1
  }
  length
}

#let is-bit-set(number, bit) = {
  let mask = int.bit-lshift(1, bit)
  int.bit-and(mask, number) != 0
}

#let float-construct(
    sign: none,
    mantissa: none,
    exponent: none,
    mantissa-bits: none,
    exponent-bits: none
) = {

  if exponent < 0 {
    // zero
    exponent = 0
    mantissa = 0
  }

  let exponent-max = int.bit-lshift(1, exponent-bits) - 1
  if exponent >= exponent-max {
    // infinity
    exponent = exponent-max
    mantissa = 0
  }

  let mantissa-max = int.bit-lshift(1, mantissa-bits) - 1
  mantissa = int.bit-and(mantissa, mantissa-max)
  
  return (
    sign: sign,
    mantissa: mantissa,
    exponent: exponent,
    mantissa-bits: mantissa-bits,
    exponent-bits: exponent-bits,
  )
}

#let float-nan(exponent-bits, mantissa-bits) = {
  // Constructor is not invoked here, it would turn it into infinity
  (
    sign: false,
    mantissa: int.bit-lshift(1, mantissa-bits - 1),
    exponent: int.bit-lshift(1, exponent-bits) - 1,
    mantissa-bits: mantissa-bits,
    exponent-bits: exponent-bits,
  )
}

#let float-one(sign, exponent-bits, mantissa-bits) = {
  float-construct(
    sign: sign,
    mantissa: 0,
    exponent: int.bit-lshift(1, exponent-bits - 1),
    mantissa-bits: mantissa-bits,
    exponent-bits: exponent-bits,
  )
}

#let float-infinity(sign, exponent-bits, mantissa-bits) = {
  float-construct(
    sign: sign,
    mantissa: 0,
    exponent: int.bit-lshift(1, exponent-bits) - 1,
    mantissa-bits: mantissa-bits,
    exponent-bits: exponent-bits,
  )
}

#let float-zero(sign, exponent-bits, mantissa-bits) = {
  float-construct(
    sign: sign,
    mantissa: 0,
    exponent: 0,
    mantissa-bits: mantissa-bits,
    exponent-bits: exponent-bits,
  )
}

#let float-is-zero(float) = {
  float.exponent == 0 and float.mantissa == 0
}

#let float-is-nan(float) = {
  float.exponent == int.bit-lshift(1, float.exponent-bits) - 1 and float.mantissa != 0
}

#let float-is-infinity(float) = {
  float.exponent == int.bit-lshift(1, float.exponent-bits) - 1 and float.mantissa == 0
}

#let float-from-int(number, exponent-bits, mantissa-bits) = {
  if number == 0 {
    return float-zero(false, exponent-bits, mantissa-bits)
  }

  let abs-number = calc.abs(number)
  let mantissa-mask = int.bit-lshift(1, mantissa-bits + 1) - 1
  let mantissa-high-bit = int.bit-lshift(1, mantissa-bits)
  let mantissa-result = int.bit-and(int(abs-number), mantissa-mask)

  let mantissa-shift = 0
  while (int.bit-and(mantissa-result, mantissa-high-bit) == 0) {
    mantissa-result = int.bit-lshift(mantissa-result, 1)
    mantissa-shift += 1
  }

  let exponent-max = int.bit-lshift(1, exponent-bits) - 1
  let exponent-zero = int.bit-lshift(1, exponent-bits - 1) - 1
  let exponent-result = mantissa-bits - mantissa-shift + exponent-zero

  float-construct(
    sign: number < 0,
    mantissa: mantissa-result,
    exponent: exponent-result,
    mantissa-bits: mantissa-bits,
    exponent-bits: exponent-bits
  )
}

#let float-from-bits(bits, exponent-bits, mantissa-bits) = {

  let exponent = 0
  let mantissa = 0

  for i in array.range(exponent-bits) {
    if bits.at(i + 1) {
      exponent = int.bit-or(exponent, int.bit-lshift(1, exponent-bits - i - 1));
    }
  }

  for i in array.range(mantissa-bits) {
    if bits.at(i + exponent-bits + 1) {
      mantissa = int.bit-or(mantissa, int.bit-lshift(1, mantissa-bits - i - 1));
    }
  }

  float-construct(
    sign: bits.at(0),
    mantissa: mantissa,
    exponent: exponent,
    mantissa-bits: mantissa-bits,
    exponent-bits: exponent-bits,
  )
}

#let float-is-normalized(float) = {
  return float.exponent != 0
}

#let float-get-full-mantissa(float) = {
  if float-is-normalized(float) {
    let mantissa-extra-bit = int.bit-lshift(1, float.mantissa-bits);
    return int.bit-or(float.mantissa, mantissa-extra-bit)
  }

  return float.mantissa
}

#let float-value(float) = {
  if(float-is-zero(float)) {
    return if float.sign { -0 } else { +0 }
  }

  if(float-is-infinity(float)) {
    return if float.sign { -calc.inf } else { +calc.inf }
  }

  if(float-is-nan(float)) {
    return if float.sign { -calc.nan } else { +calc.nan }
  }
  
  let factor-power = float.exponent - int.bit-lshift(1, float.exponent-bits - 1) + 1

  if not float-is-normalized(float) {
    factor-power += 1
  }
  
  let result = float-get-full-mantissa(float) * calc.pow(2, factor-power - float.mantissa-bits)

  if float.sign {
    -result
  } else {
    result
  }
}

#let float-bits(float) = {
  let bit-array = (float.sign,)

  for i in array.range(float.exponent-bits) {
    if is-bit-set(float.exponent, float.exponent-bits - i - 1) {
      bit-array.push(true)
    } else {
      bit-array.push(false)
    }
  }

  for i in array.range(float.mantissa-bits) {
    let bit = is-bit-set(float.mantissa, float.mantissa-bits - i - 1)
    bit-array.push(bit)
  }

  bit-array
}

#let float-compare(a, b) = {
  assert.eq(a.mantissa-bits, b.mantissa-bits, message: "can only compare floats with same format")
  assert.eq(a.exponent-bits, b.exponent-bits, message: "can only compare floats with same format")

  a.sign == b.sign and a.exponent == b.exponent and a.mantissa == b.mantissa
}

#let shr-with-rounding(number, bits) = {
  if bits == 0 {
    return number
  }

  number = int.bit-rshift(number, bits - 1)
  let round-up = is-bit-set(number, 0)
  number = int.bit-rshift(number, 1)
  
  return number + int(round-up)
}

#let trim-mantissa(mantissa, bits) = {
  let mantissa-overflow-bit = int.bit-lshift(1, bits + 1);
  let round-up = false
  let counter = 0

  while mantissa >= mantissa-overflow-bit {
    round-up = is-bit-set(mantissa, 0)
    counter += 1
    mantissa = int.bit-rshift(mantissa, 1)
  }

  // Round up if last trimmed bit was 1
  if round-up and mantissa + 1 < mantissa-overflow-bit {
    mantissa += 1;
  }

  return (counter, mantissa)
}

#let float-add(a, b) = {
  
  assert.eq(a.mantissa-bits, b.mantissa-bits, message: "can only add floats with same format")
  assert.eq(a.exponent-bits, b.exponent-bits, message: "can only add floats with same format")

  if(float-is-nan(a) or float-is-nan(b)) {
    return float-nan(a.exponent-bits, b.mantissa-bits)
  }

  if(float-is-infinity(a) and float-is-infinity(b) and a.sign != b.sign) {
    return float-nan(a.exponent-bits, b.mantissa-bits)
  }

  if(float-is-infinity(a) or float-is-zero(b)) {
    return a
  }

  if(float-is-infinity(b) or float-is-zero(a)) {
    return b
  }
    
  let a-exponent = a.exponent + int(not float-is-normalized(a))
  let b-exponent = b.exponent + int(not float-is-normalized(b))

  let max-exponent = calc.max(a-exponent, b-exponent)
  
  let a-mantissa = float-get-full-mantissa(a)
  let b-mantissa = float-get-full-mantissa(b)

  // panic(float-value(a), float-value(b))
  // panic((a-exponent, a-mantissa), (b-exponent, b-mantissa))

  let normalized-a-mantissa = shr-with-rounding(a-mantissa, max-exponent - a-exponent)
  let normalized-b-mantissa = shr-with-rounding(b-mantissa, max-exponent - b-exponent)

  if a.sign { normalized-a-mantissa = -normalized-a-mantissa }
  if b.sign { normalized-b-mantissa = -normalized-b-mantissa }

  // panic((max-exponent, normalized-a-mantissa, normalized-b-mantissa))

  let mantissa-result = normalized-a-mantissa + normalized-b-mantissa
  let sign = mantissa-result < 0
  mantissa-result = calc.abs(mantissa-result)
  let mantissa-result-length = get-bit-length(mantissa-result)

  let exponent-result = calc.max(a.exponent, b.exponent)

  // panic((mantissa-result, mantissa-result-length, a.mantissa-bits))

  // Avoid extending denormalized float
  
  if mantissa-result-length > a.mantissa-bits + 1 {
    let (trimmed-bits, trimmed-mantissa) = trim-mantissa(mantissa-result, a.mantissa-bits)
    mantissa-result = trimmed-mantissa
    exponent-result += trimmed-bits;
    
  } else if mantissa-result-length < a.mantissa-bits + 1 {
    if(mantissa-result == 0) {
      return float-zero(false, a.exponent-bits, a.mantissa-bits);
    }

    for i in array.range(mantissa-result-length, a.mantissa-bits + 1) {
      if exponent-result > 0 {
        exponent-result -= 1;
      }
      if exponent-result > 0 {
        mantissa-result = int.bit-lshift(mantissa-result, 1);
      }
    }
  }

  float-construct(
    sign: sign,
    mantissa: mantissa-result,
    exponent: exponent-result,
    mantissa-bits: a.mantissa-bits,
    exponent-bits: a.exponent-bits,
  )
}

#let float-mul(a, b) = {
  assert.eq(a.mantissa-bits, b.mantissa-bits, message: "can only mul floats with same format")
  assert.eq(a.exponent-bits, b.exponent-bits, message: "can only mul floats with same format")

  if(float-is-nan(a) or float-is-nan(b)) {
    return float-nan(a.exponent-bits, b.mantissa-bits)
  }

  if(float-is-infinity(a) or float-is-infinity(b)) {
    if(float-is-zero(a) or float-is-zero(b)) {
      return float-nan(a.exponent-bits, b.mantissa-bits)
    }
    return float-infinity(a.sign != b.sign, a.exponent-bits, b.mantissa-bits)
  }

  if(float-is-zero(a) or float-is-zero(b)) {
    return float-zero(a.sign != b.sign, a.exponent-bits, a.mantissa-bits)
  }

  let exponent-zero = int.bit-lshift(1, a.exponent-bits - 1) - 1
  let a-mantissa = float-get-full-mantissa(a)
  let b-mantissa = float-get-full-mantissa(b)

  let (trimmed-bits, mantissa-result) = trim-mantissa(a-mantissa * b-mantissa, a.mantissa-bits)

  let exponent-result = a.exponent + b.exponent - exponent-zero - a.mantissa-bits + trimmed-bits

  float-construct(
    sign: a.sign != b.sign,
    mantissa: mantissa-result,
    exponent: exponent-result,
    mantissa-bits: a.mantissa-bits,
    exponent-bits: a.exponent-bits,
  )
}

#let float-div(a, b) = {
  assert.eq(a.mantissa-bits, b.mantissa-bits, message: "can only div floats with same format")
  assert.eq(a.exponent-bits, b.exponent-bits, message: "can only div floats with same format")

  if(float-is-nan(a) or float-is-nan(b)) {
    return float-nan(a.exponent-bits, b.mantissa-bits)
  }

  if float-is-zero(a) {
    if float-is-zero(b) {
      return float-nan(a.exponent-bits, a.mantissa-bits)
    }
    return float-zero(a.sign != b.sign, a.exponent-bits, a.mantissa-bits)
  }

  if float-is-infinity(a) {
    if float-is-infinity(b) or float-is-zero(b) {
      return float-nan(a.exponent-bits, b.mantissa-bits)
    }
    return float-infinity(a.sign != b.sign, a.exponent-bits, b.mantissa-bits)
  }

  if float-is-zero(b) {
    return float-infinity(a.sign != b.sign, a.exponent-bits, a.mantissa-bits)
  }

  if float-is-infinity(b) {
    return float-zero(a.sign != b.sign, a.exponent-bits, b.mantissa-bits)
  }

  let exponent-max = int.bit-lshift(1, a.exponent-bits) - 1
  let exponent-zero = int.bit-lshift(1, a.exponent-bits - 1) - 1
  let a-mantissa = float-get-full-mantissa(a)
  let b-mantissa = float-get-full-mantissa(b)

  let exponent-result = a.exponent - b.exponent + exponent-zero + a.mantissa-bits
  let mantissa-result = 0

  let rem = a-mantissa
  let shift = 0

  // Do the long division

  let mantissa-max = int.bit-lshift(1, a.mantissa-bits) - 1;
  while mantissa-result <= mantissa-max {
    if rem >= b-mantissa {
      mantissa-result += 1
      rem -= b-mantissa
    }

    mantissa-result = int.bit-lshift(mantissa-result, 1)
    rem = int.bit-lshift(rem, 1)
    exponent-result -= 1
  }

  float-construct(
    sign: a.sign != b.sign,
    mantissa: mantissa-result,
    exponent: exponent-result,
    mantissa-bits: a.mantissa-bits,
    exponent-bits: a.exponent-bits,
  )
}

#let float-neg(float) = {
  float-construct(
    sign: not float.sign,
    mantissa: float.mantissa,
    exponent: float.exponent,
    mantissa-bits: float.mantissa-bits,
    exponent-bits: float.exponent-bits,
  )
}

#let find-exponent(exponent-bits, mantissa-bits, guide-float) = {
  let exponent-mask = int.bit-lshift(1, exponent-bits) - 1
  let mantissa-mask = int.bit-lshift(1, mantissa-bits) - 1
  
  let result = float-construct(
    sign: false,
    mantissa: 0,
    exponent: 0,
    exponent-bits: exponent-bits,
    mantissa-bits: mantissa-bits
  )

  let exponent-zero = int.bit-lshift(1, result.exponent-bits - 1) - 1

  let offset = calc.pow(2, -exponent-zero - result.mantissa-bits)

  while(float-value(result) <= guide-float + offset / 2) {
    result.exponent += 1
    if result.exponent == exponent-mask {
      break
    }
    offset *= 2
  }

  result.exponent -= 1
  result
}

#let float-from-string(string, exponent-bits, mantissa-bits) = {
  
  let guide-float = float(string)
  let sign = false
  if guide-float < 0 {
    sign = true
    guide-float = -guide-float
  }
  let mantissa-mask = int.bit-lshift(1, mantissa-bits) - 1
  let exponent-mask = int.bit-lshift(1, exponent-bits) - 1

  let result = find-exponent(exponent-bits, mantissa-bits, guide-float)

  for i in array.range(0, result.mantissa-bits) {
    let mask = int.bit-lshift(1, result.mantissa-bits - i - 1)
    let old-mantissa = result.mantissa
    result.mantissa = int.bit-or(result.mantissa, mask)

    if float-value(result) > guide-float {
      result.mantissa = old-mantissa
    }
  }

  if float-value(result) < guide-float {
    float-infinity(sign, result.exponent-bits, result.mantissa-bits)
  }

  result.sign = sign
  result
}

#let floats-test() = {
  let size(exponent, mantissa) = {
    (
      float: (number) => {
        float-from-string(str(number), exponent, mantissa)
      },
      inf: (sign: false) => {
        float-infinity(sign, exponent, mantissa)
      },
      nan: (sign: false) => {
        float-nan(exponent, mantissa)
      },
      neg: (float) => {
        float-neg(float)
      },
      check-add: (a, b, c) => {
        let sum = float-add(a, b)
        assert(float-compare(c, sum), message: str(float-value(a)) + " + " + str(float-value(b)) + " = " + str(float-value(sum)) + " instead of " + str(float-value(c)));
      },
      check-mul: (a, b, c) => {
        let sum = float-mul(a, b)
        assert(float-compare(c, sum), message: str(float-value(a)) + " * " + str(float-value(b)) + " = " + str(float-value(sum)) + " instead of " + str(float-value(c)));
      },
      check-div: (a, b, c) => {
        let sum = float-div(a, b)
        assert(float-compare(c, sum), message: str(float-value(a)) + " / " + str(float-value(b)) + " = " + str(float-value(sum)) + " instead of " + str(float-value(c)));
      }
    )
  }

  let test-size(exponent, mantissa) = {
    let (float, inf, nan, neg, check-add, check-mul, check-div) = size(exponent, mantissa)

    check-add(float(4), float(-2), float(2))

    assert.eq(float-value(float(1)), 1)
    assert.eq(float-value(float(3)), 3)
    assert(not float-compare(float(1), float(2)))
    assert(float-compare(float(1), float(1)))
    assert(float-compare(float(-1), neg(float(1))))
    assert(float-compare(inf(), neg(inf(sign: true))))
    assert(float-compare(neg(inf()), inf(sign: true)))

    check-add(float(0), float(1), float(1))
    check-add(float(1), float(0), float(1))
    check-add(neg(float(0)), float(1), float(1))
    check-add(float(1), neg(float(0)), float(1))
    check-add(float(1), float(2), float(3))
    check-add(float(2), float(1), float(3))
    check-add(float(2), float(2), float(4))
    check-add(float(2), float(4), float(6))
    check-add(float(4), float(2), float(6))
    check-add(float(4), float(4), float(8))
    check-add(float(4), float(-2), float(2))
    check-add(float(-2), float(4), float(2))
    check-add(float(4), float(-4), float(0))
    check-add(float(4), float(-6), float(-2))
    check-add(float(-2), float(6), float(4))
    check-add(float(-2), nan(), nan())
    check-add(nan(), float(-2), nan())
    check-add(nan(), nan(), nan())
    check-add(inf(), float(5), inf())
    check-add(float(5), inf(), inf())
    check-add(nan(), inf(), nan())
    check-add(inf(), nan(), nan())
    check-add(inf(), inf(), inf())
    check-add(inf(), inf(sign: true), nan())
    check-add(inf(sign: true), inf(), nan())

    check-mul(float(1), float(1), float(1))
    check-mul(float(1), float(2), float(2))
    check-mul(float(2), float(1), float(2))
    check-mul(float(2), float(2), float(4))
    check-mul(float(2), float(-2), float(-4))
    check-mul(float(-2), float(2), float(-4))
    check-mul(float(-2), float(-2), float(4))
    check-mul(float(5), float(-1), float(-5))
    check-mul(float(5), float(0), float(0))
    check-mul(float(0), float(5), float(0))
    check-mul(float(-2), nan(), nan())
    check-mul(nan(), float(0), nan())
    check-mul(nan(), nan(), nan())
    check-mul(inf(), float(5), inf())
    check-mul(float(5), inf(), inf())
    check-mul(inf(), inf(), inf())
    check-mul(inf(), inf(sign: true), inf(sign: true))
    check-mul(inf(sign: true), inf(), inf(sign: true))
    check-mul(inf(), float(0), nan())
    check-mul(float(0), inf(), nan())

    check-div(float(1), float(0), inf())
    check-div(float(1), neg(float(0)), inf(sign: true))
    check-div(nan(), nan(), nan())
    check-div(inf(), float(0), nan())
    check-div(inf(), float(1), inf())
    check-div(inf(sign: true), float(1), inf(sign: true))
    check-div(inf(sign: true), float(-1), inf())
    check-div(inf(), float(-1), inf(sign: true))
    check-div(float(10), float(1), float(10))
    check-div(float(10), float(2), float(5))
    check-div(float(10), float(10), float(1))
    check-div(float(10), float(-10), float(-1))
    check-div(float(0), float(10), float(0))
    check-div(float(0), float(-10), neg(float(0)))
  }

  test-size(3, 3)
  test-size(3, 4)
  test-size(4, 3)
  test-size(4, 4)

  {
    let (float, inf, nan, neg, check-add, check-mul, check-div) = size(3, 4)

    // Check rounding
    check-mul(float(1.1875), float(1.1875), float(1.4375))
  }

  {
    let (float, inf, nan, neg, check-add, check-mul, check-div) = size(3, 4)

    // Check denormalized floats

    let smallest-float = float(0.015625)
    assert.eq(smallest-float.exponent, 0)
    assert.eq(smallest-float.mantissa, 1)
    assert.eq(float-value(smallest-float), 0.015625)

    let two-smallest-floats = float-add(smallest-float, smallest-float)
    assert.eq(float-value(two-smallest-floats), 0.015625 * 2)

    let one-exponent = float(0.25)
    assert.eq(one-exponent.exponent, 1)
    assert.eq(one-exponent.mantissa, 0)
    assert.eq(float-value(one-exponent), 0.25);

    assert.eq(float-add(smallest-float, one-exponent).exponent, 1)
    assert.eq(float-add(smallest-float, one-exponent).mantissa, 1)
    assert.eq(float-value(float-add(smallest-float, one-exponent)), 0.265625)

    assert.eq(float-add(one-exponent, neg(smallest-float)).exponent, 0)
    assert.eq(float-add(one-exponent, neg(smallest-float)).mantissa, 15)
  }

}