#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🔨 Building Tool 3 - Job Offer Comparison..."

# ── 1. Add route to app.py ────────────────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

new_code = '''
# =============================================
# TOOL 3: JOB OFFER COMPARISON
# =============================================

def calculate_job_comparison(data):
    weeks = 48

    def calc_job(job):
        salary = float(job.get("salary", 0))
        bonus = float(job.get("bonus", 0))
        pension_pct = float(job.get("pension_pct", 0))
        holiday_days = float(job.get("holiday_days", 25))
        remote_days = float(job.get("remote_days", 0))
        commute_mins = float(job.get("commute_mins", 0))
        commute_cost_daily = float(job.get("commute_cost_daily", 0))
        culture_score = float(job.get("culture_score", 5))

        office_days = 5 - remote_days
        working_days = office_days * weeks

        # Take home (simplified)
        personal_allowance = 12570
        taxable = max(0, salary - personal_allowance)
        if taxable <= 37700:
            tax = taxable * 0.20
        elif taxable <= 112570:
            tax = 37700 * 0.20 + (taxable - 37700) * 0.40
        else:
            tax = 37700 * 0.20 + 74870 * 0.40 + (taxable - 112570) * 0.45

        ni = 0
        if salary > 12570:
            if salary <= 50270:
                ni = (salary - 12570) * 0.08
            else:
                ni = (50270 - 12570) * 0.08 + (salary - 50270) * 0.02

        pension = salary * (pension_pct / 100)
        take_home = salary - tax - ni - pension

        # Commute costs
        commute_cost_yearly = commute_cost_daily * working_days
        commute_hours_yearly = (commute_mins * 2 * working_days) / 60
        hourly_rate = salary / (weeks * 5 * 8) if salary > 0 else 0
        commute_time_value = commute_hours_yearly * hourly_rate

        # Total real value
        total_commute_cost = commute_cost_yearly + commute_time_value
        real_value = take_home + bonus - total_commute_cost

        # Holiday value
        daily_rate = salary / 260
        holiday_value = holiday_days * daily_rate

        # Remote value (time saved)
        remote_time_hours = remote_days * weeks * (commute_mins * 2 / 60)
        remote_time_value = remote_time_hours * hourly_rate

        # Culture adjusted value
        culture_multiplier = culture_score / 5
        happiness_adjusted = real_value * (0.7 + culture_multiplier * 0.3)

        return {
            "salary": round(salary),
            "bonus": round(bonus),
            "take_home": round(take_home),
            "take_home_monthly": round(take_home / 12),
            "pension": round(pension),
            "commute_cost_yearly": round(commute_cost_yearly),
            "commute_time_value": round(commute_time_value),
            "total_commute_cost": round(total_commute_cost),
            "real_value": round(real_value),
            "holiday_value": round(holiday_value),
            "remote_time_value": round(remote_time_value),
            "happiness_adjusted": round(happiness_adjusted),
            "commute_hours_yearly": round(commute_hours_yearly),
            "total_package": round(salary + bonus + pension + holiday_value),
        }

    job_a = calc_job(data.get("job_a", {}))
    job_b = calc_job(data.get("job_b", {}))

    diff = job_a["real_value"] - job_b["real_value"]
    winner = "A" if diff > 0 else "B"
    margin = abs(diff)

    return {
        "job_a": job_a,
        "job_b": job_b,
        "winner": winner,
        "margin": round(margin),
        "diff_take_home": round(job_a["take_home"] - job_b["take_home"]),
        "diff_commute": round(job_b["total_commute_cost"] - job_a["total_commute_cost"]),
        "diff_real_value": round(diff),
    }


@app.route("/compare-jobs")
def compare_jobs_page():
    return render_template("compare_jobs.html")


@app.route("/calculate-comparison", methods=["POST"])
def calculate_comparison():
    data = request.get_json()
    result = calculate_job_comparison(data)
    return jsonify(result)

'''

