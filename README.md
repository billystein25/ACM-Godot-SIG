# ACM-Godot-SIG
A set of examples used for the ACM GameDev SIG made in Godot<br>

## Ex4-Inheritance-and-Composition
In this meeting we made talked about the patterns of Inheritance and Composition.<br>
We used Inheritance to abstract the levels to a root level scene from which all the levels will inherit. The root level only contains the more basic nodes such as the player, the camera, a tilemap, the door, and the deathplane. The root node also uses the root level script which handles all the logic for the scene transition, the player death, etc.<br>
After that we used Composition to create a basic node which extends Node that handles moving its parent across a series of points, which are defined by its children. This component can move the parent node in two different modes:
+ Cyclic: The node will move through all points cyclically. Once it reaches the last point, it moves to the first.
+ Ping Pong: The node will move all the points until it reaches the last one. Then it switches direction and starts moving backwards in those points until it reaches the first one. Then it starts moving forward again.<br>
Our custom node MovingBodyComponent is also a @tool script. We use this to add warnings to the editor when the parent node isn't of type Node2D, or when there aren't enough children to make a logical list of points.<br>
We use the same component to move the enemy spike as well as a simple platform, showcasing the strengths of this pattern in adding functionality to different entities.<br>
