#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
if (length(args)<2) {
    stop ("must provide input and output filenames")
}

inFile = args[1]
outFile = args[2]

options(error = quote({dump.frames(to.file=TRUE); q()}))
        
print("Given a measured offset of one antenna vs another, and set of X,Y (UWB), calculate new X2,Y2 that are offset by the measured amount", quote=FALSE)

debugPLOTSUBSET = 0
debugPLOTALL = 1
debugPLOTALLON = 0
debugPLOTALLOFF = 1
debugASP = 1


#INPUT: how big of a window to use for the model
halfWindowSize = 5

#INPUT offset: measured distance between the antennas.
# Use a positive value if reference antenna (UWB) is closer to the nose of the car than the other antenna (COHDA or GPS)
offsetInput = -0.04


#INPUT dataset of UWB points
#df = read.csv("walkingUWB.csv")
df = read.csv(file=inFile, header=TRUE)
#print(df)

# this output uses halfWindowSize*2 points to create a model. Then, for each point, it identifies the point on
#the model closest to the original point, then generates the point ON the model offset away from that closest point
#outputOnModel <- matrix(c("time","x","y","z"),nrow=1)

# this output uses halfWindowSize*2 points to create a model. Then, for each point,
                                        #it generates the point OFFSET away that point along the line parallel to the model.
outputOffModel <- data.frame (matrix(ncol=6, nrow=0))
colnames(outputOffModel) <- c('time_Uwb','secs','nsecs','x','y','z')

#create scatterplot of raw data
if (debugPLOTALL) {plot(df$x, df$y, col='red',main='Movement Trace (with antenna offset)', xlab='x', ylab='y',asp=debugASP)}

getOffset<- function(index,halfWindowSize)
{

    # create a matrix with only the subset of data to be used - the points that before and after the index
    dataSubset<- df[(index-halfWindowSize):(index+halfWindowSize),c('x','y')]

    model <- lm(y ~ x, data=dataSubset)
    
    cf <- coef(model)
    interceptModel = cf[1]
    slopeModel = cf[2]



    #input reference point, slope and intercept
    xInput = df[index,'x']
    yInput = df[index,'y']
    slopeInput = -1/slopeModel
    interceptInput = yInput - (slopeInput * xInput)

    #plot the perpendicular to the model
    #abline(a=interceptInput, b=slopeInput, col='green')

    #calculate the X,Y on the model and on the input's perpendicular
    xOnLine = (interceptInput-interceptModel)/(slopeModel-slopeInput)
    yOnLine = (interceptInput*slopeModel-slopeInput*interceptModel) / (slopeModel-slopeInput)



    #calculate two points on the model's line, each "offest" from the intersection of model and input's perpendicular
    tmpB = sqrt (offsetInput^2 / (slopeModel^2  +1))
    tmpA = slopeModel*tmpB
    xOffset1 = xOnLine-tmpB
    yOffset1 = yOnLine-tmpA
    xOffset2 = xOnLine+tmpB
    yOffset2 = yOnLine+tmpA

    #take the "oldest" point used when generating the model
    xold = df[index-halfWindowSize,'x'] 
    yold = df[index-halfWindowSize,'y']
    #Calculate the distance from the two possible offset points to the oldest point                                    
    dist1 = sqrt((xold-xOffset1)^2+(yold-yOffset1)^2) 
    dist2 = sqrt((xold-xOffset2)^2+(yold-yOffset2)^2)

    # choose the point that it closest to the oldest point
    xOuputOffModel = 0
    yOutputOffModel =0
    if ( (offsetInput>0 && dist1<dist2) || (offsetInput<0 && dist2<dist1) ) {
        xOutput = xOffset1
        yOutput = yOffset1
        xOutputOffModel = xInput-tmpB
        yOutputOffModel = yInput-tmpA
    } else {
        xOutput = xOffset2
        yOutput = yOffset2
        xOutputOffModel = xInput+tmpB
        yOutputOffModel = yInput+tmpA
    }

#this is the old format. If we want to go back to "onModel", we need to update this    
                                        #    outputOnModel <<- rbind(outputOnModel, c(df[index,"time"],xOutput,yOutput,df[index,"z"]))
    


    outputOffModel[nrow(outputOffModel) +1,] <<-  c(df[index,1], #TODO - why can I not index properly time_Uwb???
                                                    df[index,'secs'],
                                                    df[index,'nsecs'],
                                                    xOutputOffModel,
                                                    yOutputOffModel,
                                                    df[index,'z'])



    if (debugPLOTALL && debugPLOTALLON) points(x=xOnLine, y=yOnLine, col='blue')
    if (debugPLOTALL && debugPLOTALLOFF) points(xOutputOffModel,yOutputOffModel)



    # debugging to visualize a subset of the data
    if (index==105 && debugPLOTSUBSET) {
        plot(dataSubset, col='red', main='subset of Walking Data', xlab='x',ylab='y',asp=debugASP) # plot the subset of data used for the model
        abline(model) #plot the model
        points(xOutputOffModel,yOutputOffModel)
        points(xOutput,yOutput,col='blue') # plot the output, offest XY - blue dot on the model line
        points(xOnLine,yOnLine,col='blue',pch=20) #plot the point where the perpendicular crosses the model
        points(xold,yold,pch=19, col='red') # make the oldest point red
        points( df[index+halfWindowSize,'x'], df[index+halfWindowSize,'y'], col='black',pch=19) #make the newest point green
        points(xInput,yInput,col='blue',pch=19) #make the reference XY a solid blue dot
    }


}

rows = nrow(df)
print (rows)

#cycle through all data points a window at a time
for (i in 1:(rows-2*halfWindowSize)) {
    getOffset (i+halfWindowSize, halfWindowSize)
}

#write.table (outputOnModel, "outputOnModel.csv", row.names = FALSE, col.names=FALSE,quote=FALSE)
write.csv (outputOffModel, file=outFile, row.names = FALSE, quote=FALSE)

