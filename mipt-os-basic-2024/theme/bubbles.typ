
#import "@preview/cetz:0.2.2"
#import "@preview/suiji:0.3.0": *

#let get-circle-intersections(x1, y1, r1, x2, y2, r2) = {
  let d = calc.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
  let a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
  let determinant = r1 * r1 - a * a

  if determinant < 0 {
    return ()
  }

  let h = calc.sqrt(determinant)

  let x = x1 + a * (x2 - x1) / d
  let y = y1 + a * (y2 - y1) / d

  let x3 = x + h * (y2 - y1) / d
  let y3 = y - h * (x2 - x1) / d
  let x4 = x - h * (y2 - y1) / d
  let y4 = y + h * (x2 - x1) / d

  ((x3, y3), (x4, y4))
}

#let draw-small-bubbles(label, count: 4, fill: none, stroke: 3pt + luma(50), radius-a: 0.2, radius-b: 0.8) = {
  
  cetz.draw.get-ctx(ctx => {
    let anchor = ctx.nodes.at(label)
    let distance = cetz.path-util.length(anchor.drawables.at(0).segments)

    let total-radius-deltas = (count - 1) * (count - 2) / 2
    let radius-delta = (radius-b - radius-a) / count
    let base-spacing = distance / (count - 1)

    let rng = gen-rng(42)
    let t = 0

    let res = ();

    for i in range(0, count) {
      let radius = radius-a + radius-delta * i

      cetz.draw.circle((name: label, anchor: t), radius: 1.0cm * radius, fill: fill, stroke: stroke)

      res.push(i)

      t += base-spacing

      // Radius correction
      t += radius-delta * 2 * i
      t -= radius-delta * 2 * total-radius-deltas / (count - 1)

      if t > distance {
        t = distance
      }
    }
  })
}

#let default-bubble-fill = gradient.radial((white, 0%), (luma(240), 100%))

#let bubbles-to-path(random-bubbles) = {
  let points = ()

  for i in range(0, random-bubbles.len() + 1) {
    let (x1, y1, r1) = random-bubbles.at(if i == 0 { random-bubbles.len() - 1 } else { i - 1 })
    let (x2, y2, r2) = random-bubbles.at(if i == random-bubbles.len() { 0 } else { i })

    let intersections = get-circle-intersections(x1, y1, r1, x2, y2, r2)
    let intersection-modules = intersections.map(((xi, yi)) => {
      xi * xi + yi * yi
    })
    let smallest-module = intersection-modules.fold(0, calc.max)
    let smallest-module-index = intersection-modules.position((x) => x == smallest-module)

    if(smallest-module-index == none) {
      continue
      // panic(i)
    }

    let (xi, yi) = intersections.at(smallest-module-index)

    if points.len() != 0 {
      let last-point = (xi, yi)
      let prev-point = points.at(points.len() - 1)
      let (xm, ym) = ((prev-point.at(0) + last-point.at(0)) / 2, (prev-point.at(1) + last-point.at(1)) / 2)

      xm -= x1;
      ym -= y1;
    
      let mid-length = calc.sqrt(xm * xm + ym * ym)
      let mid-coef = r1 / mid-length
      
      xm = xm * mid-coef + x1
      ym = ym * mid-coef + y1

      points.push((xm, ym));
    }

    points.push((xi, yi));
  }

  points
}

#let get-square-angles(points, coefficient) = {

  let angles = ()
  let sides = ()
  let side = int(points / 4)

  let side-w = int(side / coefficient)
  let side-h = side // int(side / coefficient)

  if side-w < 2 {
    side-w = 2
  }

  if side-h < 2 {
    side-h = 2
  }

  for i in range(0, side-w) {
    angles.push(calc.atan2(1, 1 - i / (side-w / 2)).rad())
    sides.push(0)
  }
  for i in range(0, side-h) {
    angles.push(calc.atan2(1, 1 - i / (side-h / 2)).rad() - calc.pi / 2)
    sides.push(1)
  }
  for i in range(0, side-w) {
    angles.push(angles.at(i) - calc.pi)
    sides.push(2)
  }
  for i in range(0, side-h) {
    angles.push(angles.at(i + side-w) - calc.pi)
    sides.push(3)
  }
  (angles, sides)
}

