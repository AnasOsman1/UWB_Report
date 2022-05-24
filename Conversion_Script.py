# Conversion Script by @ Anas Osman
# Performing Trilateration on a Give 3 Points
import math
import numpy

# Assuming elevation = 0
# Test values recievedƒ
# Lat and Lon and given values
# While the Dist was computed using haversine method

Lat1 = 46.0674749798995
Lon1 = 11.15111384638543
DistA = 0.02111524  # in Km
Lat2 = 46.06746707029327
Lon2 = 11.15162413599556
DistB = 0.02864995  # in Km
Lat3 = 46.06820775846681
Lon3 = 11.151114348093234
DistC = 0.06833968  # in Km

# Haversine Formula Function defined here for future use
# as values were extacted from R script


def dis_calc_herv(Lat1, Lon1, Lat2, Lon2):
    R = 6356.137  # in Km

    latA = math.radians(Lat1)
    lonA = math.radians(Lon1)
    latB = math.radians(Lat2)
    lonB = math.radians(Lon2)

    dlon = lonB - lonA
    dlat = latB - latA

    a = pow(math.sin(dlat / 2), 2)+ math.cos(latA) * \
        math.cos(latB) * pow(math.sin(dlon / 2), 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    distance = R * c

    print(distance)


# Trilateration function

def conv_latlon(Lat1, Lat2, Lat3, Lon1, Lon2, Lon3, DistA, DistB, DistC):
    earthR = 6356.137  # in Km ; could be changed to other  such as 6371
    # Using authalic sphere
    # Convert Geodetic Lat/Long to ECEF xyz
    # ECEF is a cartesian spatial reference system
    # that represents locations in the vicinity of the Earth as X, Y, and Z
    #   1. Convert Lat/Long to radians
    #   2. Convert Lat/Long(radians) to ECEF
    xA = earthR * (math.cos(math.radians(Lat1)) * math.cos(math.radians(Lon1)))
    yA = earthR * (math.cos(math.radians(Lat1)) * math.sin(math.radians(Lon1)))
    zA = earthR * (math.sin(math.radians(Lat1)))

    xB = earthR * (math.cos(math.radians(Lat2)) * math.cos(math.radians(Lon2)))
    yB = earthR * (math.cos(math.radians(Lat2)) * math.sin(math.radians(Lon2)))
    zB = earthR * (math.sin(math.radians(Lat2)))

    xC = earthR * (math.cos(math.radians(Lat3)) * math.cos(math.radians(Lon3)))
    yC = earthR * (math.cos(math.radians(Lat3)) * math.sin(math.radians(Lon3)))
    zC = earthR * (math.sin(math.radians(Lat3)))

    P1 = numpy.array([xA, yA, zA])
    P2 = numpy.array([xB, yB, zB])
    P3 = numpy.array([xC, yC, zC])

# Transform to get circle 1 at origin
# Transform to get circle 2 on x axis
    ex = (P2 - P1)/(numpy.linalg.norm(P2 - P1))
    i = numpy.dot(ex, P3 - P1)
    ey = (P3 - P1 - i*ex)/(numpy.linalg.norm(P3 - P1 - i*ex))
    ez = numpy.cross(ex, ey)
    d = numpy.linalg.norm(P2 - P1)
    j = numpy.dot(ey, P3 - P1)

# Plug and Chug those valuse
    x = (pow(DistA, 2) - pow(DistB, 2) + pow(d, 2))/(2*d)
    y = ((pow(DistA, 2) - pow(DistC, 2) + pow(i, 2) + pow(j, 2))/(2*j)) - ((i/j)*x)

# conv_back is an array with ECEF x,y,z of trilateration point
    conv_back = P1 + x*ex + y*ey

# Convert back to lat/long from ECEF <-- is a cartesian spatial reference
# system that represents locations in the vicinity of the Earth as X, Y, and Z
# convert to degrees
    lat = math.degrees(math.asin(conv_back[2] / earthR))
    lon = math.degrees(math.atan2(conv_back[1], conv_back[0]))

    print(x, y, lat, lon)


# Function Call
conv_latlon(Lat1, Lat2, Lat3, Lon1, Lon2, Lon3, DistA, DistB, DistC)
# Printed output x = 0.014870677049348975 ~ 15m, y = 0.014990701045554574 ~ 15m
# lat = 46.06760708133096, lon = 11.151311353476835
# Which does match the point provided as shown by the lat/lon output and the conversion
