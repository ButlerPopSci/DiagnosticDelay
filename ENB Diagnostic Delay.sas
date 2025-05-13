libname data "C:\Users\ebonee\OneDrive - University of North Carolina at Chapel Hill\Grants\R01 Diagnostic Delay\Aim 2 Preliminary Data";

DATA data1;
	SET data.delays ;
RUN;

DATA data2;
	SET data.hass_extra_042325 ;
RUN;

proc sort data=data1; by studyid; run;
proc sort data=data2; by studyid; run;

data dxdelay;
    merge data1(in=a) data2(in=b);
    by studyid;
    if a and b; /* keeps only matched records; change as needed */
run;


*1. Create DX Delay categorical variable using cutpoint of 60 days.;

data dxdelay;
set dxdelay;
if 0 <= days_detection <= 60 then dxdelay_categorical = 0;
if days_detection > 60 then dxdelay_categorical = 1;
if days_detection = . then dxdelay_categorical = .;
run;

proc freq data=dxdelay;
tables dxdelay_categorical;
run;

*2. Prepare additional categorical variables for Table anlayses.;


data dxdelay;
set dxdelay;

*age_group;
label age_group = "50 and older (0) and LT 50 (1)";

if agesel < 50
then age_group = 1;

if agesel >= 50
then age_group = 0;

*income20k;
label income20k = "Income levels based on 20k";

if income in (0,1,2,3)
then income20k = 0;

if income in (4,5)
then income20k = 1;

if income in (6,7)
then income20k = 2;

else if income = .
then income20k = .;

*education;

LABEL education = "Binary any college (0) or more and then hs or less (1)";

IF EDUC IN (1,2,3,4)
THEN education = 1;

IF EDUC IN (5,6,7)
THEN education = 0;

ELSE IF EDUC = .
THEN education = .;

*haas_method_detect;
LABEL haas_method_detect = "Method of detection (Haas)"; *clincal vs. symptomatic or incidental;

IF P3D4A IN (1,2)
THEN haas_method_detect = 1;

ELSE IF P3D4A IN (3,4,5)
THEN haas_method_detect = 2;

ELSE IF P3D4A = 6
THEN haas_method_detect = 3;

*odx_category_binary;
if odx_category in ("Low", "Intermediate") then odx_category_binary = 0;
if odx_category in ("High") then odx_category_binary = 1;

*ROR_PT_Group_binary;
if ROR_PT_Group in ("low", "med") then ROR_PT_Group_binary = 0;
if ROR_PT_Group in ("high") then ROR_PT_Group_binary = 1;

*Conceptual Figure;
if dxdelay_categorical = 0 and age_group = 1 then concept =1;
if dxdelay_categorical = 1 and age_group = 1 then concept =2;
if dxdelay_categorical = 0 and age_group = 0 then concept =3;
if dxdelay_categorical = 1 and age_group = 0 then concept =4;

*Luminal Type;
if PAM50_Subtype in ('LumA', 'LumB') then luminal_type = 1;
if PAM50_Subtype in ('Basal') then luminal_type = 0;


run;

proc freq data=dxdelay;
tables dxdelay_categorical*(age_group income20k education haas_method_detect);
run;

proc freq data=dxdelay;
tables dxdelay_categorical*(IHC_SUBTYPE Immune_Class_LCA HRD)/chisq;
run;

proc contents data=dxdelay; run;

*3. [] ;


*TABLE 1;

proc freq data=dxdelay;
    *tables dxdelay_categorical*(PAM50_Subtype IHC_SUBTYPE ROR_PT_Group odx_category) / list;
	*tables dxdelay_categorical*age_group*PAM50_Subtype/list chisq;
	tables age_group race income20k education/list;
	tables dxdelay_categorical*(age_group race income20k education haas_method_detect reg_care screencat)/chisq;
	where dxdelay_categorical in (0,1);
run;

PROC FREQ data=dxdelay;
	TABLES age_group/MISSING;
	TABLES race/MISSING;
	TABLES income20k/MISSING;
	TABLES education/MISSING;
	TABLES P3D4A/MISSING;
	TABLES haas_method_detect/MISSING;
	TABLES reg_care/MISSING;
	TABLES screencat/MISSING;
	TABLES symptoms/MISSING;
		where dxdelay_categorical in (0,1);
RUN;

*Table 2;
proc freq data=dxdelay;
tables concept*haas_method_detect/list;
tables concept*reg_care/list;
tables concept*symptoms/list;
tables concept*screencat/list missing;
run;



*RFD;

