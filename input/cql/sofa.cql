library sofa version '1.0.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1'

codesystem MIMIC_MEDS: 'http://fhir.mimic.mit.edu/CodeSystem/medication-ndc'
codesystem MIMIC_OBS : 'http://fhir.mimic.mit.edu/CodeSystem/chartevents-d-items'
codesystem MIMIC_LABS: 'http://fhir.mimic.mit.edu/CodeSystem/d-labitems'
codesystem MIMIC_ITEMS :'http://fhir.mimic.mit.edu/CodeSystem/d-items'


code Total_Bilirubin : '50885' from MIMIC_LABS
code Platelets : '51265' from MIMIC_LABS


code GCS_Verbal :'223900' from MIMIC_OBS
code GCS_Eye : '220739' from MIMIC_OBS
code GCS_Motor: '223901' from MIMIC_OBS

code MAP : '220181' from MIMIC_OBS


code Dopamine: '00409910420' from MIMIC_MEDS
code Dobutamine: '55390056090' from MIMIC_MEDS
code Epinephrine: '42023015925' from MIMIC_MEDS
code Norepinephrine: '00409337504' from MIMIC_MEDS

code Creatinine : '50912' from MIMIC_LABS
code Foley : '226559' from MIMIC_ITEMS

code PEEP : '220339' from MIMIC_OBS
code PaO2  : '220224' from MIMIC_OBS
code FiO2  : '223835' from MIMIC_OBS



context Patient

//GCS 
define gcs_verbal : [Observation : GCS_Verbal]
define gcs_eye : [Observation : GCS_Eye] 
define gcs_motor : [Observation : GCS_Motor] 


define sofa_gcs: 
   from gcs_verbal v,
        gcs_eye    e,
        gcs_motor  m

    let 
        v_value   : v.value.value as decimal,
        e_value   : e.value.value as decimal, 
        m_value   : m.value.value as decimal,

        v_time    : v.effective,
        e_time    : e.effective,
        m_time    : m.effective,

        gcs       : v_value  + e_value + m_value,
        score     : sofa_score_gcs(gcs)

    where difference in hours between v_time and e_time = 0 and 
          difference in hours between e_time and m_time = 0 
          


return Tuple {score : score,  gcs : gcs,
              gcs_verbal : v_value, gcs_verbal_t : v_time, 
              gcs_eye : e_value, gcs_eye_t : e_time,
              gcs_motor : m_value, gcs_motor_t : m_time
              }


define function sofa_score_gcs (gcs Decimal) returns Integer :  
    case
    when gcs >= 15 then 0
    when gcs in Interval[13, 14]then 1
    when gcs in Interval[10, 12]then 2
    when gcs in Interval[7, 9]then 3
    when gcs <= 6 then 4 
    else -100 
    end

  //-------------------------------------------------------
  // CVS 

  define sofa_map: [Observation: MAP] O 
return  Tuple {score : sofa_map_score(O.value.value as decimal),
               map_value : O.value.value as decimal, 
               map_time : O.effective
               }


define dobutamine: [MedicationAdministration: Dobutamine] 
define dopamine: [MedicationAdministration: Dopamine]
define epi : [MedicationAdministration: Epinephrine]     
define norepi: [MedicationAdministration: Norepinephrine] 

define needs_dop : exists(dopamine)
define needs_dobut : exists(dobutamine)
define needs_epi : exists(epi)
define needs_norepi : exists(norepi)
define needs_pressors : needs_dop or needs_dobut or needs_epi or needs_norepi



define sofa_pressor:

    from
         dobutamine db,
         dopamine dp,
         epi e,
         norepi ne

    let 
        
        dopamine_dose : case when needs_dop then dp.dosage.dose.value else 0 end,
        dopamine_t    : case when needs_dop then dp.effective else null end,

        dobutamine_dose : case when needs_dobut then db.dosage.dose.value else 0 end,
        dobutamine_t    : case when needs_dobut then db.effective else null end,

        epi_dose : case when needs_epi then e.dosage.dose.value else 0 end,
        epi_t    : case when needs_epi then e.effective else null end,
        
        norepi_dose : case when needs_norepi then ne.dosage.dose.value else 0 end,
        norepi_t    : case when needs_norepi then ne.effective else null end,

        dopamine_score : case when needs_dop then sofa_dopamine_score(dopamine_dose) else 0 end,

        dobutamine_score : case when needs_dobut then sofa_dobutamine_score(dobutamine_dose) else 0 end,

        norepi_score : case when needs_norepi then sofa_epi_norepi_score(norepi_dose) else 0 end,

        epi_score : case when needs_epi then sofa_epi_norepi_score(epi_dose) else 0 end,

        pressor_score : Max({dopamine_score, dobutamine_score norepi_score, epi_score}),
        pressor_used : IndexOf({dopamine_score, dobutamine_score, norepi_score, epi_score}, pressor_score),
        pressor_t : case pressor_used
                    when 0 then dopamine_t
                    when 1 then dobutamine_t
                    when 2 then norepi_t
                    when 3 then epi_t
                    else null
                    end

        return Tuple {score : pressor_score, pressor_time : pressor_t,
                      dopamine_score : dopamine_score, dopamine_time : dopamine_t,
                      dobutamine_score : dobutamine_score, dobutamine_time : dobutamine_t, 
                      norepi_score : norepi_score, norepi_time : norepi_t, 
                      epi_score : epi_score, epi_time : epi_t
                      }

    
define sofa_cvs: 

case 

