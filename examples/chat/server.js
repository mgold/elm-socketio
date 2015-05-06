var faker = require('faker');
var io = require('socket.io')(8001);

function sendData(socket){
    if (socket.disconnected) return;
    data = {name: faker.name.findName(),
            body: faker.lorem.sentence(),
            time: Date.now(),
            submit: true};
    console.log(data);
    socket.emit("chat", data);
    setTimeout(sendData, Math.random()*5000, socket);
}

var eventName = "chat"; 
io.on('connection', function (socket) {
    console.log("Client connected.");
    //sendData(socket);
    socket.on(eventName, function (data) {
        console.log("Received", JSON.parse(data));
    });
    socket.on('disconnect', function () {
        console.log("Client disconnected.");
    });
});