*P53;
proc genmod data=dxdelay;
  class P53_SUBTYPE (ref='WT-like');
  model P53_SUBTYPE = dxdelay_categorical / dist=binomial link=identity;
run;

proc genmod data=dxdelay;
  class P53_SUBTYPE (ref='WT-like');
  where age_group = 0;
  model P53_SUBTYPE = dxdelay_categorical / dist=binomial link=identity;
run;

proc genmod data=dxdelay;
  class P53_SUBTYPE (ref='WT-like');
  where age_group = 1;
  model P53_SUBTYPE = dxdelay_categorical / dist=binomial link=identity;
run;

*****;
proc genmod data=dxdelay;
  class P53_SUBTYPE (ref='WT-like') race haas_method_detect;
  model P53_SUBTYPE = dxdelay_categorical agesel race haas_method_detect/ dist=binomial link=identity;
run;



*OncotypeDX;
proc genmod data=dxdelay;
  class odx_category_binary (ref='0');
  model odx_category_binary = dxdelay_categorical / dist=binomial link=identity;
run;

proc genmod data=dxdelay;
  class odx_category_binary (ref='0');
  where age_group = 0;
  model odx_category_binary = dxdelay_categorical / dist=binomial link=identity;
run;

proc genmod data=dxdelay;
  class odx_category_binary (ref='0');
  where age_group = 1;
  model odx_category_binary = dxdelay_categorical / dist=binomial link=identity;
run;
*****;
proc genmod data=dxdelay;
  class odx_category_binary (ref='0') race haas_method_detect;
  model odx_category_binary = dxdelay_categorical agesel race haas_method_detect/ dist=binomial link=identity;
run;

*ROR_PT_Group_binary;
proc genmod data=dxdelay;
class ROR_PT_Group_binary (ref='0');
model ROR_PT_Group_binary = dxdelay_categorical / dist=binomial link=identity;
run;

proc genmod data=dxdelay;
class ROR_PT_Group_binary (ref='0');
where age_group = 0;
model ROR_PT_Group_binary = dxdelay_categorical / dist=binomial link=identity;
run;

proc genmod data=dxdelay;
class ROR_PT_Group_binary (ref='0');
where age_group = 1;
model ROR_PT_Group_binary = dxdelay_categorical / dist=binomial link=identity;
run;

*PAM50;
proc genmod data=dxdelay;
class PAM50_Subtype (ref='LumA');
model PAM50_Subtype = dxdelay_categorical / dist=binomial link=identity;
run;

proc freq data=dxdelay;
tables PAM50_Subtype/list;
run;

proc genmod data=dxdelay;
class luminal_type (ref='1');
model luminal_type = dxdelay_categorical / dist=binomial link=identity;
run;

proc genmod data=dxdelay;
class luminal_type (ref='1');
where age_group = 0;
model luminal_type = dxdelay_categorical / dist=binomial link=identity;
run;

proc genmod data=dxdelay;
class luminal_type (ref='1');
where age_group = 1;
model luminal_type = dxdelay_categorical / dist=binomial link=identity;
run;
























*Figures;
proc freq data=dxdelay;
tables concept;
run;

proc contents data=dxdelay; run;

data dxdelay_sort;
set dxdelay;
run;

proc sort data=dxdelay_sort;
by concept;
run;

proc means data=dxdelay_sort;
var ROR_PT;
by concept;
run;

proc means data=dxdelay_sort;
var P53_Score;
by concept;
run;

proc means data=dxdelay_sort;
var odx_scaled_score;
by concept;
run;


































































PROC FREQ DATA=data.DELAYS_NANO;
	TABLES age_group/MISSING;
	TABLES race/MISSING;
	TABLES income20k/MISSING;
	TABLES education/MISSING;
	TABLES P3D4A/MISSING;
	TABLES haas_method_detect/MISSING;
	TABLES reg_care/MISSING;
	TABLES screencat/MISSING;
	TABLES symptoms/MISSING;
RUN;








PROC PRINT DATA=dxdelay;
RUN;

*\Look at distribution of Black (2) and non-Black (1) and then by age;

PROC FREQ DATA=data.DELAYS;
	TABLES race / NOCUM;
	TABLES strata;
RUN;

*\ non_black = 1503
Black = 1495

111 Non-Black less than 50 = 751
112 Non-Black 50 and older = 752
113 Black less than 50 = 741
114 Black 50 and older = 754

Look at age at diagnosis;

PROC FREQ DATA=data.DELAYS;
	TABLES agesel;
RUN;

*\Create new variable for 50 and older (0, referent) and less than 50 (1, index);

