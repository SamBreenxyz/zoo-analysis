
/*==============================================================
  Zoo_Hyrax — SAS Starter (Portfolio Edition)
  Author: Sam Breen
  Purpose: Reproduce the Python EDA + Stats + ML steps in SAS.
  Notes:
    - Works in SAS Studio / SAS OnDemand.
    - Uses name literals for columns with special characters: 'weight_(kg)'n
==============================================================*/

/* 0) Recommended: allow Excel import and flexible variable names */
options validvarname=any;

/* 1) IMPORT: Read the Excel dataset (update the PATH) */
%let XLS = /home/your_user/zoohyrax_master.xlsx;  /* <-- change to your uploaded path */
proc import datafile="&XLS."
    out=hyrax dbms=xlsx replace;
    sheet="Sheet1";     /* change if needed */
    getnames=yes;
run;

/* 2) CLEANING: Standardise text, handle missing values, drop duplicates */
/* - Title-case habitat and diet
   - Replace missing population with median
   - Remove exact duplicate rows */

proc sql;
  /* Median population (ignoring missing) */
  create table _pop_nonmiss as
  select 'population'n as population
  from hyrax
  where 'population'n is not missing
  ;
quit;

proc means data=_pop_nonmiss median noprint;
  var population;
  output out=_pop_med median=median_population;
run;

data hyrax_clean;
  if _n_=1 then set _pop_med(keep=median_population);
  set hyrax;
  /* Title-case text columns (simple approach) */
  habitat = propcase(strip(habitat));
  diet    = propcase(strip(diet));
  /* Fill missing population with median */
  if missing('population'n) then 'population'n = median_population;
run;

/* Remove duplicates */
proc sort data=hyrax_clean nodupkey;
  by _all_;
run;

/* 3) EDA: Descriptives and simple visuals */

/* Descriptives */
proc means data=hyrax_clean n mean std min p25 median p75 max;
  var 'population'n 'weight_(kg)'n 'length_(cm)'n;
run;

proc freq data=hyrax_clean;
  tables habitat diet iucn_status / nocum nopercent;
run;

/* Histogram of population */
title "Distribution of Hyrax Population";
proc sgplot data=hyrax_clean;
  histogram 'population'n;
  density 'population'n;
  xaxis label="Population";
run;

/* Boxplot of population by habitat */
title "Population by Habitat";
proc sgplot data=hyrax_clean;
  vbox 'population'n / category=habitat;
  yaxis label="Population";
  xaxis label="Habitat";
run;

/* 4) STATS: T-test, Correlation, ANOVA */

/* T-test: Savanna vs Forest (only if both exist) */
proc ttest data=hyrax_clean;
  class habitat;
  var 'population'n;
  where habitat in ("Savanna","Forest");
run;

/* Pearson correlation: weight vs length */
proc corr data=hyrax_clean pearson;
  var 'weight_(kg)'n 'length_(cm)'n 'population'n;
run;

/* ANOVA: population by diet */
proc glm data=hyrax_clean;
  class diet;
  model 'population'n = diet;
  means diet / hovtest=levene;
  lsmeans diet / pdiff=all adjust=tukey;
run; quit;

/* 5) ML-ish Regression: Predict population from traits + categories */
/* Use GLMSELECT to one-hot encode CLASS variables and fit linear model */
proc glmselect data=hyrax_clean plots=all;
  class habitat diet;
  model 'population'n = 'weight_(kg)'n 'length_(cm)'n habitat diet / selection=none;
  partition fraction(validate=0.3); /* 70/30 split like train/test */
  output out=hyrax_pred p=pred;
run;

/* Predicted vs Actual scatter */
title "Predicted vs Actual Population";
proc sgplot data=hyrax_pred;
  scatter x='population'n y=pred / markerattrs=(symbol=circlefilled);
  lineparm x=0 y=0 slope=1 / lineattrs=(pattern=shortdash);
  xaxis label="Actual";
  yaxis label="Predicted";
run;

/* 6) Save out a clean CSV for reuse (optional) */
proc export data=hyrax_clean
  outfile="/home/your_user/zoohyrax_cleaned.csv"
  dbms=csv replace;
run;

title;
