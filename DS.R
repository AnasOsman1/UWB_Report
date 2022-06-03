fruits <- list('/Users/anasosman/Downloads/Car_Experiment_Data/RoundTrip/01.csv', '/Users/anasosman/Downloads/Car_Experiment_Data/RoundTrip/02.csv', '/Users/anasosman/Downloads/Car_Experiment_Data/RoundTrip/03.csv')
ff <- list('11.csv','22.csv','33.csv')

clean <- function(data) {
  new <- data %>%
    select(rosbagTimestamp, secs, nsecs, x, y)
  
  return(new)
}
s <- 0
while(s < 1){
  for (x in fruits) {
    for (i in ff) {
      n <- clean(read.csv(x))
      m <- write_csv(n, i)
      print(m)
      s <- s+1
    }
  }
}

