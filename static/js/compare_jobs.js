/* TRAVEL TAX — compare_jobs.js */

let aRemoteDays = 0;
let bRemoteDays = 0;
let cRemoteDays = 0;
let jobCVisible = false;
let lastComparison = null;

document.addEventListener("DOMContentLoaded", () => {
  // Remote day toggles for A and B
  ["a", "b"].forEach(prefix => {
    document.querySelectorAll(`#${prefix}_remote_toggle .day-btn`).forEach(btn => {
      btn.addEventListener("click", () => {
        document.querySelectorAll(`#${prefix}_remote_toggle .day-btn`).forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        if (prefix === "a") aRemoteDays = parseInt(btn.dataset.val);
        else bRemoteDays = parseInt(btn.dataset.val);
      });
    });
  });
});

function toggleJobC() {
  jobCVisible = !jobCVisible;
  document.getElementById("jobC_block").style.display = jobCVisible ? "block" : "none";
  document.getElementById("addJobCBtn").textContent = jobCVisible
    ? "- Remove third job"
    : "+ Add a third job to compare (optional)";

  if (jobCVisible) {
    // Wire up Job C remote toggle
    document.querySelectorAll("#c_remote_toggle .day-btn").forEach(btn => {
      btn.onclick = () => {
        document.querySelectorAll("#c_remote_toggle .day-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        cRemoteDays = parseInt(btn.dataset.val);
      };
    });
  } else {
    // Hide Job C results when removed
    document.getElementById("jobC_result_block").style.display = "none";
  }
}

function toggleAdvanced(job) {
  const el = document.getElementById(job + "_advanced");
  const btn = el.previousElementSibling;
  if (el.classList.contains("open")) {
    el.classList.remove("open");
    btn.textContent = "+ Advanced (bonus, pension, holidays, culture)";
  } else {
    el.classList.add("open");
    btn.textContent = "- Hide advanced";
  }
}

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
  const btn = document.getElementById("compareBtn");
  const jobA = getJobData("a", aRemoteDays);
  const jobB = getJobData("b", bRemoteDays);
  const nameA = document.getElementById("job_a_name").value.trim() || "A";
  const nameB = document.getElementById("job_b_name").value.trim() || "B";

  if (jobA.salary <= 0 || jobB.salary <= 0) {
    showCJToast("Please enter salaries for both jobs.");
    return;
  }

  const btnSpan = btn.querySelector("span") || btn;
  btnSpan.textContent = "Comparing...";
  btn.disabled = true;

  try {
    const res = await fetch("/calculate-comparison", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ job_a: jobA, job_b: jobB })
    });
    const r = await res.json();
    lastComparison = { result: r, nameA, nameB };
    renderComparison(r, nameA, nameB);

    // Handle optional Job C
    if (jobCVisible) {
      const jobC = getJobData("c", cRemoteDays);
      const nameC = document.getElementById("job_c_name").value.trim() || "C";
      if (jobC.salary > 0) {
        const res2 = await fetch("/calculate-comparison", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ job_a: jobA, job_b: jobC })
        });
        const r2 = await res2.json();
        renderJobC(r2, nameA, nameB, nameC, r.job_a.real_value, r.job_b.real_value, r2.job_b.real_value);
      }
    } else {
      document.getElementById("jobC_result_block").style.display = "none";
    }

    document.getElementById("compResults").classList.remove("hidden");
    document.getElementById("compResults").scrollIntoView({ behavior: "smooth", block: "start" });
  } catch (err) {
    showCJToast("Something went wrong. Please try again.");
  } finally {
    btnSpan.textContent = "Compare Job Offers";
    btn.disabled = false;
  }
}

