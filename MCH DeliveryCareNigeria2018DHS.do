use "C:\Users\JANET\Desktop\New folder\Nigeria practice\NGKR7ADT\NGKR7AFL.DTA", clear 
* Codes for skilled birth attendance for Nigeria DHS files: KR file for children's recode.

*generate weights
gen weight=v005/1000000

*survey set
gen psu = v021
gen strata =v023
svyset psu [pw = weight], strata(strata) vce(linearized)

rename v013 age
rename age Age 
rename v106 Education
rename v190 Wealth
rename v025 Residence
rename v024 Region

*Place of delivery
cap drop DHSdelivery
recode m15 (21/27=1 "Public sector")(31/36=2 "Private sector") (41/46=3 "NGO") ///
(11/12=4 "Home") (96=5 "Other"), gen(DHS_delivery)
label var DHS_delivery "place of delivery as in DHS eport"
label val DHS_delivery DHS_delivery

cap drop DHS_delivery2
recode m15 (21/27=1 "Public sector")(31/36=2 "Private sector") ///
(11/12=4 "Home") (41/46 96=5 "NGO/Other"), gen(DHS_delivery2)
label var DHS_delivery2 "Place of delivery"
label val DHS_delivery2 DHS_delivery2

**DELIVERY IN HEALTH FACILITY
cap drop facility_delivery
recode m15 (21/46=1 "Facility-based deliveries") (11/12 96=0 "Non-facility deliverie"), gen(facility_delivery)
label var facility_delivery "Facility-based deliveries"
label val facility_delivery facility_delivery

** ASSISTED BY MEDICALLY TRAINED PROVIDER DURING DELIVERY
gen skilledbirth=0
label define skilledbirth 1 "skilled" 0 "Unskilled"
lab var skilledbirth "Percentage delivered by a skilled worker"
lab val skilledbirth skilledbirth