DATA data.DELAYS;
	SET data.DELAYS;
	LABEL age_group = "50 and older (0) and LT 50 (1)";

	IF agesl < 50
	THEN age_group = 1;

	IF agesel >= 50
	THEN age_group = 0;
RUN;

PROC FREQ;
	TABLES age_group;
RUN;

*\Younger than 50yrs = 1492
50yrs and older = 1506

*\Look at distribution of method of detection;

PROC FREQ DATA=data.DELAYS;
	TABLES P3D4A / MISSING;
	TABLES P3D4B / MISSING;
RUN;

*\No missing data here. yay!

*\Use Matt Dunn Code from mode of detection baseline survey question D4a;

DATA data.DELAYS;
SET data.DELAYS; 
LABEL dunn_detect = "Method of detection (dunn)"; 

IF (P3D4A = 1 OR P3D4A = 2 OR P3D4A = 4) THEN dunn_detect = 1 ;  *Lump detected ; 
ELSE IF P3D4A = 3 THEN dunn_detect = 0 ; *Routine Mammogram;
ELSE dunn_detect = 2; 
LENGTH dunn_detect2 $100;
IF dunn_detect=1 THEN dunn_detect2 = "Lump found" ;
ELSE if dunn_detect = 0 THEN dunn_detect2 = "Routine Mammogram" ;
ELSE dunn_detect2 = "Other" ; 

RUN;

*\Check detect variable;

PROC FREQ DATA= data.DELAYS;
	TABLES dunn_detect;
RUN; 

*\ Looks good
1548 had lump detected
1187 had routine mammogram
263 detected via ultrasound & other

*\Create new variable for method of detection
1 = lump outside healthcare system
2 = lump detected by healthcare provider
3 = radiographic detection
4 = other;

PROC FREQ DATA=data.DELAYS;
	TABLES P3D4A / MISSING;
	TABLES P3D4B / MISSING;
RUN;

DATA data.DELAYS;
	SET data.DELAYS;
	LABEL haas_method_detect = "Method of detection (Haas)";

	IF P3D4A IN (1,2)
	THEN haas_method_detect = 1;

	ELSE IF P3D4A = 4
	THEN haas_method_detect = 2;

	ELSE IF P3D4A IN (3,5)
	THEN haas_method_detect = 3;

	ELSE IF P3D4A = 6
	THEN haas_method_detect = 4;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES haas_method_detect;
RUN;

*\Looks good
1411 lump detected outside healthcare system
137 lump detected within healthcare system

*\Look at how method of detection varies by age, race, and then race*age;

PROC FREQ DATA=data.DELAYS;
	TABLES haas_method_detect*race / NOCOL NOROW;
	TABLES haas_method_detect*strata / NOCOL NOROW;
	TABLES haas_method_detect*age_group / NOCOL NOROW;
RUN;

*\As already understood in the literature, most younger people found lump while older people had mammogram/US; 

*\MDunn code for screening adherent/nonadherent;

DATA data.DELAYS;
SET data.DELAYS ; 
*Recode missingness for number of mammograms received after age 50, between 40-50, and before 40 ;

IF P3D10C = 99 THEN over50 = . ;
ELSE IF P3D10C = 98 THEN over50 = . ;
ELSE over50 = P3D10C ; 

IF P3D10B = 99 THEN btw4050 = . ;
ELSE IF P3D10B = 98 THEN btw4050 = . ;
ELSE btw4050 = P3D10B ; 

IF P3D10A = 99 THEN und40 = . ;
ELSE IF P3D10A = 98 THEN und40 = . ;
ELSE und40 = P3D10A ;

RUN ; 

DATA data.DELAYS;
SET data.DELAYS ;
*code how many screening mammograms someone received after age 40
	(screening mammograms conservatively defined by excluding any mammogram received in the 2 years prior 
	to diagnosis, to make sure diagnostic mammograms are not included; 
IF (P3D11 = . OR P3D11 = 99 OR agesel <45 OR btw4050 = . OR ( agesel >=50 AND over50 = . )) THEN over40screen = . ;
*Set as missing IF any of following
	1) missing # of mammograms between age 40 and 50
	2)  age 50 and older and missing number of mammograms after age 50
	3) missing number of mammograms received in 2 years before dx
	4) age less than 45 ; 
ELSE over40screen= (sum(over50, btw4050))- P3D11 ;
*number of screening mammograms = sum of bewteen 40-50 and 50+, subtracting mammograms received in 2 years before dx ;
yearsafter40=agesel-42 ;
*define number of years 'eligible' for screening mammogram: the time bewteen age 40 and the age at 2 years before dx ; 
mperyr1=over40screen/yearsafter40 ;
*calculate rate  mammograms/year;

