clear
set more off

set matsize 800

cd "\\cnsdisk.austin.utexas.edu\home\lvk99\Desktop\2YP\Data\Tables"
use "\\cnsdisk.austin.utexas.edu\home\lvk99\Desktop\2YP\Data\Tables\Final 2YP data


replace reg_dummy = 1 if numeric_scrape_date > 21200 // This seems to have been missing for my final model! It doesn't significantly impact the results though. 

//*------------------ JULY UPDATED LISTING REGRESSIONS ------------------* // 

reg list_month i.singleprop##i.reg_dummy##i.SFO_ind bedrooms if minimum_nights < 30, vce(cluster zipcode)
estimates store list_updated_model_0dum

reghdfe list_month i.singleprop##i.reg_dummy##i.SFO_ind bedrooms if minimum_nights < 30, a(month_year) vce(cluster zipcode)
estimates store list_updated_model_1dum

reghdfe list_month i.singleprop##i.reg_dummy##i.SFO_ind bedrooms if minimum_nights < 30, a(room_dum month_year) vce(cluster zipcode) 
estimates store list_updated_model_2dum

reghdfe list_month i.singleprop##i.reg_dummy##i.SFO_ind bedrooms if minimum_nights < 30, a(room_dum month_year id) vce(cluster zipcode) 
estimates store list_updated_model_3dum

esttab list_updated_model_0dum list_updated_model_1dum list_updated_model_2dum list_updated_model_3dum using list_regs_updated.tex, replace label se cells(b(fmt(3)) se(par fmt(3))) nostar title(DD estimates of the impact of rental regulation on property listing probability\label{tab1})

///* Linear combinations of the results *///
lincom 1.reg_dummy#1.SFO_ind + 1.singleprop#1.reg_dummy#1.SFO_ind

//*------------------ JULY UPDATE PRICE REGRESSIONS ------------------* // 
reghdfe price i.singleprop##i.reg_dummy##i.SFO_ind bedrooms if minimum_nights < 30, a(room_dum month_year id) vce(cluster zipcode) 
estimates store price_update_model_3dum

reghdfe cleaning_fee i.singleprop##i.reg_dummy##i.SFO_ind bedrooms if minimum_nights < 30, a(room_dum month_year id) vce(cluster zipcode) 
estimates store cleaning_update_model_3dum

esttab price_update_model_3dum cleaning_update_model_3dum using Price_reg_updated.tex, replace label se cells(b(fmt(3)) se(par fmt(3))) nostar title(DD estimates of the impact of rental regulation on nightly prices and cleaning fees\label{tab1})


/*------------------------------------ City-month controls (Not used in July submission) ------------------------------------*/ 

