using PESI;

define rule HighPESIScore {
  when {
    Patient.CalculatePESI() >= 86 and
    Patient.age >= 65
  } then {
    // Patient is at high risk of mortality.
  }
}
