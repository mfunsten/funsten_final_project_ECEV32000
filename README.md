# funsten_final_project_ECEV32000
Matt Funsten- 03/20/2018

How to run in brief using files in github:

Run plate_reader_conversion.ipynb in jupyter notebook using the line
bind_dict_to_sample('output_txt_file.txt', 'automated_ELISA_template.csv', 'ELISA_data.csv', 2, 3, 3)

Analyze data with R using the line
analyze_elisa("post_python_file.csv", "R_output.csv", "standard_curve.pdf")

Output files will be added to your working directory.

Summary: 

The VerMax Spectrophotometer is a critical machine for many experiments including ELISA's which determine the concentration of a particular product in solution.  Unfortunately, the machine's text file output is difficult to work with and neccessitates assigning data manually to sample ID's and conditions from experiments which is quite time consuming.  Furthermore, analysis of ELISA data, once in a usable format, is also quite time consuming.  Therefore each of these processes would benefit from automation which is achieved by the two programs in the repository, plate_reader_conversion.ipynb and OD_to_concentration.R which are described in further detail below.  Overall the two programs convert VersaMax 96 well Spectrophotometer text files into a dictionary format, assign recorded values from the plate reader to sample ID's in a user generated csv file, and then conerts the raw OD 450 values to concentrations in pg/mL using a standard curve.  Final outputs from the programs include a csv file with non-transformed data, a csv file with transformed data, and a standard curve graph with experimental samples plotted.  

Introduction: 

ELISA, or the Enzyme Linked Immunosorbent Assay, is a plate-based technique designed to detect the presence and/or concentration of a particular substance in solution.  It is a critical technique for many wet-lab based settings and can be used for a variety of experiments.  These can range from detecting differences in cytokine production by cells in culture in different conditions to determining the concentration of a soluble factor such as insulin in an animal's blood stream.  Substance detection is accomplished using antibodies coupled to the enzyme horse radish peroxidase that are specific for the substance of interest.  Addition of the chemical TMB, the substrate for horse radish peroxidase, then results in the wells containing the substance of interest to change color from clear to yellow and this color change can then be quantified using a spectrophotomoter.  As the "yellowness" of the wells is directly proportional to the amount of the desired substance in each well, using standards of known concentration, one can infer the concentration of the desired sunstance for each sample based on the absorbance at an OD of 450.

Our lab uses the VersaMax Spectrophotometer to detect sample absorbance at OD 450.  It is fast and reliable but has one major issue.  It outputs recorded data as non-delimited text file that makes non-automated data analysis slow and tedious because it must be copied well by well by hand into a csv file containing sample information or copied and pasted well by well in excel.  Once the csv file containing data and sample information has been constructed it is typically analyzed in excel or prism graph pad to generate a standard curve and convert OD450 values to concentrations.  As this is also somewhat time consuming, automation would also be beneficial.  For my final project I have therefore written two programs, one in python and one in R to solve these respective problems.  

Plate Reader Conversion Code in Python

The plate_reader_conversion.ipynb code is split into two functions.  The program requires the packages csv, itertools, pandas, and re. Before starting to code, construct a csv file containing all of your sample information and where each sample is located on your 96 well plate.  The csv file must contain a column titled 'type' that says whether each well contains a Sample, Standard, or Blank. It must also contain a column titled position that contains the row and column position for each sample in the format A, 1 for example.  For more details see the provided template automated_ELISA_template.csv.  

The first function entitled plate_to_dict accepts the VersaMax Spectrophotometer output text file as an input and returns a dictionary where the keys correspond to the plate row names (A-H) and the values contain the spectrophotometer OD 450 data from each row (12 values per key).  

The second function entitled bind_dict_to_csv uses plate_to_dict and assigns the data contained in the dictionary to each sample in the user-provided csv file.  It accepts the input arguments input_file which refers to the raw data text file from the VersaMax Spectrophotometer, input_template which refers to the user provided csv file, output_filename which refers to the csv file containing data produced by the function.  It also contains 3 numeric input arguments referring to the number of techincal replicates for samples, standards, and blanks.  For the sample files please set technical replicates for samples to 2, standards to 3, and blanks to 3.  In short the function uses position information for each sample in the user defined csv template to find data within the 96 well plate text file.  It then takes that data and subsequent data, based on the number of technical replicates, and adds it to newly generated columns labeled OD_n.  Technical replicates must be plated horizontally for this code to work.  Once the data is appended to the csv file, the file is saved to th user's working directory.  

Example for how to run the code in jupyter notebook:

bind_dict_to_sample('output_txt_file.txt', 'automated_ELISA_template.csv', 'ELISA_data.csv', 2, 3, 3)

OD_to_concentration.R

This second program converts raw OD 450 to concentrations using a standard curve generated using the standard values run on the plate along with the samples.  This program requires the packages tidyverse and inflection.  Inflection is a package written by Demetris T. Christopoulos and can be used to determine the x value of the point of inflection of a curve.  

The first function titled blank_average_OD takes the output file from the python code above, averages the OD 450 technical replicates, and subtracts the blank average from each average.  It returns a data frame containing the original csv file and the blanked averages.  

The second function entitled best_fit_curve contains an equation to estimate a best fit sigmoidal curve from the OD 450 average values and log10(concentrations) from the standards.  The inputs are a, upper y asymptote, b the degree of curvature, cc, the point of inflection x value, and d, the lower y asymptote.  This code was found on an online forum "What is the best fitting curve for ELISA standard Curve ?" https://www.scientistsolutions.com/forum/antibody-based-technologies-assay-development-protocols/what-best-fitting-curve-elisa-standard.  It returns a sigmoidal function fit for the data which can later be applied to the samples. 

The third function entitled OD_to_conc converts the OD 450 values of the samples to concentrations.  It uses blank_average_OD and best_fit_curve to accomplish this.  a, b, cc, d are calculted in OD_to_conc from the standard data.  It requires the output file from the python code above as an input and a name for the functions output csv file.  The function returns a data frame containing the samples with calculated concentrations as a csv saved to the user's working directory.  

The final function entitled standard_curve_plot plots the standard log10 concentration values in the x axis and OD 450 standard averages in the y axis, graphs the calculated sigmoidal best fit curve over them, and then graphs the sample log10 concentration and OD 450 values as blue points over the curve.  As an input, this function requires the output file from the python code above as an input, a name for the functions output csv file, and a name for the output pdf plot generated by this function.  The function returns a pdf saved to the user's working directory. 

All of these functions are wrapped up in a final R function called analyze_elisa.  

Example for how to analyze ELISA data with R:

analyze_elisa("post_python_file.csv", "R_output.csv", "standard_curve.pdf")



