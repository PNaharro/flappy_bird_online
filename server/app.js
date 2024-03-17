const express = require('express')
const gameLoop = require('./utilsGameLoop.js')
const webSockets = require('./utilsWebSockets.js')
const debug = true

// Creamos un objeto para almacenar los clientes conectados
let connectedClients = {};
let readys = 0;
/*
    WebSockets server, example of messages:

    From client to server:
        - Client init           { "type": "init", "name": "name", "color": "0x000000" }
        - Player movement       { "type": "move", "x": 0, "y": 0 }

    From server to client:
        - Welcome message       { "type": "welcome", "value": "Welcome to the server", "id", "clientId" }
        
    From server to everybody (broadcast):
        - All clients data      { "type": "data", "data": "clientsData" }
*/

var ws = new webSockets()
var gLoop = new gameLoop()

// Start HTTP server
const app = express()
const port = process.env.PORT || 8888

// Publish static files from 'public' folder
app.use(express.static('public'))

// Activate HTTP server
const httpServer = app.listen(port, appListen)
async function appListen() {
  console.log(`Listening for HTTP queries on: http://localhost:${port}`)
}

// Close connections when process is killed
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
  console.log('Received kill signal, shutting down gracefully');
  httpServer.close()
  ws.end()
  gLoop.stop()
  process.exit(0);
}

// WebSockets
ws.init(httpServer, port)

// Mantén un registro de los movimientos de los jugadores
// Quitamos la variable connectedClients

ws.onConnection = (socket, id) => {
  if (debug) console.log("WebSocket client connected: " + id);


  // Agregamos el nuevo cliente a la lista de clientes conectados y creamos una lista vacía de movimientos para él
  connectedClients[id] = [];

  // Enviamos la lista actualizada de clientes conectados y sus movimientos a todos los clientes
  sendConnectedClientsAndMovements();
  let connectedUsersList = Object.keys(connectedClients);

  // Enviamos al cliente su propio ID
  socket.send(JSON.stringify({
    type: "id",
    id: id
  }));

  // Saludamos personalmente al nuevo cliente
  socket.send(JSON.stringify({
    type: "welcome",
    value: "Welcome to the server",
    ids: connectedUsersList
  }));

  // Enviamos el nuevo cliente a todos los clientes
  ws.broadcast(JSON.stringify({
    type: "newClient",
    id: id,
    ids: connectedClients,
    total: connectedClients.length
  }));
};


ws.onMessage = (socket, id, msg) => {
  if (debug) console.log(`New message from ${id}:  ${msg.substring(0, 32)}...`);

  let clientData = ws.getClientData(id);
  if (clientData == null) return;

  let obj = JSON.parse(msg);
  console.log(obj)
  switch (obj.type) {
    case "init":
      clientData.name = obj.name;
      clientData.color = obj.color;
      break;
    case "move":
      clientData.x = obj.x;
      clientData.y = obj.y;
      break;
    case "player_position":
      clientData.player_position = { x: obj.x, y: obj.y };
      break;
    case "player_colision":
      console.log(clientData);
      // Actualiza los datos del cliente
      clientData.player_colision = { x: obj.x, y: obj.y };
      // Envia un mensaje a todos los clientes
      ws.broadcast(JSON.stringify({ type: 'player_colision', id: obj.id }));
      readys--;

      break;
    case "player_tap":
      // Actualiza los datos del cliente
      clientData.player_tap = { x: obj.x, y: obj.y };
      // Envia un mensaje a todos los clientes
      ws.broadcast(JSON.stringify({ type: 'player_tap', id: obj.id }));
      break;
    case "ready":
      let connectedUsersList = Object.keys(connectedClients);
      readys++;
      console.log(readys);
      console.log(readys == connectedUsersList.length);
      if (readys == connectedUsersList.length) {
        console.log("arftghuj");
        ws.broadcast(JSON.stringify({
          type: "startGame"
        }));
      }
      break;
  }
  sendConnectedClientsAndMovements();
};


ws.onClose = (socket, id) => {
  if (debug) console.log("WebSocket client disconnected: " + id);
  let clientData = ws.getClientData(id);
  if (debug) console.log(readys);

  // Eliminamos al cliente desconectado de la lista de clientes conectados y sus movimientos
  delete connectedClients[id];

  // Enviamos la lista actualizada de clientes conectados y sus movimientos a todos los clientes
  sendConnectedClientsAndMovements();

  // Informamos a todos los clientes de la desconexión del cliente
  ws.broadcast(JSON.stringify({
    type: "disconnected",
    from: "server",
    id: id
  }));
};

function sendConnectedClientsAndMovements() {
  // Enviamos la lista de clientes conectados y sus movimientos a todos los clientes
  ws.broadcast(JSON.stringify({
    type: "connected_clients_and_movements",
    clients: connectedClients
  }));
}
function broadcast(message) {
  Object.values(connectedClients).forEach(function each(client) {
    // Check if the client is valid
    if (client && client.send) {
      // Send the message to the client
      client.send(message);
    }
  });
}

