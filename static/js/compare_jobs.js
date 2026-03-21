/* TRAVEL TAX — compare_jobs.js */

let aRemoteDays = 0;
let bRemoteDays = 0;
let lastComparison = null;

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("#a_remote_toggle .day-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll("#a_remote_toggle .day-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      aRemoteDays = parseInt(btn.dataset.val);
    });
  });

  document.querySelectorAll("#b_remote_toggle .day-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll("#b_remote_toggle .day-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      bRemoteDays = parseInt(btn.dataset.val);
    });
  });
});

function safeVal(id, fallback) {
  const el = document.getElementById(id);
  return el ? (parseFloat(el.value) || fallback) : fallback;
}

function getJobData(prefix, remoteDays) {
  return {
    salary: safeVal(prefix + "_salary", 0),
    bonus: safeVal(prefix + "_bonus", 0),
    pension_pct: safeVal(prefix + "_pension", 0),
    holiday_days: safeVal(prefix + "_holiday", 25),
    remote_days: remoteDays,
    commute_mins: safeVal(prefix + "_commute_mins", 0),
    commute_cost_daily: safeVal(prefix + "_commute_cost", 0),
    culture_score: safeVal(prefix + "_culture", 5),
  };
}

async function runComparison() {
  if (jobCVisible) { runComparisonWithC(); return; }
  const btn = document.getElementById("compareBtn");
  const jobA = getJobData("a", aRemoteDays);
  const jobB = getJobData("b", bRemoteDays);
  const nameA = document.getElementById("job_a_name").value.trim() || "A";
  const nameB = document.getElementById("job_b_name").value.trim() || "B";

  if (jobA.salary <= 0 || jobB.salary <= 0) {
    showCJToast("Please enter a salary for both jobs.");
    return;
  }

  btn.textContent = "Comparing...";
  btn.disabled = true;

  try {
    const res = await fetch("/calculate-comparison", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ job_a: jobA, job_b: jobB }),
    });
    const result = await res.json();
    lastComparison = { result, nameA, nameB };
    renderComparison(result, nameA, nameB);
    document.getElementById("compResults").classList.remove("hidden");
    document.getElementById("compResults").scrollIntoView({ behavior: "smooth", block: "start" });
  } catch (err) {
    alert("Something went wrong. Please try again.");
  } finally {
    btn.textContent = "Compare Job Offers →";
    btn.disabled = false;
  }
}

function renderComparison(r, nameA, nameB) {
  const winnerName = r.winner === "A" ? nameA : nameB;
  const loserName = r.winner === "A" ? nameB : nameA;

  document.getElementById("res_winner").textContent = winnerName;
  document.getElementById("res_margin").textContent = fmt(r.margin);
  document.getElementById("res_desc").textContent = "better real value per year after commute, tax and all costs";

  document.getElementById("res_label_a").textContent = nameA.toUpperCase();
  document.getElementById("res_label_b").textContent = nameB.toUpperCase();

  if (r.winner === "A") {
    document.getElementById("res_col_a").classList.add("winner");
    document.getElementById("res_col_b").classList.remove("winner");
    document.getElementById("ra_real").style.color = "var(--accent)";
    document.getElementById("rb_real").style.color = "var(--white)";
  } else {
    document.getElementById("res_col_b").classList.add("winner");
    document.getElementById("res_col_a").classList.remove("winner");
    document.getElementById("rb_real").style.color = "var(--accent)";
    document.getElementById("ra_real").style.color = "var(--white)";
  }

  const a = r.job_a;
  const b = r.job_b;

  document.getElementById("ra_gross").textContent = fmt(a.salary);
  function safeSet(id, val) { const el = document.getElementById(id); if (el) el.textContent = val; }
  safeSet("ra_bonus", "+" + fmt(a.bonus));
  safeSet("ra_pension", "+" + fmt(a.pension));
  safeSet("ra_takehome", fmt(a.take_home));
  safeSet("ra_commute", "-" + fmt(a.commute_cost_yearly));
  safeSet("ra_time", "-" + fmt(a.commute_time_value));
  safeSet("ra_holiday", "+" + fmt(a.holiday_value));
  safeSet("ra_real", fmt(a.real_value));
  safeSet("rb_gross", fmt(b.salary));
  safeSet("rb_bonus", "+" + fmt(b.bonus));
  safeSet("rb_pension", "+" + fmt(b.pension));
  safeSet("rb_takehome", fmt(b.take_home));
  safeSet("rb_commute", "-" + fmt(b.commute_cost_yearly));
  safeSet("rb_time", "-" + fmt(b.commute_time_value));
  safeSet("rb_holiday", "+" + fmt(b.holiday_value));
  safeSet("rb_real", fmt(b.real_value));

  const salaryDiff = a.salary - b.salary;
  const takehomeDiff = a.take_home - b.take_home;

  document.getElementById("diff_salary").textContent = (salaryDiff >= 0 ? "+" : "") + fmt(Math.abs(salaryDiff)) + " (" + nameA + ")";
  document.getElementById("diff_salary").className = salaryDiff >= 0 ? "diff-positive" : "diff-negative";

  document.getElementById("diff_takehome").textContent = (takehomeDiff >= 0 ? "+" : "") + fmt(Math.abs(takehomeDiff)) + " (" + nameA + ")";
  document.getElementById("diff_takehome").className = takehomeDiff >= 0 ? "diff-positive" : "diff-negative";

  document.getElementById("diff_commute").textContent = fmt(Math.abs(r.diff_commute)) + " cheaper commute (" + (r.diff_commute >= 0 ? nameA : nameB) + ")";
  document.getElementById("diff_commute").className = "diff-positive";

  document.getElementById("diff_real").textContent = fmt(r.margin) + " better (" + winnerName + ")";
  document.getElementById("diff_real").className = "diff-positive";

  // Insight
  let insight = winnerName + " is worth " + fmt(r.margin) + " more per year in real terms. ";
  if (r.diff_commute > 500) {
    insight += "A big factor is the commute — " + loserName + " costs " + fmt(Math.abs(r.diff_commute)) + " more per year in travel alone. ";
  }
  if (Math.abs(salaryDiff) > 3000 && r.winner !== (salaryDiff > 0 ? "A" : "B")) {
    insight += "Interestingly, " + loserName + " has the higher salary but once commute costs and time are factored in, " + winnerName + " comes out ahead.";
  }
  document.getElementById("res_insight").textContent = insight;
}

