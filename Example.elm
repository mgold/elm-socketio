module Example where

import Graphics.Element exposing (show)
import Task exposing (Task)
import SocketIO

socket = SocketIO.io "localhost" SocketIO.defaultOptions

port foo : Task x ()
port foo = SocketIO.emit socket "news" "read all about it"


main = show (SocketIO.isConnected socket)

