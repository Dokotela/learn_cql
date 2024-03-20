library sofa version '1.0.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1'

codesystem LOINC : 'http://loinc.org' 

//basic codes for signs/symptoms

code GCS : '9269-2' from LOINC 

code MAP : '8478-0' from LOINC
code Dobutamine : '21248-0' from LOINC
code Dopamine : '21249-8' from LOINC
code Epinephrine : '21250-6' from LOINC
code Norepinephrine : '21251-4' from LOINC

code PF_ratio : '50982-8' from LOINC
code PEEP : '20075-8' from  LOINC

code Plts : '5379-3' from LOINC
code T_bili : '33898-8' from  LOINC

code UOP : '9187-6' from LOINC
code sCr : '2148-5' from  LOINC


context Patient 

 
//CNS score 
define gcs_list : [Observation: GCS] G            //This returns a list of GCS values from observation (obs)
    return 
      FHIRHelpers.ToQuantity(G.value).value
      
define gcs : singleton from gcs_list               //This gets the only element, works in this context since obs has one value 
define cns_score :                                 //calculates GCS score from SOFA 
        case 
        when gcs >= 15 then 0
        when gcs in Interval[13,14] then 1
        when gcs in Interval[10,12] then 2 
        when gcs in Interval[7,9] then 3 
        when gcs <= 6 then 4 
        else 'error'
      end


//CVS score 

define map_list : [Observation: MAP] P return FHIRHelpers.ToQuantity(P.value).value       
define map : singleton from map_list            


define map_score : 
      case 
          when map < 70 then 1 
          else 0
      end 



define dobutamine_list : [MedicationAdministration: Dobutamine] M return FHIRHelpers.ToQuantity(M.dosage.dose).value

define dobutamine_dose : singleton from dobutamine_list 

define dopamine_list : [MedicationAdministration : Dopamine] M return FHIRHelpers.ToQuantity(M.dosage.dose).value

define dopamine_dose : singleton from dopamine_list

define epi_list : [MedicationAdministration : Epinephrine] M return FHIRHelpers.ToQuantity(M.dosage.dose).value

define epi_dose : singleton from epi_list

define "norepi" : [MedicationAdministration : Norepinephrine] M return FHIRHelpers.ToQuantity(M.dosage.dose).value

define norepi_dose : singleton from norepi


define pressor_score : 
        case
            when dobutamine_dose > 0 or dopamine_dose <= 5 then 1 
            when dopamine_dose > 5 or epi_dose < 0.1 or norepi_dose < 0.1  then 2 
            when dopamine_dose > 15 or epi_dose > 0.1 or norepi_dose > 0.1 then 3 
            else 0
        end


define cvs_score :  map_score + pressor_score

//PS score 

define pfr_list : [Observation: PF_ratio] O return FHIRHelpers.ToQuantity(O.value).value

define pfr : singleton from pfr_list

define peep_list : [Observation: PEEP] O return FHIRHelpers.ToQuantity(O.value).value

define peep : singleton from peep_list


define ps_score : 

    if peep = 0 then
              case 
                when pfr >= 400 then 0
                when pfr in Interval[300,399]  then 1
                when pfr in Interval[200,299] then 2
                else -100
              end
        else 
              case
                when pfr >= 400 then 0
                when pfr in Interval[300,399]  then 1
                when pfr in Interval[200,299] then 2
                when pfr in Interval [100,199] then 3
                when pfr in Interval [0,100] then 4
                else -100 
              end
        

//HS score (include coag and T bili)

define plts_list : [Observation : Plts] P return FHIRHelpers.ToQuantity(P.value as Quantity).value
define plts : singleton from plts_list

define tbili_list : [Observation : T_bili] O return FHIRHelpers.ToQuantity(O.value as Quantity).value
define tbili : singleton from tbili_list

define coag_score : 

      case 
          when plts >= 150 then 0
          when plts in Interval[100,149] then 1
          when plts in Interval[50,99] then 2
          when plts in Interval[20,49] then 3
          when plts  < 20 then 4 
          else -100
      end

define tbili_score : 

      case 
            when tbili < 1.2 then 0
            when tbili in Interval[1.2,1.9] then 1 
            when tbili in Interval[2.0,5.9] then 2 
            when tbili in Interval[6.0,11.9] then 3 
            when tbili > 12.0 then 4 
            else -100
        end 


//RS score

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
      
    


define SOFA : cns_score + cvs_score + ps_score + coag_score + tbili_score + rs_score


    




