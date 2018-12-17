#############################################################
### Construct features and responses for training images###
#############################################################

### Authors: Hengyang Lin
### Project 3

feature <- function(LR_dir, HR_dir, n_points = 1000, gap = 1, method = "Normal", ratio = 0){
  library("EBImage")
  library(OpenImageR)
  n_files <- length(list.files(LR_dir))
  
  featMat <- array(NA, c(n_files * n_points, (2*gap+1)^2 - 1, 3))
  labMat <- array(NA, c(n_files * n_points, 4, 3))
  getpix <- function(coord, layer, IMG){
    row = coord[1]
    col = coord[2]
    if(row >=1 && row <= dim(IMG)[1] && col >= 1 && col <= dim(IMG)[2]){
      return(as.numeric(IMG[row, col, layer]))
    }
    else
      return(0)
  }
  patch <- function(coord, layer, IMG, mode){ ##mode = for features, mode = 2 for lab
    row = coord[1]
    col = coord[2]
    if(mode == 1){
      mat <- matrix(NA, ncol = 2, nrow = (2*gap+1)^2 - 1)
      mat[,1] <- c(rep((row-gap):(row-1),rep(2*gap+1,gap)), rep(row,2*gap), rep((row+1):(row+gap), rep(2*gap+1,gap)))
      mat[,2] <- c(rep((col-gap):(col+gap),gap),(col-gap):(col-1),(col+1):(col+gap),rep((col-gap):(col+gap),gap))
    }
    if(mode == 2){
      mat <- matrix(c(rep((2*row-1):(2*row), c(2,2)),rep((2*col-1):(2*col),2)), ncol = 2)
    }
    center <- imgLR[row, col, layer]
    return(apply(mat, MARGIN = 1, FUN = getpix, layer = layer, IMG = IMG) - center)
  }
  
  for(i in 1:n_files){
    imgLR <- OpenImageR::readImage(paste0(LR_dir,  "img_", sprintf("%04d", i), ".jpg"))
    imgHR <- OpenImageR::readImage(paste0(HR_dir,  "img_", sprintf("%04d", i), ".jpg"))

    dim <- dim(imgLR)
    coord <- matrix(NA, nrow = n_points, ncol = 2)
    if(method == "Normal"){
      samp <- sample(1:(dim[1]*dim[2]), size = n_points, replace = FALSE)
      res <- samp %% dim[2]
      coord_row <- ifelse(res == 0, samp%/%dim[2], samp%/%dim[2]+1)
      coord_col <- ifelse(res == 0, dim[2], res)
      coord <- matrix(c(coord_row, coord_col), ncol = 2)
    }
    
    if(method == "Laplacian"){
      f_high <- matrix(1, nc=3, nr=3)
      f_high[2,2] <- -8
      img_highPass <- filter2(imgLR, f_high)
      img_highPass <- ifelse(img_highPass < 0, 0, img_highPass)
      
      img_sum <- img_highPass[,,1]+img_highPass[,,2]+img_highPass[,,3]
      n <- as.integer(ratio*n_points)
      ord <- order(t(img_sum), decreasing = TRUE)
      
      samp <- ord[1:n]
      last <- ord[min((n+1),length(ord)):length(ord)]
      last <- sample(last, size = n_points - n, replace = FALSE)
      
      samp <- c(samp, last)
      res <- samp %% dim[2]
      coord_row <- ifelse(res == 0, samp%/%dim[2], samp%/%dim[2]+1)
      coord_col <- ifelse(res == 0, dim[2], res)
      coord <- matrix(c(coord_row, coord_col), ncol = 2)
    }
    
    for(c in 1:3){
      featMat[(n_points*(i-1)+1):(n_points*i),,c] <- t(apply(coord, MARGIN = 1, FUN = patch, layer = c, IMG = imgLR, mode = 1))
      labMat[(n_points*(i-1)+1):(n_points*i),,c] <- t(apply(coord, MARGIN = 1, FUN = patch, layer = c, IMG = imgHR, mode = 2))
    }
    print(i)
  }
  return(list(feature = featMat, label = labMat))
}