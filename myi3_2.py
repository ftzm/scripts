#!/usr/bin/env python

#potentially handle timeout exceptions differently
#only listen to messages of right type
#differentiate between event messages and not.
#the above fix problems otherwise avoided by having separate sockets, but
#robustness is nice

import socket
import subprocess
import struct
import json

#maybe delete
import pprint

socket_path_raw = subprocess.check_output(['i3', '--get-socketpath'])
socket_path = socket_path_raw.decode('utf-8').rstrip()

#header infos
magic_string = 'i3-ipc'

#< is byte order, little-endian which is standard for x86 and x86-64
#s represents a string (magic string), and the preceding integer its length.
#not strictly necessary to use struct to unpack it but saves doing
#it in a separate step to find start point for unpacking the two Is
#(Unsigned ints, message length and type)
struct_header = '<%dsII' % len(magic_string.encode('utf-8'))
struct_header_size = struct.calcsize(struct_header)


class Socket():

    def __init__(self):
        #must define AF_UNIX or unsupported, SOCK_STREAM is socket type
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.settimeout(2)
        self.sock.connect(socket_path)


    def format_msg(self, msg_type, payload):
        # msg_type = 1 #code for GET_WORKSPACES
        #get length of message as byte count, not char count
        #(payloud is converted to byte string)
        msg_length = len(payload.encode('utf-8'))

        # convert to unsigned integers in byte string format,
        # these are then converted to utf-8 for purposes of concatenation
        msg_length = struct.pack('I', msg_length).decode('utf-8')
        msg_type = struct.pack('I', msg_type).decode('utf-8')

        msg = '%s%s%s%s' % (magic_string, msg_length, msg_type, payload)
        msg = msg.encode('utf-8')
        return msg

    def deformat_msg(self, data):
        payload = data.decode('utf-8')
        payload = json.loads(payload)
        return (payload)

    def process_header(self, data):
        header = struct.unpack(struct_header, data[:struct_header_size])
        return header

    def listen(self, callback):
        #add only listen to messages with right code
        subscribed = 1
        while subscribed == 1:
            try:
                event = self.receive()
                if callback:
                    callback(event)
                else:
                    print(event)
            except socket.timeout:
                    continue

    def send(self, msg_type, payload):
        msg = self.format_msg(msg_type, payload)
        self.sock.sendall(msg)

    def receive(self):
        # we know the header size, so only get that much from socket and process
        header = self.sock.recv(struct_header_size)
        magic_string, msg_length, msg_type = self.process_header(header)
        # first bit of event unsigned int is set to 1 if event,
        # makes the int super high, so if above range of non-event reply ints,
        # set event to true and shave off first bit (plus bin encoding '0b' prefix)
        # to get actual event int
        if msg_type > 7:
            event = True
            msg_type = int(bin(msg_type)[3:], 2)
        # msg_length tells us exactly how much more we need from socket
        remaining = msg_length
        # attempt to get it in one go
        data = self.sock.recv(remaining)
        # if the above didn't work, keep receiving from socket until we get all
        while len(data) < msg_length:
            # we use remaining instead of msg_length so that we only request what
            # we need, avoid stealing part of next message
            data += self.sock.recv(remaining)
            # adjust remaining size each iteration
            remaining -= len(data)
        data = self.deformat_msg(data)
        return msg_type, data

    def get(self, msg_type, payload):
        self.send(msg_type, payload)
        data = self.receive()
        return data

class Subscription():

    def subscribe(self, event, callback=None):
        #this is message type for subscription
        sub_sock = Socket()
        msg_type = 2
        #this must become variable
        payload = json.dumps([event])
        request = sub_sock.get(msg_type, payload)
        sub_sock.listen(callback)

class Interface():
    def __init__(self):
        main_sock = Socket()

    def get(self):
        return self.main_sock.get(msg_type, payload='')

    def subscribe(self):
        pass


### MODULE END ###


### EXAMPLE CALLBACKS ###

def track_workspace_change(event):
    event = event[1]
    change = event['change']
    if change != 'focus':
        return
    output = event
    pprint.pprint(output)

def print_current_workspace(event):
    event = event[1]
    output = event['current']['name']
    print(output)


# example to send command to move to workspace one
#i3_sock = Socket()
#i3_sock.send(0, 'workspace 1')

### EXAMPLE CALLBACKS END ###

### SCRIPT ###

sub_sock = Socket()
data_sock = Socket()

def print_workspaces(event):
    data = data_sock.get(1, '')[1]
    if event[1]['change'] != 'focus':
        return
    output = "3"
    for workspace in data:
        if workspace["focused"]:
            w = "foc"
        elif workspace["urgent"]:
            w = 'urg'
        else:
            w = 'unf'
        w += workspace['name']
        output += ' %s' % w
    print(output)

sub_sock.subscribe('workspace', print_workspaces)
