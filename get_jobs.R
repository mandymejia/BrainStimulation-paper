project_path = '/N/project/brain_stimulation_utah'
data_path = paste0(project_path, "/data")

# extract session and region names
files <- list.files(path = data_path, pattern = "sub-.*_ses-.*_space-T1w_sphere_template_.*\\.txt", full.names = FALSE)
session_names <- unique(gsub(".*_ses-([A-Za-z0-9]+)_.*", "\\1", files))
region_names <- unique(gsub(".*sphere_template_([^/]+)\\.txt", "\\1", files)) 

# create all combinations
jobs <- expand.grid(session = session_names, region = region_names, stringsAsFactors = FALSE)

# save as csv file
write.csv(jobs, file = "job_list.csv", row.names = FALSE)
