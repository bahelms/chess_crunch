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
Cycles -> cycles_sets <- Sets
Cycle: timestamps, completed_on, time_limit
Drill: timestamps, answer, duration, cycle_id, position_id

Running a cycle on a set
* Click button
* Redirected to start first position in first set
* After all positions in all sets have been run, mark time on completed_on

Running a drill
* Shown image, to play, solution input
* Timer starts
* Input solution
* Click done button
* Timer stops
* Start next position in set