IF mperyr1 = . THEN screencat=. ; 
ELSE IF mperyr1 = 0 THEN screencat=0; *never screened ;
ELSE IF 0 < mperyr1 <0.5 THEN screencat=1; *under-screened ; 
ELSE IF 0.5 <= mperyr1  THEN screencat=2; *screening-adherent ; 

IF screencat = 0 or screencat = 1 THEN screen = 1 ; *under-screened ; 
ELSE IF screencat = 2  THEN screen = 0 ; *screening-adherent ;
RUN ; 

PROC FREQ DATA=data.DELAYS;
	TABLES screencat;
RUN;

*\Look at regular care (Baseline questionnaire Question I6);

PROC FREQ DATA=data.DELAYS;
	TABLES P3I6A;
	TABLES P3I6B;
	TABLES P3I6C;
	TABLES P3I6D;
	TABLES P3I6E;
	TABLES P3I6F;
RUN;

*\Create regular care variables where
0 = No regular care and 1 = regular care.
Seeing a gen practitioner or specialist indicates had regular care.
Utilizing ER/urgent care, local health dept, or other indicates no regular care;

DATA data.DELAYS;
	SET data.DELAYS;
	LABEL reg_care = "Had Regular Care (0=N 1=Y)";

	IF (P3I6A OR P3I6B) = 1
	THEN reg_care = 1;

	IF (P3I6C OR P3I6D OR P3I6E OR P3I6F) = 1
	AND (P3I6A OR P3I6B) = 0
	THEN reg_care = 0;

RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES reg_care;
RUN;

*\Look at all those with symptoms;

PROC FREQ DATA=data.DELAYS;
	TABLES P3D5A*P3D5B*P3D5C*P3D5D / LIST;
RUN;

*\No symptoms = 1992
Had symptoms = 1006;

DATA data.DELAYS;
	SET data.DELAYS;
	LABEL symptoms = "Had symptoms at dx (1=Y 0=N)";

	IF P3D5A = 1
	THEN symptoms = 1;

	ELSE IF P3D5B = 1
	THEN symptoms = 1;

	ELSE IF P3D5C = 1
	THEN symptoms = 1;

	ELSE IF P3D5D = 1
	THEN symptoms = 1;

	ELSE symptoms = 0;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES symptoms;
RUN;

*\Look at those on whom we have nanostring data;

PROC FREQ DATA=data.DELAYS;
	TABLES SAMPLEID;
RUN;

*\Missing data on 1029 participants. Have on 1969 participants.;

DATA data.DELAYS;
	SET data.DELAYS;
	LABEL nanostring = "Nanostring data available (Y/N)";

	IF SAMPLEID = ""
	THEN nanostring = "N";

	ELSE nanostring = "Y";
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES nanostring / MISSING;
RUN;

*\ Look at gene expression data (ESR1, PGR, ERBB2);

PROC MEANS DATA=data.DELAYS;
	VAR ESR1 PGR ERBB2;
RUN;

*\Also only have this on 1969 participants

Look at distribution of race & age among these participants (n=1969);

PROC FREQ DATA=data.DELAYS;
	TABLES race;
	TABLES strata;
	TABLES age_group;

	WHERE nanostring = "Y";
RUN;

*\Things still seem relatively even

Create new dataset with just these participants;

DATA data.delays_nano;
	SET data.DELAYS;
	WHERE nanostring = "Y";
RUN;

*\Look at PAM50 subtypes within those with nanostring data;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES PAM50_Subtype;
RUN;

*\Check on distribution of proliferation and ROR scores;

PROC MEANS DATA=data.DELAYS_NANO;
	VAR ROR_S Proliferation_Score ROR_P ROR_T ROR_PT;
RUN;

PROC SGPLOT DATA=data.DELAYS_NANO;
	HISTOGRAM Proliferation_Score;
	XAXIS LABEL='Proliferation Score';
	YAXIS LABEL='Count';
RUN;

PROC SGPLOT DATA=data.DELAYS_NANO;
	HISTOGRAM ROR_P;
	XAXIS LABEL='ROR Score + Proliferation Score';
	YAXIS LABEL='Count';
RUN;

PROC SGPLOT DATA=data.DELAYS_NANO;
	HISTOGRAM ROR_S;
	XAXIS LABEL='ROR Score + Subtype';
	YAXIS LABEL='Count';
