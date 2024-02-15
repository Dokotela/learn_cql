library PESIScoreExample version '1.0'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1'

codesystem "PESI Score Codes": 'http://example.org/fhir/ValueSet/PESIScoreCodes'

parameter Age at least 0 years
parameter Gender one of 'male', 'female'
parameter HeartRateInHospital at least 0
parameter SystolicBloodPressure at least 0
parameter RespiratoryRate at least 0
parameter OxygenSaturation at least 0
parameter HistoryOfCancer boolean
parameter HistoryOfHeartFailure boolean
parameter ChronicLungDisease boolean
parameter AlteredMentalStatus boolean
parameter ArterialOxygenTension at least 0
parameter SerumCreatinine at least 0

context Patient

define PESIScore:
  let agePoints = Age > 80 then 5 else
                  Age > 70 then 3 else
                  Age > 60 then 2 else
                  0
  let genderPoints = Gender = 'male' then 10 else 0
  let vitalSignsPoints = HeartRateInHospital > 110 then 20 else
                        SystolicBloodPressure < 100 then 30 else
                        RespiratoryRate > 30 then 20 else
                        OxygenSaturation < 90 then 20 else
                        0
  let comorbidityPoints = HistoryOfCancer then 30 else
                         HistoryOfHeartFailure then 10 else
                         ChronicLungDisease then 10 else
                         0
  let mentalStatusPoints = AlteredMentalStatus then 60 else 0
  let laboratoryPoints = ArterialOxygenTension < 60 then 20 else
                        SerumCreatinine > 1.5 then 10 else
                        0
  return agePoints + genderPoints + vitalSignsPoints + comorbidityPoints + mentalStatusPoints + laboratoryPoints

define PESISeverityCategory:
  if PESIScore <= 65 then 'I'
  else if PESIScore <= 85 then 'II'
  else if PESIScore <= 105 then 'III'
  else if PESIScore <= 125 then 'IV'
  else 'V'
