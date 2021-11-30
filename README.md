# ChessCrunch
Study chess like a boss! Input your own sets of positions to drill in cycles, a la the Woodpecker method.

### Features
* Create sets of drills to practice. Take picture from phone/manual
* Pull in games from chess.com and analyze them with stockfish
    * Be able to select a position to turn into a drill like `checkmates` or `defense`
* Compile expert games (chessgames.com) based on a search and auto play through them with some delay between moves (2 secs)
* Dan Heisman study book of positions from played games to drill

#### Dev Notes
Running a cycle on a set
* Click button
* Redirected to start first position in first set
* After all positions in all sets have been run, mark time on completed_on

Cycle states:
* in progress needing solutions
* in progress with all solutions
* round 1 complete, needing solutions
    next round can't start
* round N complete, under accuracy threshold
    next round can't start
* round N complete
* last round complete
    no next round
