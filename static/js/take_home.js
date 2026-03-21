/* TRAVEL TAX — take_home.js */

let thSelectedPlan = "none";
let thLastResult = null;

const TH_FACTS = [
  { text: "The average UK worker pays <em>£5,500/year</em> in income tax." },
  { text: "National Insurance costs the average UK worker <em>£2,800/year</em>." },
  { text: "A 5% pension contribution on a £35k salary saves you <em>£350/year</em> in tax." },
  { text: "Earning over <em>£100,000</em> means you lose your personal allowance — fast." },
  { text: "The average UK take home pay is <em>£2,228/month</em> after all deductions." },
  { text: "Student loan repayments cost Plan 2 graduates an average of <em>£1,800/year</em>." },
  { text: "Salary sacrifice pension contributions reduce your <em>NI bill</em> as well as tax." },
];

document.addEventListener("DOMContentLoaded", () => {
  // Fun facts
  const display = document.getElementById("thFactDisplay");
  const dots = document.getElementById("thFactDots");
  if (display && dots) {
    TH_FACTS.forEach((_, i) => {
      const dot = document.createElement("div");
      dot.className = "fun-fact-dot" + (i === 0 ? " active" : "");
      dots.appendChild(dot);
    });
    let current = 0;
    function showFact(i) {
      display.style.opacity = "0";
      setTimeout(() => {
        display.innerHTML = TH_FACTS[i].text;
        display.style.opacity = "1";
        dots.querySelectorAll(".fun-fact-dot").forEach((d, j) => d.classList.toggle("active", j === i));
      }, 400);
    }
    showFact(0);
    setInterval(() => { current = (current + 1) % TH_FACTS.length; showFact(current); }, 4000);
  }

  // Student loan toggle
  document.querySelectorAll(".transport-btn[data-plan]").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".transport-btn[data-plan]").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      thSelectedPlan = btn.dataset.plan;
    });
  });

  // Pension slider
  const slider = document.getElementById("th_pension_slider");
  const input = document.getElementById("th_pension");
  if (slider && input) {
    slider.addEventListener("input", () => { input.value = slider.value; });
    input.addEventListener("input", () => { slider.value = Math.min(input.value, 20); });
  }

  // Calculate button
  document.getElementById("thCalculateBtn").addEventListener("click", runTakeHome);
});

async function runTakeHome() {
  const btn = document.getElementById("thCalculateBtn");
  const salary = parseFloat(document.getElementById("th_salary").value) || 0;
  const pension = parseFloat(document.getElementById("th_pension").value) || 0;

  if (salary <= 0) {
    showTHToast("Please enter your annual salary.");
    return;
  }

  btn.querySelector("span").textContent = "Calculating...";
  btn.disabled = true;

  try {
    const res = await fetch("/calculate-take-home", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ salary, student_loan: thSelectedPlan, pension_pct: pension }),
    });
    const result = await res.json();
    thLastResult = result;
    renderTakeHome(result);
    document.getElementById("thResultsPanel").scrollIntoView({ behavior: "smooth", block: "start" });
  } catch (err) {
    showTHToast("Something went wrong. Please try again.");
  } finally {
    btn.querySelector("span").textContent = "Calculate My Take Home Pay";
    btn.disabled = false;
  }
}

function renderTakeHome(r) {
  document.getElementById("thResultsPlaceholder").classList.add("hidden");
  document.getElementById("thResultsContent").classList.remove("hidden");

  document.getElementById("th_monthly").textContent = fmtTH(r.take_home_monthly);
  document.getElementById("th_yearly_sub").textContent = fmtTH(r.take_home_yearly) + " per year take home";
  document.getElementById("th_weekly").textContent = fmtTH(r.take_home_weekly);
  document.getElementById("th_deductions").textContent = fmtTH(r.total_deductions);
  document.getElementById("th_effective_rate").textContent = r.effective_rate + "%";
  document.getElementById("th_daily").textContent = fmtTH(r.take_home_daily);

  document.getElementById("th_gross").textContent = fmtTH(r.gross_yearly);
  document.getElementById("th_tax").textContent = "-" + fmtTH(r.income_tax);
  document.getElementById("th_ni").textContent = "-" + fmtTH(r.national_insurance);
  document.getElementById("th_takehome_yearly").textContent = fmtTH(r.take_home_yearly);

  // Student loan row
  if (r.student_loan > 0) {
    document.getElementById("th_sl_row").style.display = "flex";
    document.getElementById("th_sl").textContent = "-" + fmtTH(r.student_loan);
  }

  // Pension row
  if (r.pension > 0) {
    document.getElementById("th_pension_row").style.display = "flex";
    document.getElementById("th_pension_val").textContent = "-" + fmtTH(r.pension);
  }

  // Reality check
  const hourly = Math.round(r.take_home_yearly / 52 / 40);
  const pctKept = Math.round((r.take_home_yearly / r.gross_yearly) * 100);
  document.getElementById("th_reality").textContent =
    "For every £100 you earn, you keep £" + pctKept + ". Your effective hourly take home rate is £" + hourly + "/hr. You hand £" + fmtTH(r.total_deductions).replace("£", "") + " to the government every year.";
}

async function submitEmail(source) {
  const emailEl = document.getElementById(source === "takehome" ? "thEmail" : "commEmail");
  const email = emailEl ? emailEl.value.trim() : "";
  if (!email || !email.includes("@")) {
    showTHToast("Please enter a valid email address.");
    return;
  }

  const summary = thLastResult
    ? "Take home: " + fmtTH(thLastResult.take_home_yearly) + "/yr, Effective rate: " + thLastResult.effective_rate + "%"
    : "";

  try {
    const res = await fetch("/subscribe", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, results_summary: summary }),
    });
    const data = await res.json();
    if (data.success) {
      showTHToast("Done! Check your inbox shortly.");
      emailEl.value = "";
    }
  } catch (err) {
    showTHToast("Something went wrong. Please try again.");
  }
}

function fmtTH(n) { return "£" + Math.round(n).toLocaleString("en-GB"); }

function showTHToast(msg) {
  const existing = document.querySelector(".toast");
  if (existing) existing.remove();
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = msg;
  toast.style.cssText = "position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#f0e040;color:#0a0a0a;padding:12px 24px;font-family:monospace;font-size:12px;letter-spacing:0.08em;z-index:9999;max-width:400px;text-align:center;";
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3500);
}