content = content.replace('if __name__ == "__main__":', new_code + '\nif __name__ == "__main__":')

# Add to sitemap
content = content.replace(
    '{"loc": "https://www.traveltax.co.uk/take-home", "priority": "0.9", "changefreq": "monthly"},',
    '{"loc": "https://www.traveltax.co.uk/take-home", "priority": "0.9", "changefreq": "monthly"},\n        {"loc": "https://www.traveltax.co.uk/compare-jobs", "priority": "0.9", "changefreq": "monthly"},'
)

with open(path, 'w') as f:
    f.write(content)
print("Done app.py")
PYEOF

# ── 2. Compare Jobs HTML ──────────────────────────────────────────────────────
cat > "$TARGET/templates/compare_jobs.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Job Offer Comparison Tool UK 2025 — Which Job Should I Take?</title>
  <meta name="description" content="Compare two job offers side by side. Takes into account salary, take home pay, commute cost, pension, holidays and remote days to show which job is really worth more." />
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
    .compare-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0; border: 1px solid var(--border); }
    .job-col { padding: 32px 28px; background: var(--panel); }
    .job-col:first-child { border-right: 1px solid var(--border); }
    .job-col-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
    .job-label { font-family: var(--font-display); font-size: 32px; color: var(--accent); }
    .job-name-input { flex: 1; background: var(--off-black); border: 1px solid var(--border-light); color: var(--text); font-family: var(--font-mono); font-size: 13px; padding: 8px 12px; outline: none; }
    .job-name-input:focus { border-color: var(--accent); }
    .compare-btn { width: 100%; padding: 20px; background: var(--accent); color: var(--black); border: none; font-family: var(--font-mono); font-size: 14px; font-weight: 500; letter-spacing: 0.12em; text-transform: uppercase; cursor: pointer; transition: background 0.2s; margin-top: 0; }
    .compare-btn:hover { background: var(--white); }
    .verdict-wrap { border: 1px solid var(--accent); background: #0f0f00; padding: 40px; text-align: center; margin-bottom: 24px; }
    .verdict-winner { font-family: var(--font-display); font-size: 80px; color: var(--accent); line-height: 1; }
    .verdict-margin { font-family: var(--font-display); font-size: 48px; color: var(--white); }
    .verdict-desc { font-size: 14px; color: var(--text-dim); margin-top: 12px; }
    .results-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
    .result-col { background: var(--panel); border: 1px solid var(--border); padding: 24px; }
    .result-col.winner { border-color: var(--accent); background: #0f0f00; }
    .result-col-label { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.2em; color: var(--text-dimmer); margin-bottom: 16px; }
    .result-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--border); font-size: 13px; color: var(--text-dim); }
    .result-row:last-child { border-bottom: none; }
    .result-row span:last-child { font-family: var(--font-mono); color: var(--text); }
    .result-real-value { font-family: var(--font-display); font-size: 36px; color: var(--accent); margin-top: 12px; }
    .diff-block { background: var(--panel); border: 1px solid var(--border); padding: 24px; margin-bottom: 24px; }
    .diff-row { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--border); font-size: 14px; }
    .diff-row:last-child { border-bottom: none; }
    .diff-positive { color: var(--green); font-family: var(--font-mono); font-weight: 500; }
    .diff-negative { color: var(--red); font-family: var(--font-mono); font-weight: 500; }
    .culture-slider { -webkit-appearance: none; width: 100%; height: 2px; background: var(--border-light); outline: none; cursor: pointer; }
    .culture-slider::-webkit-slider-thumb { -webkit-appearance: none; width: 18px; height: 18px; background: var(--accent); cursor: pointer; border-radius: 0; }
    @media (max-width: 768px) {
      .compare-grid { grid-template-columns: 1fr; }
      .job-col:first-child { border-right: none; border-bottom: 1px solid var(--border); }
      .results-grid { grid-template-columns: 1fr; }
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
        <span>Salary · Commute · Pension · Culture</span>
      </div>
    </div>
    <div class="ticker-tape">
      <span>JOB OFFER COMPARISON &nbsp;·&nbsp; WHICH JOB SHOULD I TAKE? &nbsp;·&nbsp; TRUE VALUE CALCULATOR &nbsp;·&nbsp; SALARY IS NOT THE WHOLE STORY &nbsp;·&nbsp; JOB OFFER COMPARISON &nbsp;·&nbsp;</span>
      <span aria-hidden="true">JOB OFFER COMPARISON &nbsp;·&nbsp; WHICH JOB SHOULD I TAKE? &nbsp;·&nbsp; TRUE VALUE CALCULATOR &nbsp;·&nbsp; SALARY IS NOT THE WHOLE STORY &nbsp;·&nbsp; JOB OFFER COMPARISON &nbsp;·&nbsp;</span>
    </div>
  </header>

  <main class="calc-section">

    <!-- INPUT GRID -->
    <div class="compare-grid" id="inputGrid">

      <!-- JOB A -->
      <div class="job-col">
        <div class="job-col-header">
          <span class="job-label">A</span>
          <input type="text" class="job-name-input" id="job_a_name" placeholder="Job A (e.g. Current role)" />
        </div>

        <div class="field-group">
          <label>Annual Salary (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="a_salary" placeholder="35000" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Annual Bonus (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="a_bonus" placeholder="0" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Employer Pension (%)</label>
          <div class="slider-wrap">
            <input type="range" id="a_pension_slider" min="0" max="20" value="5" step="1" oninput="document.getElementById('a_pension').value=this.value" />
            <div class="slider-input-wrap">
              <input type="number" id="a_pension" value="5" min="0" max="100" oninput="document.getElementById('a_pension_slider').value=Math.min(this.value,20)" />
              <span class="slider-unit">%</span>
            </div>
          </div>
        </div>
        <div class="field-group">
          <label>Holiday Days</label>
          <div class="slider-wrap">
            <input type="range" id="a_holiday_slider" min="20" max="40" value="25" step="1" oninput="document.getElementById('a_holiday').value=this.value" />
            <div class="slider-input-wrap">
              <input type="number" id="a_holiday" value="25" min="0" oninput="document.getElementById('a_holiday_slider').value=Math.min(this.value,40)" />
              <span class="slider-unit">days</span>
            </div>
          </div>
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
          <label>One-Way Commute Time (mins)</label>
          <div class="input-wrap"><input type="number" id="a_commute_mins" placeholder="45" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Daily Transport Cost (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="a_commute_cost" placeholder="12.50" min="0" step="0.50" /></div>
        </div>
        <div class="field-group">
          <label>Company Culture Score</label>
          <div style="display:flex;align-items:center;gap:12px;">
            <input type="range" class="culture-slider" id="a_culture" min="1" max="10" value="5" oninput="document.getElementById('a_culture_val').textContent=this.value+'/10'" />
            <span id="a_culture_val" style="font-family:var(--font-display);font-size:24px;color:var(--accent);min-width:60px;">5/10</span>
          </div>
          <p class="field-hint">1 = toxic, 10 = dream workplace</p>
        </div>
      </div>

      <!-- JOB B -->
      <div class="job-col">
        <div class="job-col-header">
          <span class="job-label" style="color:var(--white)">B</span>
          <input type="text" class="job-name-input" id="job_b_name" placeholder="Job B (e.g. New offer)" />
        </div>

        <div class="field-group">
          <label>Annual Salary (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="b_salary" placeholder="40000" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Annual Bonus (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="b_bonus" placeholder="0" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Employer Pension (%)</label>
          <div class="slider-wrap">
            <input type="range" id="b_pension_slider" min="0" max="20" value="5" step="1" oninput="document.getElementById('b_pension').value=this.value" />
            <div class="slider-input-wrap">
              <input type="number" id="b_pension" value="5" min="0" max="100" oninput="document.getElementById('b_pension_slider').value=Math.min(this.value,20)" />
              <span class="slider-unit">%</span>
            </div>
          </div>
        </div>
        <div class="field-group">
          <label>Holiday Days</label>
          <div class="slider-wrap">
            <input type="range" id="b_holiday_slider" min="20" max="40" value="25" step="1" oninput="document.getElementById('b_holiday').value=this.value" />
            <div class="slider-input-wrap">
              <input type="number" id="b_holiday" value="25" min="0" oninput="document.getElementById('b_holiday_slider').value=Math.min(this.value,40)" />
              <span class="slider-unit">days</span>
            </div>
          </div>
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
          <label>One-Way Commute Time (mins)</label>
          <div class="input-wrap"><input type="number" id="b_commute_mins" placeholder="30" min="0" /></div>
        </div>
        <div class="field-group">
          <label>Daily Transport Cost (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="b_commute_cost" placeholder="8.00" min="0" step="0.50" /></div>
        </div>
        <div class="field-group">
          <label>Company Culture Score</label>
          <div style="display:flex;align-items:center;gap:12px;">
            <input type="range" class="culture-slider" id="b_culture" min="1" max="10" value="5" oninput="document.getElementById('b_culture_val').textContent=this.value+'/10'" />
            <span id="b_culture_val" style="font-family:var(--font-display);font-size:24px;color:var(--white);min-width:60px;">5/10</span>
          </div>
          <p class="field-hint">1 = toxic, 10 = dream workplace</p>
        </div>
      </div>
    </div>

    <button class="compare-btn" id="compareBtn" onclick="runComparison()">
      Compare Job Offers →
    </button>

    <!-- RESULTS -->
    <div id="compResults" class="hidden" style="margin-top:32px;">

      <!-- Verdict -->
      <div class="verdict-wrap">
        <p class="verdict-label">THE WINNER IS</p>
        <div class="verdict-winner" id="res_winner">A</div>
        <div class="verdict-margin" id="res_margin">£0</div>
        <p class="verdict-desc" id="res_desc">better in real terms after all costs</p>
      </div>

      <!-- Side by side results -->
      <div class="results-grid">
        <div class="result-col" id="res_col_a">
          <p class="result-col-label" id="res_label_a">JOB A</p>
          <div class="result-row"><span>Gross salary</span><span id="ra_gross">£0</span></div>
          <div class="result-row"><span>+ Bonus</span><span id="ra_bonus">£0</span></div>
          <div class="result-row"><span>+ Pension</span><span id="ra_pension">£0</span></div>
          <div class="result-row"><span>Take home (yearly)</span><span id="ra_takehome">£0</span></div>
          <div class="result-row"><span>Commute cost</span><span id="ra_commute" style="color:var(--red)">-£0</span></div>
          <div class="result-row"><span>Commute time value</span><span id="ra_time" style="color:var(--red)">-£0</span></div>
          <div class="result-row"><span>Holiday value</span><span id="ra_holiday" style="color:var(--green)">+£0</span></div>
          <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--text-dimmer);margin-top:16px;">TRUE ANNUAL VALUE</p>
          <div class="result-real-value" id="ra_real">£0</div>
        </div>
        <div class="result-col" id="res_col_b">
          <p class="result-col-label" id="res_label_b">JOB B</p>
          <div class="result-row"><span>Gross salary</span><span id="rb_gross">£0</span></div>
          <div class="result-row"><span>+ Bonus</span><span id="rb_bonus">£0</span></div>
          <div class="result-row"><span>+ Pension</span><span id="rb_pension">£0</span></div>
          <div class="result-row"><span>Take home (yearly)</span><span id="rb_takehome">£0</span></div>
          <div class="result-row"><span>Commute cost</span><span id="rb_commute" style="color:var(--red)">-£0</span></div>
          <div class="result-row"><span>Commute time value</span><span id="rb_time" style="color:var(--red)">-£0</span></div>
          <div class="result-row"><span>Holiday value</span><span id="rb_holiday" style="color:var(--green)">+£0</span></div>
          <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--text-dimmer);margin-top:16px;">TRUE ANNUAL VALUE</p>
          <div class="result-real-value" id="rb_real" style="color:var(--white)">£0</div>
        </div>
      </div>

      <!-- Key differences -->
      <div class="diff-block">
        <h3 class="block-title">Key Differences</h3>
        <div class="diff-row">
          <span>Salary difference</span>
          <span id="diff_salary" class="diff-positive">£0</span>
        </div>
        <div class="diff-row">
          <span>Take home difference</span>
          <span id="diff_takehome" class="diff-positive">£0</span>
        </div>
        <div class="diff-row">
          <span>Commute cost difference</span>
          <span id="diff_commute" class="diff-positive">£0</span>
        </div>
        <div class="diff-row" style="font-weight:500;font-size:15px;">
          <span>Real value difference</span>
          <span id="diff_real" class="diff-positive">£0</span>
        </div>
      </div>

      <!-- Insight -->
      <div class="savings-callout" id="res_insight" style="margin-bottom:24px;font-size:14px;line-height:1.7;"></div>

      <!-- Share -->
      <div class="share-block">
        <p class="share-label">Share your comparison</p>
        <div class="share-btns-grid">
          <button class="share-btn s-twitter" onclick="shareComparison('twitter')">X Twitter</button>
          <button class="share-btn s-whatsapp" onclick="shareComparison('whatsapp')">WhatsApp</button>
          <button class="share-btn s-linkedin" onclick="shareComparison('linkedin')">LinkedIn</button>
          <button class="share-btn s-copy" onclick="shareComparison('copy')">Copy</button>
        </div>
      </div>

      <!-- Cross-sell -->
      <div class="comparison-block">
        <h3 class="block-title">Also Calculate</h3>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:4px;">
          <a href="/" style="display:block;padding:16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;transition:border-color 0.2s;" onmouseover="this.style.borderColor='var(--accent)'" onmouseout="this.style.borderColor='var(--border)'">Commute Cost Calculator →</a>
          <a href="/take-home" style="display:block;padding:16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;transition:border-color 0.2s;" onmouseover="this.style.borderColor='var(--accent)'" onmouseout="this.style.borderColor='var(--border)'">Take Home Pay Calculator →</a>
        </div>
      </div>

    </div>

  </main>

  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Frequently Asked Questions</h2>
      <div class="faq-item">
        <h3>How is the "true value" calculated?</h3>
        <p>We take your take home pay, add bonus and pension value, then subtract the full commute cost — both transport and the monetary value of your commute time at your hourly rate. This gives you the real annual value of each job, not just the headline salary.</p>
      </div>
      <div class="faq-item">
        <h3>How is commute time valued?</h3>
        <p>We divide your annual salary by 2,080 working hours (52 weeks × 40 hours) to get your hourly rate. We then multiply this by your annual commute hours to show what that time is worth in monetary terms.</p>
      </div>
      <div class="faq-item">
        <h3>What does the culture score affect?</h3>
        <p>The culture score adjusts the happiness-weighted value of the role. A job with a 10/10 culture score is worth more in real life than its financial value alone suggests. We weight it at 30% of the final adjusted value.</p>
      </div>
      <div class="faq-item">
        <h3>Should I always take the higher real value job?</h3>
        <p>Not necessarily — the tool gives you the financial picture. Career development, job security, and personal circumstances all matter too. Use the tool as one input in your decision, not the only one.</p>
      </div>
    </div>
  </section>

  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Commute Calculator</a> · <a href="/take-home">Take Home Pay</a> · <a href="/compare-jobs">Compare Jobs</a> · <a href="/guide">Guide</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p>
  </footer>

  <script src="/static/js/compare_jobs.js"></script>
</body>
</html>
HTMLEOF

# ── 3. Compare Jobs JS ────────────────────────────────────────────────────────
cat > "$TARGET/static/js/compare_jobs.js" << 'JSEOF'
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

function getJobData(prefix, remoteDays) {
  return {
    salary: parseFloat(document.getElementById(prefix + "_salary").value) || 0,
    bonus: parseFloat(document.getElementById(prefix + "_bonus").value) || 0,
    pension_pct: parseFloat(document.getElementById(prefix + "_pension").value) || 0,
    holiday_days: parseFloat(document.getElementById(prefix + "_holiday").value) || 25,
    remote_days: remoteDays,
    commute_mins: parseFloat(document.getElementById(prefix + "_commute_mins").value) || 0,
    commute_cost_daily: parseFloat(document.getElementById(prefix + "_commute_cost").value) || 0,
    culture_score: parseFloat(document.getElementById(prefix + "_culture").value) || 5,
  };
}

async function runComparison() {
  const btn = document.getElementById("compareBtn");
  const jobA = getJobData("a", aRemoteDays);
  const jobB = getJobData("b", bRemoteDays);
  const nameA = document.getElementById("job_a_name").value || "Job A";
  const nameB = document.getElementById("job_b_name").value || "Job B";

  if (jobA.salary <= 0 || jobB.salary <= 0) {
    alert("Please enter a salary for both jobs.");
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
  document.getElementById("ra_bonus").textContent = "+" + fmt(a.bonus);
  document.getElementById("ra_pension").textContent = "+" + fmt(a.pension);
  document.getElementById("ra_takehome").textContent = fmt(a.take_home);
  document.getElementById("ra_commute").textContent = "-" + fmt(a.commute_cost_yearly);
  document.getElementById("ra_time").textContent = "-" + fmt(a.commute_time_value);
  document.getElementById("ra_holiday").textContent = "+" + fmt(a.holiday_value);
  document.getElementById("ra_real").textContent = fmt(a.real_value);

  document.getElementById("rb_gross").textContent = fmt(b.salary);
  document.getElementById("rb_bonus").textContent = "+" + fmt(b.bonus);
  document.getElementById("rb_pension").textContent = "+" + fmt(b.pension);
  document.getElementById("rb_takehome").textContent = fmt(b.take_home);
  document.getElementById("rb_commute").textContent = "-" + fmt(b.commute_cost_yearly);
  document.getElementById("rb_time").textContent = "-" + fmt(b.commute_time_value);
  document.getElementById("rb_holiday").textContent = "+" + fmt(b.holiday_value);
  document.getElementById("rb_real").textContent = fmt(b.real_value);

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
JSEOF

# ── 4. Update nav on all pages ────────────────────────────────────────────────
python3 << 'PYEOF'
import os

pages = [
    '/Users/ss/Documents/Commute Tax/templates/index.html',
    '/Users/ss/Documents/Commute Tax/templates/take_home.html',
]

for path in pages:
    if not os.path.exists(path):
        continue
    with open(path, 'r') as f:
        content = f.read()
    content = content.replace(
        '<a href="/take-home">Take Home Pay</a> · <a href="/guide">Guide</a>',
        '<a href="/take-home">Take Home Pay</a> · <a href="/compare-jobs">Compare Jobs</a> · <a href="/guide">Guide</a>'
    )
    with open(path, 'w') as f:
        f.write(content)
    print(f"Updated nav: {path}")
PYEOF

# ── 5. Test ───────────────────────────────────────────────────────────────────
echo ""
echo "Testing..."
cd "$TARGET" && python3 -c "
import app
print('OK - no syntax errors')
" 2>&1

echo ""
echo "Done! Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add Tool 3 job offer comparison' && git push"
