library QSofa version '1.0.0'

using FHIR version '4.0.1'

// Include the FHIRHelpers library for simplifying interacton w/ the FHIR data model
include FHIRHelpers version '4.0.1' called FHIRHelpers

// Codesystems
codesystem "LOINC": 'http://loinc.org' // '2.16.840.1.113883.6.1'

// Codes
code "GCS": '9269-2' from "LOINC" display 'Glasgow coma score total'
code "RR": '9279-1' from "LOINC" display 'Respiratory rate'
code "SBP": '8480-6' from "LOINC" display 'Systolic blood pressure'


// Altered mental status GCS <15
// Respiratory rate ≥22
// Systolic BP ≤100
define function TotalScore(integer List<Fhir.Observation>):
    let score = 0
    for observation in observations:
        let quantity = FHIRHelpers.ToQuantity(observation.value as FHIR.Quantity)
        if quantity.code = 'GCS' then
            score = score + (gcs.value < 15 ? 1 : 0)
        else if quantity.code = 'RR' then
            score = score + (rr.value >= 22 ? 1 : 0)
        else if quantity.code = 'SBP' then
            score = score + (sbp.value <= 100 ? 1 : 0)
    return score



