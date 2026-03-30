#------------------------------------------------------------------------
#Backup model results to data bucket


#------------------------------------------------------------------------
#Mount bucket to cloud work station

#---System commands 
#See these instructions to use gcsfuse to mount bucket to workstation
# file:///C:/Users/peter.kuriyama/Downloads/SWFSC_MSECloud_Helper%20(1).html


# system("sudo apt-get update")
# system("sudo apt-get install -y curl lsb-release")
# 
# system("export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`")
# system('echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list')
# 
# 
# 
# system("sudo apt-get update")
# system("sudo apt-get install gcsfuse")
# 
# 
# system("gcsfuse frd_popdy_peter '$HOME/bucket'")

#

#------------------------------------------------------------------------
#Create bucket directory 
# setwd("/home/user/")
# mkdir '$HOME/bucket'
# gcsfuse frd_popdy_peter "$HOME/bucket"


#Start of file copying
library(foreach)
library(doParallel)

#Specify directories to add
bucketdir <- "/home/user/bucket/albacore/model/"
workstationdir <- "/home/user/2026_albacore/model/"
  
bucket_files <- list.files(bucketdir)
workstation_files <- list.files(workstationdir)

#Files not yet uploaded
files_to_upload <- workstation_files[which(workstation_files %in% bucket_files == FALSE)]
#Keep base_model_2026 on workstation
files_to_upload <- files_to_upload[which(files_to_upload != "base_model_2026")]
#Also only keep folders that have mod or day in the name
files_to_upload <- files_to_upload[grep("day|mod", files_to_upload)]

# files_to_upload <- files_to_upload[-grep("\\.ss|\\.par", files_to_upload)]



# files_to_upload_dirs <- paste0(bucketdir, "/", files_to_upload)

#Upload the files in parallel
ncores <- 10

cl <- makeCluster(ncores)
registerDoParallel(cl)

start_time <- Sys.time()

foreach(ii = 1:length(files_to_upload)) %dopar% {
  fromdir <- paste0(workstationdir, "/",files_to_upload[ii], "/")
  todir <- paste0(bucketdir, "/", files_to_upload[ii], "/")
  
  dir.create(todir, recursive = T)
  
  mv_command <- paste0("mv ", fromdir, "* ", todir, '')
  system(mv_command)  
}
stopCluster(cl)
  
run_time <- Sys.time() - start_time; run_time


#------------------------------------------------
#Clean up the bucket filestructure because I messed up the backslash at the end of the
#directories

#List of all the bucket files
bucketfiles <- list.files(bucketdir)

ii <- 1

#Move everything up if the directory has the same name
# for(ii in 1:length(bucketfiles)){
  
  # bucketdirfiles <- list.files(paste0(bucketdir, "/", bucketfiles[ii]))
  
  # paste0(bucketdir, bucketfiles[ii], "/", bucketfiles[ii], "/")
sum(bucketfiles[ii] == list.files(paste0(bucketdir, bucketfiles[ii]))) > 0
  
ii <- 7
if(sum(bucketfiles[ii] == list.files(paste0(bucketdir, bucketfiles[ii]))) > 0){
    fromdir <- paste0(bucketdir, bucketfiles[ii], "/", bucketfiles[ii], "/")
    todir <-   paste0(bucketdir, bucketfiles[ii], "/" )
    mv_command <- paste0("mv ", fromdir, "* ", todir, "")
    system(mv_command)
    #Delete the folder
    rm_command <- paste0("rmdir ", fromdir)
    system(rm_command)  
  
  }
# } 






