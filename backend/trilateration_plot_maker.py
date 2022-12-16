from bluetooth import *
import math
from scipy.optimize import minimize
import numpy as np
import matplotlib.pyplot as plt


def geographical_distance(latitude_a, longitude_a, latitude_b, longitude_b):
    # cartesian
    return math.sqrt(math.pow(math.fabs(latitude_a - latitude_b), 2) +
                     math.pow(math.fabs(longitude_a - longitude_b), 2))

    # geographical distance without assuming the curvature of the earth
    # delta_latitude = math.radians(latitude_b - latitude_a)
    # delta_longitude = math.radians(longitude_a - longitude_b)
    # mean_latitude = math.radians((latitude_a + latitude_b) / 2)
    #
    # r = 6371.009
    #
    # return r * math.sqrt((math.pow(delta_latitude, 2)) + math.pow(math.cos(mean_latitude) * delta_longitude, 2))


# finds the possible points of intercepts for a given circles
def circles_intercept(x_circle1, y_circle1, x_circle2, y_circle2, radius1, radius2):
    a = x_circle1
    b = y_circle1
    c = x_circle2
    d = y_circle2
    r1 = radius1
    r2 = radius2
    # try:
    z = pow(a, 2) + pow(b, 2) - (pow(c, 2) + pow(d, 2))
    if b == d:
        if a == c:
            # infinite solutions Or no solution
            return ['no-solution!']
        x = (z - pow(r1, 2) + pow(r2, 2)) / (2*(a - c))
        y1 = math.sqrt(pow(r1, 2) - pow((x - a), 2)) + b
        y2 = - math.sqrt(pow(r1, 2) - pow((x - a), 2)) + b
        return [(x, y1), (x, y2)]
    e = (z + pow(r2, 2) - pow(r1, 2)) / (2*(b - d))
    f = (a - c) / (b - d)
    g = e - b
    q = 1 + pow(f, 2)
    n = -2*(a + g*f)
    m = pow(g, 2) - pow(r1, 2) + pow(a, 2)
    delta = (pow(n, 2) - 4*m*q)
    # except:
    #     print('error')
    #     return (0, 0), (0, 0)
    if delta < 0:
        # no solution found
        return ['no-solution!']
    if delta >= 0:
        x1 = (-n + math.sqrt(delta)) / (2*q)
        y1 = e - f * x1
        x2 = (-n - math.sqrt(delta)) / (2*q)
        y2 = e - f * x2
        return [(x1, y1), (x2, y2)]


# mean square error
def mse(x, locations_arg, distances_arg):
    mean_square_error = 0.0
    for location, distance in zip(locations_arg, distances_arg):
        distance_calculated = geographical_distance(x[0], x[1], location[0], location[1])
        print('x[0],x[1]: ')
        print(x[0], x[1])
        print('location[0],location[1]')
        print(location[0], location[1])
        # print('distance_calculated')
        # print(distance_calculated)
        # print('locations')
        # print(locations_arg)
        print('delta distance')
        print(math.fabs(distance_calculated - distance))
        # mean_square_error += math.pow(math.fabs(distance_calculated - location), 2.0)
        mean_square_error += math.fabs(distance_calculated - distance)
    # print('error:')
    # print(mean_square_error / len(distances_arg))
    return mean_square_error / len(distances_arg)


def three_circle_intercept(locations, distances):
    points = [circles_intercept(locations[0][0], locations[0][1],
                                locations[1][0], locations[1][1],
                                distances[0], distances[1]),

              circles_intercept(locations[0][0], locations[0][1],
                                locations[2][0], locations[2][1],
                                distances[0], distances[2]),

              circles_intercept(locations[1][0], locations[1][1],
                                locations[2][0], locations[2][1],
                                distances[1], distances[2])]

    return points


def draw_map(points, locations, distances):
    circle1 = plt.Circle(locations[0], distances[0], fill=False)
    circle2 = plt.Circle(locations[1], distances[1], fill=False)
    circle3 = plt.Circle(locations[2], distances[2], fill=False)
    fig, ax = plt.subplots()
    ax.add_patch(circle1)
    ax.add_patch(circle2)
    ax.add_patch(circle3)
    new_points = []
    intercepted_x_sum = 0
    intercepted_y_sum = 0
    for i in points:
        if i != ['no-solution!']:
            new_points.append(i)
    intercepted_x = []
    intercepted_y = []
    for i in range(len(new_points)):
        for j in range(2):
            x = new_points[i][j][0]
            y = new_points[i][j][1]
            intercepted_x.append(x)
            intercepted_y.append(y)
            intercepted_x_sum += x
            intercepted_y_sum += y

    # run minimized algorithm
    centroid_x = intercepted_x_sum / len(new_points)
    centroid_y = intercepted_y_sum / len(new_points)
    minimized_result = get_minimize(centroid_x, centroid_y)

    print(intercepted_x)
    print('***')
    print(intercepted_y)
    plt.scatter(intercepted_x, intercepted_y, label="Intercepted")
    # beacons
    plt.scatter(locations[0][0], locations[0][1], marker='v', label="Beacons", color='green')
    plt.scatter(locations[1][0], locations[1][1], marker='v', color='green')
    plt.scatter(locations[2][0], locations[2][1], marker='v', color='green')
    # centroid point
    plt.scatter(centroid_x, centroid_y, label="Initial point", color='yellow')
    # minimized pointed
    plt.scatter(minimized_result[0], minimized_result[1], marker='*', s=200, label="You are here", color='red')
    # plt.rcParams.update({'figure.figsize': (10, 8), 'figure.dpi': 100})
    plt.title('Trilateration Positioning')
    plt.xlabel('X-axis')
    plt.ylabel('Y-axis')
    plt.legend()
    plt.show()
    print('points:')
    print(new_points)


def get_minimize(centroid_x, centroid_y):
    result = minimize(mse,
                      (centroid_x, centroid_y),  # initial solution
                      args=(beacon_locations, client_distances),
                      method='L-BFGS-B',
                      options={
                          'ftol': 1e-5,
                          'maxiter': 1e+7
                      })
    print('result')
    print(result)
    minimized = result.x
    return minimized


# beacon locations of building
beacon_locations = [(0, 0), (4, 0), (0, 4)]
# distances from client app
# client point is (2,2)
# client_distances = [2.828, 2.828, 2.828]
# client point is (1,2)
client_distances = [2.23606, 3.6, 2.23606]
# client point is (3,1)
# client_distances = [3.16, 1.41, 4.24]


# initializing server
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

print("Waiting for connection on RFCOMM channel[%d]..." % port)

# client_sock, client_info = server_sock.accept()

# print("Accepted connection from ", client_info)

# this part will try to get something form the client
# you are missing this part - please see it's an endlees loop!!
# while True:
#     data = client_sock.recv(1024)
#     if len(data) == 0:
#         break
#     # location = int.from_bytes(data, byteorder="big")
#     received = ''
#     for i in range(len(data)):
#         received += str(data[i])
#         print('[received] ', received)
#         # client_distances.append(data[i])
#         if len(client_distances) == 4:
#             break


# get all intercept points from three beacons that are closest to client
intercept_points = three_circle_intercept(beacon_locations, client_distances)
# draw_map also run minimized optimizer
draw_map(intercept_points, beacon_locations, client_distances)


# print("disconnected")
# print('')

# client_sock.close()
server_sock.close()





