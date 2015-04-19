module SocketIO where

{-| A module for working with [Socket.io](http://socket.io/) servers. **All
    functions are impure.** This module uses Socket.io 1.3.5.

# Creating a Socket
Avoid creating signals of sockets.
@docs io, Options, defaultOptions

# Sending and Receiving
@docs emit, on

# Checking the connection
@docs isConnected, isDisconnected
-}

import Time
import Task
import Native.SocketIO

type Socket = Socket

{-| A type for options on a socket. See the [Socket.io docs](http://socket.io/docs/client-api/)
    for further explanation.
-}
type alias Options =
    {multiplex : Bool,
     reconnection : Bool,
     reconnectionDelay : Time.Time,
     reconnectionDelayMax : Time.Time,
     timeout : Time.Time}

{-| Default options for a new socket and manager. These are the same as
    Socket.io itself. -}
defaultOptions : Options
defaultOptions =
    Options False True 1000 500 20000

{-| Create a socket, given a hostname and options.

    socket = SocketIO.io "http://localhost:8001" SocketIO.defaultOptions

It's possible to run the Elm Reactor and your Socket.io node server
simultanesouly on different ports.
-}
io : String -> Options -> Socket
io = Native.SocketIO.io

{-| Send anything on the socket using the given event name. No serialization is
    done and the server must accept the JS representation of the Elm object
    sent.
-}
emit : Socket -> String -> a -> Task.Task x ()
emit = Native.SocketIO.emit

{-| Create a signal for an event. The values are JSON encoded. The inital value,
    and default for unserializable JS objects, is `"null"`. -}
on : Socket -> String -> Signal String
on = Native.SocketIO.on

{-| Check if a socket is connected. -}
isConnected : Socket -> Bool
isConnected = Native.SocketIO.isConnected

{-| Check if a socket is disconnected. Socket.io tracks this separately from
    the connection boolean. -}
isDisconnected : Socket -> Bool
isDisconnected = Native.SocketIO.isDisconnected
