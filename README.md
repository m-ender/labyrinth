# Labyrinth

Labyrinth is a two-dimensional [esoteric programming language](https://esolangs.org/wiki/Main_Page). The source code resembles a maze which is traversed by the instruction pointer. Labyrinth has two main features setting it apart from most other languages: a) there are no control flow operators - control flow is determined solely by the layout of the maze - and b) the source code can be modified at runtime via cyclic shifts of rows and columns. The latter mechanic was inspired by the German board game [*Das verrückte Labyrinth*](https://en.wikipedia.org/wiki/Labyrinth_(board_game)).

Labyrinth is Turing-complete as any Brainfuck program can be translated to Labyrinth quite trivially.

This repository contains the language specification (below), a reference implementation in Ruby as well as a handful of example programs.

## Overview

The source code consists of single-character instructions and is interpreted as a 2D grid. The instruction pointer starts at the first known character in the file (in reading order) going right. All unknown characters are considered walls.

As for data structures, Labyrinth has two stacks, called *main* and *auxiliary*. They both start empty but the bottoms of the stacks are treated as an infinite number of zeroes (so if you try to pop from operate on an empty stack you will get zeroes).

## Control Flow

Labyrinth is interpreted in a simple loop. At each step, the command under the instruction pointer is executed, then the new movement direction is determined, and then the instruction pointer moves one cell in that direction. The edges of the grid are *not* connected.

The instruction pointer will generally follow "corridors" of instructions. Junctions can be used for non-trivial control flow. How the new movement direction is determined depends on the number of available steps (i.e. number of direct neighbours with known commands):

- **4 neighbours:** The top of the *main* stack is examined. If it's 0, keep moving straight ahead. If it's negative, turn left. If it's positive, turn right.
- **3 neighbours:** Do the same as for four neighbours, but if you hit the wall, reverse the direction. Hence, a T-junction hit from the side differentiates between 0 and non-zero. A T-junction hit from the bottom on the other hand sends negative/positive to the left/right whereas a 0 value reverses the direction.
- **2 neighbours:** The first rule here is, don't turn around. So if you came from one of the two directions, continue in the other direction. If this is not the case, but one of the two directions is straight ahead, follow that one (this can happen, for instance, at the start of the program in a corner).

  *Important special case:* If the instruction pointer is facing a wall and has a wall at its back (i.e. the neighbours are to the left and right)... if the top of the *main* stack is negative/positive, go left/right (as you would with 3 or 4 neighbours). However, if the top of the stack is 0, choose one of the two directions at random. This is the only built-in random number generator. Note also that this setup can only be reached via very specific source code manipulation (see commands below). See [this example program](https://github.com/mbuettner/labyrinth/blob/master/examples/rng.lab) for how to make use of this in actual code.
  
- **1 neighbour:** Go towards the only available direction. Usually, this means you have hit a deadend and turn around on the spot (executing the command you turn around on only once).
- **0 neighbours:** Remain where you are without changing your direction. This can occur at the very start of the program or due to source code manipulation.

## Commands

With the exception of `v` Labyrinth uses only non-letter commands. Spaces are reserved as walls and `'`, `[` and `]` have no function yet but may be added later (that is, they are currently also treated as walls).

### General

- `"` is no-op, but is not considered a wall. It is very useful in padding some paths of your maze layout.
- `@` is an exit of the maze: the program terminates when this command is executed.

### Arithmetic

All arithmetic operators work with the *main* stack.

- `_` pushes a `0`.
- `0` to `9` multiplies the top of the stack by 10 and then adds the corresponding digit. If the top of the stack is negative, the digit is subtracted instead of added. This allows you to write decimal number into the source code despite each digit being processed separately. (This mechanic has been used in [Emmental](http://esolangs.org/wiki/Emmental) before but was conceived of independently.)
- `)` increments the top of the stack.
- `(` decrements the top of the stack.
- `+` pops two values from the stack and pushes their sum.
- `-` pops *y*, pops *x*, pushes *x-y*.
- `*` pops two values from the stack and pushes their product.
- `/` pops *y*, pops *x*, pushes *x/y* (integer division, rounded towards negative infinity).
- `%` pops *y*, pops *x*, pushes *x%y* (modulo; the sign of the result is the same as the sign of *y*).
- `` ` `` multiplies the top of the stack by `-1`.
- `&` pops two values from the stack and pushes their bitwise AND.
- `|` pops two values from the stack and pushes their bitwise OR.
- `$` pops two values from the stack and pushes their bitwise XOR.
- `~` pops a value from the stack and pushes its bitwise NOT.

### Stack manipulation

- `:` duplicates the top of the *main* stack.
- `;` pops the top of the *main* stack and discards it.
- `}` pops the top of the *main* stack and pushes it onto the *auxiliary* stack.
- `{` pops the top of the *auxiliary* stack and pushes it onto the *main* stack.
- `=` swaps the tops of two stacks.
- `#` pushes the depth of the *main* stack onto the *main* stack (not counting the implicit zeroes at the bottom).

### I/O

These also operate on the *main* stack.

- `,` read a single character from STDIN and push its byte value. Pushes `-1` once EOF is reached.
- `?` read as many characters as possible to form a valid (signed) decimal integer and push its value. Pushes `0` once EOF is reached.
- `.` pop a value and write the corresponding character to STDOUT.
- `!` pop a vlaue and write its decimal representation to STDOUT.
- `\` print a newline/line feed character (0x0A).

### Grid manipulation

The four trickiest commands are `<^>v`:

- All of them pop a value from the *main* stack to determine which row or column to shift.
- `<` or `>` shift a row cyclically by a single cell to the left or right, respectively.
- `^` or `v` shift a column cyclically by a single cell up or down, respectively.
- The value read from the stack is used as a relative index from the current position of the instruction pointer: if the top of the stack was 0, the row or column of the instruction pointer is shifted. If the value was -1, the previous row or column (to the left or upwards) is shifted. If the value was 2, the row or column two ahead (right or down) is shifted. This indexing is modular, so if the offset is too big for the grid it wraps around the edges.
- If the row or column of the instruction pointer is shifted, the instruction pointer is shifted along with the row/column *before* the new direction is determined and the pointer makes its own move. The instruction pointer *can* be shifted through the edges of the grid this way.

## Comments

Labyrinth doesn't have an dedicated comment syntax. However, spaces and all letters except lower-case `v` are considered walls, so you can use them freely around your code to add comments. Furthermore, you can use arbitrary characters (even recognised ones) as long as they are not reachable, e.g. by separating them from the actual program by a layer of walls. However, in this case be careful if you use the grid manipulation commands as they might bring your comments in contact with your actual program.

## Interpreter features

The interpreter has a verbose debug mode which can be activated with the command-line flag `-d`.