RUN;

PROC SGPLOT DATA=data.DELAYS_NANO;
	HISTOGRAM ROR_T;
	XAXIS LABEL='ROR Score + Tumor Size';
	YAXIS LABEL='Count';
RUN;

PROC SGPLOT DATA=data.DELAYS_NANO;
	HISTOGRAM ROR_PT;
	XAXIS LABEL='ROR Score + Size + Proliferation Score';
	YAXIS LABEL='Count';
RUN;

*\Proliferation seems a bit more shifted right than centered but I think this is probably close enough?
Most of these plots seem to be roughly right skewed as well but still relatively normal.

*\Look at proliferation scores by method of detection;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES method_detect*Proliferation_Score;
RUN;

*\Yikes. Can I collapse these? TBD...

Make dummy variables for method of detection (all levels). Level not
included in the model will be the referent.
Starting with dunn variable;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES dunn_detect;
RUN;

DATA data.DELAYS_NANO;
	SET data.DELAYS_NANO;
	LABEL lump = "Lump detected";
	LABEL mammo = "Cancer found via mammogram";
	LABEL method_detect_other = "Cancer detected in another way";
	
	IF dunn_detect = 1
	THEN lump = 1;
	ELSE lump = 0;

	IF dunn_detect = 0
	THEN mammo = 1;
	ELSE mammo = 0;

	IF dunn_detect = 2
	THEN method_detect_other = 1;
	ELSE method_detect_other = 0;
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES lump;
	TABLES mammo;
	TABLES method_detect_other;
RUN;

*\Haas detect variable;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES haas_method_detect;
RUN;

DATA data.DELAYS_NANO;
	SET data.DELAYS_NANO;
	LABEL lumpathome = "Lump detected at home";
	LABEL lumpatdoc = "Lump found in clinical setting";
	LABEL mammoUS = "Cancer found radiographically";
	LABEL detect_other = "Cancer detected in another way";
	
	IF haas_method_detect = 1
	THEN lumpathome = 1;
	ELSE lumpathome = 0;

	IF haas_method_detect = 2
	THEN lumpatdoc = 1;
	ELSE lumpatdoc = 0;

	IF haas_method_detect = 3
	THEN mammoUS = 1;
	ELSE mammoUS = 0;

	IF haas_method_detect = 4
	THEN detect_other = 1;
	ELSE detect_other = 0;
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES lumpathome;
	TABLES lumpatdoc;
	TABLES mammoUS;
	TABLES detect_other;
RUN;

*\Run regression to look at proliferation score as outcome
lump detected via mammogram or ultrasound is referent group;

PROC GENMOD DATA=data.DELAYS_NANO;
	MODEL Proliferation_score= lumpathome lumpatdoc detect_other / LINK=IDENTITY DIST=NORMAL;
	TITLE "Regression of proliferation score on method of detection (REF=mammoUS)";
RUN;

*\Need to look at residuals and check assumptions;

PROC REG DATA=data.DELAYS_NANO;
	MODEL Proliferation_score= lumpathome lumpatdoc detect_other;
	OUTPUT OUT=residuals RESIDUAL=residual PREDICTED=fitted COOKD=cooksd;
RUN;

*\Per ANOVA there is definitely something going on here;

PROC SGPLOT DATA=residuals;
	SCATTER X=fitted Y=residual;
	LOESS X=fitted Y=residual;
	REFLINE 0 / AXIS=Y;
	XAXIS LABEL="Fitted Values";
	YAXIS LABEL="Residuals";
	TITLE "Plot of Residuals v Fitted Values";
RUN;

*\Okay this is not what I needed to do lol (or maybe it was and I need to adjust). I will look at my 716 stuff and see how I evaluated things;


*\Try running code for looking at proliferation score by method of detection, controlling for age and stage at diagnosis and race;

PROC GENMOD DATA=data.DELAYS_NANO;
	MODEL Proliferation_score= lumpathome lumpatdoc detect_other agesel stage race / LINK=IDENTITY DIST=NORMAL;
RUN;

PROC REG DATA=data.DELAYS_NANO;
	MODEL Proliferation_score= lumpathome lumpatdoc detect_other agesel stage race;
	OUTPUT OUT=residuals RESIDUAL=residual PREDICTED=fitted;
RUN;

PROC SGPLOT DATA=residuals;
	SCATTER X=fitted Y=residual;
	LOESS X=fitted Y=residual;
	REFLINE 0 / AXIS=Y;
	XAXIS LABEL="Fitted Values";
	YAXIS LABEL="Residuals";
	TITLE "Plot of Residuals v Fitted Values";