function shareComparison(platform) {
  if (!lastComparison) return;
  const { result, nameA, nameB } = lastComparison;
  const winner = result.winner === "A" ? nameA : nameB;
  const text = "I compared two job offers and the results were surprising. " + winner + " is worth " + fmt(result.margin) + " more per year once commute, tax and all costs are factored in. Calculate yours at traveltax.co.uk/compare-jobs";

  if (platform === "twitter") window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(text), "_blank");
  else if (platform === "whatsapp") window.open("https://wa.me/?text=" + encodeURIComponent(text), "_blank");
  else if (platform === "linkedin") window.open("https://www.linkedin.com/sharing/share-offsite/?url=" + encodeURIComponent("https://traveltax.co.uk/compare-jobs"), "_blank");
  else if (platform === "copy") navigator.clipboard.writeText(text).then(() => showCJToast("Copied!"));
}

function fmt(n) { return "£" + Math.round(n).toLocaleString("en-GB"); }

function showCJToast(msg) {
  const existing = document.querySelector(".toast");
  if (existing) existing.remove();
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = msg;
  toast.style.cssText = "position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#f0e040;color:#0a0a0a;padding:12px 24px;font-family:monospace;font-size:12px;letter-spacing:0.08em;z-index:9999;max-width:400px;text-align:center;";
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3500);
}

function toggleAdvanced(job) {
  const el = document.getElementById(job + "_advanced");
  const btn = el.previousElementSibling;
  if (el.classList.contains("open")) {
    el.classList.remove("open");
    btn.textContent = "+ Advanced options (bonus, pension, holidays, culture)";
  } else {
    el.classList.add("open");
    btn.textContent = "- Hide advanced options";
  }
}

// Job C
let cRemoteDays = 0;
let jobCVisible = false;

function toggleJobC() {
  jobCVisible = !jobCVisible;
  const container = document.getElementById("jobC_container");
  const btn = document.getElementById("addJobCBtn");
  container.classList.toggle("hidden", !jobCVisible);
  btn.textContent = jobCVisible ? "- Remove third job" : "+ Add a third job to compare";

  if (jobCVisible) {
    document.querySelectorAll("#c_remote_toggle .day-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        document.querySelectorAll("#c_remote_toggle .day-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        cRemoteDays = parseInt(btn.dataset.val);
      });
    });
  }
}

