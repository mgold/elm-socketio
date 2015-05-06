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

main = Signal.map (\b -> if b then show "CONNECTED" else show "disconnected") connected.signal
