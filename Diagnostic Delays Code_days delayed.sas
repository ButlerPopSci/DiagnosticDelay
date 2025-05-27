libname data "C:\Users\ebhaa\OneDrive - University of North Carolina at Chapel Hill\Research\CBCS 3 Diagnostic Delays\SAS Dataset";

PROC CONTENTS DATA=data.DELAYS_MERGED;
RUN;

PROC MEANS DATA=data.hass_extra_042325;
	VAR days_detection;
RUN;

PROC FREQ DATA=data.HASS_EXTRA_042325;
	TABLES days_detection / MISSING;
RUN;

*\N=2998 with N=49 missing

complete dataset N=2998

Run a PROC FREQ on a random variable so I can check counts
after merging;

PROC FREQ DATA=data.DELAYS;
	TABLES race;
RUN;

*\Merge the above datasets;

PROC SORT DATA=data.hass_extra_042325; 
	BY STUDYID;
RUN;

PROC SORT DATA=data.delays; 
	BY STUDYID;
RUN;

DATA data.delays_merged;
   MERGE data.hass_extra_042325 data.DELAYS;
   BY STUDYID;
RUN;

*\Check merge;

PROC MEANS DATA=data.hass_extra_042325;
	VAR days_detection;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES race;
RUN;

PROC MEANS DATA=data.DELAYS_MERGED;
	VAR days_detection;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES race;
RUN;

*\Looks good!

Make days_delayed variable

0 = 60 days or less = timely
1 = Greater than 60 days = delayed;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES days_detection;
RUN;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;

	IF days_detection = .
	THEN days_delayed = .;

	ELSE IF days_detection <= 60
	THEN days_delayed = 0;

	ELSE days_delayed = 1;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES days_delayed;
RUN;

*\Checking I match w Ebonee;

data enb_delay;
set data.delays_merged;
if 0 <= days_detection <= 60 then dxdelay_categorical = 0;
if days_detection > 60 then dxdelay_categorical = 1;
if days_detection = . then dxdelay_categorical = .;
run;

proc freq data=enb_delay;
	TABLES dxdelay_categorical;
RUN;

*\Looks good!

Create variable for clinical v non-clinical detection (& other);

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES haas_method_detect;
RUN;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;

	IF (haas_method_detect = 1)
	THEN method_of_detection = "Non-clinical";

	ELSE IF haas_method_detect IN (2,3)
	THEN method_of_detection = "Clinical";

	ELSE method_of_detection = "Other";
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES method_of_detection;
RUN;

*\Pull counts for Table 1;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES age_group*days_delayed / LIST MISSING;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES race*days_delayed / LIST MISSING;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES income20k*days_delayed/LIST MISSING;
	TABLES education*days_delayed/LIST MISSING;
	TABLES reg_care*days_delayed/LIST MISSING;
	Tables method_of_detection*days_delayed/LIST MISSING;
	TABLES screencat*days_delayed/LIST MISSING;
	TABLES symptoms*days_delayed/LIST MISSING;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES STAGE*days_delayed/LIST MISSING;
	TABLES ESTSIZE*days_delayed/LIST MISSING;
	TABLES NODESTAT*days_delayed/LIST MISSING;
	Tables GRADE*days_delayed/LIST MISSING;
	TABLES ER*days_delayed/LIST MISSING;
	TABLES PR*days_delayed/LIST MISSING;
	TABLES PATH_HER2*days_delayed/LIST MISSING;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES STAGE/MISSING;
	TABLES ESTSIZE/MISSING;
	TABLES NODESTAT/MISSING;
	Tables GRADE/MISSING;
	TABLES ER/MISSING;
	TABLES PR/MISSING;
	TABLES PATH_HER2/MISSING;
	WHERE days_delayed NE .;
RUN;

*\Look at options for "other" methods of detection (P3D4B);

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES P3D4B;
	TABLES method_of_detection;
RUN;

