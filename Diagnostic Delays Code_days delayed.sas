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

Look at P53;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES nanostring*days_delayed / LIST;
	TABLES nanostring*age_group / LIST;
	TABLES nanostring*delay_group / LIST;
	TABLES P53_Subtype*days_delayed / LIST MISSING;
	TABLES P53_Subtype*delay_group / LIST;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED;
	CLASS P53_Subtype (REF='WT-like');
	MODEL P53_Subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

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

*\Make TNBC variable using where borderline/weak positive are combined w positives;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES ERSTAT PRSTAT path_HER2;
	TABLES ERSTAT*PRSTAT*PATH_HER2 / LIST MISSING;
RUN;

*\ 
TNBC = 577
Missing (any one of the 3 vars) = 30
Not TNBC = 2391;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;
	LABEL TNBC = '1 = TNBC, 0 = has some positive';

	IF (ERSTAT = 2 AND PRSTAT = 2 AND PATH_HER2 = 2)
	THEN TNBC = 1;

	ELSE IF (ERSTAT = . OR PRSTAT = . OR PATH_HER2 = .)
	THEN TNBC = .;

	ELSE TNBC = 0;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES TNBC;
	TABLES TNBC*days_delayed/ LIST MISSING;
	TABLES TNBC*days_delayed/ LIST CHISQ;
	TABLES TNBC*delay_group/ LIST MISSING;
	TABLES TNBC*delay_group/ LIST CHISQ;
RUN;

*\Investigate method of detection against the pt IDs who were marked as missing for delay;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES P3D4A;
	WHERE studyid IN (30569, 31394, 32626,
32956,
36146,
36465,
37598,
38170,
39215,
39765,
41789,
44165,
44451,
45001,
45430,
45782,
46640,
47432,
47608,
48312,
49808,
51073,
51799,
52767,
53680,
54747,
54780,
57860,
57937,
59719,
59994,
60742,
60775,
62667,
63800,
64097,
64856,
68299,
68662,
70334,
72930,
73194,
73931,
74316,
75713,
76835,
77308,
78914,
81587
);
RUN;

*\Merge dataset w insurance variables. Check random variable to confirm transfer;

PROC CONTENTS DATA=data.HASS_INSURANCE_053025;
RUN;

DATA data.DELAYS_MERGED;
	MERGE data.DELAYS_MERGED data.HASS_INSURANCE_053025;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES P3I2;
	TABLES P3I3A;
	TABLES P3I3B;
	TABLES P3I3C;
	TABLES P3I3D;
	TABLES P3I3E;
	TABLES P3I3F;
	TABLES P3I3A*P3I3B*P3I3C*P3I3D*P3I3E*P3I3F / LIST;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES P3I2*days_delayed;
	TABLES P3I3A*days_delayed;
	TABLES P3I3B*days_delayed;
	TABLES P3I3C*days_delayed;
	TABLES P3I3D*days_delayed;
	TABLES P3I3E*days_delayed;
	TABLES P3I3F*days_delayed;
RUN;


*\Create insurance variable w combos:
No insurance (P3I2 = 2)
Medicaid only (P3I3C = 1)
Medicare only (P3I3D = 1)
Medicare & Medicaid (P3I3C AND P3I3D = 1)
Medicare & Private (P3I3D AND (P3I3A OR P3I3B) = 1)
Private only (P3I3A OR P3I3B = 1)
(From Durham et al, 2016)

We'll set 'NA' to missing (P3I3F = 1)
We'll also make missing those who only said they have 'any other insurance
that covers part of their medical bills' (N=18);

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;
	LENGTH insurance $20;
	LABEL insurance = 'Insurance at time of survey';

	IF P3I2 = 2
	THEN insurance = 'No Insurance';

	ELSE IF P3I2 = 9
	THEN insurance = 'Missing';

	ELSE IF P3I3F = 1
	THEN insurance = 'Missing';

	ELSE IF (P3I3C = 1 OR (P3I3C = 1 AND P3I3E = 1)) AND P3I3A = 0 AND P3I3B = 0 AND P3I3D = 0 AND P3I3F = 0
	THEN insurance = 'Medicaid Only';

	ELSE IF (P3I3D = 1 OR (P3I3D = 1 AND P3I3E = 1)) AND P3I3A = 0 AND P3I3B = 0 AND P3I3C = 0 AND P3I3F = 0 	
	THEN insurance = 'Medicare Only';
	
	ELSE IF ((P3I3D = 1 AND P3I3C = 1) OR (P3I3D = 1 AND P3I3C = 1 AND P3I3E =1)) AND P3I3A = 0 AND P3I3B = 0 AND P3I3F = 0
	THEN insurance = 'Medicare & Medicaid';

	ELSE IF ((P3I3D = 1 AND P3I3B = 1) OR (P3I3D = 1 AND P3I3B = 1 AND P3I3E = 1) OR
	(P3I3D = 1 AND P3I3A = 1) OR (P3I3D = 1 AND P3I3A = 1 AND P3I3E = 1) OR (P3I3D = 1 AND P3I3B = 1 AND P3I3A = 1)) AND
	P3I3C = 0 AND P3I3F = 0
	THEN insurance = 'Medicare & Private';

	ELSE IF P3I3E = 1 AND P3I3A = 0 AND P3I3B = 0 AND P3I3C = 0 AND P3I3D = 0 AND P3I3F = 0
	THEN insurance = 'Other';

	ELSE IF ((P3I3B = 1) OR (P3I3B = 1 AND P3I3E =1) OR (P3I3A = 1) OR (P3I3A = 1 AND P3I3B = 1)) AND P3I3C = 0 AND P3I3D = 0 AND P3I3F = 0
	THEN insurance = 'Private only';

	ELSE insurance = 'Medicaid & Private';

RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES P3I2;
	TABLES P3I3A*P3I3B*P3I3C*P3I3D*P3I3E*P3I3F / LIST;
	TABLES insurance;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES insurance;
	TABLES insurance*days_delayed / LIST CHISQ;
RUN;

*\ROR_PT dichotomous scores, RFD overall by delay v no delay and then by delays w/in age groups;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES ROR_PT_Group;
RUN;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;
	LABEL ROR_PTbinom = "1 = high, 0 = low/intermediate";

	IF ROR_PT_Group IN ('low', 'med')
	THEN ROR_PTbinom = 0;

	ELSE IF ROR_PT_Group = 'high'
	THEN ROR_PTbinom = 1;

	ELSE ROR_PTbinom = .;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES ROR_PTbinom;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES ROR_PTbinom*days_delayed / LIST MISSING;
	TABLES ROR_PTbinom*delay_group / LIST MISSING;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	MODEL ROR_PTbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\RFD = 6.3% (2%, 10.6%);

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE age_group = 0;
	MODEL ROR_PTbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\
RFD = 7.3% (1.1%,13.5%)

"Among those 50yrs and older, experiencing diagnostic delay is associated with a 7.3% increase 
in probability of having a high ROR_PT score, regardless of age, race, or regular care."

Younger than 50yrs;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE age_group = 1;
	MODEL ROR_PTbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\
RFD = 5.2% (-0.82%,11.2%)

Look at PAM50 subtype;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES PAM50_Subtype;
	TABLES PAM50_Subtype*days_delayed / LIST;
	TABLES PAM50_Subtype*delay_group / LIST;
RUN;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;
	LABEL PAM50_Subtype_RFDbinom = '1 = basal-like 0 = luminal';

	IF PAM50_Subtype = 'Basal'
	THEN PAM50_Subtype_RFDbinom = 1;

	ELSE IF PAM50_Subtype IN ('LumA', 'LumB')
	THEN PAM50_Subtype_RFDbinom = 0;

	ELSE PAM50_Subtype_RFDbinom = .;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES PAM50_Subtype_RFDbinom;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	MODEL PAM50_Subtype_RFDbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE age_group = 0;
	MODEL PAM50_Subtype_RFDbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE age_group = 1;
	MODEL PAM50_Subtype_RFDbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES odx_category;
RUN;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;
	LABEL odx_binary = '1 = High 0 = Low/Intermediate';

	IF odx_category = 'High'
	THEN odx_binary = 1;

	ELSE IF odx_category IN ('Intermediate', 'Low')
	THEN odx_binary = 0;

	ELSE odx_category = .;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES odx_binary;
	TABLES odx_binary*days_delayed / LIST;
	TABLES odx_binary*delay_group / LIST;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	MODEL odx_binary = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE age_group = 0;
	MODEL odx_binary = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE age_group = 1;
	MODEL odx_binary = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\Explore Gaussian mixture models for OncotypeDX and ROR scores;

PROC UNIVARIATE DATA=data.DELAYS_MERGED;
	VAR odx_scaled_score;
	WHERE delay_group NE .;
RUN;

PROC SGPLOT DATA=data.DELAYS_MERGED;
	HISTOGRAM odx_scaled_score;
	WHERE delay_group NE .;
RUN;

*\This distribution is really just skewed right;

PROC UNIVARIATE DATA=data.DELAYS_MERGED;
	VAR days_detection;
RUN;

PROC SGPLOT DATA=data.DELAYS_MERGED;
	SCATTER X=odx_scaled_score Y=days_detection;
	YAXIS MIN=0 MAX=250;
RUN;

*\What if I transformed the scores to the log scale?;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;
	log_odxscores = log(odx_scaled_score);
RUN;

PROC SGPLOT DATA=data.DELAYS_MERGED;
	HISTOGRAM log_odxscores;
	WHERE delay_group NE .;
RUN;

*\That just made it left-skewed. Let's try square root;

