---
title: "Autumn Code Challenge"
category: challenges
tags: programming
published: false
---

## Implement Conway's Game of Life

![](/assets/conways-game-of-life--masthead.png)

The purpose of this challenge is to get something going that can serve as a
structure for future code challenges. I have long wanted to try out Conway's
Game of Life, which is basically a simple square grid simulation of black and
white tiles. 

The initial learning purpose is rehashing game programming and trying out some
functional packages for C# in a more complex setting.

[Wikipedia](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)

### Rules

Given an infinite 2D grid of cells. Let each cell be in a live or dead state.
For each turn apply the following rules for all cells.

* **Rule of under-population**: Any live cells with fewer than two live neighbors
  dies
* **Rule of over-population**: Any live cells with more than three live neighbors
  dies
* **Rule of reproduction:** Any dead cells with exactly three neighbors becomes
  alive
* **Rule of preservation**: Any live cells with exactly two neighbors stays alive

### Constraints 

* **Language**: C#
* **Tests**: Adequate coverage
* **Visualization**: Minimal
* **Style**: Functional
* **Packages**: Either Nullable.Extensions, CSharpFunctionalExtensions or
  language-ext

### Features

* **Pause**: The game can be paused
* **Interactive**: The game accepts state overrides during the simulation
* **Seedbed**: The game can be started with a pre-configured seed
* **Turn-counter**: The game should support a turn counter

### Ideas for Future Iterations

* **Mazes**: Goblin Catch Maze Runner: Maze generation, AI maze solving, player input, visualizations.
* **Visualizations**: Razor, React, Svelte, Unity
* **Backends**; F#, node, Azure
* **Rules and representation**: Game of life with hexagons