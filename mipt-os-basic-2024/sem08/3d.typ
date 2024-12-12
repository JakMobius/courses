
#import "@preview/cetz:0.2.2"

#let set-matrix() = {
  cetz.draw.set-transform((
    (-1, 0, 0.2, 0),
    (0, -1, 0.2, 0),
    (0, 0, 0, 0),
    (0, 0, 0, 0),
  ))
}

#let draw-model() = {
  set-matrix();

  let model = json("models/locomotive.json")
  let verts = model.at("verts")
  let indices = model.at("indices")
  let texcoords = model.at("texcoords")

  let vert(i) = {
    verts.at(i - 1).map(x => x * 100)
  }
  let texcoord(i) = {
    texcoords.at(i - 1).map(x => x * 255)
  }
  
  for face in indices {
    let vertices = face.at(0).map(i => vert(i))
    let color = texcoord(face.at(2).at(0))

    let r = int(color.at(0))
    let g = int(color.at(1))
    let b = int(color.at(2))

    if r < 0 { r = 0 } else if r > 255 { r = 255 }
    if g < 0 { g = 0 } else if g > 255 { g = 255 }
    if b < 0 { b = 0 } else if b > 255 { b = 255 }

    cetz.draw.line(..vertices, close: true, fill: rgb(r, g, b))
  }
}