foreach xvar of varlist m3a m3b m3c m3d m3e {
replace skilledbirth=1 if `xvar'==1
}

cap drop skilledprovider
egen skilledprovider = rowmax (m3a m3b m3c m3d m3e)
label define skilledprovider 0 "unskilled" 1 "skilled"
lab var skilledprovider "Percentage delivered by a skilled worker"
lab val skilledprovider skilledprovider 
tab skilledprovider [iweight=weight], m

**DROP MISSING CASES
keep if DHS_delivery!=.

** Check
svy: tab Wealth DHS_delivery, percent format(%4.1f) miss row
svy: tab Wealth facility_delivery, percent format(%4.1f) miss row
svy: tab Wealth skilledbirth, percent format(%4.1f) miss row
svy: tab Wealth skilledprovider, percent format(%4.1f) miss row


********************************************************************************
** RECODE VARIABLES FOR ANALYSIS **
*mother's age at birth 
cap drop agebirth
gen agebirth=(b3-v011)/12
cap drop age_at_birth
sort agebirth **(*to see the oldest 19year old)
recode agebirth (min/19.91667=1 "<20") (20/34.91667=2 "20-34")(35/max=3 "35-49"), gen(age_at_birth)
lab var age_at_birth "Mother's age at birth"
lab val age_at_birth age_at_birth
tab age_at_birth

*Birth order
gen birthorder1 = bord
replace birthorder1 = bord-1 if b0 == 2
replace birthorder1	=	bord-2 if b0 == 3

recode birthorder1 (1=1 "1") (2/3=2 "2-3") (4/5=3 "4-5")(6/20=4 "6+"), gen(birthorder)
label var birthorder "Birth order"
label values birthorder birthorder

* Antenatal care visits
cap drop antenatal_dhs
recode m14 (0=0 "None") (1/3=1 "1-3") (4/20=4 "4+") ///
(98=88 "DNK") (else =99 "Missing"), gen(antenatal_dhs)
label var antenatal_dhs "Antenatal visits - as in DHS report"
label val antenatal_dhs antenatal_dhs

** ========================================================================== **
** ========================================================================== **

** REPLICATING TABLE 9.8 (page 149)DHS delivery
svy: tab age_at_birth DHS_delivery, percent format (%4.1f) row
svy: tab birthorder DHS_delivery, percent format(%4.1f) row
svy: tab antenatal_dhs DHS_delivery, percent format(%4.1f) row // report excludes DNK & Missing
svy: tab Residence DHS_delivery, percent format(%4.1f) row
svy: tab Region DHS_delivery, percent format(%4.1f) row
svy: tab Education DHS_delivery, percent format(%4.1f) row
svy: tab Wealth DHS_delivery, percent format(%4.1f) row

****************

** COUNTS
svy: tab age_at_birth DHS_delivery, count format(%4.0f) miss
svy: tab birthorder DHS_delivery, count format(%4.0f) miss
svy: tab antenatal_dhs DHS_delivery, count format(%4.0f) miss
svy: tab Residence DHS_delivery, count format(%4.0f) miss
svy: tab Region DHS_delivery, count format(%4.0f) miss
svy: tab Education DHS_delivery, count format(%4.0f) miss
svy: tab Wealth DHS_delivery, count format(%4.0f) miss
** ========================================================================== **


** REPLICATING TABLE 9.8 (page 149) - Facility delivery
svy: tab age_at_birth facility_delivery, percent format (%4.1f) row
svy: tab birthorder facility_delivery, percent format(%4.1f) row
svy: tab antenatal_dhs facility_delivery, percent format(%4.1f) row
svy: tab Residence facility_delivery, percent format(%4.1f) row
svy: tab Region facility_delivery, percent format(%4.1f) row
svy: tab Education facility_delivery, percent format(%4.1f) row
svy: tab Wealth facility_delivery, percent format(%4.1f) row

****************
/*
svy: tab age_at_birth facility_delivery, count format(%4.0f) miss
svy: tab birthorder facility_delivery, count format(%4.0f) miss
svy: tab antenatal_dhs facility_delivery, count format(%4.0f) miss
svy: tab Residence facility_delivery, count format(%4.0f) miss
svy: tab Region facility_delivery, count format(%4.0f) miss
svy: tab Education facility_delivery, count format(%4.0f) miss
svy: tab Wealth facility_delivery, count format(%4.0f) miss
*/

** ========================================================================== **

** REPLICATING TABLE 9.9 (page 150) - Percentage delivered by a skilled provider

svy: tab age_at_birth skilledprovider, percent format(%4.1f) row
svy: tab birthorder skilledprovider, percent format(%4.1f) row
svy: tab antenatal_dhs skilledprovider, percent format(%4.1f) row
svy: tab Residence skilledprovider, percent format(%4.1f) row
svy: tab Region skilledprovider, percent format(%4.1f) row
svy: tab Education skilledprovider, percent format(%4.1f) row
svy: tab Wealth skilledprovider, percent format(%4.1f) row

****************
/*
svy: tab age_at_birth skilled_birth, count format(%4.0f) miss
svy: tab birthorder skilled_birth, count format(%4.0f) miss
svy: tab antenatal_dhs skilled_birth, count format(%4.0f) miss
svy: tab Residence skilled_birth, count format(%4.0f) miss
svy: tab Region skilled_birth, count format(%4.0f) miss
svy: tab Education skilled_birth, count format(%4.0f) miss
svy: tab Wealth skilled_birth, count format(%4.0f) miss
*/

** ========================================================================== **
** ================================= GRAPHS ================================= **
** ========================================================================== **

ssc install catplot, replace
catplot DHS_delivery2 [aw=weight], by(Wealth, compact note("") col(1)) ///
        bar(1, blcolor(gs8) bfcolor(brown*.4)) blabel(bar, format(%9.1f) ///
        pos(base)) percent(Wealth) subtitle(, pos(9) ring(1) bcolor(none) nobexpand place(e)) ///
        ytitle(Place of delivery (%)) var1opts(gap(*0.1) axis(noline)) ///
        var2opts(gap(*.2)) ysize(5) yla(none) ysc(noline) ///
        plotregion(lcolor(none))
		

catplot DHS_delivery2 Wealth [aw=weight], percent(Wealth) stack asyvars ///
		bar(1, bcolor(ltblue)) bar(2, bcolor(pink*.2)) bar(3, bcolor(brown*.4)) ///
		bar(4, bcolor(bluishgray)) bar(5, bcolor(gs10)) bar(6, bcolor(red*.4)) ///
		bar(7, bcolor(sand)) blabel(bar, format(%9.1f) pos(center)) ///
		blabel(bar, format(%9.1f) pos(center) size(tiny)orientation(vertical) color(black)) ///
		ytitle(%) title(Place of delivery by HH wealth) subtitle(Nigeria DHS 2018)
		
catplot facility_delivery Wealth [aw=weight], percent(Wealth) stack asyvars ///
		bar(1, bcolor(green)) bar(2, bcolor(ltblue)) bar(3, bcolor(gs0)) ///
		blabel(bar, format(%9.1f) pos(center)) bar(4, bcolor(g)) ytitle(%) ///
		title(Percentage delivered in a health facility) subtitle(Nigeria DHS 2018)
		
catplot skilledprovider Wealth [aw=weight], percent(Wealth) stack asyvars ///
		bar(1, bcolor(black)) bar(2, bcolor(ltblue)) bar(3, bcolor(gs0)) ///
		blabel(bar, format(%9.1f) pos(center)) bar(4, bcolor(g)) ytitle(%) ///
		title(Prevalence of skilled birth attendance) subtitle(Nigeria DHS 2018)
		
		
**You can repeat the same for other variables		
save "C:\Users\JANET\Desktop\New folder\Skilleddelivery recode.dta", replace 
