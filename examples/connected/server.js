var io = require('socket.io')(8001);

io.on('connection', function (socket) {
  console.log("Client connected.");
  socket.on('disconnect', function (socket) {
    console.log("Client disconnected.");
  });
});
