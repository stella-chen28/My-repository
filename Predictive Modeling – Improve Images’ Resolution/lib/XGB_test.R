######################################################
### Fit the regression model with testing data ###
######################################################

### Author: Hengyang Lin
### Project 3

XGB_test <- function(modelList, dat_test){
  
  stopifnot(modelList[[1]]$fit$nfeatures == dim(dat_test)[2])

  library(xgboost)
  
  predArr <- array(NA, c(dim(dat_test)[1], 4, 3))
  
  for (i in 1:12){
    fit_train <- modelList[[i]]
    ### calculate column and channel
    c1 <- (i-1) %% 4 + 1
    c2 <- (i-c1) %/% 4 + 1
    featMat <- dat_test[, , c2]
    ### make predictions
    predArr[, c1, c2] <- predict(fit_train$fit, newdata=featMat)
  }
  return(predArr)
  #return(as.numeric(predArr))
}
