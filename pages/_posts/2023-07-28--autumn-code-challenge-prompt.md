---
title: "Autumn Code Challenge (Prompt)"
category: challenges
tags: creativity architecture
published: true
---

## Implement Conway's Game of Life

![  ](/assets/conways-game-of-life--masthead.png)

The primary aim of this challenge is to get something going that can serve as a
structure for future code challenges. I have long wanted to try out Conway's
Game of Life, and as a simple square grid simulation of black and white tiles,
it seems like the perfect candidate for a foundation. 

[👉 Conway's Game of Life \| Wikipedia](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)

The secondary goal is to rehash game programming and to experiment a bit with
functional programming in C#.

### Rules

Given a 1000x1000 2D grid of cells, let each cell be in a live or dead state.  
For each turn apply the following rules for all cells.  

* **Rule of under-population**: Any live cells with fewer than two live neighbors
  dies
* **Rule of over-population**: Any live cells with more than three live neighbors
  dies
* **Rule of reproduction:** Any dead cells with exactly three neighbors becomes
  alive
* **Rule of preservation**: Any live cells with exactly two neighbors stays
  alive
* **Tiny world**: The game breaks at any time where a larger grid would be
  required to represent the state.

### Constraints 

* **Language**: C#
* **Tests**: Included
* **Visualization**: Minimal
* **Style**: Functional
* **Packages**: [language-ext](https://github.com/louthy/language-ext) and [FluidAssertions](https://fluentassertions.com/)
<!-- * (Alternatives Nullable.Extensions, CSharpFunctionalExtensions) -->

### Features

* **Pausing**: The game can be paused
* **Interactive**: The game accepts state overrides during the simulation
* **Seeding**: The game can be started with a pre-configured seed
* **Turn Counter**: The game should support a turn counter
* **Colorable**: The game can represent up to 10 generations of cells in different colors

### Notes for Future Iterations

* **Mazes**: Maze generation, AI maze solving.
* **Visualizations**: Razor, React, Svelte, Unity
* **Backends**; F#, Node.js, Azure
* **Representation**: Game of Life with hexagons

### Addendum (1th of February 2024)

Check out the end of the challenge [here](https://tugend.github.io/challenges/2024/02/01/autumn-code-challenge-conclusion.html).