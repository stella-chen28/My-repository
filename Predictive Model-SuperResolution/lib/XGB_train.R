#########################################################
### Train a XGboost model with training features ###
#########################################################

### Author: Hengyang Lin
### Project 3

XGB_train <- function(dat_train, label_train, par = NULL){ #par = list(eta, max_depth, colsample_bytree, nrounds)
  library(xgboost)
  modelList <- list()
  
  if(is.null(par)){
    params <- list(eta = 0.3, max_depth = 6, colsample_bytree = .9, nrounds = 100)
  } else {
    params <- par
  }
  for (i in 1:12){
    c1 <- (i-1) %% 4 + 1
    c2 <- (i-c1) %/% 4 + 1
    
    featMat <- dat_train[, , c2]
    labMat <- label_train[, c1, c2]
    
    xg_mat <- xgb.DMatrix(data = featMat, label = labMat)
    
    fit <- xgboost(params = params[1:3], data = xg_mat, objective = "reg:linear", nrounds = params$nrounds, verbose = 1)
    
    best_iter <- fit$best_iteration
    modelList[[i]] <- list(fit = fit, iter = best_iter)
  }
  #modelList$gap <- as.integer((sqrt(dim(dat_train)[2]+1)-1)/2)
  return(modelList)
}