RUN;

*\This looks pretty homoscedastic;

*\RUn regression of ROR+P on method of detection;

PROC GENMOD DATA=data.DELAYS_NANO;
	MODEL ROR_P= lumpathome lumpatdoc detect_other / LINK=IDENTITY DIST=NORMAL;
	TITLE "Regression of ROR + proliferation score on method of detection (REF: MammoUS)";
RUN;

*\Need to look at residuals and check assumptions;

PROC REG DATA=data.DELAYS_NANO;
	MODEL ROR_P= lumpathome lumpatdoc detect_other;
	OUTPUT OUT=residuals RESIDUAL=residual PREDICTED=fitted COOKD=cooksd;
RUN;

*\Add in confounders of race, stage, age;

PROC GENMOD DATA=data.DELAYS_NANO;
	MODEL ROR_P= lumpathome lumpatdoc detect_other agesel stage race/ LINK=IDENTITY DIST=NORMAL;
	TITLE "Regression of ROR + proliferation score on method of detection (REF: MammoUS)";
RUN;

*\Use same model as above but instead of agesl and race, use the strata for race&age.
Estimate effect measures

111=NonAA age<50
112 = NonAA age 50+
113 = AA age <50
114 = AA age 50+

I'm just not sure if these are really interpretable since I have a continuous outcome;

PROC GENMOD DATA=data.DELAYS_NANO;
	MODEL ROR_P= lumpathome lumpatdoc detect_other STRATA stage / LINK=IDENTITY DIST=NORMAL;
	TITLE "Regression of ROR + proliferation score on method of detection (REF: MammoUS)";
	ESTIMATE 'Risk for nonAA age<50' int 1 STRATA 111;
	ESTIMATE 'Risk for AA age<50' int 1 STRATA 113;
	ESTIMATE 'Risk for nonAA age 50+' int 1 STRATA 112;
	ESTIMATE 'Risk for AA age 50+' int 1 STRATA 114;
RUN;

*\Try running ordinal logistic regression using ROR_P_GROUP;

PROC LOGISTIC DESCENDING DATA=data.DELAYS_NANO;
	CLASS haas_method_detect / PARAM=REFERENCE REF=FIRST;
	MODEL ROR_P_Group = haas_method_detect / SCALE=NONE AGGREGATE;
RUN;

*\Yikes need to come back to this. IDK how to interpret/if I even can;

*\Attempt heat maps;

PROC SGPLOT DATA=data.DELAYS_NANO;
	HEATMAPPARM X=agesel Y=haas_method_detect COLORRESPONSE=Proliferation_score / COLORMODEL=(white blue);
	XAXIS VALUES=(20 25 30 35 40 45 50 55 60 65 70 75) LABEL='Age at Diagnosis';
	YAXIS DISCRETEORDER=DATA LABEL='Method of Detection';
RUN;

*\Prolieration scores only range from -1.35 to 1.1 so maybe try an ROR score var;

PROC SGPLOT DATA=data.DELAYS_NANO;
	HEATMAPPARM X=agesel Y=haas_method_detect COLORRESPONSE=ROR_P / COLORMODEL=(white blue);
	XAXIS VALUES=(20 25 30 35 40 45 50 55 60 65 70 75) LABEL='Age at Diagnosis';
	YAXIS DISCRETEORDER=DATA LABEL='Method of Detection';
RUN;

*\This is just not very intuitive

Maybe break this up into 4 groups:
1: >50 not delayed (doubly unexposed)
1: >50 delayed
2: <50 not delayed
3: <50 delayed (doubly exposed)

Maybe start with defining delay via method of detection 
Delayed = Lump detected or u/s or other
Not delayed = mammogram

Make new variables to represent these groups;

PROC FREQ DATA=data.DELAYS_nano;
	TABLES dunn_detect*age_group/LIST;
RUN;

DATA data.DELAYS_nano;
	SET data.DELAYS_nano;
	LABEL delayed = "4 Levels for age and delay where delay=lump";

	IF (dunn_detect=0 AND age_group=0)
	THEN delayed = 0;

	IF (dunn_detect=1 AND age_group=0)
	THEN delayed = 1;
	
	IF (dunn_detect=2 AND age_group=0)
	THEN delayed = 1;

	IF (dunn_detect=0 AND age_group=1)
	THEN delayed = 2;

	IF (dunn_detect=1 AND age_group=1)
	THEN delayed = 3;

	IF (dunn_detect=2 AND age_group=1)
	THEN delayed = 3;