when needs_pressors then 


        from sofa_map  map,
             sofa_pressor  pressor

        let 
            map_score : map.score,
            pressor_score : pressor.score,


            cvs_score : map_score + pressor_score


          where   difference in hours between map.map_time and pressor.dopamine_time < 1 or
                  difference in hours between map.map_time and pressor.dobutamine_time < 1 or
                  difference in hours between map.map_time and pressor.epi_time < 1 or 
                  difference in hours between map.map_time and pressor.norepi_time < 1 
        

    return Tuple {score : cvs_score, map_time : map.map_time, map_value : map.map_value, 
                  pressor_score : pressor.score, pressor_time : pressor.pressor_time,
                  dobutamine_score : pressor.dobutamine_score, dobutamine_time : pressor.dobutamine_time, 
                  norepi_score : pressor.norepi_score, norepi_time : pressor.norepi_time, 
                  epi_score : pressor.epi_score, epi_time : pressor.epi_time
                  }
    
else 
    
    from sofa_map  map
        let 
            cvs_score : map.score

    return Tuple {score : cvs_score, map_time : map.map_time, map_value : map.map_value}
    
end

  

  define function sofa_dobutamine_score(dobutamine decimal) returns Integer :

    case 
        when dobutamine > 0 then 1
        else 0 
        end


define function sofa_dopamine_score (dopamine decimal) returns Integer :

    case 
         when dopamine < 5 then 1 
        when dopamine >= 5 and dopamine < 15 then 2
        when dopamine >= 15 then 3
        else 0
        end

define function sofa_epi_norepi_score(epi_norepi decimal) returns Integer :

    case 
        when epi_norepi <= 0.1 then 2
        when epi_norepi > 0.1 then 3 
        else 0
        end


define function sofa_map_score (map Decimal) returns Integer :


    case 
        when map >= 70 then 0 
        when map < 70 then 1 
        else -100 
        end


//-------------------------------------
//PS 

define peep : [Observation : PEEP] O return Tuple {value : O.value.value, time : O.effective}
define pao2 : [Observation : PaO2] 
define fio2 : [Observation : FiO2]

define pfr : 
    from pao2 p,
         fio2 f

    let 
        p_value : p.value.value,
        f_value : f.value.value,
        pfr_value : 100*(p_value / f_value),
        p_time : p.effective,
        f_time : f.effective 

        where  difference in hours between p_time and f_time = 0

    return Tuple {value : pfr_value, time : p_time}



define sofa_ps : 
    from pfr pf,
         peep pp 

    let 
        score : sofa_pulm_score(pf.value, pp.value),
        peep_time : pp.time,
        pfr_time : pf.time

        where difference in hours between peep_time and pfr_time =  0

    return Tuple {score : score , peep : pp.value , pfr : pf.value, time : pfr.time}

define function sofa_pulm_score(pfr Decimal, pp Decimal) returns Integer : 
    case 
    when pfr >= 400 then 0
    when pfr in Interval[300, 399] then 1
    when pfr in Interval[200, 299]then 2
    when pp != 0 and pfr in Interval[100,199] then 3
    when pp != 0  and pfr in Interval[0,99] then 4 
    else -100 end 
    


//HS score (include coag and T bili)
define sofa_plts : [Observation: Platelets] O 
return Tuple {score : sofa_plt_score(O.value.value as decimal),
              plts_value : O.value.value,
              plts_time : O.effective
              }

define sofa_tbilli : [Observation: Total_Bilirubin] O
return Tuple {score : sofa_tbilli_score(O.value.value as decimal),
              tbilli_value : O.value.value,
              tbilli_time : O.effective
              }
              


    define function sofa_plt_score (plts Decimal) returns Integer :
        case 
            when plts >= 150 then 0
            when plts in Interval[100, 149] then 1
            when plts in Interval[50, 99] then 2
            when plts in Interval[20, 49] then 3
            when plts < 20 then 4
            else -100
        end

    define function sofa_tbilli_score (tbilli Decimal) returns Integer :
        case 
            when tbilli < 1.2 then 0
            when tbilli in Interval[1.2, 1.9] then 1
            when tbilli in Interval[2.0, 5.9] then 2
            when tbilli in Interval[6.0, 11.9] then 3
            when tbilli > 12.0 then 4
            else -100
        end

//RS score


define scr : [Observation : Creatinine] 

define foley_uop : [Observation : Foley] O return Tuple {value : FHIRHelpers.ToDecimal(O.value.value),
              time : ToDate(O.effective)}
              

define daily_uop:
  foley_uop X
    return distinct {
         uop: Sum(foley_uop I where  I.time same as X.time  return all I.value),
        time: X.time
                    }


define sofa_rs : 

case when exists(foley_uop) then 
from daily_uop uop,
     scr   cr
    
    let 
        value :  sofa_rs_score(cr.value.value, uop.uop)

    where 
        ToDate(cr.effective) same as uop.time


return Tuple {score : value, uop : uop.uop, scr : cr.value.value, time : uop.time}

else 
from scr cr 
let 
        value :  sofa_rs_score(cr.value.value, 1000)
        return Tuple {score : value, scr : cr.value.value , time : ToDate(cr.effective)}
end



define function sofa_rs_score (scr Decimal, uop Decimal) returns Integer : 

 case
    when scr < 1.2 then 0
    when scr in Interval[1.2, 1.9]then 1
    when scr in Interval[2.0, 3.4]then 2
    when scr in Interval[3.5, 4.9] or uop in Interval [200,499] then 3
    when scr < 5 or uop < 200 then 4 
    else - 100 end 






