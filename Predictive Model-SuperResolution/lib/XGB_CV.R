########################
### Cross Validation For XGBOOST ###
########################

### Author: Hengyang Lin
### Project 3

XGB_crossvalidation <- function(feat_dat, label_dat){
  library(xgboost)
  v.eta <- c(0.15, 0.3, 0.9)
  v.depth <- c(6,10)
  v.colsample_bytree = c(0.8, 1)
  
  compare <- matrix(c(eta = 0, depth = 0, colsample_tree = 0, best_iter = 0, best_rmse = 0),ncol = 5)
  
  for(b in 1:3){
    for(c in 1:2){
        for(e in 1:2){
          max <- 200
          eva <- rep(0, max)
          params <- list(eta = v.eta[b], max_depth = v.depth[c], colsample_bytree = v.colsample_bytree[e])
          for (i in 1:12){
            c1 <- (i-1) %% 4 + 1
            c2 <- (i-c1) %/% 4 + 1
            
            featMat <- feat_dat[, , c2]
            labMat <- label_dat[, c1, c2]
              
            xg_mat <- xgb.DMatrix(data = featMat, label = labMat)
            fit <- xgb.cv(params = params, data = xg_mat, objective = "reg:linear", nrounds = max, verbose = 1, nfold = 5)
            eva <- eva + fit$evaluation_log[,4]
          }
          
          best.iter <- which.min(as.matrix(eva))
          best.test_rmse <- min(as.matrix(eva))/12
          newrow <- c(v.eta[b], v.depth[c], v.colsample_bytree[e], best.iter, best.test_rmse)
          compare <- rbind(compare, newrow)
        }
        
    }
      
  }
    
  compare <- compare[-1,]
  colnames(compare) <- c("eta", "depth", "colsample_bytree", "best_iter", "best_rmse")
  return(compare)
}