function renderComparison(r, nameA, nameB) {
  const fmt = n => "£" + Math.round(Math.abs(n)).toLocaleString("en-GB");
  const winnerIsA = r.winner === "A";
  const winnerName = winnerIsA ? nameA : nameB;

  document.getElementById("res_winner").textContent = winnerName;
  document.getElementById("res_margin").textContent = fmt(r.margin);
  document.getElementById("res_desc").textContent = "better real value per year after all costs";
  document.getElementById("res_label_a").textContent = nameA.toUpperCase();
  document.getElementById("res_label_b").textContent = nameB.toUpperCase();

  document.getElementById("res_col_a").classList.toggle("winner", winnerIsA);
  document.getElementById("res_col_b").classList.toggle("winner", !winnerIsA);
  document.getElementById("ra_real").style.color = winnerIsA ? "var(--accent)" : "var(--white)";
  document.getElementById("rb_real").style.color = winnerIsA ? "var(--white)" : "var(--accent)";

  const a = r.job_a, b = r.job_b;
  const safeSet = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };

  safeSet("ra_gross", fmt(a.salary));
  safeSet("ra_takehome", fmt(a.take_home));
  safeSet("ra_commute", "-" + fmt(a.commute_cost_yearly));
  safeSet("ra_time", "-" + fmt(a.commute_time_value));
  safeSet("ra_pension", "+" + fmt(a.pension));
  safeSet("ra_real", fmt(a.real_value));

  safeSet("rb_gross", fmt(b.salary));
  safeSet("rb_takehome", fmt(b.take_home));
  safeSet("rb_commute", "-" + fmt(b.commute_cost_yearly));
  safeSet("rb_time", "-" + fmt(b.commute_time_value));
  safeSet("rb_pension", "+" + fmt(b.pension));
  safeSet("rb_real", fmt(b.real_value));

  const salDiff = a.salary - b.salary;
  const thDiff = a.take_home - b.take_home;

  safeSet("diff_salary", fmt(Math.abs(salDiff)) + " more (" + (salDiff >= 0 ? nameA : nameB) + ")");
  safeSet("diff_takehome", fmt(Math.abs(thDiff)) + " more (" + (thDiff >= 0 ? nameA : nameB) + ")");
  safeSet("diff_commute", fmt(Math.abs(r.diff_commute)) + " cheaper (" + (r.diff_commute >= 0 ? nameA : nameB) + ")");
  safeSet("diff_real", fmt(r.margin) + " better (" + winnerName + ")");

  safeSet("res_insight", winnerName + " is worth " + fmt(r.margin) + " more per year in real terms after all costs including commute.");
}

function renderJobC(r2, nameA, nameB, nameC, valA, valB, valC) {
  const fmt = n => "£" + Math.round(Math.abs(n)).toLocaleString("en-GB");
  const block = document.getElementById("jobC_result_block");
  const label = document.getElementById("jobC_result_label");
  const all = [{name:nameA,val:valA},{name:nameB,val:valB},{name:nameC,val:valC}].sort((a,b)=>b.val-a.val);

  label.textContent = nameC.toUpperCase() + " — OPTIONAL THIRD JOB";
  document.getElementById("jc_takehome").textContent = fmt(r2.job_b.take_home);
  document.getElementById("jc_commute").textContent = "-" + fmt(r2.job_b.commute_cost_yearly);
  document.getElementById("jc_value").textContent = fmt(valC);
  document.getElementById("jc_value").style.color = all[0].name === nameC ? "var(--accent)" : "var(--white)";
  document.getElementById("jc_insight").textContent =
    "Overall winner across all 3 options: " + all[0].name + " with " + fmt(all[0].val) + " true annual value — " + fmt(all[0].val - all[1].val) + " ahead of " + all[1].name + ".";
  block.style.display = "block";
}

function shareComparison(platform) {
  if (!lastComparison) return;
  const { result: r, nameA, nameB } = lastComparison;
  const fmt = n => "£" + Math.round(n).toLocaleString("en-GB");
  const winner = r.winner === "A" ? nameA : nameB;
  const text = "I compared two job offers. " + winner + " is worth " + fmt(r.margin) + " more per year once commute, tax and all costs are factored in. Calculate yours at traveltax.co.uk/compare-jobs";
  if (platform === "twitter") window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(text), "_blank");
  else if (platform === "whatsapp") window.open("https://wa.me/?text=" + encodeURIComponent(text), "_blank");
  else if (platform === "linkedin") window.open("https://www.linkedin.com/sharing/share-offsite/?url=" + encodeURIComponent("https://traveltax.co.uk/compare-jobs"), "_blank");
  else if (platform === "copy") navigator.clipboard.writeText(text).then(() => showCJToast("Copied!"));
}

function showCJToast(msg) {
  const existing = document.querySelector(".toast");
  if (existing) existing.remove();
  const t = document.createElement("div");
  t.className = "toast";
  t.textContent = msg;
  t.style.cssText = "position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#f0e040;color:#000;padding:12px 24px;font-family:monospace;font-size:12px;letter-spacing:0.08em;z-index:9999;max-width:400px;text-align:center;";
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 3500);
}