#let distance-to-unit-square(angle) = {
  if angle < 0 {
    return distance-to-unit-square(-angle)
  }
  angle = calc.rem(angle, calc.pi / 2)
  
  if(angle > calc.pi / 4) {
    angle = calc.pi / 2 - angle
  }

  let tangent1 = 1;
  let tangent2 = calc.tan(angle);

  return calc.sqrt(tangent1 * tangent1 + tangent2 * tangent2)
}

#let generate-bubbles-from-angles(angles, variances: (), seed: 42) = {
  let bubbles = angles.len()
  let radius-variance = 0.3
  let bubble-default-radius = (4 / bubbles) * (1 + radius-variance) * 1.3

  let rng = gen-rng(seed)
  let random-bubbles = ()
  for (i, angle) in angles.enumerate() {
    let rand-arr = ()
    (rng, rand-arr) = random(rng, size: 3);
    
    let square = distance-to-unit-square(angle)
    let cx = calc.cos(angle) * square
    let cy = calc.sin(angle) * square
    let cr = bubble-default-radius * (1 + radius-variance * (rand-arr.at(2) - 0.5) * 2) * variances.at(i, default: 1)

    // cetz.draw.circle((
    //   cx * width / 2 + x, 
    //   -cy * width / 2 + y),
    //   stroke: 3pt + black, 
    //   radius: 1cm * cr * width / 2
    // )

    random-bubbles.push((cx, cy, cr))
  }
  random-bubbles
}

#let clamp-reduce(value, reduce) = {
  if value > reduce {
    value - reduce
  } else if value < -reduce {
    value + reduce
  } else {
    0
  }
}

#let generate-bubble-wall(x0, y0, x1, y1, count, seed: 42) = {
  let distance = calc.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))
  let dx = (x1 - x0) / count
  let dy = (y1 - y0) / count
  
  let radius-variance = 0.3
  let bubble-default-radius = (distance / count / 2) * (1 + radius-variance) * 1.3

  let rng = gen-rng(seed)
  let random-bubbles = ()

  for i in range(0, count) {
    let rand-arr = ()
    (rng, rand-arr) = random(rng, size: 3);
    
    let cx = x0 + dx * i
    let cy = y0 + dy * i
    let cr = bubble-default-radius * (1 + radius-variance * (rand-arr.at(2) - 0.5) * 2)

    random-bubbles.push((cx, cy, cr))
  }

  random-bubbles
}

#let draw-bubble(x0, y0, width, height, fill: default-bubble-fill, stroke: 3pt + luma(50), seed: 42) = {
  let x = x0 + width / 2
  let y = y0 + height / 2

  let bubbles = 16
  let dimension-reduce = 0.8

  width = clamp-reduce(width, dimension-reduce)
  height = clamp-reduce(height, dimension-reduce)

  let coef = calc.abs(height / width)

  let (angles, sides) = get-square-angles(bubbles, 1 / coef)
  let variances = sides.map((side) => {
    if calc.rem(side, 2) == 0 {
      coef
    } else {
      1
    }
  })
  let random-bubbles = generate-bubbles-from-angles(angles, variances: variances, seed: seed)
  let points = bubbles-to-path(random-bubbles)

  points = points.map(((xp, yp)) => {
    ((xp / 2) * width + x, (yp / 2) * height + y)
  })

  if points.len() > 2 {
    cetz.draw.hobby(..points, close: true,
      fill: fill, stroke: stroke)

    //cetz.draw.line(..points, close: true,
    //  fill: fill, stroke: stroke)
  }
}