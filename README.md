#Socket.io for Elm

This library provides Elm code with realtime two-way communication with a server using [socket.io](http://socket.io/). It works quite well for the most common use case, a stable connection to a server.

That said, error handling is limited to setting options up front and reading the connection status. Joining [rooms](http://socket.io/docs/rooms-and-namespaces/), an inherently impure action, is not supported. If you need to dynamically connect and disconnect, use JavaScript.

For documentation, see `src/SocketIO.elm`. Supports Elm 0.16 and Socket.io 1.3.7. Also supports vanilla websockets (use the empty string as the event name).

## Examples

For each example, a  working Elm client and Node server are provided. In separate terminals, run `node examples/<example>/server.js` and `elm reactor`, then [open your browser](http://localhost:8000/examples) as you normally would with the reactor.

### Numbers
In the example, client and server exchange a number, incrementing it each time. The server sees odd numbers and the client sees even numbers.

This example is big enough to show all the useful features of the library, but no bigger. There is also [a version](https://gist.github.com/mgold/c7832f9197ff3e931152) using The Elm Architecture and elm-effects.


### Chat
The main example: a realtime chat program. You can test it out yourself with multiple browser tabs.

Chat is divided into five modules. `Protocol` most of the knowledge shared with the server and a few other common functions. `Login` is the login page, `Post` is the text field and submit button, and `View` makes the messages look pretty. Finally, `ChatClient` pulls it all together and does the I/O.

### Connected
A very simple example to show that you can obtain a signal about the connection state and use this to render information in the UI.

### Websocket
A very simple demonstration of socket.io as [cross-browser websocket](http://socket.io/docs/#using-it-just-as-a-cross-browser-websocket).


