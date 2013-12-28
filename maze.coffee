# Generate random integer in [0, max]
randInt = (max) ->
  Math.floor(Math.random() * (max + 1))

# Using backtracking algorithm to generate a maze
mazeGenerator = (width, height) ->
  # Setup constants
  # N for North, S for South,
  # E for East, W for West
  [N, S, E, W] = [1, 2, 4, 8]
  DIRS_VALUE = { N: 1, S: 2, E: 4, W: 8 }
  DX = { E: 1, W: -1, N: 0, S: 0 }
  DY = { E: 0, W: 0, N: -1, S: 1 }
  OPPOSITE = { E: W, W: E, N: S, S: N }

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
    _.any directions, (direction) ->
      nx = x + DX[direction]
      ny = y + DY[direction]

      if nx>=0 && ny>=0 && nx < width && ny < height && grid[ny][nx] == 0
        grid[y][x] += DIRS_VALUE[direction]
        grid[ny][nx] += OPPOSITE[direction]
        cells.push([nx, ny])

        index = null
        return true

    if index != null
      cells.splice(index, 1)

  return grid


class MazeGame
  constructor: (width, height, grid_size) ->
    @width = width || 10
    @height = height || @width
    @grid_size = grid_size
    @grids = mazeGenerator(width, height)

  # For drawing maze in canvas
  drawMaze: () ->
    @canvas = document.getElementById('maze-game')
    w = @grid_size * @width
    h = @grid_size * @height
    @canvas.setAttribute("width", w)
    @canvas.setAttribute("height", h)


    ix = 0
    iy = 0
    len = @width * @height
    @ctx = @canvas.getContext("2d")
    @ctx.fillStyle = "#f5f5f5"
    @ctx.fillRect(0, 0, @width*@grid_size, @height*@grid_size)
    tmp = 0
    for i in [0..@height-1]
      for j in [0..@width-1]
        ix = @grid_size * (tmp % @width)
        iy = @grid_size * Math.floor(tmp / @width)
        @drawBorder(ix, iy, ix + @grid_size, iy + @grid_size, @grids[i][j])
        tmp++

  drawBorder: (ix, iy, ix2, iy2, v) ->
    if !v
      @ctx.fillRect(ix, iy, ix2, iy2)
      return;

    @ctx.strokeStyle = "#aaa"
    @ctx.lineWidth = 1
    draw = (x1, y1, x2, y2) =>
      @ctx.beginPath();
      @ctx.moveTo(x1 + 0.5, y1 + 0.5);
      @ctx.lineTo(x2 + 0.5, y2 + 0.5);
      @ctx.closePath();
      @ctx.stroke();

    if !(v & 1) # N
      draw(ix, iy, ix2, iy)
    if !(v & 2) # S
      draw(ix, iy2, ix2, iy2)
    if !(v & 4) # E
      draw(ix2, iy, ix2, iy2)
    if !(v & 8) # W
      draw(ix, iy, ix, iy2)



$(document).ready () ->
  mazeGame = new MazeGame(20, 20, 20);
  mazeGame.drawMaze()