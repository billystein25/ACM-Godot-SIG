# ACM-Godot-SIG
A set of examples used for the ACM GameDev SIG made in Godot

## Ex2-2D-Player-And-Level
This project implements a simple 2D character controller designed for a basic 2D platformer as well as a simple 2D level making use of tilemaps and parallax.<br>
The player controller includes acceleration and deceleration, variadic jump, and coyote time. The player also uses a sprite-sheet with a few simple animations.<br>
The level is made using a tileset and a tilemap which also implements a terrain for automatic filling of tiles.<br>
The parallax consists of two layers with a single sprite each with a region bigger than the sprite size and the texture repeat mode set accordingly.<br>
The tileset is a modified version of Kenney's 2D Platformer assets while the assets used for the parallax come from the same pack.<br>