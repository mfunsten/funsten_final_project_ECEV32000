# funsten_final_project_ECEV32000
Matt Funsten- 03/20/2018

Summary: 

The VerMax Spectrophotometer is a critical machine for many experiments including ELISA's which determine the concentration of a particular product in solution.  Unfortunately, the machine's text file output is difficult to work with and neccessitates assigning data manually to sample ID's and conditions from experiments which is quite time consuming.  Furthermore, analysis of ELISA data, once in a usable format, is also quite time consuming.  Therefore each of these processes would benefit from automation which is achieved by the two programs in the repository, plate_reader_conversion.ipynb and OD_to_concentration.R which are described in further detail below.  Overall the two programs convert VersaMax 96 well Spectrophotometer text files into a dictionary format, assign recorded values from the plate reader to sample ID's in a user generated csv file, and then conerts the raw OD 450 values to concentrations in pg/mL using a standard curve.  Final outputs from the programs include a csv file with non-transformed data, a csv file with transformed data, and a standard curve graph with experimental samples plotted.  

Introduction: 

ELISA, or the Enzyme Linked Immunosorbent Assay, is a plate-based technique designed to detect the presence and/or concentration of a particular substance in solution.  It is a critical technique for many wet-lab based settings and can be used for a variety of experiments.  These can range from detecting differences in cytokine production by cells in culture in different conditions to determining the concentration of a soluble factor such as insulin in an animal's blood stream.  Substance detection is accomplished using antibodies coupled to the enzyme horse radish peroxidase that are specific for the substance of interest.  Addition of the chemical TMB, the substrate for horse radish peroxidase, then results in the wells containing the substance of interest to change color from clear to yellow and this color change can then be quantified using a spectrophotomoter.  As the "yellowness" of the wells is directly proportional to the amount of the desired substance in each well, using standards of known concentration, one can infer the concentration of the desired sunstance for each sample based on the absorbance at an OD of 450.

Our lab uses the 
