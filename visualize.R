setwd('~/Documents/GitHub/BrainStimulation-paper/')

library(ciftiTools)
ciftiTools.setOption('wb_path', '/Applications/')

library(BayesfMRI)

fnames_GLM <- list.files('Results')

region <- c('ACC1','ACC2','NAcc1','NAcc2')

for(r in region){
  
  print(r)
  fnames_r <- fnames_GLM[grepl(r, fnames_GLM)]
  
  for(f in fnames_r){
    
    print(f)
    GLM_f <- readRDS(file.path('Results', f))  
    
    #pfname <- gsub('_.+','', f)
    fname_plot <- gsub('_result.rds','',f)
    #plot(GLM_f, zlim = c(-0.3,0.3), Bayes = TRUE, fname = file.path('Plots', fname_plot))

    fname_plot <- gsub('Bayes','classical',fname_plot)
    plot(GLM_f, zlim = c(-0.3,0.3), Bayes = FALSE, fname = file.path('Plots', fname_plot))
  }
  
}

