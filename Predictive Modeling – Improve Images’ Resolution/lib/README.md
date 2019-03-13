# Project: Can you unscramble a blurry image? 

### Code lib Folder

The lib directory contains various files with function definitions and code.

Files for feature extraction.
+ feature.R  : Starter Codes from TA
+ feature_Stella.R  :  Implemented by Sizhu(Stella) Chen.
  + input: LR_dir  : a string, which is the file route of LR images.
  + input: HR_dir  : a string, which is the file route of HR images.
  + input: n_points   : a number, which is the number of random selected points. Default is 1000.
  + ouput: a list, first element: array of feature data with dim = (n_files x n_points, 8, 3); second element: array of label data with dim = (n_files x n_points, 4, 3)
  
+ feature_.R  :  Implemented by Hengyang Lin.
  + input: LR_dir  : a string, which is the file route of LR images.
  + input: HR_dir  : a string, which is the file route of HR images.
  + input: n_points   : a number, which is the number of random selected points.Default is 1000.
  + input: gap  : a integer, which is the gap btw center points and grid points. n_features  = (2 x gap + 1)^2 - 1. Default is 1.
  + input: method  : a string, "Normal" for random selected points, "Laplacian" for key points. Default is "Normal".
  + input: ratio  : a number btw 0 & 1, which is the weight of key points sample. Default if 0.7
  + ouput: a list, first element: array of feature data with dim = (n_files x n_points, (2 x gap + 1)^2 - 1, 3); second element: array of label data with dim = (n_files x n_points, (2 x gap + 1)^2 - 1, 3)
  
Files for train.
* GBM model.
+ train.R  :Implemented by TA.
  + input: dat_train  : an array of feature data
  + input: label_train  : an array of label data
  + input: par:  a list, an element depth indicating the depth of GBM model. Default is NULL. (Under default, the depth in GBM model is 3)
  + output: modelList: a list with length 12. Each element is a fit object.
 
 * Parallized GBM model.
 + train_bz.R  :Implemented by Binglun Zhao.
  + input: dat_train  : an array of feature data
  + input: label_train  : an array of label data
  + input: par:  a list, an element depth indicating the depth of GBM model. Default is NULL. (Under default, the depth in GBM model is 3)
  + output: modelList: a list with length 12. Each element is a fit object.
  
  * XGB model.
  + train.R  :Implemented by TA.
  + input: dat_train  : an array of feature data
  + input: label_train  : an array of label data
  + input: par:  a list, an element depth indicating the depth of GBM model. Default is NULL. (Under default, the depth in GBM model is 3)
