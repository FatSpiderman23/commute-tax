#!/bin/bash

cat > ~/Documents/Commute\ Tax/templates/compare_jobs.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Job Offer Comparison Tool UK 2026 — Which Job Should I Take?</title>
  <meta name="description" content="Compare two job offers side by side. Takes into account salary, commute cost, pension, holidays and remote days to show which job is really worth more." />
  <meta name="keywords" content="job offer comparison, which job should I take, compare job offers UK, job offer calculator" />
  <link rel="canonical" href="https://www.traveltax.co.uk/compare-jobs" />
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"WebApplication","name":"Job Offer Comparison Tool","url":"https://www.traveltax.co.uk/compare-jobs","applicationCategory":"FinanceApplication","offers":{"@type":"Offer","price":"0","priceCurrency":"GBP"}}</script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
  <style>
    .jobs-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0; border: 1px solid var(--border); }
    .job-col { padding: 28px 24px; background: var(--panel); }
    .job-col:first-child { border-right: 1px solid var(--border); }
    .job-label-a { font-family: var(--font-display); font-size: 32px; color: var(--accent); }
    .job-label-b { font-family: var(--font-display); font-size: 32px; color: var(--white); }
    .job-name-input { flex: 1; background: var(--off-black); border: 1px solid var(--border-light); color: var(--text); font-family: var(--font-mono); font-size: 13px; padding: 8px 12px; outline: none; }
    .job-name-input:focus { border-color: var(--accent); }
    .verdict-wrap { border: 1px solid var(--accent); background: #0f0f00; padding: 32px; text-align: center; margin-bottom: 20px; }
    .verdict-winner { font-family: var(--font-display); font-size: 56px; color: var(--accent); line-height: 1; }
    .verdict-margin { font-family: var(--font-display); font-size: 40px; color: var(--white); margin-top: 4px; }
    .results-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px; }
    .result-col { background: var(--panel); border: 1px solid var(--border); padding: 20px; }
    .result-col.winner { border-color: var(--accent); background: #0f0f00; }
    .result-col-label { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.2em; color: var(--text-dimmer); margin-bottom: 12px; }
    .result-row { display: flex; justify-content: space-between; padding: 7px 0; border-bottom: 1px solid var(--border); font-size: 13px; }
    .result-row:last-child { border-bottom: none; }
    .result-real-value { font-family: var(--font-display); font-size: 30px; margin-top: 12px; }
    .diff-block { background: var(--panel); border: 1px solid var(--border); padding: 20px; margin-bottom: 20px; }
    .diff-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid var(--border); font-size: 13px; }
    .diff-row:last-child { border-bottom: none; font-weight: 500; }
    .diff-pos { color: #4caf50; font-family: var(--font-mono); }
    .diff-neg { color: #f44336; font-family: var(--font-mono); }
    .add-job-btn { width: 100%; padding: 12px; background: var(--off-black); border: 1px dashed var(--border); color: var(--accent); font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.1em; cursor: pointer; margin-top: 0; transition: all 0.2s; }
    .add-job-btn:hover { border-color: var(--accent); background: var(--panel); }
    .job-c-block { border: 1px solid var(--border); border-top: none; background: var(--panel); padding: 24px; }
    .job-c-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .job-c-result { background: var(--off-black); border: 1px solid var(--border); padding: 20px; margin-top: 16px; }
    @media (max-width: 768px) {
      .jobs-grid { grid-template-columns: 1fr; }
      .job-col:first-child { border-right: none; border-bottom: 1px solid var(--border); }
      .results-grid { grid-template-columns: 1fr; }
      .job-c-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>

  <header class="slim-header">
    <div class="slim-header-inner">
      <div class="slim-logo">
        <a href="/" style="text-decoration:none">
          <span class="slim-logo-main">Travel Tax.</span>
          <span class="slim-logo-sub">UK Financial Reality Check</span>
        </a>
      </div>
      <div class="slim-stats">
        <span>Avg UK commute: <strong>59 min/day</strong></span>
        <span>Avg cost: <strong>£135/month</strong></span>
        <span>Hours lost: <strong>243/yr</strong></span>
      </div>
    </div>
    <div class="ticker-tape">
      <span>JOB OFFER COMPARISON &nbsp;·&nbsp; WHICH JOB SHOULD I TAKE? &nbsp;·&nbsp; SALARY IS NOT THE WHOLE STORY &nbsp;·&nbsp;</span>
      <span aria-hidden="true">JOB OFFER COMPARISON &nbsp;·&nbsp; WHICH JOB SHOULD I TAKE? &nbsp;·&nbsp; SALARY IS NOT THE WHOLE STORY &nbsp;·&nbsp;</span>
    </div>
  </header>

  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/compare-jobs" class="nav-link active">Compare Jobs</a>
      <a href="/city-comparison" class="nav-link">City Comparison</a>
      <a href="/buy-vs-rent" class="nav-link">Buy vs Rent</a>
      <div class="nav-dropdown">
        <button class="nav-link nav-dropdown-btn">More Tools ▾</button>
        <div class="nav-dropdown-menu">
          <a href="/student-loan" class="nav-dropdown-item">Student Loan</a>
          <a href="/pension-calculator" class="nav-dropdown-item">Pension Calculator</a>
          <a href="/redundancy-calculator" class="nav-dropdown-item">Redundancy Pay</a>
          <a href="/maternity-calculator" class="nav-dropdown-item">Maternity Pay</a>
          <a href="/self-employed-vs-paye" class="nav-dropdown-item">Self-Employed vs PAYE</a>
          <a href="/tools" class="nav-dropdown-item">All Tools →</a>
        </div>
      </div>
      <a href="/cost-of-living" class="nav-link">Cost of Living</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>

  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>

  <main class="calc-section">

    <!-- JOB A and B — always visible -->
    <div class="jobs-grid">
      <div class="job-col">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
          <span class="job-label-a">A</span>
          <input type="text" class="job-name-input" id="job_a_name" placeholder="e.g. Current role" />
        </div>
        <div class="field-group">
          <label>Annual Salary (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="a_salary" placeholder="35000" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Remote Days Per Week</label>
          <div class="day-toggle" id="a_remote_toggle">
            <button class="day-btn active" data-val="0">0</button>
            <button class="day-btn" data-val="1">1</button>
            <button class="day-btn" data-val="2">2</button>
            <button class="day-btn" data-val="3">3</button>
            <button class="day-btn" data-val="4">4</button>
            <button class="day-btn" data-val="5">5</button>
          </div>
        </div>
        <div class="field-group">
          <label>One-Way Commute (mins)</label>
          <div class="input-wrap"><input type="number" id="a_commute_mins" placeholder="45" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Daily Transport Cost (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="a_commute_cost" placeholder="12.50" min="0" step="0.50" /></div>
        </div>
        <button class="advanced-toggle" onclick="toggleAdvanced('a')">+ Advanced (bonus, pension, holidays, culture)</button>
        <div class="advanced-fields" id="a_advanced">
          <div class="field-group" style="margin-top:12px;">
            <label>Bonus (£)</label>
            <div class="input-wrap"><span class="prefix">£</span><input type="number" id="a_bonus" placeholder="0" min="0" /></div>
          </div>
          <div class="field-group">
            <label>Pension (%)</label>
            <div class="input-wrap"><input type="number" id="a_pension" placeholder="5" min="0" max="100" /></div>
          </div>
          <div class="field-group">
            <label>Holiday Days</label>
            <div class="input-wrap"><input type="number" id="a_holiday" placeholder="25" min="0" /></div>
          </div>
          <div class="field-group">
            <label>Culture Score (1-10)</label>
            <div style="display:flex;align-items:center;gap:12px;">
              <input type="range" id="a_culture" min="1" max="10" value="5" style="-webkit-appearance:none;width:100%;height:2px;background:var(--border-light);outline:none;cursor:pointer;" oninput="document.getElementById('a_culture_val').textContent=this.value+'/10'" />
              <span id="a_culture_val" style="font-family:var(--font-display);font-size:20px;color:var(--accent);min-width:48px;">5/10</span>
            </div>
          </div>
        </div>
      </div>

      <div class="job-col">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
          <span class="job-label-b">B</span>
          <input type="text" class="job-name-input" id="job_b_name" placeholder="e.g. New offer" />
        </div>
        <div class="field-group">
          <label>Annual Salary (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="b_salary" placeholder="40000" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Remote Days Per Week</label>
          <div class="day-toggle" id="b_remote_toggle">
            <button class="day-btn active" data-val="0">0</button>
            <button class="day-btn" data-val="1">1</button>
            <button class="day-btn" data-val="2">2</button>
            <button class="day-btn" data-val="3">3</button>
            <button class="day-btn" data-val="4">4</button>
            <button class="day-btn" data-val="5">5</button>
          </div>
        </div>
        <div class="field-group">
          <label>One-Way Commute (mins)</label>
          <div class="input-wrap"><input type="number" id="b_commute_mins" placeholder="30" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Daily Transport Cost (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="b_commute_cost" placeholder="8.00" min="0" step="0.50" /></div>
        </div>
        <button class="advanced-toggle" onclick="toggleAdvanced('b')">+ Advanced (bonus, pension, holidays, culture)</button>
        <div class="advanced-fields" id="b_advanced">
          <div class="field-group" style="margin-top:12px;">
            <label>Bonus (£)</label>
            <div class="input-wrap"><span class="prefix">£</span><input type="number" id="b_bonus" placeholder="0" min="0" /></div>
          </div>
          <div class="field-group">
            <label>Pension (%)</label>
            <div class="input-wrap"><input type="number" id="b_pension" placeholder="5" min="0" max="100" /></div>
          </div>
          <div class="field-group">
            <label>Holiday Days</label>
            <div class="input-wrap"><input type="number" id="b_holiday" placeholder="25" min="0" /></div>
          </div>
          <div class="field-group">
            <label>Culture Score (1-10)</label>
            <div style="display:flex;align-items:center;gap:12px;">
              <input type="range" id="b_culture" min="1" max="10" value="5" style="-webkit-appearance:none;width:100%;height:2px;background:var(--border-light);outline:none;cursor:pointer;" oninput="document.getElementById('b_culture_val').textContent=this.value+'/10'" />
              <span id="b_culture_val" style="font-family:var(--font-display);font-size:20px;color:var(--white);min-width:48px;">5/10</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Optional Job C -->
    <button class="add-job-btn" id="addJobCBtn" onclick="toggleJobC()">+ Add a third job to compare (optional)</button>
    <div id="jobC_block" style="display:none;">
      <div class="job-c-block">
        <div class="job-c-grid">
          <div>
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
              <span style="font-family:var(--font-display);font-size:28px;color:var(--text-dim);">C</span>
              <input type="text" class="job-name-input" id="job_c_name" placeholder="e.g. Third option" />
            </div>
            <div class="field-group">
              <label>Annual Salary (£)</label>
              <div class="input-wrap"><span class="prefix">£</span><input type="number" id="c_salary" placeholder="38000" min="0" /></div>
            </div>
            <div class="field-group">
              <label>Remote Days Per Week</label>
              <div class="day-toggle" id="c_remote_toggle">
                <button class="day-btn active" data-val="0">0</button>
                <button class="day-btn" data-val="1">1</button>
                <button class="day-btn" data-val="2">2</button>
                <button class="day-btn" data-val="3">3</button>
                <button class="day-btn" data-val="4">4</button>
                <button class="day-btn" data-val="5">5</button>
              </div>
            </div>
          </div>
          <div>
            <div class="field-group" style="margin-top:56px;">
              <label>One-Way Commute (mins)</label>
              <div class="input-wrap"><input type="number" id="c_commute_mins" placeholder="20" min="0" /></div>
            </div>
            <div class="field-group">
              <label>Daily Transport Cost (£)</label>
              <div class="input-wrap"><span class="prefix">£</span><input type="number" id="c_commute_cost" placeholder="5.00" min="0" step="0.50" /></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Calculate button -->
    <button class="calculate-btn" id="compareBtn" onclick="runComparison()" style="border-radius:0;margin-top:0;">
      <span>Compare Job Offers</span>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
    </button>

    <!-- RESULTS A vs B -->
    <div id="compResults" class="hidden" style="margin-top:24px;">
      <div class="verdict-wrap">
        <p class="verdict-label">THE WINNER IS</p>
        <div class="verdict-winner" id="res_winner">A</div>
        <div class="verdict-margin" id="res_margin">£0</div>
        <p class="verdict-sub" id="res_desc">better real value per year</p>
      </div>
      <div class="results-grid">
        <div class="result-col" id="res_col_a">
          <p class="result-col-label" id="res_label_a">JOB A</p>
          <div class="result-row"><span>Gross salary</span><span id="ra_gross">£0</span></div>
          <div class="result-row"><span>Take home</span><span id="ra_takehome">£0</span></div>
          <div class="result-row"><span>Commute cost</span><span id="ra_commute" style="color:#f44">-£0</span></div>
          <div class="result-row"><span>Time cost</span><span id="ra_time" style="color:#f44">-£0</span></div>
          <div class="result-row"><span>Pension</span><span id="ra_pension" style="color:#4c4">+£0</span></div>
          <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--text-dimmer);margin-top:12px;">TRUE VALUE</p>
          <div class="result-real-value" id="ra_real">£0</div>
        </div>
        <div class="result-col" id="res_col_b">
          <p class="result-col-label" id="res_label_b">JOB B</p>
          <div class="result-row"><span>Gross salary</span><span id="rb_gross">£0</span></div>
          <div class="result-row"><span>Take home</span><span id="rb_takehome">£0</span></div>
          <div class="result-row"><span>Commute cost</span><span id="rb_commute" style="color:#f44">-£0</span></div>
          <div class="result-row"><span>Time cost</span><span id="rb_time" style="color:#f44">-£0</span></div>
          <div class="result-row"><span>Pension</span><span id="rb_pension" style="color:#4c4">+£0</span></div>
          <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--text-dimmer);margin-top:12px;">TRUE VALUE</p>
          <div class="result-real-value" id="rb_real">£0</div>
        </div>
      </div>

      <div class="diff-block">
        <h3 class="block-title">Key Differences</h3>
        <div class="diff-row"><span>Salary difference</span><span id="diff_salary" class="diff-pos">£0</span></div>
        <div class="diff-row"><span>Take home difference</span><span id="diff_takehome" class="diff-pos">£0</span></div>
        <div class="diff-row"><span>Commute cost difference</span><span id="diff_commute" class="diff-pos">£0</span></div>
        <div class="diff-row"><span>Real value difference</span><span id="diff_real" class="diff-pos">£0</span></div>
      </div>

      <div class="savings-callout" id="res_insight" style="margin-bottom:20px;font-size:14px;line-height:1.7;"></div>

      <!-- Job C result block — appended here by JS when needed -->
      <div id="jobC_result_block" style="display:none;border:1px solid var(--border);background:var(--panel);padding:20px;margin-bottom:20px;">
        <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.2em;color:var(--accent);margin-bottom:12px;" id="jobC_result_label">JOB C</p>
        <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;margin-bottom:12px;">
          <div style="text-align:center;padding:12px;border:1px solid var(--border);">
            <div style="font-family:var(--font-mono);font-size:9px;color:var(--text-dimmer);margin-bottom:4px;">TAKE HOME</div>
            <div style="font-family:var(--font-display);font-size:22px;color:var(--white);" id="jc_takehome">£0</div>
          </div>
          <div style="text-align:center;padding:12px;border:1px solid var(--border);">
            <div style="font-family:var(--font-mono);font-size:9px;color:var(--text-dimmer);margin-bottom:4px;">COMMUTE COST</div>
            <div style="font-family:var(--font-display);font-size:22px;color:#f44;" id="jc_commute">-£0</div>
          </div>
          <div style="text-align:center;padding:12px;border:1px solid var(--border);">
            <div style="font-family:var(--font-mono);font-size:9px;color:var(--text-dimmer);margin-bottom:4px;">TRUE VALUE</div>
            <div style="font-family:var(--font-display);font-size:22px;" id="jc_value">£0</div>
          </div>
        </div>
        <p style="font-size:13px;color:var(--text-dim);" id="jc_insight"></p>
      </div>

      <div class="share-block">
        <p class="share-label">Share your comparison</p>
        <div class="share-btns-grid">
          <button class="share-btn s-twitter" onclick="shareComparison('twitter')">X Twitter</button>
          <button class="share-btn s-whatsapp" onclick="shareComparison('whatsapp')">WhatsApp</button>
          <button class="share-btn s-linkedin" onclick="shareComparison('linkedin')">LinkedIn</button>
          <button class="share-btn s-copy" onclick="shareComparison('copy')">Copy</button>
        </div>
      </div>

      <div class="comparison-block">
        <h3 class="block-title">Also Try</h3>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:4px;">
          <a href="/" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Commute Calculator →</a>
          <a href="/take-home" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Take Home Pay →</a>
        </div>
      </div>
    </div>

  </main>

  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Frequently Asked Questions</h2>
      <div class="faq-item"><h3>How is true value calculated?</h3><p>We take your take home pay, add pension and bonus, then subtract the full commute cost including the monetary value of your time at your hourly rate.</p></div>
      <div class="faq-item"><h3>Should I always take the higher true value job?</h3><p>Not necessarily. Career development, job security, and personal circumstances all matter. Use this as one input in your decision.</p></div>
    </div>
  </section>

  <footer class="site-footer">
    <p>© 2026 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/compare-jobs">Compare Jobs</a> · <a href="/tools">All Tools</a> · <a href="/privacy">Privacy</a></p>
  </footer>

  <script src="/static/js/compare_jobs.js"></script>
  <script>
  document.addEventListener("DOMContentLoaded", function() {
    var dropdown = document.querySelector(".nav-dropdown");
    var btn = document.querySelector(".nav-dropdown-btn");
    if (!btn || !dropdown) return;
    btn.addEventListener("click", function(e) {
      e.stopPropagation();
      dropdown.classList.toggle("open");
    });
    document.addEventListener("click", function(e) {
      if (!dropdown.contains(e.target)) dropdown.classList.remove("open");
    });
  });
  </script>
</body>
</html>
HTMLEOF

echo "Done — now rewriting compare_jobs.js cleanly"

cat > ~/Documents/Commute\ Tax/static/js/compare_jobs.js << 'JSEOF'
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
JSEOF

echo "✅ Done — push with:"
echo "cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Rebuild compare jobs and JS from scratch' && git push"
