use "data/instrument_predictions.dta", replace

***************

*create variables
egen ISO_ID = group(ISO)
egen POLICY_ID = group(Policy)

gen loggdppc = log(gdppc)
gen logco2pc = log(co2pc)

replace debt = debt/1000
replace logco2pc = logco2pc/1000
replace precipitation = precipitation/1000
replace airquality = airquality/1000
replace popAtRisk = popAtRisk/1000

***

*drop observations with missing values
keep if !missing(dummy_policies_post_2016, wpm_prox_pre2015new, logpop, loggdppc, debt, logco2pc, precipitation, airquality, popAtRisk, A_ControlofCorruption, A_RuleofLaw, A_RegulatoryQuality, A_GovernmentEffectiveness, A_PoliticalStabilityNoViolence, A_VoiceandAccountability)

***

*define control variable set
global control0 ""
global control1 "logpop loggdppc"
global control2 "logpop loggdppc debt"
global control3 "logpop loggdppc debt logco2pc precipitation airquality"
global control4 "logpop loggdppc debt logco2pc precipitation airquality popAtRisk"
global control5 "logpop loggdppc debt logco2pc precipitation airquality popAtRisk A_ControlofCorruption A_RuleofLaw A_RegulatoryQuality A_GovernmentEffectiveness A_PoliticalStabilityNoViolence A_VoiceandAccountability"

*define dependent variable set
global dependent "dummy_policies_post_2016"

***

*Table 1: 
local path "results/table_1.txt"
capture noisily rm `path'
foreach dep in $dependent {
	foreach indep of var wgt_relatedness_pre_2016 {
		forvalues i = 0/5 {
	
			reg `dep' `indep' ${control`i'} i.POLICY_ID, vce(cluster ISO_ID)
			outreg2 using `path', bdec(3) tdec(2) rdec(2) alpha(0.01, 0.05, 0.1) stat(coef se pval) ///
			addtext(POLICY FE, YES, CONTROLSET, `i') keep(`indep' $control5) ///
			sortvar($control5) excel app
		
		}
	}
}

***

*Table S4.1: 
local path "results/table_S4_1.txt"
capture noisily rm `path'
foreach dep in $dependent {
	foreach indep of var wgt_relatedness_pre_2016_RPP {
		forvalues i = 0/5 {
	
			reg `dep' `indep' ${control`i'} i.POLICY_ID, vce(cluster ISO_ID)
			outreg2 using `path', bdec(3) tdec(2) rdec(2) alpha(0.01, 0.05, 0.1) stat(coef se pval) ///
			addtext(POLICY FE, YES, CONTROLSET, `i') keep(`indep' $control5) ///
			sortvar($control5) excel app
		
		}
	}
}

***

*Table S4.2: 
local path "results/table_S4_2.txt"
capture noisily rm `path'
foreach dep in $dependent {
	foreach indep of var hh_relatedness_pre_2016 {
		forvalues i = 0/5 {
	
			reg `dep' `indep' ${control`i'} i.POLICY_ID, vce(cluster ISO_ID)
			outreg2 using `path', bdec(3) tdec(2) rdec(2) alpha(0.01, 0.05, 0.1) stat(coef se pval) ///
			addtext(POLICY FE, YES, CONTROLSET, `i') keep(`indep' $control5) ///
			sortvar($control5) excel app
		
		}
	}
}

***

*Table S4.3: 
local path "results/table_S4_3.txt"
capture noisily rm `path'
foreach dep in $dependent {
	foreach indep of var hh_relatedness_pre_2016_RPP {
		forvalues i = 0/5 {
	
			reg `dep' `indep' ${control`i'} i.POLICY_ID, vce(cluster ISO_ID)
			outreg2 using `path', bdec(3) tdec(2) rdec(2) alpha(0.01, 0.05, 0.1) stat(coef se pval) ///
			addtext(POLICY FE, YES, CONTROLSET, `i') keep(`indep' $control5) ///
			sortvar($control5) excel app
		
		}
	}
}