// Job C version of runComparison
async function runComparisonWithC() {
  const btn = document.getElementById("compareBtn");
  const jobA = getJobData("a", aRemoteDays);
  const jobB = getJobData("b", bRemoteDays);
  const jobC = getJobData("c", cRemoteDays);
  const nameA = document.getElementById("job_a_name").value.trim() || "A";
  const nameB = document.getElementById("job_b_name").value.trim() || "B";
  const nameC = document.getElementById("job_c_name").value.trim() || "C";

  if (jobA.salary <= 0 || jobB.salary <= 0) { showCJToast("Please enter salaries for both jobs."); return; }

  const btnSpan = btn.querySelector("span") || btn;
  btnSpan.textContent = "Comparing...";
  btn.disabled = true;

  try {
    // Get all 3 results by running A vs B, then A vs C
    const [res1, res2] = await Promise.all([
      fetch("/calculate-comparison", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ job_a: jobA, job_b: jobB }) }).then(r => r.json()),
      fetch("/calculate-comparison", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ job_a: jobA, job_b: jobC }) }).then(r => r.json()),
    ]);

    // Find overall winner by real value
    const values = [
      { name: nameA, value: res1.job_a.real_value },
      { name: nameB, value: res1.job_b.real_value },
      { name: nameC, value: res2.job_b.real_value },
    ];
    values.sort((a, b) => b.value - a.value);
    const winner = values[0];
    const second = values[1];
    const margin = winner.value - second.value;

    // Update verdict
    document.getElementById("res_winner").textContent = winner.name;
    document.getElementById("res_margin").textContent = fmt(margin);
    document.getElementById("res_desc").textContent = "better real value than the next best option";

    // Update results columns — show all 3
    const allJobs = [
      { name: nameA, data: res1.job_a },
      { name: nameB, data: res1.job_b },
      { name: nameC, data: res2.job_b },
    ];

    // Rebuild results grid with 3 columns
    const grid = document.querySelector(".results-grid");
    grid.style.gridTemplateColumns = "1fr 1fr 1fr";
    grid.innerHTML = allJobs.map((job, i) => {
      const isWinner = job.name === winner.name;
      return `<div class="result-col ${isWinner ? "winner" : ""}">
        <p class="result-col-label">${job.name.toUpperCase()}</p>
        <div class="result-row"><span>Gross salary</span><span>${fmt(job.data.salary)}</span></div>
        <div class="result-row"><span>Take home</span><span>${fmt(job.data.take_home)}</span></div>
        <div class="result-row"><span>Commute cost</span><span style="color:var(--red)">-${fmt(job.data.commute_cost_yearly)}</span></div>
        <div class="result-row"><span>Time value lost</span><span style="color:var(--red)">-${fmt(job.data.commute_time_value)}</span></div>
        <div class="result-row"><span>Pension</span><span style="color:var(--green)">+${fmt(job.data.pension)}</span></div>
        <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--text-dimmer);margin-top:12px;">TRUE VALUE</p>
        <div style="font-family:var(--font-display);font-size:28px;color:${isWinner ? "var(--accent)" : "var(--white)"};">${fmt(job.data.real_value)}</div>
      </div>`;
    }).join("");

    // Update key differences
    document.getElementById("diff_salary").textContent = values.map(v => v.name + ": " + fmt(v.value)).join(" · ");
    document.getElementById("diff_salary").className = "diff-positive";
    document.getElementById("diff_takehome").textContent = nameA + ": " + fmt(res1.job_a.take_home) + " · " + nameB + ": " + fmt(res1.job_b.take_home) + " · " + nameC + ": " + fmt(res2.job_b.take_home);
    document.getElementById("diff_commute").textContent = "Cheapest commute: " + allJobs.sort((a,b) => a.data.commute_cost_yearly - b.data.commute_cost_yearly)[0].name;
    document.getElementById("diff_real").textContent = winner.name + " wins by " + fmt(margin);

    document.getElementById("res_insight").textContent = winner.name + " is the best offer overall, worth " + fmt(margin) + " more per year in real terms than " + second.name + " once all costs are factored in.";

    lastComparison = { result: res1, nameA, nameB };
    document.getElementById("compResults").classList.remove("hidden");
    document.getElementById("compResults").scrollIntoView({ behavior: "smooth", block: "start" });

  } catch(err) {
    showCJToast("Something went wrong. Please try again.");
  } finally {
    const s = btn.querySelector("span") || btn;
    s.textContent = "Compare Job Offers";
    btn.disabled = false;
  }
}

