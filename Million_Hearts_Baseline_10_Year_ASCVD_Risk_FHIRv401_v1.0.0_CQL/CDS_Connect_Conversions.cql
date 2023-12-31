/**
 * This library supports conversions from one unit to another.  Conversions are added as needed by artifacts in
 * development.  Since case is important for some units, rather than use our normal PascalCasing, we use underscore
 * to separate words and maintain casing.  For example, to convert to "mg/dL", rather than call the function
 * `ToMgPerDL`, we call it `to_mg_per_dL`, in order to maintain casing.
 *
 * Change log:
 * - 1.0.2:
 *  - Rename to_mg_per_dL function and add to_mg_per_dL_for_trigylceride() and
 *    to_mg_per_dL_for_blood_glucose() functions.
 *
 */
library CDS_Connect_Conversions version '1.0.2'

/**
 * Converts mmol/L to mg/dL for blood cholesterol, using the formula: 1 mmol/L = 38.66976 mg/dL.  If the unit is
 * already mg/dL, it leaves it as is.  If an unrecognized unit is used, null is returned.
 * @param Q - a Quantity
 * @returns {Quantity} a Quantity using mg/dL units or null if null was passed in or unit couldn't be converted
 */
define function to_mg_per_dL_for_blood_cholesterol (Q Quantity):
  case
    when Q.unit = 'mg/dL' then Q
    when Q.unit = 'mmol/L' then Quantity{value: Q.value * 38.66976, unit: 'mg/dL'}
    else null
  end

/**
 * Converts mmol/L to mg/dL for triglyceride, using the formula: 1 mmol/L = 88.57 mg/dL.  If the unit is
 * already mg/dL, it leaves it as is.  If an unrecognized unit is used, null is returned.
 * @param Q - a Quantity
 * @returns {Quantity} a Quantity using mg/dL units or null if null was passed in or unit couldn't be converted
 */
define function to_mg_per_dL_for_triglyceride (Q Quantity):
  case
    when Q.unit = 'mg/dL' then Q
    when Q.unit = 'mmol/L' then Quantity{value: Q.value * 88.57, unit: 'mg/dL'}
    else null
  end

  /**
 * Converts mmol/L to mg/dL for blood glucose, using the formula: 1 mmol/L = 18.02 mg/dL.  If the unit is
 * already mg/dL, it leaves it as is.  If an unrecognized unit is used, null is returned.
 * @param Q - a Quantity
 * @returns {Quantity} a Quantity using mg/dL units or null if null was passed in or unit couldn't be converted
 */
define function to_mg_per_dL_for_blood_glucose (Q Quantity):
  case
    when Q.unit = 'mg/dL' then Q
    when Q.unit = 'mmol/L' then Quantity{value: Q.value * 18.02, unit: 'mg/dL'}
    else null
  end