RUN;
PROC FREQ DATA=data.DELAYS_NANO;
	TABLES delayed;
RUN;

*\Now try making heat maps with each variable separately using age as x and ROR_P as y;

PROC SGPLOT DATA=data.DELAYS_NANO;
	WHERE delayed = 0;
	HEATMAPPARM X=agesel Y=ROR_P COLORRESPONSE=ROR_P / COLORMODEL=(blue white) TRANSPARENCY=0.2;
	XAXIS VALUES=(50 to 75 by 5) LABEL='Age at Diagnosis';
	YAXIS LABEL='ROR_P';
RUN;

*\Okay, I need to make the bins smaller but when I try the NYBINS=100 thing it does not work help
Let's try a scatterplot for fun;

PROC SGPLOT DATA=data.DELAYS_NANO;
	SCATTER X=agesel Y=ROR_P / JITTER;
	XAXIS LABEL='Age at Diagnosis';
	YAXIS LABEL='ROR_P';
	TITLE 'Scatterplot of Age by ROR_P scores';
RUN;

*\There's a cluster of higher ROR_P scores in the 40-50 age range between ~25 and 75

Now that I have the delayed variable, let me try making dummy variables and running a linear regression

delayed0 = >50 not delayed
delayed1 = >50 delayed
delayed2 = <50 not delayed
delayed3 = <50 delayed (doubly exposed);

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES delayed;
RUN;

DATA data.DELAYS_NANO;
	SET data.DELAYS_NANO;
		
	IF delayed = 0
	THEN delayed0 = 1;

	ELSE IF delayed = .
	THEN delayed0 = .;

	ELSE delayed0 = 0;

	IF delayed = 1
	THEN delayed1 = 1;

	ELSE IF delayed = .
	THEN delayed1 = .;

	ELSE delayed1 = 0;

	IF delayed = 2
	THEN delayed2 = 1;

	ELSE IF delayed = .
	THEN delayed2 = .;

	ELSE delayed2 = 0;

	IF delayed = 3
	THEN delayed3 = 1;

	ELSE IF delayed = .
	THEN delayed3 = .;

	ELSE delayed3 = 0;
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES delayed0;
	TABLES delayed1;
	TABLES delayed2;
	TABLES delayed3;
RUN;

PROC GENMOD DATA=data.DELAYS_NANO;
	MODEL ROR_P = delayed1 delayed2 delayed3 / LINK=IDENTITY DIST=NORMAL;
	ESTIMATE 'Risk >50 Delayed' INT 1 delayed1 1;
	ESTIMATE 'RD >50 Delayed v >50 Not Delayed' INT 0 delayed1 1;
RUN;

*\How do I interpret this since my outcome is a continuous variable in terms of risk?

