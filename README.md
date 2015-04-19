#Socket.io for Elm

This is a work in progress. Feedback on the API is welcome.

For documentation, see `SocketIO.elm`.

Supports Elm 0.15 and Socket.io 1.3.5.

## Example

A working Elm client and Node server are provided. In separate terminals, run `node server.js` and `elm reactor`, then [open your browser](http://localhost:8000/Example.elm) as you normally would with the reactor.

In the example, client and server exchange a number, incrementing it each time. The server sees odd numbers and the client sees even numbers.
