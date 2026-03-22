/* TRAVEL TAX — self_employed.js */

let seLimited = true;

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("seBtn").addEventListener("click", calcSE);
});

function setSEStructure(ltd) {
  seLimited = ltd;
  document.getElementById("se_ltd_btn").classList.toggle("active", ltd);
  document.getElementById("se_sole_btn").classList.toggle("active", !ltd);
}

async function calcSE() {
  const btn = document.getElementById("seBtn");
  const paye = parseFloat(document.getElementById("se_paye").value) || 0;
  const rate = parseFloat(document.getElementById("se_dayrate").value) || 0;
  if (!paye || !rate) { seToast("Please enter both salary and day rate."); return; }
  const btnSpan = btn.querySelector("span") || btn;
  btnSpan.textContent = "Calculating...";
  btn.disabled = true;
  try {
    const res = await fetch("/calculate-self-employed", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        paye_salary: paye,
        day_rate: rate,
        days_per_year: parseInt(document.getElementById("se_days").value) || 220,
        limited_company: seLimited,
        expenses: parseFloat(document.getElementById("se_expenses").value) || 0,
      })
    });
    const r = await res.json();
    const fmt = n => "£" + Math.round(Math.abs(n)).toLocaleString("en-GB");
    document.getElementById("sePlaceholder").classList.add("hidden");
    document.getElementById("seResults").classList.remove("hidden");
    document.getElementById("se_verdict_label").textContent = r.se_wins ? "SELF-EMPLOYED WINS" : "PAYE WINS";
    document.getElementById("se_diff").textContent = fmt(r.difference);
    document.getElementById("se_verdict_sub").textContent = r.se_wins ? "more per year as " + r.structure : "more per year as PAYE employee";
    document.getElementById("se_paye_takehome").textContent = fmt(r.paye_take_home);
    document.getElementById("se_paye_monthly").textContent = fmt(r.paye_monthly) + "/month";
    document.getElementById("se_structure_label").textContent = r.structure.toUpperCase();
    document.getElementById("se_takehome").textContent = fmt(r.se_take_home);
    document.getElementById("se_takehome").style.color = r.se_wins ? "var(--accent)" : "var(--white)";
    document.getElementById("se_monthly").textContent = fmt(r.se_monthly) + "/month";
    document.getElementById("se_gross").textContent = fmt(r.gross_contract);
    document.getElementById("se_rate").textContent = r.effective_rate + "%";
    document.getElementById("se_takehome2").textContent = fmt(r.se_take_home);
    document.getElementById("se_equiv_rate").textContent = fmt(r.day_rate_needed) + "/day";
    document.getElementById("se_insight").textContent = r.se_wins
      ? "As a " + r.structure + " you take home " + fmt(r.difference) + " more per year. Effective tax rate: " + r.effective_rate + "%."
      : "PAYE wins by " + fmt(Math.abs(r.difference)) + ". You would need " + fmt(r.day_rate_needed) + "/day to match your PAYE take-home.";
    document.getElementById("seResultsPanel").scrollIntoView({ behavior: "smooth", block: "start" });
  } catch(e) { seToast("Something went wrong. Please try again."); }
  finally { btnSpan.textContent = "Compare Self-Employed vs PAYE"; btn.disabled = false; }
}

// Mobile
let seLtdMob = true;
function seMobileTab(tab) {
  document.getElementById("se_panel_calc").classList.toggle("active", tab === "calc");
  document.getElementById("se_panel_results").classList.toggle("active", tab === "results");
  document.querySelectorAll(".calc-mobile-tabs .calc-tab-btn").forEach((b,i) => b.classList.toggle("active", (i===0)===(tab==="calc")));
}
function setSEMob(ltd) {
  seLtdMob = ltd;
  document.getElementById("se_ltd_mob").classList.toggle("active", ltd);
  document.getElementById("se_sole_mob").classList.toggle("active", !ltd);
}
async function calcSEMob() {
  const paye = parseFloat(document.getElementById("se_paye_mob").value) || 0;
  const rate = parseFloat(document.getElementById("se_rate_mob").value) || 0;
  if (!paye || !rate) { seToast("Please enter both salary and day rate."); return; }
  try {
    const res = await fetch("/calculate-self-employed", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        paye_salary: paye, day_rate: rate,
        days_per_year: parseInt(document.getElementById("se_days_mob").value) || 220,
        limited_company: seLtdMob,
        expenses: parseFloat(document.getElementById("se_exp_mob").value) || 0,
      })
    });
    const r = await res.json();
    const fmt = n => "£" + Math.round(Math.abs(n)).toLocaleString("en-GB");
    document.getElementById("se_mob_placeholder").classList.add("hidden");
    document.getElementById("se_mob_results").classList.remove("hidden");
    document.getElementById("se_mob_verdict").textContent = r.se_wins ? "SELF-EMPLOYED WINS" : "PAYE WINS";
    document.getElementById("se_mob_diff").textContent = fmt(r.difference);
    document.getElementById("se_mob_sub").textContent = r.se_wins ? "more as " + r.structure : "more as PAYE employee";
    document.getElementById("se_mob_paye").textContent = fmt(r.paye_take_home);
    document.getElementById("se_mob_paye_mo").textContent = fmt(r.paye_monthly) + "/mo";
    document.getElementById("se_mob_struct").textContent = r.structure.toUpperCase();
    document.getElementById("se_mob_se").textContent = fmt(r.se_take_home);
    document.getElementById("se_mob_se").style.color = r.se_wins ? "var(--accent)" : "var(--white)";
    document.getElementById("se_mob_se_mo").textContent = fmt(r.se_monthly) + "/mo";
    document.getElementById("se_mob_insight").textContent = r.se_wins
      ? "As a " + r.structure + " you keep " + fmt(r.difference) + " more per year. Effective tax rate: " + r.effective_rate + "%."
      : "PAYE wins by " + fmt(Math.abs(r.difference)) + ". You would need " + fmt(r.day_rate_needed) + "/day to match.";
    seMobileTab("results");
  } catch(e) { seToast("Something went wrong."); }
}

function seToast(msg) {
  const t = document.createElement("div");
  t.textContent = msg;
  t.style.cssText = "position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#f0e040;color:#000;padding:12px 24px;font-family:monospace;font-size:12px;z-index:9999;";
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 3000);
}
