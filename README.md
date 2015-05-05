#Socket.io for Elm

This is a work in progress. The API is subject to change dramatically.

Currently, if you want a stable connection to the server (the most common use case), the library can accommodate you. Dynamic connections have not been tested. Joining [rooms](http://socket.io/docs/rooms-and-namespaces/) is not (yet?) supported.

For documentation, see `src/SocketIO.elm`. For more information, see the [mailing list thread](https://groups.google.com/d/msg/elm-discuss/qq2mv2igZ_I/FRWhy6PfKYUJ).

Supports Elm 0.15 and Socket.io 1.3.5.

## Examples

### Numbers
In the example, client and server exchange a number, incrementing it each time. The server sees odd numbers and the client sees even numbers.

A working Elm client and Node server are provided. In separate terminals, run `node examples/numbers/server.js` and `elm reactor`, then [open your browser](http://localhost:8000/examples/numbers/Example.elm) as you normally would with the reactor.

