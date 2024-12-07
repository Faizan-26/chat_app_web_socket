
from flask import Flask, request
from flask_socketio import SocketIO, join_room, leave_room, send

app = Flask(__name__)
socketio = SocketIO(app)

@app.route('/')
def index():
    return "WebSocket Server"

@socketio.on('join_room')
def handle_join_room(data):
    join_room(data['room_name'])
    send(f"{data['username']} has joined the room.", room=data['room_name'])

@socketio.on('leave_room')
def handle_leave_room(data):
    leave_room(data['room_name'])
    send(f"{data['username']} has left the room.", room=data['room_name'])

@socketio.on('send_message')
def handle_send_message(data):
    send(data, room=data['room_name'])

@socketio.on('send_file')
def handle_send_file(data):
    # Handle file sending logic here
    send(data, room=data['room_name'])

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)