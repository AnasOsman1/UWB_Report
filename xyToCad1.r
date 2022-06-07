#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
if (length(args)<2) {
    stop ("must provide input and output filenames")
}

inFile = args[1]
outFile = args[2]

debugPLOT = 1

#INPUT dataset of UWB points
df = read.csv(file=inFile)

convertedPoints <- data.frame (matrix(ncol = 6, nrow = 0))
colnames(convertedPoints) <- c('time_Uwb','secs','nsecs','x','y','z')
        
print("Given 2 points in both UWB and CAD coordinate systems, 
      convert points from UWB to CAD", quote=FALSE)


#### constants

#Palo 1
x1UWB = 0
y1UWB = 0
x1CAD = 118.05
y1CAD = 50.6

#Palo 4
x2UWB = -15.15
y2UWB = 65.709
x2CAD = 52.49 
y2CAD = 35.6

u = matrix ( c(x1CAD,y1CAD,x2CAD,y2CAD), nrow = 4, ncol = 1)

M = matrix ( c(x1UWB,-y1UWB,x2UWB,-y2UWB,y1UWB,
               x1UWB,y2UWB,x2UWB,1,0,1,0,0,1,0,1), nrow = 4, ncol = 4)

abcd <- solve(M)  %*% u

a <- abcd[1,1]
b <- abcd[2,1]
c <- abcd[3,1]
d <- abcd[4,1]



getX<-function(xUWB,yUWB)
{
    a*xUWB + b*yUWB + c
}

getY<-function(xUWB,yUWB)
{
    b*xUWB - a*yUWB + d
}





rows = nrow(df)
print (rows)

#cycle through all data points a window at a time
for (i in 1:rows) {
    convertedPoints[nrow(convertedPoints)+1,] <-c(df[i,'time_Uwb'],
                                                df[i,'secs'],
                                                df[i,'nsecs'],
                                                getX(df[i,'x'], df[i,'y']),
                                                getY(df[i,'x'], df[i,'y']),
                                                df[i,'z'])

}
write.csv (convertedPoints, file=outFile, row.names = FALSE, quote=FALSE)

if (debugPLOT) {
    #create scatterplot of raw data
    plot(df$x, df$y, col='red',main='Original Points (green), CAD points (black_', xlab='x', ylab='y', xlim=c(-20,120),ylim=c(-20,120) )
    points(convertedPoints$x, convertedPoints$y, pch=19)
    plot(convertedPoints$x, convertedPoints$y, main="Points In CAD", asp=1)
#    plot(df, col='green', main="Points In CAD", xlab='x', ylab='y', asp=debugASP)
}

