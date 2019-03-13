########################
### Super-resolution ###
########################

### Author: Sizhu Chen
### Project 3

superResolution <- function(LR_dir, HR_dir, modelList){
  
  ### Construct high-resolution images from low-resolution images with trained predictor
  
  ### Input: a path for low-resolution images + a path for high-resolution images 
  ###        + a list for predictors
  
  ### load libraries
  library("EBImage")
  library(OpenImageR)
  ########################### functions #######################################
  # x is a matrix (a layer of pic)
  feat<-function(x){
    ind<-cbind(rep(1:nrow(x),ncol(x)),rep(1:ncol(x),each=nrow(x)))
    x1<-cbind(rep(0,nrow(x)),x,rep(0,nrow(x)))
    x1<-rbind(rep(0,ncol(x1)),x1,rep(0,ncol(x1)))# add 0
    samp<-as.vector(x)
    ep<-t(apply(ind+1,1,find_point,dt=x1))-samp #row = nrow(x)*ncol(x) ; col=8
    return(ep)
  }
  move_mat<-matrix(c(rep(-1,3),0,rep(1,3),0,-1,0,rep(1,3),0,-1,-1),ncol=8,byrow = T)
  find_point<-function(v,dt){
    return(diag(dt[(move_mat+v)[1,],(move_mat+v)[2,]]))
  } 
  dup<-function(mat){
    y1<-apply(mat,2,rep,each=2)
    y2<-apply(y1,1,rep,each=2)
    return(t(y2))
  }
  
  ##############################################################################
  ### read LR/HR image pairs
  n_files <- length(list.files(LR_dir))
  for(i in 1:n_files){
    imgLR <- readImage(paste0(LR_dir,  "img", "_", sprintf("%04d", i), ".jpg"))
    pathHR <- paste0(HR_dir,  "img", "_", sprintf("%04d", i), ".jpg")
    
    featMat<-array(apply(imgLR,3,feat),dim = c(dim(imgLR)[1] * dim(imgLR)[2], 8, 3))
    ### step 2. apply the modelList over featMat
    predMat <- test(modelList, featMat)
    pred<-array(predMat,dim = c(nrow(imgLR)*2,ncol(imgLR)*2,3))
    ### step 3. recover high-resolution from predMat and save in HR_dir
    
    img_origin<-array(apply(imgLR,3,dup),dim= c(nrow(imgLR)*2,ncol(imgLR)*2,3))
    writeImage(pred+img_origin,file_name = pathHR)
    
  }
}


# LR_d<-"./data/try_file/LR/"
# HR_d<-"./data/try_file/HR/"
#superResolution(LR_d,HR_d,ml)
#system.time(superResolution(LR_d,HR_d,ml))
