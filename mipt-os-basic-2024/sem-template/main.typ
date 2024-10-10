
#import "@preview/polylux:0.3.1": *
#import "@preview/cetz:0.2.2"
#import "../theme/theme.typ": *

#show: theme

#title-slide[
  #align(horizon + center)[
    = Заголовок

    АКОС, МФТИ

    XX сентября, 20XX
  ]
]

#show: enable-handout

#slide[
  // ...
]

#title-slide[
  #place(horizon + center)[
    = Спасибо за внимание!
  ]

  #place(
    bottom + center,
  )[
    // #qr-code("https://github.com/JakMobius/courses/tree/main/mipt-os-basic-2024", width: 5cm)

    #box(
      baseline: 0.2em + 4pt, inset: (x: 15pt, y: 15pt), radius: 5pt, stroke: 3pt + rgb(185, 186, 187), fill: rgb(240, 240, 240),
    )[
      🔗 #link(
        "https://github.com/JakMobius/courses/tree/main/mipt-os-basic-2024",
      )[*github.com/JakMobius/courses/tree/main/mipt-os-basic-2024*]
    ]
  ]
]