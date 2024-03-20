library Simple

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1'
 
codesystem LOINC : 'http://loinc.org' 

code UOP : '9187-6' from LOINC
code sCr : '2148-5' from  LOINC

context Patient 

/*
define AllObservations : [Observation]
define AllMedications : [Medication]
define AllMediationsAdmins : [MedicationAdministration]
*/

define scr_list : [Observation : sCr] O return FHIRHelpers.ToQuantity(O.value as Quantity).value
define scr : singleton from scr_list

define uop_list : [Observation : UOP] O return FHIRHelpers.ToQuantity(O.value as Quantity).value
define uop : singleton from uop_list

define rs_score : 

if uop >= 500 then
      case 
          when scr < 1.2 then 0
          when scr in Interval[1.2,1.9] then 1
          when scr in Interval[2.0,3.4] then 2
          when scr in Interval[3.5,4.9] then 3
          when scr  < 5 then 4 
          else -100
      end

else
      case
          when uop in Interval [200,499] then 3
          when uop in Interval [0,199] then 4 
          else -100 
      end 
