document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("pCalculateBtn").addEventListener("click", calcPension);
});

async function calcPension() {
  const btn = document.getElementById("pCalculateBtn");
  const salary = parseFloat(document.getElementById("p_salary").value) || 0;
  if (salary <= 0) { pToast("Please enter your salary."); return; }
  const data = {
    salary, current_age: parseInt(document.getElementById("p_age").value) || 30,
    retirement_age: parseInt(document.getElementById("p_retire").value) || 67,
    contribution_pct: parseFloat(document.getElementById("p_contrib").value) || 5,
    employer_pct: parseFloat(document.getElementById("p_employer").value) || 3,
    current_pot: parseFloat(document.getElementById("p_pot").value) || 0,
    growth_rate: 5,
  };
  btn.querySelector("span").textContent = "Calculating...";
  btn.disabled = true;
  try {
    const res = await fetch("/calculate-pension", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data) });
    const r = await res.json();
    document.getElementById("pPlaceholder").classList.add("hidden");
    document.getElementById("pResults").classList.remove("hidden");
    const fmt = n => "£" + Math.round(n).toLocaleString("en-GB");
    document.getElementById("p_pot_result").textContent = fmt(r.projected_pot);
    document.getElementById("p_track_sub").textContent = r.on_track ? "You are on track ✓" : "You may have a shortfall";
    document.getElementById("p_monthly").textContent = fmt(r.monthly_income);
    document.getElementById("p_state").textContent = fmt(r.state_pension_monthly) + "/mo";
    document.getElementById("p_total_monthly").textContent = fmt(r.total_monthly_with_state);
    document.getElementById("p_saving").textContent = fmt(r.monthly_contribution) + "/mo";
    document.getElementById("p_years").textContent = r.years_to_retirement + " years";
    document.getElementById("p_pot2").textContent = fmt(r.projected_pot);
    document.getElementById("p_recommended").textContent = fmt(r.recommended_pot);
    document.getElementById("p_shortfall").textContent = r.shortfall > 0 ? fmt(r.shortfall) : "None";
    document.getElementById("p_status").textContent = r.on_track ? "On track" : "Below target";
    document.getElementById("p_status").style.color = r.on_track ? "var(--green)" : "var(--red)";
    if (r.shortfall > 0) {
      const extra_monthly = Math.round(r.shortfall / (r.years_to_retirement * 12));
      document.getElementById("p_insight").textContent = "To close the shortfall, you would need to save an additional " + fmt(extra_monthly) + " per month. Even small increases in your contribution now make a significant difference over time due to compound growth.";
    } else {
      document.getElementById("p_insight").textContent = "You are on track for a comfortable retirement. Your projected pot of " + fmt(r.projected_pot) + " should provide around " + fmt(r.total_monthly_with_state) + " per month including the state pension.";
    }
  } catch(err) { pToast("Something went wrong."); }
  finally { btn.querySelector("span").textContent = "Calculate My Pension"; btn.disabled = false; }
}

function pToast(msg) {
  const t = document.createElement("div");
  t.textContent = msg;
  t.style.cssText = "position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#f0e040;color:#000;padding:12px 24px;font-family:monospace;font-size:12px;z-index:9999;";
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 3000);
}
