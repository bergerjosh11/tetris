require 'ruby2d'

# Set up game window
set title: 'Tetris', background: 'black', width: 400, height: 600

# Define game constants
BLOCK_SIZE = 20
BOARD_WIDTH = 10
BOARD_HEIGHT = 20
PIECES = [
  [ [1,1],
    [1,1] ],
    
  [ [1,1,1],
    [0,1,0] ],
    
  [ [1,1,0],
    [0,1,1] ],
    
  [ [0,1,1],
    [1,1,0] ],
    
  [ [1,0,0],
    [1,1,1] ],
    
  [ [0,0,1],
    [1,1,1] ],
    
  [ [1,1,1,1] ]
]

# Define game variables
board = Array.new(BOARD_HEIGHT) { Array.new(BOARD_WIDTH, 0) }
current_piece = PIECES.sample
current_x = BOARD_WIDTH / 2
current_y = 0
score = 0

# Define game methods
def draw_board(board)
  board.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if cell == 1
        Square.new(x: x * BLOCK_SIZE, y: y * BLOCK_SIZE, size: BLOCK_SIZE, color: 'white')
      end
    end
  end
end

def draw_piece(piece, x, y)
  piece.each_with_index do |row, dy|
    row.each_with_index do |cell, dx|
      if cell == 1
        Square.new(x: (x + dx) * BLOCK_SIZE, y: (y + dy) * BLOCK_SIZE, size: BLOCK_SIZE, color: 'white')
      end
    end
  end
end

def collision?(board, piece, x, y)
  piece.each_with_index do |row, dy|
    row.each_with_index do |cell, dx|
      if cell == 1
        if y + dy >= BOARD_HEIGHT ||
           x + dx < 0 ||
           x + dx >= BOARD_WIDTH ||
           board[y + dy][x + dx] == 1
          return true
        end
      end
    end
  end
  false
end

def remove_rows(board)
  new_board = board.reject { |row| row.all? { |cell| cell == 1 } }
  num_rows_removed = BOARD_HEIGHT - new_board.length
  new_board = Array.new(num_rows_removed) { Array.new(BOARD_WIDTH, 0) } + new_board
  [new_board, num_rows_removed]
end

# Set up game loop
update do
  clear

  # Draw board
  draw_board(board)

  # Draw current piece
  draw_piece(current_piece, current_x, current_y)

  # Move current piece down
  if !collision?(board, current_piece, current_x, current_y + 1)
    current_y += 1
  else
    # Add current piece to board
    current_piece.each_with_index do |row, dy|
      row.each_with_index do |cell, dx|
        if cell == 1
          board[current_y + dy][current_x + dx] = 1
        end
      end
    end

    # Remove any full rows
    board, num_rows_removed = remove_rows(board)
    score += num_rows_removed * 100

    # Create new
    current_piece = PIECES.sample
    current_x = BOARD_WIDTH / 2
    current_y = 0

    # Game over if new piece collides with top of board
    if collision?(board, current_piece, current_x, current_y)
      set title: "Game Over! Score: #{score}"
      board = Array.new(BOARD_HEIGHT) { Array.new(BOARD_WIDTH, 0) }
      score = 0
    end
  end
end

# Add user input functionality
on :key_down do |event|
  if event.key == 'left'
    if !collision?(board, current_piece, current_x - 1, current_y)
      current_x -= 1
    end
  end

  if event.key == 'right'
    if !collision?(board, current_piece, current_x + 1, current_y)
      current_x += 1
    end
  end

  if event.key == 'up'
    rotated_piece = current_piece.transpose.map(&:reverse)
    if !collision?(board, rotated_piece, current_x, current_y)
      current_piece = rotated_piece
    end
  end

  if event.key == 'down'
    while !collision?(board, current_piece, current_x, current_y + 1)
      current_y += 1
    end
  end
end

# Start game loop
show
