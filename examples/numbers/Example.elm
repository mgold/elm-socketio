module Example where

import Graphics.Element exposing (show)
import Task exposing (Task, andThen)
import String
import Time
import SocketIO

socket : Task x SocketIO.Socket
socket = SocketIO.io "http://localhost:8001" SocketIO.defaultOptions

eventName = "example"

-- send a value once at program start
port initial : Task x ()
port initial = socket `andThen` SocketIO.emit eventName "0"

received : Signal.Mailbox String
received = Signal.mailbox "null"

-- set up the receiving of data
port responses : Task x ()
port responses = socket `andThen` SocketIO.on eventName received.address

validResponses : Signal Int
validResponses =
    Signal.filterMap (String.toInt>>Result.toMaybe) 0 received.signal

-- send many values (with a 1-second throttle)
port recurring : Signal (Task x ())
port recurring =
    Signal.map (\i -> socket `andThen` SocketIO.emit eventName (toString (i+1)))
    <| Signal.sampleOn (Time.fps 1) validResponses

main = Signal.map show validResponses
