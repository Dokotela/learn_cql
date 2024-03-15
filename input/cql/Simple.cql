library Simple

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1'

valueset Medications : 'http://hl7.org/fhir/ValueSet/medication-codes'
 
codesystem SNOMEDCT : 'http://snomed.info/sct' version '2024-03'

code MAP : '1285244000' from SNOMEDCT
code Dobutamine : '372687004' from SNOMEDCT 

context Patient

define map_list : [Observation: MAP] P          //This returns a list of MAP values 
    return 
       
      FHIRHelpers.ToQuantity(P.value).value       
define map : singleton from map_list            //This gets the only element, works in this context since file has one value 

define map_score : 
      case 
          when map >= 70 then 0
          when map < 70 then 1 
          else 'error'
      end 



define dobutamine_list : [MedicationAdministration: Dobutamine] M

      
         return FHIRHelpers.ToQuantity(M.dosage.dose).value


define dobutamine_dose : singleton from dobutamine_list 

//define "dopamine" : [Medication :  ]

//define "epi" : 

//define "norepi" : 

/*
define "pressor_score" : 
        case
            when dobutamine_dose > 0 then 1
            else 0  



define "cvs_score" : 
        case 
          map >= 70 then 0
          map < 70 and pressor_score = 0 then 1 
          map < 70 and pressor_score > 0 then 1 + pressor_score 

          else 'error'
        end 

*/




      
    




