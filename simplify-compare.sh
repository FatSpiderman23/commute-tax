#!/bin/bash
TARGET=~/Documents/Commute\ Tax

# Fix ticker tape size on mobile
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* Ticker tape mobile fix */
@media (max-width: 768px) {
  .ticker-tape span {
    font-size: 9px !important;
  }
}

/* Compare jobs simplified */
.compare-grid-simple {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0;
  border: 1px solid var(--border);
}

.compare-grid-simple .job-col {
  padding: 28px 24px;
  background: var(--panel);
}

.compare-grid-simple .job-col:first-child {
  border-right: 1px solid var(--border);
}

.advanced-toggle {
  width: 100%;
  background: none;
  border: 1px dashed var(--border);
  color: var(--text-dimmer);
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.1em;
  padding: 10px;
  cursor: pointer;
  margin-top: 8px;
  transition: all 0.2s;
}

.advanced-toggle:hover {
  border-color: var(--accent);
  color: var(--accent);
}

.advanced-fields {
  display: none;
  margin-top: 8px;
}

.advanced-fields.open {
  display: block;
}

@media (max-width: 768px) {
  .compare-grid-simple {
    grid-template-columns: 1fr;
  }
  .compare-grid-simple .job-col:first-child {
    border-right: none;
    border-bottom: 1px solid var(--border);
  }
}
CSSEOF

