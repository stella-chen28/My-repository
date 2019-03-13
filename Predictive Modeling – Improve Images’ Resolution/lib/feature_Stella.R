#############################################################
### Construct features and responses for training images###
#############################################################

### Authors: Sizhu Chen
### Project 3

feature <- function(LR_dir, HR_dir, n_points=1000){

  library("EBImage")
  library(OpenImageR)
  ########################### functions ##########################
  feat_each_mat<-function(x,y){
    #featMat
    x1<-cbind(rep(0,nrow(x)),x,rep(0,nrow(x)))
    x1<-rbind(rep(0,ncol(x1)),x1,rep(0,ncol(x1)))# add 0
    samp<-diag(x[samp_ind[,1],samp_ind[,2]])
    ep<-t(apply(samp_ind+1,1,find_point,dt=x1))-samp #row = samp ; col=8
    #labMat
    fp<-t(apply(2*samp_ind-1,1,find_point2,dt=y))-samp #row = samp ; col=4
    return(list(ep,fp))
  }
  
  move_mat<-matrix(c(rep(-1,3),0,rep(1,3),0,-1,0,rep(1,3),0,-1,-1),ncol=8,byrow = T)
  move_mat2<-rbind(c(0,0,1,1),c(0,1,0,1))
  
  find_point<-function(v,dt){
    return(diag(dt[(move_mat+v)[1,],(move_mat+v)[2,]]))
  } 
  find_point2<-function(v,dt){
    return(diag(dt[(move_mat2+v)[1,],(move_mat2+v)[2,]]))
  } 
  
  ################################### start ##########################
  n_files <- length(list.files(LR_dir))
 
  featMat <- array(NA, c(n_files*n_points, 8, 3))
  labMat <- array(NA, c(n_files*n_points, 4, 3))
  
  for(i in 1:n_files){
    imgLR <- readImage(paste0(LR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    imgHR <- readImage(paste0(HR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    
    samp_p<-sample(imgLR[,,1],n_points,replace = F)
    samp_ind<-arrayInd(samp_p,dim(imgLR[,,1]))
    
    for(j in 1:3){
      lt<-feat_each_mat(imgLR[,,j],imgHR[,,j])
      featMat[(n_points*(i-1)+1):(n_points*i),,j]<-lt[[1]]
      labMat[(n_points*(i-1)+1):(n_points*i),,j]<-lt[[2]]
    }
    #print(i)
  }
  return(list(feature = featMat, label = labMat))
}


# LR_dir<-"./data/LR/"
# HR_dir<-"./data/HR/"
# 
# system.time(ft<-feature(LR_dir,HR_dir,1000))


