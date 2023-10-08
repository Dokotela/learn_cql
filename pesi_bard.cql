library PESI;

version '1.1.0';

using FHIR version '4.0.1';

define function CalculatePESI(patient: Patient) returns Integer {
  var age: Integer = patient.birthDate.value as Integer;
  var sex: String = patient.gender;
  var heartRate: Integer = patient.vitalSign[where(code = '27708-7')].valueQuantity.value as Integer;
  var respiratoryRate: Integer = patient.vitalSign[where(code = '59867-1')].valueQuantity.value as Integer;
  var systolicBloodPressure: Integer = patient.vitalSign[where(code = '8462-9')].valueQuantity.value as Integer;
  var oxygenSaturation: Integer = patient.observation[where(code = '2708-6')].valueQuantity.value as Integer;
  var temperature: Integer = patient.observation[where(code = '38387-3')].valueQuantity.value as Integer;
  var alteredMentalStatus: Boolean = patient.observation[where(code = '42553-6')].valueBoolean;
  var cancerHistory: Boolean = patient.condition[where(code = '198342004')].exists();
  var heartFailureHistory: Boolean = patient.condition[where(code = '399007002')].exists();
  var chronicLungDiseaseHistory: Boolean = patient.condition[where(code = '198343003')].exists();

  var score: Integer = 0;

  // Age
  if (age >= 80) {
    score += 1;
  }

  // Sex
  if (sex = 'female') {
    score += 10;
  }

  // Heart rate
  if (heartRate >= 110) {
    score += 20;
  }

  // Respiratory rate
  if (respiratoryRate >= 30) {
    score += 20;
  }

  // Systolic blood pressure
  if (systolicBloodPressure < 100) {
    score += 30;
  }

  // Oxygen saturation
  if (oxygenSaturation < 90) {
    score += 20;
  }

  // Temperature
  if (temperature < 36) {
    score += 20;
  }

  // Altered mental status
  if (alteredMentalStatus) {
    score += 60;
  }

  // Cancer history
  if (cancerHistory) {
    score += 30;
  }

  // Heart failure history
  if (heartFailureHistory) {
    score += 10;
  }

  // Chronic lung disease history
  if (chronicLungDiseaseHistory) {
    score += 10;
  }

  return score;
}
