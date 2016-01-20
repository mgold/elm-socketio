#Socket.io for Elm

This library provides Elm code with realtime push-based two-way communication with a server using [socket.io](http://socket.io/). It works quite well for the most common use case, a stable connection to a server that you wrote in Node.js.

That said, error handling is limited to setting options up front and reading the connection status. Joining [rooms](http://socket.io/docs/rooms-and-namespaces/), an inherently impure action, is not supported. If you need to dynamically connect and disconnect, or interface with an API you don't control, use JavaScript.

Note that vanilla websockets (i.e. servers other than Socket.io) are not supported. You should use ports and the JS Websocket API.

For documentation, see `src/SocketIO.elm`. Supports Elm 0.16 and Socket.io 1.4.4.

## Examples
For each example, a working Elm client and Node server are provided. You will need to `cd examples` to start. This first time you do this, you will also need to `npm install` to get socket.io for the server. Then in separate terminals, run `node <example-name>/server.js` and `elm reactor`, then [open your browser](http://localhost:8000) and navigate to the example as you normally would with the reactor.

### Numbers
In this example, client and server exchange a number, incrementing it each time. The server sees odd numbers and the client sees even numbers.

This example is big enough to show all the useful features of the library, but no bigger. There is also a version using The Elm Architecture and elm-effects (with the same server).

### Chat
The main example: a realtime chat program. You can test it out yourself with multiple browser tabs.

Chat is divided into five modules. `Protocol` most of the knowledge shared with the server and a few other common functions. `Login` is the login page, `Post` is the text field and submit button, and `View` makes the messages look pretty. Finally, `ChatClient` pulls it all together and does the I/O.

### Connected
A very simple example to show that you can obtain a signal about the connection state and use this to render information in the UI.
