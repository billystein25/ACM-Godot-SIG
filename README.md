# ACM-Godot-SIG
A set of examples used for the ACM GameDev SIG made in Godot<br>

## Ex3-Areas-And-Signals
In this meeting we made use of Area2D's to implement a basic spike enemy and a door that loads the next level.<br>
We made use of signals to detect when the player is inside each of these scenes so that they emit their own signals that the root level listens to. This way the transition and death functions are handled within the root level script, in a centralised and easily modifiable location.<br>
The sprites used are part of Kenney's 2D Platformer assets.