// Patch — overrides getFormData to include car_type and manual minutes
const _origGetFormData = window.getFormData;
window.getFormData = function() {
  const salary = parseFloat(document.getElementById("salary").value) || 0;
  const manual = document.getElementById("commute_minutes_manual");
  const slider = document.getElementById("commute_minutes");
  const minutes = parseFloat((manual && manual.value) ? manual.value : slider.value) || 0;
  return {
    salary,
    commute_minutes: minutes,
    days_per_week: selectedDays,
    weeks_per_year: 48,
    transport_type: selectedTransport,
    transport_cost_daily: parseFloat(document.getElementById("transport_cost_daily").value) || 0,
    miles_one_way: parseFloat(document.getElementById("miles_one_way").value) || 0,
    is_ev: selectedCarType === "electric",
    mpg: selectedCarType === "petrol_large" ? 28 : selectedCarType === "diesel" ? 50 : 40,
    fuel_cost_per_litre: parseFloat(document.getElementById("fuel_cost_per_litre").value) || 1.55,
    car_type: selectedCarType,
  };
};
