#!/bin/bash

bin/chess_crunch eval "ChessCrunch.Release.migrate"
exec bin/chess_crunch start