/* Note: It would be good to incorporate this into the paper if I keep revising it!     */
foreach k of varlist list_month price cleaning_fee {
reghdfe `k' i.singleprop##i.reg_dummy##i.SFO_ind bedrooms i.city_dum##i.month_year if minimum_nights < 30, a(room_dum id) vce(cluster zipcode)
}

/*------------------------------------ Placebo Testing ------------------------------------*/ 


/*****---------- Pre treatment period placebo ----------*****/ 


/***** No SF (SHOULD BE USING A BIG LOOP FOR THIS SECTION)*****/
quietly reghdfe list_month i.singleprop##i.reg_dummy##i.LA_ind bedrooms i.room_dum i.month_year if minimum_nights < 30 & (city == "LA" | city == "POR"), a(room_dum month_year id) vce(cluster zipcode)

scalar g6_placebo_LA = _b[1.reg_dummy#1.LA_ind]
scalar g6_t_placebo_LA = _b[1.reg_dummy#1.LA_ind]/_se[1.reg_dummy#1.LA_ind]

scalar g7_placebo_LA = _b[1.singleprop#1.reg_dummy#1.LA_ind]
scalar g7_t_placebo_LA = _b[1.singleprop#1.reg_dummy#1.LA_ind]/_se[1.singleprop#1.reg_dummy#1.LA_ind]

quietly reghdfe list_month i.singleprop##i.reg_dummy##i.POR_ind bedrooms i.room_dum i.month_year if minimum_nights < 30 &(city == "LA" | city == "POR"), a(room_dum month_year id) vce(cluster zipcode) 

scalar g6_placebo_POR = _b[1.reg_dummy#1.POR_ind]
scalar g6_t_placebo_POR = _b[1.reg_dummy#1.POR_ind]/_se[1.reg_dummy#1.POR_ind]

scalar g7_placebo_POR = _b[1.singleprop#1.reg_dummy#1.POR_ind]
scalar g7_t_placebo_POR = _b[1.singleprop#1.reg_dummy#1.POR_ind]/_se[1.singleprop#1.reg_dummy#1.POR_ind]

matrix Plac_city1 = (g6_placebo_LA,  g6_placebo_POR \ g6_t_placebo_LA, g6_t_placebo_POR)
matrix Plac_city1_T = Plac_city1'
matrix list Plac_city1_T

matrix Plac_city2 = (g7_placebo_LA,  g7_placebo_POR \ g7_t_placebo_LA, g7_t_placebo_POR)
matrix Plac_city2_T = Plac_city2'
matrix list Plac_city2_T

quietly reghdfe price i.singleprop##i.reg_dummy##i.LA_ind bedrooms i.room_dum i.month_year if minimum_nights < 30 & (city == "LA" | city == "POR"), a(room_dum month_year id) vce(cluster zipcode)

scalar th6_placebo_LA = _b[1.reg_dummy#1.LA_ind]
scalar th6_t_placebo_LA = _b[1.reg_dummy#1.LA_ind]/_se[1.reg_dummy#1.LA_ind]

scalar th7_placebo_LA = _b[1.singleprop#1.reg_dummy#1.LA_ind]
scalar th7_t_placebo_LA = _b[1.singleprop#1.reg_dummy#1.LA_ind]/_se[1.singleprop#1.reg_dummy#1.LA_ind]

quietly reghdfe price i.singleprop##i.reg_dummy##i.POR_ind bedrooms i.room_dum i.month_year if minimum_nights < 30 &(city == "LA" | city == "POR"), a(room_dum month_year id) vce(cluster zipcode) 

scalar th6_placebo_POR = _b[1.reg_dummy#1.POR_ind]
scalar th6_t_placebo_POR = _b[1.reg_dummy#1.POR_ind]/_se[1.reg_dummy#1.POR_ind]

scalar th7_placebo_POR = _b[1.singleprop#1.reg_dummy#1.POR_ind]
scalar th7_t_placebo_POR = _b[1.singleprop#1.reg_dummy#1.POR_ind]/_se[1.singleprop#1.reg_dummy#1.POR_ind]

matrix Plac_city3 = (th6_placebo_LA,  th6_placebo_POR \ th6_t_placebo_LA, th6_t_placebo_POR)
matrix Plac_city3_T = Plac_city3'
matrix list Plac_city3_T

matrix Plac_city4 = (th7_placebo_LA,  th7_placebo_POR \ th7_t_placebo_LA, th7_t_placebo_POR)
matrix Plac_city4_T = Plac_city4'
matrix list Plac_city4_T

putexcel set "Placebo_city.csv", modify
putexcel B4=matrix(Plac_city1_T, Plac_city2_T, Plac_city3_T,Plac_city4_T)

// ---------- Placebo for listing probability ---------- //

foreach lev in 20454 20547 20637 20728 20820 20911 21002 21094{ 

gen placebo_`lev' = 1 if numeric_scrape_file_date >= `lev'
replace placebo_`lev' = 0 if placebo_`lev' == .
}

