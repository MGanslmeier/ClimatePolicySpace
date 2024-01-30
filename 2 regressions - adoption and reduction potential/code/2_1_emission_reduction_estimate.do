use "data/Eskander_Fankhauser_table-1_data.dta", replace

***

*merge data
gen ISO = iso
gen YEAR = year
merge 1:1 ISO YEAR using "data/policy_potential.dta"
keep if _merge == 3
egen ISO_ID = group(ISO)
sort ISO_ID YEAR
xtset ISO_ID YEAR

***

*define variable sets
global dependent "lnghg lnco2"
global dependent "lnco2"
global control L1.(gdp_hp c.lngdp##c.lngdp import_share service_share dtemp federal2 rle1)
global independent "P_Adviceoraidinimplementa P_Auditing P_Barrierremoval P_Buildingcodesandstandar P_Comparisonlabel P_Coordinatingbodyforclim P_COtaxes P_Demonstrationproject P_Endorsementlabel P_Energyandothertaxes P_Feedintariffsorpremiums P_Formallegallybindingcli P_Formallegallybindingene P_FormallegallybindingGHG P_Formallegallybindingren P_Fundstosubnationalgover P_GHGemissionreductioncre P_GHGemissionsallowances P_Grantsandsubsidies P_Greencertificates P_Gridaccessandpriorityfo P_Industrialairpollutions P_Informationprovision P_Infrastructureinvestmen P_Institutionalcreation P_Loans P_Monitoring P_Negotiatedagreementspub P_Netmetering P_Obligationschemes P_Othermandatoryrequireme P_Politicalnonbindingclim P_Politicalnonbindingener P_PoliticalnonbindingGHGr P_Politicalnonbindingrene P_Procurementrules P_Productstandards P_Professionaltrainingand P_Publicvoluntaryschemes P_RDDfunding P_Removaloffossilfuelsubs P_Retirementpremium P_Sectoralstandards P_Strategicplanning P_Taxrelief P_Technologydeploymentand P_Technologydevelopment P_Tenderingschemes P_Unilateralcommitmentspr P_Usercharges P_Vehicleairpollutionstan P_Vehiclefueleconomyandem P_Voluntaryapproaches P_Whitecertificates"

***

*select policy types with at least 30 occurrences
preserve
keep if year == 2016
foreach var in $independent {
    rename `var'_C `var'
}
keep $independent
collapse (sum) $independent
local varlist ""
foreach var of varlist _all {
    qui summarize `var', meanonly
    if r(mean) >= 30 {
        local varlist "`varlist' `var'"
    }
}
global independent `varlist'
restore
di "$independent"

***

*Figure 2 & Table S6.1
local path "results/figure2_&_table_S6_1.txt"
capture noisily rm `path'

foreach indep in $independent {
	foreach dep in $dependent {
		
		reghdfe `dep' L1.(c.`indep'_Y3R c.`indep'_CmY3R) $control ///
		if YEAR>1998, absorb(i.YEAR i.ISO_ID) vce(robust)
		
		outreg2 using `path', bdec(5) dec(5) tdec(5) rdec(5) alpha(0.01, 0.05, 0.1) stat(coef se pval) ///
		sortvar($control L1.(c.`indep'_Y3R c.`indep'_CmY3R)) addtext(Country FE, YES, Year FE, YES) e(r2_within) ///
		title(Table 1 - Climate laws and their effect on emission) excel app 
		
	}
}

***

*Figure 2 & Table S6.1 - without p-values for ease of visualization
local path "results/figure2_&_table_S6_1_wo_pval.txt"
capture noisily rm `path'

foreach indep in $independent {
	foreach dep in $dependent {
		
		reghdfe `dep' L1.(c.`indep'_Y3R c.`indep'_CmY3R) $control ///
		if YEAR>1998, absorb(i.YEAR i.ISO_ID) vce(robust)
		
		outreg2 using `path', bdec(5) dec(5) tdec(5) rdec(5) alpha(0.01, 0.05, 0.1) stat(coef se) ///
		sortvar($control L1.(c.`indep'_Y3R c.`indep'_CmY3R)) addtext(Country FE, YES, Year FE, YES) e(r2_within) ///
		title(Table 1 - Climate laws and their effect on emission) excel app 
		
	}
}
