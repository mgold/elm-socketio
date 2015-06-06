var io = require('socket.io')(8001);

io.on('connection', function (socket) {
  console.log("Client connected.");
  socket.on('message', function (data) {
    console.log('Received:', data);
  });
  socket.on('disconnect', function (socket) {
    console.log("Client disconnected.");
  });
  socket.send('Hello I am a server using Websockets');
});
