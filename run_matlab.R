
matlab_run <- function(matlab_location = "../stationary_generator") {
  workingDir <- getwd()
  setwd(matlab_location)
  # file.remove(list.files(path = "RESULTAT", full.names = TRUE))
  iError <- system(command = "run.m")
  setwd(workingDir)
  if(iError != 0) stop("MATLAB has returned an error", iError)
}

