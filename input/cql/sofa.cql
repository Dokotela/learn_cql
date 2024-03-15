library sofa version '1.0.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem LOINC : 'http://loinc.org' 

//basic codes for signs/symptoms

code GCS : '9269-2' from LOINC 

code MAP : '8478-0' from LOINC

code Plts : '26515-7' from LOINC

code Tbilli : '42719-5' from LOINC

code PfR : '50984-4' from LOINC
code PEEP : '20075-8' from LOINC

code sCr : '2160-0' from LOINC
code UOP : '9192-6' from LOINC

//?need codes for pressor use 

context Patient 
 
//GCS score 
define gcs_list : [Observation: GCS] G            //This returns a list of GCS values from observation (obs)
    return 
      FHIRHelpers.ToQuantity(G.value).value
      
define gcs : singleton from gcs_list               //This gets the only element, works in this context since obs has one value 
define "gcs_score" :                                 //calculates GCS score from SOFA 
        case 
        when gcs >= 15 then 0
        when gcs in Interval[13,14] then 1
        when gcs in Interval[10,12] then 2 
        when gcs in Interval[7,9] then 3 
        when gcs <= 6 then 4 
        else 'error'
      end
    




