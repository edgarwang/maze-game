# Using growing tree algorithm to generate
# random maze

# Setup constants
[N, S, E, W] = [1, 2, 4, 8]

DX = {
  E: 1,
  W: -1,
  N: 0,
  S: 0
}

DY = {
  E: 0,
  W: 0,
  N: -1,
  S: 1
}

OPPOSITE = {
  E: 'W',
  W: 'E',
  N: 'S',
  S: 'N'
}

# Generate random integer in [min, max]
randInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1) + min)