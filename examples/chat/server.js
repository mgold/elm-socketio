var io = require('socket.io')(8001);

var eventName = "chat";
io.on('connection', function (socket) {
    console.log("Client connected.")
    var data;
    socket.on(eventName, function (data) {
        msg = JSON.parse(data);
        if (msg.name === "") return;
        if (!msg.time) msg.time = Date.now();
        if (msg.method === "join"){
            console.log(msg.name, "joined")
            data = {name: msg.name, quest: msg.body, color: msg.color};
            socket.broadcast.emit(eventName, msg)
        }else if (msg.method === "post"){
            if (msg.body === "") return;
            //TODO: persist?
            console.log(msg.name, "posted", msg.body)
            socket.broadcast.emit(eventName, msg)
        }
        // TODO: Handle client-sent leave messages?
    });
    socket.on('disconnect', function () {
        if (!socket.chat){
            console.log("Client disconnected without logging in.");
        }else{
            msg = {method: "leave", name: data.name, body: "",
                   color: data.color, time: Date.now()};
            socket.broadcast.emit(eventName, msg);
        }
    });
});
