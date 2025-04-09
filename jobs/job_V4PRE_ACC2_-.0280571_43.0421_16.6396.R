library(dplyr)
library(hrf)
library(BayesfMRI) 
library(ciftiTools)
ciftiTools.setOption('wb_path','/N/u/wuyuno/Quartz/Downloads/workbench')

project_path = '/N/project/brain_stimulation_utah'
data_path = paste0(project_path, "/data")
results_path = paste0(project_path, "/results")

surf_L <- read_surf(file.path(data_path, "sub-UA001_acq-pseudoMPRAGE_hemi-L_pial_32k.surf.gii"))
surf_R <- read_surf(file.path(data_path, "sub-UA001_acq-pseudoMPRAGE_hemi-R_pial_32k.surf.gii"))

session <- "V4PRE"
region <- "ACC2_-.0280571_43.0421_16.6396"

BOLD <- read_xifti(file.path(data_path, paste0("sub-UA001_ses-", session, "_task-rest_space-fsLR_den-91k_bold.dtseries.nii")))
confounds <- read.table(file.path(data_path, paste0("sub-UA001_ses-", session, "_task-rest_desc-confounds_timeseries.tsv")), header = TRUE)

TR <- BOLD$meta$cifti$time_step
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
scrubbing_numeric <- apply(scrubbing, 2, as.numeric)
nuisance_numeric <- suppressWarnings(apply(nuisance, 2, as.numeric))
nuisance_numeric[is.na(nuisance_numeric)] <- 0

task <- read.table(file.path(data_path, paste0("sub-UA001_ses-", session, "_space-T1w_sphere_template_", region, ".txt")), header = FALSE)
names(task) <- make.names(paste0(session, region))
design <- as.matrix(task)

bglm <- BayesGLM(
  BOLD = BOLD,
  design = design,
  brainstructures = "all",
  subROI = c("Accumbens-L", "Accumbens-R", "Amygdala-L", "Amygdala-R", "Hippocampus-L", "Hippocampus-R"),
  TR = TR,
  nuisance = nuisance_numeric,
  scrub = scrubbing_numeric,
  scale_BOLD = "mean",
  hpf = 0.01,
  surfL = surf_L,
  surfR = surf_R,
  resamp_res = 10000,
  nbhd_order = 1,
  ar_order = 3,
  ar_smooth = 0,
  Bayes = TRUE,
  verbose = 0,
  meanTol = 1
)

saveRDS(bglm, file = file.path(results_path, paste0(session, region, "_BayesGLM_result.rds")))