foreach p of varlist placebo_20454-placebo_21094 {

quietly reghdfe list_month i.singleprop##i.`p'##i.SFO_ind bedrooms if minimum_nights < 30 & numeric_scrape_file_date < 21200, a(room_dum month_year id) vce(cluster zipcode)
scalar g6_`p' = _b[1.`p'#1.SFO_ind]
scalar g6_t_`p' = _b[1.`p'#1.SFO_ind]/_se[1.`p'#1.SFO_ind]

scalar g7_`p' = _b[1.singleprop#1.`p'#1.SFO_ind]
scalar g7_t_`p' = _b[1.singleprop#1.`p'#1.SFO_ind]/_se[1.singleprop#1.`p'#1.SFO_ind]

}

matrix Plac1 = (g6_placebo_20454,  g6_placebo_20547,  g6_placebo_20637,  g6_placebo_20728,  g6_placebo_20820,  g6_placebo_20911,  g6_placebo_21002,  g6_placebo_21094 \ g6_t_placebo_20454,  g6_t_placebo_20547,  g6_t_placebo_20637,  g6_t_placebo_20728,  g6_t_placebo_20820,  g6_t_placebo_20911,  g6_t_placebo_21002,  g6_t_placebo_21094)
matrix Plac1_T = Plac1'
matrix list Plac1_T

matrix Plac2 = (g7_placebo_20454,  g7_placebo_20547,  g7_placebo_20637,  g7_placebo_20728,  g7_placebo_20820,  g7_placebo_20911,  g7_placebo_21002,  g7_placebo_21094 \ g7_t_placebo_20454,  g7_t_placebo_20547,  g7_t_placebo_20637,  g7_t_placebo_20728,  g7_t_placebo_20820,  g7_t_placebo_20911,  g7_t_placebo_21002,  g7_t_placebo_21094)
matrix Plac2_T = Plac2'
matrix list Plac2_T


// ---------- Placebo for prices ---------- // 

foreach p of varlist placebo_20454-placebo_21094 {

quietly reghdfe price i.singleprop##i.`p'##i.SFO_ind bedrooms if minimum_nights < 30 & numeric_scrape_file_date < 21200, a(room_dum month_year id) vce(cluster zipcode)
scalar th6_`p' = _b[1.`p'#1.SFO_ind]
scalar th6_t_`p' = _b[1.`p'#1.SFO_ind]/_se[1.`p'#1.SFO_ind]

scalar th7_`p' = _b[1.singleprop#1.`p'#1.SFO_ind]
scalar th7_t_`p' = _b[1.singleprop#1.`p'#1.SFO_ind]/_se[1.singleprop#1.`p'#1.SFO_ind]

}

matrix Plac3 = (th6_placebo_20454,  th6_placebo_20547,  th6_placebo_20637,  th6_placebo_20728,  th6_placebo_20820,  th6_placebo_20911,  th6_placebo_21002,  th6_placebo_21094 \ th6_t_placebo_20454,  th6_t_placebo_20547,  th6_t_placebo_20637,  th6_t_placebo_20728,  th6_t_placebo_20820,  th6_t_placebo_20911,  th6_t_placebo_21002,  th6_t_placebo_21094)
matrix Plac3_T = Plac3'
matrix list Plac3_T

matrix Plac4 = (th7_placebo_20454,  th7_placebo_20547,  th7_placebo_20637,  th7_placebo_20728,  th7_placebo_20820,  th7_placebo_20911,  th7_placebo_21002,  th7_placebo_21094 \ th7_t_placebo_20454,  th7_t_placebo_20547,  th7_t_placebo_20637,  th7_t_placebo_20728,  th7_t_placebo_20820,  th7_t_placebo_20911,  th7_t_placebo_21002,  th7_t_placebo_21094)
matrix Plac4_T = Plac4'
matrix list Plac4_T

putexcel set "Placebo.csv", modify
putexcel B4=matrix(Plac1_T, Plac2_T, Plac3_T, Plac4_T)
