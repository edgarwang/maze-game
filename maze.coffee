# Generate random integer in [0, max]
randInt = (max) ->
  Math.floor(Math.random() * (max + 1))

# Using recursiveBacktracking to generate a maze
mazeGenerator = (width, height) ->
  # Setup constants
  # N for North, S for South,
  # E for East, W for West
  [N, S, E, W] = [1, 2, 4, 8]
  DIRS_VALUE = { N: 1, S: 2, E: 4, W: 8 }
  DX = { E: 1, W: -1, N: 0, S: 0 }
  DY = { E: 0, W: 0, N: -1, S: 1 }
  OPPOSITE = { E: W, W: E, N: S, S: E }

  # helper functions
  # Used to create a 2-dim array
  createGrid = (width, height) ->
    grid = []
    h = height
    while h--
      cell = []
      w = width
      while w--
        cell.push(0)
      grid.push(cell)
    return grid

  choose_index = (cells_sz) ->
    cells_sz - 1 # choost newest cell (recursiveBacktracking)

  # cells is used to store all active nodes
  cells = []
  cells.push [randInt(width-1), randInt(height-1)]
  index = 0
  grid = createGrid(width, height)

  while cells.length != 0
    index = choose_index(cells.length)
    [x, y] = cells[index]
    directions = _.shuffle(['N', 'S', 'E', 'W'])
    _.each directions, (direction) ->
      nx = x + DX[direction]
      ny = y + DY[direction]

      if nx>=0 && ny>=0 && nx < width && ny < height && grid[ny][nx] == 0
        grid[y][x] += DIRS_VALUE[direction]
        grid[ny][nx] += OPPOSITE[direction]
        cells.push([nx, ny])

        index = null
        return true

      cells.splice(index, 1) if index != null

  return grid