# Rewrite compare_jobs.html with simplified form
cat > "$TARGET/templates/compare_jobs.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Job Offer Comparison Tool UK 2025 — Which Job Should I Take?</title>
  <meta name="description" content="Compare two job offers side by side. Takes into account salary, commute cost, pension, holidays and remote days to show which job is really worth more." />
  <meta name="keywords" content="job offer comparison, which job should I take, compare job offers UK, job offer calculator" />
  <link rel="canonical" href="https://www.traveltax.co.uk/compare-jobs" />
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    "name": "Job Offer Comparison Tool",
    "description": "Compare two UK job offers including salary, commute, pension and culture.",
    "url": "https://www.traveltax.co.uk/compare-jobs",
    "applicationCategory": "FinanceApplication",
    "offers": {"@type": "Offer", "price": "0", "priceCurrency": "GBP"}
  }
  </script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
  <style>
    .verdict-wrap { border:1px solid var(--accent); background:#0f0f00; padding:32px; text-align:center; margin-bottom:24px; }
    .verdict-winner { font-family:var(--font-display); font-size:64px; color:var(--accent); line-height:1; }
    .verdict-margin { font-family:var(--font-display); font-size:40px; color:var(--white); margin-top:8px; }
    .verdict-desc { font-size:13px; color:var(--text-dim); margin-top:8px; }
    .results-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:20px; }
    .result-col { background:var(--panel); border:1px solid var(--border); padding:20px; }
    .result-col.winner { border-color:var(--accent); background:#0f0f00; }
    .result-col-label { font-family:var(--font-mono); font-size:10px; letter-spacing:0.2em; color:var(--text-dimmer); margin-bottom:12px; }
    .result-row { display:flex; justify-content:space-between; padding:7px 0; border-bottom:1px solid var(--border); font-size:13px; color:var(--text-dim); }
    .result-row:last-child { border-bottom:none; }
    .result-row span:last-child { font-family:var(--font-mono); color:var(--text); }
    .result-real-value { font-family:var(--font-display); font-size:32px; color:var(--accent); margin-top:12px; }
    .diff-block { background:var(--panel); border:1px solid var(--border); padding:20px; margin-bottom:20px; }
    .diff-row { display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid var(--border); font-size:13px; }
    .diff-row:last-child { border-bottom:none; font-weight:500; font-size:14px; }
    .diff-positive { color:var(--green); font-family:var(--font-mono); }
    .diff-negative { color:var(--red); font-family:var(--font-mono); }
    .culture-slider { -webkit-appearance:none; width:100%; height:2px; background:var(--border-light); outline:none; cursor:pointer; }
    .culture-slider::-webkit-slider-thumb { -webkit-appearance:none; width:18px; height:18px; background:var(--accent); cursor:pointer; border-radius:0; }
    .job-label-a { font-family:var(--font-display); font-size:28px; color:var(--accent); }
    .job-label-b { font-family:var(--font-display); font-size:28px; color:var(--white); }
    @media(max-width:768px) { .results-grid { grid-template-columns:1fr; } }
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
      <a href="/guide" class="nav-link">Commute Guide</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>

  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>

  <main class="calc-section">

    <div class="compare-grid-simple">

      <!-- JOB A -->
      <div class="job-col">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
          <span class="job-label-a">A</span>
          <input type="text" id="job_a_name" placeholder="e.g. Current role" style="flex:1;background:var(--off-black);border:1px solid var(--border-light);color:var(--text);font-family:var(--font-mono);font-size:13px;padding:8px 12px;outline:none;" />
        </div>

        <div class="field-group">
          <label for="a_salary">Annual Salary (£)</label>
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
          <label for="a_commute_mins">One-Way Commute (mins)</label>
          <div class="input-wrap"><input type="number" id="a_commute_mins" placeholder="45" min="0" /></div>
        </div>

        <div class="field-group">
          <label for="a_commute_cost">Daily Transport Cost (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="a_commute_cost" placeholder="12.50" min="0" step="0.50" /></div>
        </div>

        <button class="advanced-toggle" onclick="toggleAdvanced('a')">+ Advanced options (bonus, pension, holidays, culture)</button>
        <div class="advanced-fields" id="a_advanced">
          <div class="field-group" style="margin-top:16px;">
            <label for="a_bonus">Annual Bonus (£)</label>
            <div class="input-wrap"><span class="prefix">£</span><input type="number" id="a_bonus" placeholder="0" min="0" /></div>
          </div>
          <div class="field-group">
            <label for="a_pension">Pension (%)</label>
            <div class="input-wrap"><input type="number" id="a_pension" placeholder="5" min="0" max="100" /></div>
          </div>
          <div class="field-group">
            <label for="a_holiday">Holiday Days</label>
            <div class="input-wrap"><input type="number" id="a_holiday" placeholder="25" min="0" /></div>
          </div>
          <div class="field-group">
            <label>Culture Score</label>
            <div style="display:flex;align-items:center;gap:12px;">
              <input type="range" class="culture-slider" id="a_culture" min="1" max="10" value="5" oninput="document.getElementById('a_culture_val').textContent=this.value+'/10'" />
              <span id="a_culture_val" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:52px;">5/10</span>
            </div>
            <p class="field-hint">1 = toxic, 10 = dream workplace</p>
          </div>
        </div>
      </div>

      <!-- JOB B -->
      <div class="job-col">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
          <span class="job-label-b">B</span>
          <input type="text" id="job_b_name" placeholder="e.g. New offer" style="flex:1;background:var(--off-black);border:1px solid var(--border-light);color:var(--text);font-family:var(--font-mono);font-size:13px;padding:8px 12px;outline:none;" />
        </div>

        <div class="field-group">
          <label for="b_salary">Annual Salary (£)</label>
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
          <label for="b_commute_mins">One-Way Commute (mins)</label>
          <div class="input-wrap"><input type="number" id="b_commute_mins" placeholder="30" min="0" /></div>
        </div>

        <div class="field-group">
          <label for="b_commute_cost">Daily Transport Cost (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="b_commute_cost" placeholder="8.00" min="0" step="0.50" /></div>
        </div>

        <button class="advanced-toggle" onclick="toggleAdvanced('b')">+ Advanced options (bonus, pension, holidays, culture)</button>
        <div class="advanced-fields" id="b_advanced">
          <div class="field-group" style="margin-top:16px;">
            <label for="b_bonus">Annual Bonus (£)</label>
            <div class="input-wrap"><span class="prefix">£</span><input type="number" id="b_bonus" placeholder="0" min="0" /></div>
          </div>
          <div class="field-group">
            <label for="b_pension">Pension (%)</label>
            <div class="input-wrap"><input type="number" id="b_pension" placeholder="5" min="0" max="100" /></div>
          </div>
          <div class="field-group">
            <label for="b_holiday">Holiday Days</label>
            <div class="input-wrap"><input type="number" id="b_holiday" placeholder="25" min="0" /></div>
          </div>
          <div class="field-group">
            <label>Culture Score</label>
            <div style="display:flex;align-items:center;gap:12px;">
              <input type="range" class="culture-slider" id="b_culture" min="1" max="10" value="5" oninput="document.getElementById('b_culture_val').textContent=this.value+'/10'" />
              <span id="b_culture_val" style="font-family:var(--font-display);font-size:22px;color:var(--white);min-width:52px;">5/10</span>
            </div>
            <p class="field-hint">1 = toxic, 10 = dream workplace</p>
          </div>
        </div>
      </div>
    </div>

    <button class="calculate-btn" id="compareBtn" onclick="runComparison()" style="border-radius:0;margin-top:0;">
      <span>Compare Job Offers</span>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
    </button>

    <!-- RESULTS -->
    <div id="compResults" class="hidden" style="margin-top:24px;">

      <div class="verdict-wrap">
        <p class="verdict-label">THE WINNER IS</p>
        <div class="verdict-winner" id="res_winner">A</div>
        <div class="verdict-margin" id="res_margin">£0</div>
        <p class="verdict-desc" id="res_desc">better in real terms per year</p>
      </div>

      <div class="results-grid">
        <div class="result-col" id="res_col_a">
          <p class="result-col-label" id="res_label_a">JOB A</p>
          <div class="result-row"><span>Gross salary</span><span id="ra_gross">£0</span></div>
          <div class="result-row"><span>Take home</span><span id="ra_takehome">£0</span></div>
          <div class="result-row"><span>Commute cost</span><span id="ra_commute" style="color:var(--red)">-£0</span></div>
          <div class="result-row"><span>Commute time value</span><span id="ra_time" style="color:var(--red)">-£0</span></div>
          <div class="result-row"><span>Pension</span><span id="ra_pension" style="color:var(--green)">+£0</span></div>
          <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--text-dimmer);margin-top:12px;">TRUE VALUE</p>
          <div class="result-real-value" id="ra_real">£0</div>
        </div>
        <div class="result-col" id="res_col_b">
          <p class="result-col-label" id="res_label_b">JOB B</p>
          <div class="result-row"><span>Gross salary</span><span id="rb_gross">£0</span></div>
          <div class="result-row"><span>Take home</span><span id="rb_takehome">£0</span></div>
          <div class="result-row"><span>Commute cost</span><span id="rb_commute" style="color:var(--red)">-£0</span></div>
          <div class="result-row"><span>Commute time value</span><span id="rb_time" style="color:var(--red)">-£0</span></div>
          <div class="result-row"><span>Pension</span><span id="rb_pension" style="color:var(--green)">+£0</span></div>
          <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--text-dimmer);margin-top:12px;">TRUE VALUE</p>
          <div class="result-real-value" id="rb_real" style="color:var(--white)">£0</div>
        </div>
      </div>

      <div class="diff-block">
        <h3 class="block-title">Key Differences</h3>
        <div class="diff-row"><span>Salary difference</span><span id="diff_salary" class="diff-positive">£0</span></div>
        <div class="diff-row"><span>Take home difference</span><span id="diff_takehome" class="diff-positive">£0</span></div>
        <div class="diff-row"><span>Commute cost difference</span><span id="diff_commute" class="diff-positive">£0</span></div>
        <div class="diff-row"><span>Real value difference</span><span id="diff_real" class="diff-positive">£0</span></div>
      </div>

      <div class="savings-callout" id="res_insight" style="margin-bottom:20px;font-size:14px;line-height:1.7;"></div>

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
      <div class="faq-item">
        <h3>How is the true value calculated?</h3>
        <p>We take your take home pay, add pension and bonus, then subtract the full commute cost including the monetary value of your commute time at your hourly rate. This gives you the real annual value of each role.</p>
      </div>
      <div class="faq-item">
        <h3>Should I always take the higher true value job?</h3>
        <p>Not necessarily. The tool gives the financial picture. Career development, job security, and personal circumstances all matter too. Use it as one input in your decision.</p>
      </div>
    </div>
  </section>

  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/compare-jobs">Compare Jobs</a> · <a href="/guide">Guide</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p>
  </footer>

  <script src="/static/js/compare_jobs.js"></script>
</body>
</html>
HTMLEOF

# Update compare_jobs.js to add toggleAdvanced and handle missing fields
cat >> "$TARGET/static/js/compare_jobs.js" << 'JSEOF'

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
JSEOF

echo ""
echo "Testing..."
cd "$TARGET" && python3 -c "import app; print('OK')" 2>&1

echo ""
echo "Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Simplify compare jobs, fix ticker mobile' && git push"