DATA data.DELAYS_MERGED;
	SET data.DELAYS_MERGED;
	sqrt_odxscores = sqrt(odx_scaled_score);
RUN;

PROC SGPLOT DATA=data.DELAYS_MERGED;
	HISTOGRAM sqrt_odxscores;
	WHERE delay_group NE .;
RUN;

*\That seems relatively normal. Let's run that in a regression model;

ODS GRAPHICS ON;
PROC REG DATA=data.DELAYS_MERGED PLOTS=ALL;
	MODEL sqrt_odxscores = days_delayed agesel race reg_care;
RUN; 
ODS GRAPHICS OFF;

PROC SGPLOT DATA=data.DELAYS_MERGED;
	VBOX sqrt_odxscores / CATEGORY=days_delayed;
RUN;

*\What if I ran the exposure (days delayed) as a continuous variable?;

ODS GRAPHICS ON;
PROC REG DATA=data.DELAYS_MERGED PLOTS=ALL;
	MODEL sqrt_odxscores = days_detection agesel race reg_care;
RUN; 
ODS GRAPHICS OFF;

PROC SGPLOT DATA=data.DELAYS_MERGED;
	REG Y=sqrt_odxscores X=days_detection;
RUN;

*\Because there are some extreme values for days_detection, what if we restricted to 360 days or less?;

ODS GRAPHICS ON;
PROC REG DATA=data.DELAYS_MERGED PLOTS=ALL;
	MODEL sqrt_odxscores = days_detection agesel race reg_care;
	WHERE days_detection <= 365;
RUN; 
ODS GRAPHICS OFF;

PROC SGPLOT DATA=data.DELAYS_MERGED;
	REG Y=sqrt_odxscores X=days_detection;
	WHERE days_detection <= 365;
RUN;

*\Let's look at contour plots;

PROC GCONTOUR DATA=data.DELAYS_MERGED;
	PLOT days_detection*agesel = odx_scaled_score;
	WHERE days_detection <= 75;
RUN;

*\Too many empty cells

Pivoting to look at the women who fell into the 40-49yr bucket
diagnosed prior to November 2009;

PROC CONTENTS DATA=data.HASS_DIAGNOSIS_061025;
RUN;

PROC SORT DATA=data.DELAYS_MERGED;
	BY STUDYID;
RUN;

PROC SORT DATA=data.HASS_DIAGNOSIS_061025;
	BY STUDYID;
RUN;

DATA data.DELAYS_MERGED;
	MERGE data.DELAYS_MERGED data.HASS_DIAGNOSIS_061025;
	BY STUDYID;
RUN;

PROC FREQ DATA=data.DELAYS_MERGED;
	TABLES Bef_Nov09;
	TABLES Bef_Nov09_4049;
	WHERE days_delayed NE .;
RUN;

*\Run analysis with by these two variables;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	MODEL PAM50_Subtype_RFDbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09 = 1;
	MODEL PAM50_Subtype_RFDbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09 = 0;
	MODEL PAM50_Subtype_RFDbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09_4049 = 1;
	MODEL PAM50_Subtype_RFDbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09_4049 = 0;
	MODEL PAM50_Subtype_RFDbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\Nothing seems significant here...Let's look at P53;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	MODEL P53_subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09 = 1;
	MODEL P53_subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09 = 0;
	MODEL P53_subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09_4049 = 1;
	MODEL P53_subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09_4049 = 0;
	MODEL P53_subtype = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\The last model does have a significant value for the days_delayed beta.
Based on this model, women who did NOT fall into the category of being between 40 and 49 diagnosed prior to November 2009
were associated with a decreased probability of being P53 wild type (protective);

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	MODEL ROR_PTbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09 = 1;
	MODEL ROR_PTbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09 = 0;
	MODEL ROR_PTbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09_4049 = 1;
	MODEL ROR_PTbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09_4049 = 0;
	MODEL ROR_PTbinom = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\The second and fourth models contain significant values for the days_delayed beta in terms of 
actually being associated with a slight increase in probability of having a high ROR_PT score (harmful).
Both of these models are looking at the women who were either diagnosed after Nov 2009
or were not 40-49yrs diagnosed prior to Nov 2009;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	MODEL odx_binary = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09 = 1;
	MODEL odx_binary = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09 = 0;
	MODEL odx_binary = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09_4049 = 1;
	MODEL odx_binary = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

PROC GENMOD DATA=data.DELAYS_MERGED DESCENDING;
	WHERE Bef_Nov09_4049 = 0;
	MODEL odx_binary = days_delayed agesel race reg_care/ DIST=BINOMIAL LINK=IDENTITY;
RUN;

*\Similarly, the second and fourth models are significant with respect to the beta for days_delayed
showing a harmful association. AGainm both of these models are looking at the women who were either diagnosed after Nov 2009
or were not 40-49yrs diagnosed prior to Nov 2009; 