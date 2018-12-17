################################
### XGBoost Super-resolution ###
################################

### Author: Hengyang Lin
### Project 3

XGB_superResolution <- function(LR_dir, HR_dir, modelList){
  
  ### Construct high-resolution images from low-resolution images with trained predictor
  
  ### Input: a path for low-resolution images + a path for high-resolution images 
  ###        + a list for predictors
  
  ### load libraries
  library("EBImage")
  library(OpenImageR)
  n_files <- length(list.files(LR_dir))
  
  ### read LR/HR image pairs
  for(i in 1:n_files){
    imgLR <- OpenImageR::readImage(paste0(LR_dir,  "img", "_", sprintf("%04d", i), ".jpg"))
    pathHR <- paste0(HR_dir,  "img", "_", sprintf("%04d", i), ".jpg")
    
    n_features <- modelList[[1]]$fit$nfeatures
    gap <- as.integer((sqrt(n_features + 1) - 1)/2)
    featMat <- array(NA, c(dim(imgLR)[1] * dim(imgLR)[2], n_features, 3))

    getpix <- function(coord, layer, IMG){
      row = coord[1]
      col = coord[2]
      if(row >=1 && row <= dim(IMG)[1] && col >= 1 && col <= dim(IMG)[2]){
        return(as.numeric(IMG[row, col, layer]))
      }
      else
        return(0)
    }
    patch <- function(coord, layer, IMG){
      row = coord[1]
      col = coord[2]
      mat <- matrix(NA, ncol = 2, nrow = (2*gap+1)^2 - 1)
      mat[,1] <- c(rep((row-gap):(row-1),rep(2*gap+1,gap)), rep(row,2*gap), rep((row+1):(row+gap), rep(2*gap+1,gap)))
      mat[,2] <- c(rep((col-gap):(col+gap),gap),(col-gap):(col-1),(col+1):(col+gap),rep((col-gap):(col+gap),gap))
      center <- imgLR[row, col, layer]
      return(apply(mat, MARGIN = 1, FUN = getpix, layer = layer, IMG = IMG) - center)
    }
    
    dup<-function(mat){
      y1<-apply(mat,2,rep,each=2)
      y2<-apply(y1,1,rep,each=2)
      return(t(y2))
    }
    
    n_row <- dim(imgLR)[1]
    n_col <- dim(imgLR)[2]
    coord <- matrix(c(rep(1:n_row, rep(n_col, n_row)), rep(1:n_col, n_row)), ncol = 2)
    for(c in 1:3){
      featMat[,,c] <- t(apply(coord, MARGIN = 1, FUN = patch, layer = c, IMG = imgLR))
    }
    ### step 2. apply the modelList over featMat
    predArr <- XGB_test(modelList, featMat)
    
    
    #########begin change####################################################
    origin <- array(NA, dim = dim(predArr))
    for(c in 1:3){
      vec <- apply(coord, MARGIN = 1, FUN = getpix, layer = c, IMG = imgLR)
      origin[,,c] <- matrix(rep(vec,4), ncol = 4)
    }
    predArr <- predArr + origin
    #origin <- array(apply(imgLR,3,dup),dim= c(nrow(imgLR)*2,ncol(imgLR)*2,3))
    
    
    #########begin change####################################################
    #### step 3. recover high-resolution from predMat and save in HR_dir
    
    newimg <- array(NA, dim = c(2*n_row, 2*n_col, 3))
    for(c in 1:3){
      for(p in 1:n_row){
        for(q in 1:n_col){
          pos <- (p-1)*n_col+q
          newimg[c(2*p-1,2*p),c(2*q-1,2*q),c] <- matrix(predArr[pos,,c], ncol = 2)
        }
      }
    }
    
    #pred <- array(predArr,dim = c(n_row*2,n_col*2,3))
    
    #########begin change####################################################
    writeImage(newimg, file_name = pathHR)
    #writeImage(pred + origin, file_name = pathHR)
  }
}