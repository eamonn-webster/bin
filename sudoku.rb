#
# File: sudoku.rb
# Author: eweb
# Copyright eweb, 2016-2018
# Contents:
#
# Date:          Author:  Comments:
# 21st Aug 2016  eweb     #0008 solve sudoku
#  7th Apr 2018  eweb     #0007 rubocop
#
require 'io/console'

class Board
  attr_accessor :pause

  def clear
    @board = [0] * 81
  end

  def board
    @board ||=
      [8, 3, 0, 0, 0, 0, 6, 2, 0,
       2, 8, 1, 0, 6, 4, 3, 0, 7,
       0, 0, 0, 2, 7, 3, 0, 0, 8,
       0, 0, 0, 0, 9, 0, 5, 4, 0,
       6, 5, 7, 4, 1, 2, 9, 8, 3,
       0, 4, 9, 0, 5, 0, 0, 0, 0,
       0, 0, 0, 8, 4, 6, 0, 0, 5,
       5, 0, 8, 0, 3, 0, 4, 6, 1,
       0, 0, 0, 0, 2, 0, 8, 0, 9]
  end

  def setup_board
    clear
    pos = 0
    display_board(nil, pos)
    loop do
      ch = read_char
      break if ch == 'q'

      @board[pos] = ch.to_i
      pos += 1
      display_board(nil, pos)
    end
  end

  def rows
    0.upto(8).map { |x| board[(x * 9)..(x * 9 + 8)] }
  end

  def columns
    0.upto(8).map { |x| 0.upto(8).map { |y| board[y * 9 + x] } }
  end

  def squares
    0.upto(8).map { |x| [3 * (x / 3), 3 * (x % 3)] }.map do |x, y|
      board[(x * 9 + y)..(x * 9 + y) + 2] +
        board[((x + 1) * 9 + y)..((x + 1) * 9 + y) + 2] +
        board[((x + 2) * 9 + y)..((x + 2) * 9 + y) + 2]
    end
  end

  def group_finished(group)
    group.reject(&:zero?).uniq.size == 9
  end

  def groups_finished(groups)
    groups.all? { |x| group_finished(x) }
  end

  def finished_rows
    groups_finished(rows)
  end

  def finished_columns
    groups_finished(columns)
  end

  def finished_squares
    groups_finished(squares)
  end

  def finished
    finished_rows &&
      finished_columns &&
      finished_squares
  end

  def no_dupes(x)
    1.upto(9).all? { |n| x.count(n) <= 1 }
  end

  def check_rows
    rows.map { |x| no_dupes(x) }
  end

  def check_columns
    columns.map { |x| no_dupes(x) }
  end

  def check_squares
    squares.map { |x| no_dupes(x) }
  end

  def check
    [check_rows,
     check_columns,
     check_squares]
  end

  def no_dup_rows
    rows.all? { |x| no_dupes(x) }
  end

  def no_dup_columns
    columns.all? { |x| no_dupes(x) }
  end

  def no_dup_squares
    squares.all? { |x| no_dupes(x) }
  end

  def no_dupes_at_all
    no_dup_rows &&
      no_dup_columns &&
      no_dup_squares
  end

  def set_cell(p, c)
    board[p] = c
    display_board("setting #{p.div(9)},#{p.modulo(9)} to #{c}")
  end

  # Reads keypresses from the user including 2 and 3 escape character sequences.
  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e"
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
    input
  ensure
    STDIN.echo = true
    STDIN.cooked!
  end

  def display_board(msg = nil)
    print "\033[1;1f"
    puts
    puts msg
    read_char if msg && pause
    puts
    rows.each_with_index do |row, index|
      puts '+' + '-----------+' * 3 if index % 3 == 0
      puts '| ' + row.map { |cell| cell.zero? ? ' ' : cell }.zip([' ', ' ', '|'] * 3).flatten.join(' ')
    end
    puts '+' + '-----------+' * 3
    puts
    # print "\033[19A"
  end

  # but no good for reasoning...
  # we want to look at a cell and decide what it could be.
  # suppose we replaced it with an 'x'
  # then found the row, column and square that contained the 'x'
  # then for 1 to 9 we replace the x and check
  def what_to_do_all
    board.each_with_index do |c, i|
      if c == 0
        begin
          choices = []
          1.upto(9) do |x|
            board[i] = x
            choices << x if no_dupes_at_all
          end
          if choices.size == 1
            set_cell(i, choices.first)
          else
            board[i] = 0
          end
        end
      end
    end
    squares.map { |s| group_finished(s) }
  end

  def what_to_do_groups(what)
    send(what).each_with_index do |sqr, sqr_i|
      # puts "#{sqr}"
      1.upto(9) do |x|
        # next unless x == 7
        choices = []
        sqr.each_with_index do |c, i|
          bi = to_board_index(what, sqr_i, i)
          if c == 0
            board[bi] = x
            choices << i if no_dupes_at_all
            board[bi] = 0
          end
        end
        # puts "choices: #{choices}"
        if choices.size == 1
          p = to_board_index(what, sqr_i, choices.first)
          sqr[choices.first] = x
          set_cell(p, x)
        end
      end
    end
    send(what).map { |x| x.uniq.size == 9 }
  end

  def what_to_do_columns
    what_to_do_groups(:columns)
  end

  def what_to_do_rows
    what_to_do_groups(:rows)
  end

  def what_to_do_squares
    what_to_do_groups(:squares)
  end

  def number_of_zeros
    board.count(0)
  end

  def what_to_do
    display_board
    loop do
      z0 = number_of_zeros
      loop do
        z1 = number_of_zeros
        what_to_do_all
        break unless number_of_zeros < z1
      end
      loop do
        z1 = number_of_zeros
        what_to_do_squares
        break unless number_of_zeros < z1
      end
      loop do
        z1 = number_of_zeros
        what_to_do_columns
        break unless number_of_zeros < z1
      end
      loop do
        z1 = number_of_zeros
        what_to_do_rows
        break unless number_of_zeros < z1
      end
      break unless number_of_zeros < z0
    end
  end

  def to_board_index(what, which, index)
    case what
    when :rows
      row_index_to_board_index(which, index)
    when :columns
      column_index_to_board_index(which, index)
    when :squares
      square_index_to_board_index(which, index)
    end
  end

  def row_index_to_board_index(row, index)
    row * 9 + index
  end

  def column_index_to_board_index(col, index)
    index * 9 + col
  end

  def square_index_to_board_index(sqr, index)
    (sqr.div(3) * 3 + index.div(3)) * 9 + ((sqr % 3) * 3 + index % 3)
  end
end
