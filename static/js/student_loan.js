let slPlan = "plan2";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".transport-btn[data-plan]").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".transport-btn[data-plan]").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      slPlan = btn.dataset.plan;
    });
  });
  document.getElementById("slCalculateBtn").addEventListener("click", calcSL);
});

async function calcSL() {
  const btn = document.getElementById("slCalculateBtn");
  const salary = parseFloat(document.getElementById("sl_salary").value) || 0;
  const balance = parseFloat(document.getElementById("sl_balance").value) || 0;
  if (salary <= 0) { slToast("Please enter your salary."); return; }
  btn.querySelector("span").textContent = "Calculating...";
  btn.disabled = true;
  try {
    const res = await fetch("/calculate-student-loan", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ salary, plan: slPlan, balance }) });
    const r = await res.json();
    document.getElementById("slPlaceholder").classList.add("hidden");
    document.getElementById("slResults").classList.remove("hidden");
    document.getElementById("sl_monthly").textContent = "£" + r.monthly_repayment.toLocaleString("en-GB");
    document.getElementById("sl_yearly_sub").textContent = "£" + r.yearly_repayment.toLocaleString("en-GB") + " per year";
    document.getElementById("sl_monthly2").textContent = "£" + r.monthly_repayment.toLocaleString("en-GB");
    document.getElementById("sl_yearly").textContent = "£" + r.yearly_repayment.toLocaleString("en-GB");
    document.getElementById("sl_interest").textContent = balance > 0 ? "£" + r.interest_yearly.toLocaleString("en-GB") : "N/A";
    document.getElementById("sl_writeoff").textContent = r.write_off_years + " yrs";
    document.getElementById("sl_threshold").textContent = "£" + r.threshold.toLocaleString("en-GB");
    document.getElementById("sl_rate").textContent = r.rate + "%";
    document.getElementById("sl_monthly3").textContent = "£" + r.monthly_repayment.toLocaleString("en-GB");
    document.getElementById("sl_interest2").textContent = balance > 0 ? "£" + r.interest_yearly.toLocaleString("en-GB") : "Enter balance above";
    if (r.years_to_repay) {
      document.getElementById("sl_years").textContent = r.years_to_repay + " years";
      document.getElementById("sl_verdict_label").textContent = "Estimated years to repay";
      document.getElementById("sl_insight").textContent = r.will_repay_before_writeoff
        ? "At your current salary, you are on track to repay your loan in full in approximately " + r.years_to_repay + " years — before the " + r.write_off_years + "-year write-off. Consider whether overpaying makes sense for you."
        : "At your current salary, your loan balance is growing faster than your repayments. Your loan is likely to be written off after " + r.write_off_years + " years with balance remaining — meaning you may never fully repay it. This is normal for most Plan 2 graduates.";
    } else {
      document.getElementById("sl_years").textContent = "Written off after " + r.write_off_years + " yrs";
      document.getElementById("sl_insight").textContent = r.monthly_repayment === 0
        ? "Your salary is below the repayment threshold of £" + r.threshold.toLocaleString("en-GB") + "/year. You do not currently make any repayments."
        : "Based on your salary and balance, your loan will likely be written off after " + r.write_off_years + " years.";
    }
  } catch(err) { slToast("Something went wrong."); }
  finally { btn.querySelector("span").textContent = "Calculate My Repayments"; btn.disabled = false; }
}

function slToast(msg) {
  const t = document.createElement("div");
  t.textContent = msg;
  t.style.cssText = "position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#f0e040;color:#000;padding:12px 24px;font-family:monospace;font-size:12px;z-index:9999;";
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 3000);
}

// ── Mobile student loan tab ───────────────────────────────────────────────────
let slPlanM = "plan2";

function slTab(tab) {
  document.getElementById("sl_panel_calc").classList.toggle("active", tab === "calc");
  document.getElementById("sl_panel_results").classList.toggle("active", tab === "results");
  document.querySelectorAll(".calc-mobile-tabs .calc-tab-btn").forEach((b, i) => b.classList.toggle("active", (i === 0) === (tab === "calc")));
}

function setSlPlanM(btn, plan) {
  btn.closest(".transport-toggle").querySelectorAll(".transport-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");
  slPlanM = plan;
}

async function calcSLMobile() {
  const salary = parseFloat(document.getElementById("sl_salary_m").value) || 0;
  const balance = parseFloat(document.getElementById("sl_balance_m").value) || 0;
  if (salary <= 0) { slToast("Please enter your salary."); return; }
  try {
    const res = await fetch("/calculate-student-loan", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ salary, plan: slPlanM, balance }) });
    const r = await res.json();
    document.getElementById("sl_m_placeholder").classList.add("hidden");
    document.getElementById("sl_m_results").classList.remove("hidden");
    document.getElementById("sl_m_monthly").textContent = "£" + r.monthly_repayment.toLocaleString("en-GB");
    document.getElementById("sl_m_yearly").textContent = "£" + r.yearly_repayment.toLocaleString("en-GB") + " per year";
    document.getElementById("sl_m_monthly2").textContent = "£" + r.monthly_repayment.toLocaleString("en-GB");
    document.getElementById("sl_m_yearly2").textContent = "£" + r.yearly_repayment.toLocaleString("en-GB");
    document.getElementById("sl_m_interest").textContent = balance > 0 ? "£" + r.interest_yearly.toLocaleString("en-GB") : "N/A";
    document.getElementById("sl_m_writeoff").textContent = r.write_off_years + " yrs";
    document.getElementById("sl_m_insight").textContent = r.monthly_repayment === 0
      ? "Your salary is below the repayment threshold of £" + r.threshold.toLocaleString("en-GB") + ". No repayments currently."
      : (r.will_repay_before_writeoff ? "You are on track to repay in full in " + r.years_to_repay + " years." : "Your loan will likely be written off after " + r.write_off_years + " years.");
    slTab("results");
  } catch(err) { slToast("Something went wrong."); }
}
