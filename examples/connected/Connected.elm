module Example where

import Graphics.Element exposing (show)
import Task exposing (Task, andThen)
import SocketIO

socket : Task x SocketIO.Socket
socket = SocketIO.io "http://localhost:8001" SocketIO.defaultOptions

connected : Signal.Mailbox Bool
connected = Signal.mailbox False

port connection : Task x ()
port connection = socket `andThen` SocketIO.connected connected.address

everConnected : Signal Bool
everConnected = Signal.foldp (||) False connected.signal


main =
    let f : (Bool, Bool) -> String
        f tup = case tup of
            (False, False) -> "Connecting..."
            (False, True) -> "DISCONNECTED"
            (True, _) -> "Connected."
    in Signal.map2 (\a b -> f (a,b) |> show) connected.signal everConnected
