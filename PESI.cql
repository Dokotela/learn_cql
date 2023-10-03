
/* 
PESI = 

        //EPI
        AGE_IN_YEARS +
        GENDER = MALE 10 + 

        //CMBD
        CANCER = TRUE 30 +
        HF = TRUE 10 +
        COPD = TRUE 10 + 
        DELRIUM = TRUE 60 + 

        //PHYS
        HR >= 110 20  +
        SBP < 100 30 + 
        RR > 30 20 + 
        T < 36 20 + 
        SaO2 < 90 20 + 

  
*/ 


Define "Inpt Encounter" :
        ["Encounter, Preformed" : "Inpatient Encounter Codes"]
"Inpt Encounter" Encounter 
   where Encounter.relevantPeriod during "Measurement Period"

