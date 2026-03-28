#-------------------------------------------------------------------------------
#Albacore 2026 stock assessment diagnostics and
#sensitivities




#-------------------------------------------------------------------------------
#Model Sensitivities
# 1. Natural Mortality
# 1a. Constant M of 0.3 across sexes and ages (same as approach used in 2014)
# 1b. Constant M of constant M of 0.48 and 0.39 for female and male of all ages, respectively
# 1c. estimated M with Lorenzen based on prior from Kinney and Teo (2017). 
# 
# 2. Stock-recruitment steepness (h)
# 2a. alternative values for the steepness parameter (h=0.75; 0.80 and 0.85); and
# 2b. adding prior based on Brodziak et al. (2011).
# 
# 3. Growth
# 3a.	CV of Linf is fixed higher (0.06 or 0.08) than base case; and
# 3b.	estimating growth.  
# 
# 4. Size composition weighting
# 4a.	down weighting each individual fleet; and 
# 4b.	down weighting all fleets so the input sample size is maximum 50 (currently 150).
# 
# 5. Selectivity
# 5a.	different sigmas (up/down 0.25)
# 5b.	turn off 2DARs 
# 5c.	no age selectivities
# 5d.	not assuming that the US longline fishery in Area 2 and 4 has a descending limb in asymptotic size selectivity; and
# 
# 6. Index standardization models
# 6a.	S36 for adults all area include ASPM/ASPMR
# 6b.	TWNLL JUV S37 in addition to F10 include ASPM/ASPMR
# 6c.	GLM Juvenile: Area 3/5 & Quarter 3/4 (EPO) in addition to F10.
# 
# 7.	Initial conditions  
# 7a.	investigate other initial fleets – check what was done in 2023
# 
# 8.	Same model structure as in 2023 stock assessment.  
# 8a.	use 2023 model structure with updated data

#-------------------------------------------------------------------------------A. Natural mortality (M):