*\Look at chi square test for Table 1 var (we'll start with 1 var);
PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES income20k*days_delayed/LIST MISSING CHISQ;
RUN;

*\Checking that the order gets me the same thing;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES days_delayed*income20k/LIST MISSING CHISQ;
RUN;

*\It does!
What about when I ignore missing?;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES income20k*days_delayed/LIST CHISQ;
	WHERE days_delayed IN (0,1);
RUN;

*\This gives me a different number. Need to exclude missing for chisq;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES Immune_Class_LCA;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES STAGE*days_delayed/LIST CHISQ;
	TABLES ESTSIZE*days_delayed/LIST CHISQ;
	TABLES NODESTAT*days_delayed/LIST CHISQ;
	Tables GRADE*days_delayed/LIST CHISQ;
	TABLES ER*days_delayed/LIST CHISQ;
	TABLES PR*days_delayed/LIST CHISQ;
	TABLES PATH_HER2*days_delayed/LIST CHISQ;
	WHERE days_delayed IN (0,1);
RUN;

*\Make groupings:
Group 1: LT 50, Timely Dx
Group 2: LT 50, Delayed Dx
Group 3: 50+, Timely Dx
Group 4: 50+, Delayed Dx

age_group = 1 when LT 50;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES age_group*days_delayed / LIST MISSING;
RUN;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;

	IF (age_group = 1 AND days_delayed = 0)
	THEN delay_group = 1;

	ELSE IF (age_group = 1 AND days_delayed = 1)
	THEN delay_group = 2;

	ELSE IF (age_group = 0 AND days_delayed = 0)
	THEN delay_group = 3;

	ELSE IF (age_group = 0 AND days_delayed = 1)
	THEN delay_group = 4;

	ELSE delay_group = .;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES delay_group;
RUN;

*\Get numbers for table 2;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES delay_group*reg_care / LIST MISSING;
	TABLES delay_group*method_of_detection / LIST MISSING;
	TABLES delay_group*symptoms / LIST MISSING;
	TABLES delay_group*screencat / LIST MISSING;
	TABLES delay_group*stage / LIST MISSING;
	TABLES delay_group*estsize / LIST MISSING;
	TABLES delay_group*grade / LIST MISSING;
	TABLES delay_group*nodestat / LIST MISSING;
	TABLES delay_group*ER / LIST MISSING;
	TABLES delay_group*PR / LIST MISSING;
	TABLES delay_group*path_HER2 / LIST MISSING;
RUN;

*\There are a lot of data missing for ER/PR status...going 
to see how many are missing from the centrally-collected data;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES delay_group*central_ER / LIST MISSING;
	TABLES delay_group*central_PR / LIST MISSING;
RUN;

*\There's still a fair amount missing

Per Jessica, if someones was weak positive/borderline for ER/PRSTAT variables
they were classified as missing for ER/PR. Let's look at ERSTAT and PRSTAT;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES delay_group*ERSTAT / LIST MISSING;
	TABLES delay_group*PRSTAT / LIST MISSING;
RUN;

*\Get chi square values for table 2;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES delay_group*reg_care / LIST CHISQ;
	TABLES delay_group*method_of_detection / LIST CHISQ;
	TABLES delay_group*symptoms / LIST CHISQ;
	TABLES delay_group*screencat / LIST CHISQ;
	TABLES delay_group*stage / LIST CHISQ;
	TABLES delay_group*estsize / LIST CHISQ;
	TABLES delay_group*grade / LIST CHISQ;
	TABLES delay_group*nodestat / LIST CHISQ;
	TABLES delay_group*ER / LIST CHISQ;
	TABLES delay_group*PR / LIST CHISQ;
	TABLES delay_group*path_HER2 / LIST CHISQ;
	TABLES delay_group*ERSTAT / LIST CHISQ;
	TABLES delay_group*PRSTAT / LIST CHISQ;
	WHERE delay_group IN (1,2,3,4);
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES P3D4B;
RUN;

*\Explore P53 subtype;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES P53_Subtype;
	TABLES P53_Subtype*days_delayed;
RUN;

*\Run same analysis ENB ran;

PROC GENMOD DATA=data.DELAYS_MERGED;
	CLASS P53_Subtype (REF='WT-like');
	MODEL P53_Subtype = days_delayed / DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\Add in adjustment set I found

age as a continuous variable (agesl)
race
regular care;

PROC GENMOD DATA=data.DELAYS_MERGED;
	CLASS P53_Subtype (REF='WT-like');
	MODEL P53_Subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\Adjustment changes to 5% (1%,10%), p<0.05

This is like saying "Experiencing diagnostic delay is associated with a 5% increase in probability 
of being P53 mutant type, regardless of age, race, or regular care."

I think race and regular care should be modeled as disjoint indicator variables;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES race reg_care;
RUN;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;
	LABEL raceAA = 'Race (1=AA, 0=non-AA)';
	LABEL racenonAA = 'Race (1=non-AA, 0=AA)';
	LABEL reg_care_Y = 'Had regular care (1=Y, 0=N)';
	LABEL reg_care_N = 'No regular care (1=N, 0=Y)';

	IF race = 1
	THEN raceAA = 0;
	ELSE raceAA = 1;

	IF race = 1
	THEN racenonAA = 1;
	ELSE racenonAA = 0;

	IF reg_care = 1
	THEN reg_care_N = 0;
	ELSE reg_care_N = 1;

	IF reg_care = 1
	THEN reg_care_Y = 1;
	ELSE reg_care_Y = 0;

RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES raceAA racenonAA reg_care_N reg_care_Y;
RUN;

*\Looks good!;

PROC GENMOD DATA=data.DELAYS_MERGED;
	CLASS P53_Subtype (REF='WT-like');
	MODEL P53_Subtype = days_delayed agesel raceAA racenonAA reg_care_N reg_care_Y/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\compare to model without disjoint indicator vars;

PROC GENMOD DATA=data.DELAYS_MERGED;
	CLASS P53_Subtype (REF='WT-like');
	MODEL P53_Subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\Okay these are basically the same lol

Look at P53 within each age group

50yrs & older;

PROC GENMOD DATA=data.DELAYS_MERGED;
	CLASS P53_Subtype (REF='WT-like');
	WHERE age_group = 0;
	MODEL P53_Subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\
RFD = 8.5% (1.6%,15.4%) p=0.0162

"Among those 50yrs and older, experiencing diagnostic delay is associated with an 8.5% increase 
in probability of being P53 mutant type, regardless of age, race, or regular care."

Younger than 50yrs;

PROC GENMOD DATA=data.DELAYS_MERGED;
	CLASS P53_Subtype (REF='WT-like');
	WHERE age_group = 1;
	MODEL P53_Subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\
RFD = 2.5% (-3.9%,8.9%) p=0.4411

What would this look like if we used the continuous scores for P53?;

PROC MEANS DATA=data.DELAYS_MERGED;
	VAR P53_score;
RUN;

PROC SGPLOT DATA=data.DELAYS_MERGED;
	HISTOGRAM P53_Score;
RUN;

PROC UNIVARIATE DATA=data.DELAYS_MERGED;
   VAR P53_Score;
   HISTOGRAM / NORMAL;
RUN;

*\So this is actually bimodal because of how the cutoffs are established,
meaning the negative scores are associated with that sample resembling wild-type
while positive scores are associated w mutant-like;

PROC UNIVARIATE DATA=data.DELAYS_MERGED;
   VAR P53_Score;
   WHERE P53_Subtype = 'Mut-like';
   HISTOGRAM / NORMAL;
RUN;

PROC UNIVARIATE DATA=data.DELAYS_MERGED;
   VAR P53_Score;
   WHERE P53_Subtype = 'WT-like';
   HISTOGRAM / NORMAL;
RUN;

*\I'm going to run a Gaussian mixture model...
I'll use PROC FMM (finitie mixture model) that indicates 2 peaks via K=2;

PROC FMM DATA=data.DELAYS_MERGED;
   MODEL P53_Score = days_delayed agesel race reg_care / DIST=NORMAL K=2;
RUN;

*\Look at ROR_PT;

PROC GENMOD DATA=data.DELAYS_MERGED;
	MODEL ROR_PT = days_delayed agesel race reg_care / DIST=NORMAL LINK=IDENTITY;
RUN;

