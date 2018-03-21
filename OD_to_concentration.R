library(tidyverse)
library(inflection)
 
blank_average_OD <- function(elisa_file){
  data <- read.csv(elisa_file)
  
  #Take average of Blank OD values
  blk_mean <- data %>% filter(type == "Blank") %>% 
    select(contains("OD")) %>% rowMeans()
  #Take average of OD values for each sample and subtract blank average
  data$OD_mean <- data %>% select(contains("OD")) %>% rowMeans(na.rm = TRUE)
  data$blank_mean <- blk_mean
  data$OD_mean <- data$OD_mean - data$blank_mean
  data$log_conc <- log10(data$Concentration)
  return(data)
}


best_fit_curve <- function(a, b, cc, d, standard_df){
  #Generate best fit sigmoidal curve using a nonlinear least squares model
  #a = maximum y value
  #b = degree of curvature (-11 seems to work well as a constant for this)
  #cc = x value at point of inflection
  #d = minnimum y value
  #adapted from "What is the best fitting curve for ELISA standard Curve ?"
  #https://www.scientistsolutions.com/forum/antibody-based-technologies-assay-development-protocols/what-best-fitting-curve-elisa-standard

  fit <- nls(OD_mean ~ d+(a-d)/(1+(log_conc/cc)^b), data=standard_df,
      start=list(d=d, a=a, cc=cc, b=b), trace=TRUE)
  return(fit)
}

OD_to_conc <- function(elisa_file, output_file){
  #Uses best fit curve function and standards to estimate sample concentrations from OD450 values
  data <- blank_average_OD(elisa_file)
  standards <- data %>% filter(type == "Standard")
  samples <- data %>% filter(type == "Sample")
  
  #calculate point of inflection in sigmoidal data using Demetris Christopoulos package Inflection
  inf_point <- ese(standards$log_conc, standards$OD_mean, 0)[3]
  y_max <- standards %>% arrange(desc(OD_mean)) %>% 
    summarise(max(OD_mean)) %>% as.numeric(as.character())
  y_min <- standards %>% arrange(desc(OD_mean)) %>% 
    summarise(min(OD_mean)) %>% as.numeric(as.character())
  
  fit <- best_fit_curve(y_max, -11, inf_point, y_min, standards)
  samples$loganswer <- coef(fit)["cc"]*
    (((-1*coef(fit)["a"]+samples$OD_mean)/(coef(fit)["d"]-samples$OD_mean))^(1/coef(fit)["b"]))
  samples$conc <- 10^samples$loganswer
  write.csv(samples, output_file)
  return(samples)
}

standard_curve_plot <- function(elisa_file, output_csv_file, output_plot_file){
  pdf(output_plot_file)
  samples <- OD_to_conc(elisa_file, output_csv_file)
  data <- blank_average_OD(elisa_file)
  standards <- data %>% filter(type == "Standard")
  x_max <- standards %>% arrange(desc(OD_mean)) %>% 
    summarise(max(log_conc)) %>% as.numeric(as.character())
  x_min <- standards %>% arrange(desc(OD_mean)) %>% 
    summarise(min(log_conc)) %>% as.numeric(as.character())
  
  plot(standards$log_conc, standards$OD_mean,
       main="standard curve",
       xlab="x=log10(conc pg/mL)", ylab="y=OD_450")
  
  inf_point <- ese(standards$log_conc, standards$OD_mean, 0)[3]
  y_max <- standards %>% arrange(desc(OD_mean)) %>% 
    summarise(max(OD_mean)) %>% as.numeric(as.character())
  y_min <- standards %>% arrange(desc(OD_mean)) %>% 
    summarise(min(OD_mean)) %>% as.numeric(as.character())
  
  fit <- best_fit_curve(y_max, -11, inf_point, y_min, standards)
  
  #Plot fitted curve.
  #x a sequence of lenth 100 from x_min to x_max
  #y plots nonlinear model values
  x <- seq(x_min, x_max, length=100)
  y <- (coef(fit)["d"]+(coef(fit)["a"]-coef(fit)["d"])/(1+(x/coef(fit)
                                                           ["cc"])^coef(fit)["b"]))
  lines(x,y, col="red")
  
  #Plot samples that fall on curve in blue dots
  lines(samples$loganswer,samples$OD_mean, type="points", col="blue", pch=16)
  dev.off()
}

#Run all of the data with this
analyze_elisa <- function(elisa_file, output_csv_file, output_plot_pdf){
  OD_to_conc(elisa_file, output_csv_file)
  standard_curve_plot(elisa_file, output_csv_file, output_plot_pdf)
}
