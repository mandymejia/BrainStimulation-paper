rm(list=ls())

library(dplyr)
library(hrf)
library(BayesfMRI) 
library(ciftiTools)
ciftiTools.setOption('wb_path','/N/u/wuyuno/Quartz/Downloads/workbench')

project_path = '/N/project/brain_stimulation_utah'
data_path = paste0(project_path, "/data")
results_path = paste0(project_path, "/results")

result = readRDS(file.path(results_path, "V4POSTNAcc2_13.5891_37.2597_-7.71998_BayesGLM_result.rds"))

library(webshot2)
plot(result, Bayes = TRUE, what = "surface", fname = "my_surface_plot.html")
browseURL("my_surface_plot.html")
