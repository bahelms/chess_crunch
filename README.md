# ChessCrunch

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

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

TODO:
- MVP:
  * Change when drill is completed; waiting on button click puts in a bad state when page is refreshed after the drill is done.
  * Set halted cycle into correct state after solutions are provided
- Nice to have:
  * Change Next Drill button text when there is no other drill
  * When creating positions, orient board based on To Play
  * Restyle position edit page on mobile
