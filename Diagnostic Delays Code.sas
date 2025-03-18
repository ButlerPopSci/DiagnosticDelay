libname data "C:\Users\ebhaa\OneDrive - University of North Carolina at Chapel Hill\Research\CBCS 3 Diagnostic Delays\SAS Dataset";

DATA data.delays;
	SET data.hass_cbcs3_031425;
RUN;

PROC PRINT DATA=data.DELAYS;
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

Look at those on whom we have nanostring data;

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

*\Look at distribution of method of detection;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES P3D4A / MISSING;
	TABLES P3D4B / MISSING;
RUN;

*\No missing data here. yay!
49% of these people found a lump themselves, 36% found via routine mammogram

Create new variable for method of detection
1 = lump (found by self, spouse, or provider)
2 = routine mammo or U/S
3 = other;


DATA data.DELAYS_NANO;
	SET data.DELAYS_NANO;
	LABEL method_detect = "Method of detection";

	IF P3D4A IN (1,2,4)
	THEN method_detect = 1;

	ELSE IF P3D4A IN (3,5)
	THEN method_detect = 2;

	ELSE IF P3D4A = 6
	THEN method_detect = 3;
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES method_detect;
RUN;


*\Look at how method of detection varies by age, race, and then race*age;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES method_detect*race / NOCOL NOROW;
	TABLES method_detect*strata / NOCOL NOROW;
	TABLES method_detect*age_group / NOCOL NOROW;
RUN;

*\As already understood in the literature, most younger people found lump while older people had mammogram/US; 

*\Look at distribution of symptoms at time of detection;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES P3D5A;
	TABLES P3D5B;
	TABLES P3D5C;
	TABLES P3D5D;
	TABLES P3D5E;
	TABLES P3D5F;

RUN;

*\Create new variable for those who experienced any symptoms;

DATA data.DELAYS_NANO;
	SET data.DELAYS_NANO;
	LABEL any_sx = "Had any symptoms at diagnosis (Y/N/NA)";

	IF (P3D5A = 1 OR P3D5B = 1 OR P3D5C = 1 OR P3D5D = 1)
	THEN any_sx = "Y";

	ELSE IF (P3D5A = 2 AND P3D5B = 2 AND P3D5C = 2 AND P3D5D = 2)
	THEN any_sx = "N";

	ELSE IF (P3D5A = 9 AND P3D5B = 9 AND P3D5C = 9 AND P3D5D = 9)
	THEN any_sx = "NA";
RUN;

PROC FREQ DATA=data.DELAYS_NANO;
	TABLES any_sx;
RUN;

DATA data.DELAYS_NANO_P3D5A;
	SET data.DELAYS_NANO;
	WHERE P3D5A = 9;
RUN;

*\ID 47432 should be NA for "any_sx" (has 9 for P3D5A - P3D5D) but is marked as "N" sos help;



	




