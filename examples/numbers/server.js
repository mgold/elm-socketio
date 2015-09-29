var io = require('socket.io')(8001);

io.on('connection', function (socket) {
  console.log("Client connected.");
  socket.on('example', function (data) {
    console.log('Received:', data);
    socket.emit('example', +data + 1);
  });
  socket.on('disconnect', function (socket) {
    console.log("Client disconnected.");
  });
});
