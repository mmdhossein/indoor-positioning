from bluetooth import *

server_sock = BluetoothSocket(RFCOMM)
server_sock.bind(("", PORT_ANY))
server_sock.listen(1)
print('server is ready!')
print('server Host: {} \nPort: {}'.format(server_sock.getsockname()[0], server_sock.getsockname()[1]))

port = server_sock.getsockname()[1]

uuid = "94f39d29-7d6d-437d-973b-fba39e49d4ee"

advertise_service(server_sock, "SampleServer",
                               service_id=uuid,
                               service_classes=[uuid, SERIAL_PORT_CLASS],
                               profiles=[SERIAL_PORT_PROFILE],
                               description='this is my server')

print("Waiting for connection on RFCOMM channel %d..." % port)

client_sock, client_info = server_sock.accept()

print("Accepted connection from ", client_info)

#this part will try to get something form the client
# you are missing this part - please see it's an endlees loop!!
try:
    while True:
        data = client_sock.recv(1024)
        if len(data) == 0:
            break
        location = int.from_bytes(data, byteorder="big")
        print(location)

# raise an exception if there was any error
except IOError:
    pass

print("disconnected")

client_sock.close()
server_sock.close()