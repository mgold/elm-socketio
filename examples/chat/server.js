var io = require('socket.io')(8001);

var messages = [];
var eventName = "chat";
io.on('connection', function (socket) {
    console.log("    Client connected.")
    var metadata;
    socket.on(eventName, function (data) {
        msg = JSON.parse(data);
        if (msg.name === "") return;
        if (!msg.time) msg.time = Date.now();
        if (msg.method === "join"){
            console.log(msg.name, "joined the room.")
            metadata = {name: msg.name, quest: msg.body, color: msg.color};
            socket.broadcast.emit(eventName, msg)
            messages.push(msg);
            messages.slice(-20).forEach(function(oldMsg){
                socket.emit(eventName, oldMsg);
            })
        }else if (msg.method === "post"){
            if (msg.body === "") return;
            console.log(msg.name + ":", msg.body)
            messages.push(msg);
            socket.broadcast.emit(eventName, msg)
        }
        // TODO: Handle client-sent leave messages?
    });
    socket.on('disconnect', function () {
        if (!metadata){
            console.log("    Client disconnected without logging in (how rude).");
        }else{
            msg = {method: "leave", name: metadata.name, body: "",
                   color: metadata.color, time: Date.now()};
            messages.push(msg);
            socket.broadcast.emit(eventName, msg);
            console.log(metadata.name, "left the room.");
        }
    });
});
