# Froggy Game🐸

A classic arcade-style game written in Assembly language.

## Objective

The objective of this project is to develop a simple and fun arcade-style game using Assembly language. 

## Game Description

Froggy Game is a classic arcade-style game where the player controls a frog that must navigate through various obstacles to reach its destination. The game is implemented in Assembly language, providing a hands-on experience with low-level programming and hardware interaction.

### Key Features

- **Player Control**: Control the frog using keyboard inputs.
- **Obstacles**: Navigate through moving obstacles to reach the destination.
- **Scoring System**: Keep track of the player's score based on performance.
- **Game Over**: Display a game over screen when the player loses.

## Implementation

The Froggy Game is implemented in x86 Assembly language. Below are some of the key aspects of the implementation:

### Graphics

- The game uses text mode graphics to display the game elements, such as the frog, obstacles, and the game area.
- ASCII characters are used to represent different game elements, making it easier to render the game on the screen.

### Input Handling

- The game captures keyboard inputs to control the movement of the frog.
- Interrupts are used to handle keyboard events and update the frog's position accordingly.

### Game Loop

- The game is driven by a main loop that continuously updates the game state and renders the game elements on the screen.
- The loop checks for player inputs, updates the positions of the obstacles, and detects collisions.

### Collision Detection

- Simple collision detection logic is implemented to check if the frog collides with any obstacles.
- If a collision is detected, the game ends and the game over screen is displayed.

### Scoring System

- The game keeps track of the player's score based on the distance traveled and successful navigation through obstacles.
- The score is displayed on the screen during gameplay.

### Assembly Instructions

- The game makes extensive use of x86 Assembly instructions for low-level operations, such as reading inputs, updating memory, and rendering graphics.
- Conditional jumps, loops, and interrupts are used to control the game flow and handle various events.