Same model but with race and stage (age is already a part of the 'delayed' variable;

PROC GENMOD DATA=data.DELAYS_NANO;
	MODEL ROR_P = delayed1 delayed2 delayed3 race stage/ LINK=IDENTITY DIST=NORMAL;
	ESTIMATE 'Risk >50 Delayed' INT 1 delayed1 1;
	ESTIMATE 'Risk <50 Not Delayed' INT 1 delayed2 1;
	ESTIMATE 'Risk <50 Delayed' INT 1 delayed3 1;
	ESTIMATE 'RD >50 Delayed v >50 Not Delayed' INT 0 delayed1 1;
	ESTIMATE 'RD <50 NOt Delayed v >50 Not Delayed' INT 0 delayed2 1;
	ESTIMATE 'RD <50 Delayed v >50 Not Delayed' INT 0 delayed3 1;
RUN;

*\ Add in regular care, screening category, and symptoms;

PROC GENMOD DATA=data.DELAYS_NANO;
	MODEL ROR_P = delayed1 delayed2 delayed3 race stage screencat reg_care symptoms/ LINK=IDENTITY DIST=NORMAL;
	ESTIMATE 'Risk >50 Delayed' INT 1 delayed1 1;
	ESTIMATE 'Risk <50 Not Delayed' INT 1 delayed2 1;
	ESTIMATE 'Risk <50 Delayed' INT 1 delayed3 1;
	ESTIMATE 'RD >50 Delayed v >50 Not Delayed' INT 0 delayed1 1;
	ESTIMATE 'RD <50 NOt Delayed v >50 Not Delayed' INT 0 delayed2 1;
	ESTIMATE 'RD <50 Delayed v >50 Not Delayed' INT 0 delayed3 1;
RUN;

*\Table 1 stuff

Make income20k var;

PROC FREQ DATA=data.DELAYS;
	TABLES income;
RUN;

*\Missing 159;

DATA data.DELAYS;
	SET data.DELAYS;
	LABEL income20k = "Income levels based on 20k";

	IF income IN (0,1,2,3)
	THEN income20k = 0;

	IF income IN (4,5)
	THEN income20k = 1;

	IF income IN (6,7)
	THEN income20k = 2;

	ELSE IF income = .
	THEN income20k = .;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES income20k;
RUN;

*\Education

Any college
HS grad/GED or less;

PROC FREQ DATA=data.DELAYS;
	TABLES EDUC;
RUN;

*\Missing 1;

DATA data.DELAYS;
	SET data.DELAYS;
	LABEL education = "Binary any college (0) or more and then hs or less (1)";

	IF EDUC IN (1,2,3,4)
	THEN education = 1;

	IF EDUC IN (5,6,7)
	THEN education = 0;

	ELSE IF EDUC = .
	THEN education = .;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES education;
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES age_group/MISSING;
	TABLES race/MISSING;
	TABLES income20k/MISSING;
	TABLES education/MISSING;
	TABLES P3D4A/MISSING;
	TABLES haas_method_detect/MISSING;
	TABLES reg_care/MISSING;
	TABLES screencat/MISSING;
	TABLES symptoms/MISSING;
RUN;

*\Copy delayed variabled over to main dataset

0: >50 not delayed (doubly unexposed)
1: >50 delayed
2: <50 not delayed
3: <50 delayed (doubly exposed)

Delayed = Lump detected or u/s or other
Not delayed = mammogram;

PROC FREQ DATA=data.DELAYS;
	TABLES dunn_detect*age_group/LIST;
RUN;

DATA data.DELAYS;
	SET data.DELAYS;
	LABEL delayed = "4 Levels for age and delay where delay=lump";

	IF (dunn_detect=0 AND age_group=0)
	THEN delayed = 0;

	IF (dunn_detect=1 AND age_group=0)
	THEN delayed = 1;
	
	IF (dunn_detect=2 AND age_group=0)
	THEN delayed = 1;

	IF (dunn_detect=0 AND age_group=1)
	THEN delayed = 2;

	IF (dunn_detect=1 AND age_group=1)
	THEN delayed = 3;

	IF (dunn_detect=2 AND age_group=1)
	THEN delayed = 3;

RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES delayed;
RUN;

*\Table 2;

PROC FREQ DATA=data.DELAYS;
	TABLES ESTSIZE*delayed/LIST;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES NODESTAT*delayed/LIST;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES STAGE*delayed/LIST;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES GRADE*delayed/LIST;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES ER*PATH_HER2*delayed/LIST;
RUN;

PROC FREQ DATA=data.DELAYS;
	TABLES race*delayed/LIST;
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES delayed;
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES PAM50_Subtype*delayed / NOCOL NOROW;
RUN;

*\Make binary variable for ROR_S and ROR_P;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES ROR_S_Group;
RUN;

DATA data.DELAYS_NANO;
	SET data.DELAYS_NANO;
	LABEL ROR_S_binary = "ROR_S Binary Group (0=low/med 1=high)";

	IF ROR_S_Group = "high"
	THEN ROR_S_binary = 1;
	ELSE ROR_S_binary = 0;
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES ROR_S_binary;
RUN;

*\Run logistic regression to find odds of having high ROR_S score
Not delayed >/= 50 is ref;

PROC GENMOD DATA=data.delays_nano DESCENDING;
	MODEL ROR_S_binary = delayed1 delayed2 delayed3 / LINK=LOG DIST=BINOMIAL;
	ESTIMATE "OR of High ROR_S score for Delayed >/=50" int 0 delayed1 1;
	ESTIMATE "OR of High ROR_S score for Not Delayed <50" int 0 delayed2 1;
	ESTIMATE "OR of High ROR_S score for Delayed <50" int 0 delayed3 1;
RUN;

*\Include regular care, screening adherent, symptoms;

PROC GENMOD DATA=data.delays_nano DESCENDING;
	MODEL ROR_S_binary = delayed1 delayed2 delayed3 symptoms reg_care screencat/ LINK=LOG DIST=BINOMIAL;
	ESTIMATE "OR of High ROR_S score for Delayed >/=50" int 0 delayed1 1;
	ESTIMATE "OR of High ROR_S score for Not Delayed <50" int 0 delayed2 1;
	ESTIMATE "OR of High ROR_S score for Delayed <50" int 0 delayed3 1;
RUN;














