#Socket.io for Elm

This library provides Elm code with realtime two-way communication with a server using [socket.io](socket.io). It works quite well for the most common use case, a stable connection to a server.

That said, error handling is limited to setting options up front and reading the connection status. Joining [rooms](http://socket.io/docs/rooms-and-namespaces/), an inherently impure action, is not supported. If you need to dynamically connect and disconnect, use JavaScript.

For documentation, see `src/SocketIO.elm`. Supports Elm 0.15 and Socket.io 1.3.5.

## Examples

For each example,  working Elm client and Node server are provided. In separate terminals, run `node examples/<example>/server.js` and `elm reactor`, then [open your browser](http://localhost:8000/examples) as you normally would with the reactor.

### Numbers
In the example, client and server exchange a number, incrementing it each time. The server sees odd numbers and the client sees even numbers.

### Connected
A very simple example to show that you can obtain a signal about the connection state and use this to render information in the UI.

### Chat
The main example: a realtime chat program. You can test it out yourself with multiple browser tabs.

Chat is divided into five modules. `Protocol` most of the knowledge shared with the server and a few other common functions. `Login` is the login page, `Post` is the text field and submit button, and `View` makes the messages look pretty. Finally, `ChatClient` pulls it all together and does the I/O.
