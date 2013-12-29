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


  re_gen_maze: () ->
    @grids = mazeGenerator(@width, @height)
    @drawMaze()
    return @grids

  # For drawing maze in canvas
  drawMaze: () ->
    @canvas = document.getElementById('maze-zone')
    w = @grid_size * @width
    h = @grid_size * @height
    @canvas.setAttribute("width", w)
    @canvas.setAttribute("height", h)


    ix = 0
    iy = 0
    @ctx = @canvas.getContext("2d")
    @ctx.fillStyle = "#f3f3f3"
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

class Person
  constructor: (grids) ->
    @grids = grids
    @person = $(".person.face");
    @pos = [0, 0]
    @width = grids[0].length
    @height = grids.length
    @initShortcuts()

  initShortcuts: () ->
    Mousetrap.bind('up', () =>
      @move('up')
    )
    Mousetrap.bind('down', () =>
      @move('down')
    )
    Mousetrap.bind('left', () =>
      @move('left')
    )
    Mousetrap.bind('right', () =>
      @move('right')
    )

  reset: (grids) ->
    if grids
      @grids = grids
    @pos = [0, 0]
    @drawPerson()

  drawPerson: () ->
    @person.css("left", "#{@pos[0]*20+2}" + "px" )
    @person.css("top", "#{@pos[1]*20+2}"+"px")

  move: (direction) ->
    if not @validate_move(direction)
      return false

    switch direction
      when "up" then @pos[1]--
      when "down" then @pos[1]++
      when "left" then @pos[0]--
      when "right" then @pos[0]++

    @drawPerson()

    if @check_finished()
      console.log("DONE")
    return true

  validate_move: (direction) ->
    mazeNode = @grids[@pos[1]][@pos[0]]
    switch direction
      when "up"
        if @pos[1] == 0
          return false
        if (mazeNode & 1) == 0
          return false
      when "down"
        if @pos[1] == @height-1
          return false
        if (mazeNode & 2) == 0
          return false
      when "right"
        if @pos[0] == @width-1
          return false
        if (mazeNode & 4) == 0
          return false
      when "left"
        if @pos[0] == 0
          return false
        if (mazeNode & 8) == 0
          return false
    return true

  check_finished: () ->
    if @pos[0] == @height-1 && @pos[1] == @width-1
      alert("恭喜！")
    return false


$(document).ready () ->
  mazeGame = new MazeGame(20, 20, 20);
  mazeGame.drawMaze()
  person = new Person(mazeGame.grids)

  gui = require('nw.gui')
  menu = new gui.Menu()

  menu.append(new gui.MenuItem({ label: '还原本迷宫' }))
  menu.append(new gui.MenuItem({ label: '重新生成迷宫' }))

  menu.items[0].on('click', () ->
    person.reset()
  )
  menu.items[1].on('click', () ->
    person.reset(mazeGame.re_gen_maze())
  )

  document.body.addEventListener('contextmenu', (ev) ->
    ev.preventDefault()
    menu.popup(ev.x, ev.y)
    return false
  )