#Socket.io for Elm

This is a work in progress. The API is subject to change dramatically.

Currently, if you want a stable connection to the server (the most common use case), the library can accommodate you. Dynamic connections have not been tested. Joining [rooms](http://socket.io/docs/rooms-and-namespaces/) is not (yet?) supported.

For documentation, see `src/SocketIO.elm`. For more information, see the [mailing list thread](https://groups.google.com/d/msg/elm-discuss/qq2mv2igZ_I/FRWhy6PfKYUJ).

Supports Elm 0.15 and Socket.io 1.3.5.

## Examples

For each example,  working Elm client and Node server are provided. In separate terminals, run `node examples/<example>/server.js` and `elm reactor`, then [open your browser](http://localhost:8000/examples) as you normally would with the reactor.

### Numbers
In the example, client and server exchange a number, incrementing it each time. The server sees odd numbers and the client sees even numbers.

### Connected
A very simple example to show that you can obtain a signal about the connection state and use this to render information in the UI.

### Chat
The main example: a realtime chat program. You can test it out yourself with multiple browser tabs.

Chat is divided into five modules. `Protocol` most of the knowledge shared with the server and a few other common functions. `Login` is the login page, `Post` is the text field and submit button, and `View` makes the messages look pretty. Finally, `ChatClient` pulls it all together and does the I/O.
