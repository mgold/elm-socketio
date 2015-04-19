module Example where

import Graphics.Element exposing (show)
import Task exposing (Task)
import String
import Time
import SocketIO

socket : SocketIO.Socket
socket = SocketIO.io "http://localhost:8001" SocketIO.defaultOptions

eventName = "example"

-- send a value once at program start
port initial : Task x ()
port initial = SocketIO.emit socket eventName 0

responses : Signal String
responses = SocketIO.on socket eventName

validResponses : Signal Int
validResponses =
    Signal.filterMap (String.toInt>>Result.toMaybe) 0 responses

-- send many values (with a throttle)
port recurring : Signal (Task x ())
port recurring =
    Signal.map (\i -> SocketIO.emit socket eventName (i+1))
    <| Signal.sampleOn (Time.fps 1) validResponses

main = Signal.map show responses
