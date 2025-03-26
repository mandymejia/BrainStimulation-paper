rm(list=ls())

library(dplyr)
library(hrf)
library(BayesfMRI) 
library(ciftiTools)
ciftiTools.setOption('wb_path','/N/u/wuyuno/Quartz/Downloads/workbench')

project_path = '/N/project/brain_stimulation_utah'
data_path = paste0(project_path, "/data")
results_path = paste0(project_path, "/results")

# resample the surface files
# resample_gifti(
#   original_fname = file.path(data_path,
#                              "sub-UA001_acq-pseudoMPRAGE_hemi-R_pial.surf.gii"),
#   target_fname = file.path(data_path,
#                            "sub-UA001_acq-pseudoMPRAGE_hemi-R_pial_32k.surf.gii"),
#   hemisphere = "right",
#   file_type = "surface",
#   original_res = 111279,
#   resamp_res = 32492,
#   resamp_method = "barycentric",
#   area_original_fname = NULL,
#   area_target_fname = NULL,
#   ROIcortex_original_fname = NULL,
#   ROIcortex_target_fname = NULL,
#   sphere_original_fname = file.path(data_path,
#                                     "sub-UA001_acq-pseudoMPRAGE_hemi-R_space-fsLR_desc-msmsulc_sphere.surf.gii"),
#   sphere_target_fname = file.path(data_path,
#                                   "Q1-Q6_R440.R.sphere.32k_fs_LR.surf.gii"),
#   read_dir = NULL,
#   write_dir = NULL
# )
# 
# resample_gifti(
#   original_fname = file.path(data_path,
#                              "sub-UA001_acq-pseudoMPRAGE_hemi-L_pial.surf.gii"),
#   target_fname = file.path(data_path,
#                            "sub-UA001_acq-pseudoMPRAGE_hemi-L_pial_32k.surf.gii"),
#   hemisphere = "left",
#   file_type = "surface",
#   original_res = 111675,
#   resamp_res = 32492,
#   resamp_method = "barycentric",
#   area_original_fname = NULL,
#   area_target_fname = NULL,
#   ROIcortex_original_fname = NULL,
#   ROIcortex_target_fname = NULL,
#   sphere_original_fname = file.path(data_path,
#                                     "sub-UA001_acq-pseudoMPRAGE_hemi-L_space-fsLR_desc-msmsulc_sphere.surf.gii"),
#   sphere_target_fname = file.path(data_path,
#                                   "Q1-Q6_R440.L.sphere.32k_fs_LR.surf.gii"),
#   read_dir = NULL,
#   write_dir = NULL
# )

# read surface files
surf_L <- read_surf(file.path(data_path,
                              "sub-UA001_acq-pseudoMPRAGE_hemi-L_pial_32k.surf.gii"))
surf_R <- read_surf(file.path(data_path,
                              "sub-UA001_acq-pseudoMPRAGE_hemi-R_pial_32k.surf.gii"))

# extract session and region names
files <- list.files(path = data_path, pattern = "sub-.*_ses-.*_space-T1w_sphere_template_.*\\.txt", full.names = FALSE)
session_names <- unique(gsub(".*_ses-([A-Za-z0-9]+)_.*", "\\1", files))
region_names <- unique(gsub(".*sphere_template_([^/]+)\\.txt", "\\1", files)) 


for (session in session_names){
  # read BOLD signals
  BOLD <- read_xifti(file.path(data_path,
                               paste0("sub-UA001_ses-",
                                      session,
                                      "_task-rest_space-fsLR_den-91k_bold.dtseries.nii")))
  # read confounders
  confounds <- read.table(file.path(data_path,
                                    paste0("sub-UA001_ses-",
                                           session,
                                           "_task-rest_desc-confounds_timeseries.tsv")), header = T)
  # get TR and nT
  TR <- BOLD$meta$cifti$time_step
  nT <- ncol(BOLD)
  # select scrubbing and nuisance variables
  scrubbing <- confounds %>% select(contains("outlier"))
  nuisance_cols <- c(
    "trans_x", "trans_y", "trans_z", "rot_x", "rot_y", "rot_z",
    "trans_x_derivative1", "trans_y_derivative1", "trans_z_derivative1",
    "rot_x_derivative1", "rot_y_derivative1", "rot_z_derivative1",
    "trans_x_power2", "trans_y_power2", "trans_z_power2",
    "rot_x_power2", "rot_y_power2", "rot_z_power2",
    paste0("w_comp_cor_0", 0:4),
    paste0("c_comp_cor_0", 0:4),
    paste0("t_comp_cor_0", 0:4)
  )
  nuisance <- confounds %>% select(all_of(nuisance_cols))
  # convert them to numeric format
  scrubbing_numeric <- apply(scrubbing, 2, as.numeric)
  nuisance_numeric <- suppressWarnings(apply(nuisance, 2, as.numeric))
  nuisance_numeric[is.na(nuisance_numeric)] <- 0
  
  for (region in region_names){
    # read task files
    task <- read.table(file.path(data_path, paste0("sub-UA001_ses-",
                                                   session,
                                                   "_space-T1w_sphere_template_",
                                                   region,
                                                   ".txt")), header = F)
    # get design matrix
    names(task) <- paste0(session, region)
    design <- as.matrix(task)
    # Bayes GLM model
    system.time(
      bglm <- BayesGLM(BOLD = BOLD,
                       design = design,
                       brainstructures = "all",
                       subROI = c('Accumbens-L', 'Accumbens-R', 'Amygdala-L',
                                  'Amygdala-R', 'Hippocampus-L', 'Hippocampus-R'),
                       TR = TR,
                       nuisance = nuisance_numeric,
                       scrub = scrubbing_numeric,
                       scale_BOLD = 'mean',
                       hpf = .01,
                       surfL = surf_L,
                       surfR = surf_R,
                       resamp_res = 10000,
                       nbhd_order = 1,
                       ar_order = 3,
                       ar_smooth = 0,
                       Bayes = TRUE,
                       verbose = 2,
                       meanTol = 1))
    # save the model results
    saveRDS(bglm, file = file.path(results_path, paste0(session, region, "_BayesGLM_result.rds")))
  }
}

