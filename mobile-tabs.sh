#!/bin/bash
TARGET=~/Documents/Commute\ Tax

# Add mobile tab CSS if not already there
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* =============================================
   MOBILE TABS FOR ALL CALCULATORS
   ============================================= */
.calc-mobile-tabs {
  display: none;
}

@media (max-width: 768px) {
  /* Hide desktop two-column layout */
  .calc-wrapper {
    display: none !important;
  }

  /* Show mobile tabs */
  .calc-mobile-tabs {
    display: block;
  }

  .calc-tab-btns {
    display: flex;
    border-bottom: 1px solid var(--border);
    background: var(--panel);
    position: sticky;
    top: 48px;
    z-index: 50;
  }

  .calc-tab-btn {
    flex: 1;
    padding: 14px;
    background: none;
    border: none;
    font-family: var(--font-mono);
    font-size: 11px;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--text-dimmer);
    cursor: pointer;
    border-bottom: 2px solid transparent;
    transition: all 0.15s;
  }

  .calc-tab-btn.active {
    color: var(--accent);
    border-bottom-color: var(--accent);
  }

  .calc-tab-panel {
    display: none;
    padding: 24px 20px;
  }

  .calc-tab-panel.active {
    display: block;
  }
}
CSSEOF

echo "CSS added"

# ── Fix Take Home Pay ─────────────────────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/templates/take_home.html'
with open(path, 'r') as f:
    content = f.read()

mobile_tabs = '''
  <!-- MOBILE TABS -->
  <div class="calc-mobile-tabs">
    <div class="calc-tab-btns">
      <button class="calc-tab-btn active" id="th_tab_calc" onclick="thTab('calc')">Calculator</button>
      <button class="calc-tab-btn" id="th_tab_results" onclick="thTab('results')">My Results</button>
    </div>
    <div class="calc-tab-panel active" id="th_panel_calc">
      <div class="field-group">
        <label for="th_salary_m">Annual Salary (£)</label>
        <div class="input-wrap"><span class="prefix">£</span><input type="number" id="th_salary_m" placeholder="35000" min="0" inputmode="numeric" /></div>
      </div>
      <div class="field-group">
        <label>Student Loan</label>
        <div class="transport-toggle" style="grid-template-columns:1fr 1fr 1fr;">
          <button class="transport-btn active" data-plan="none" onclick="setMPlan(this,'none')">None</button>
          <button class="transport-btn" data-plan="plan1" onclick="setMPlan(this,'plan1')">Plan 1</button>
          <button class="transport-btn" data-plan="plan2" onclick="setMPlan(this,'plan2')">Plan 2</button>
          <button class="transport-btn" data-plan="plan4" onclick="setMPlan(this,'plan4')">Plan 4</button>
          <button class="transport-btn" data-plan="plan5" onclick="setMPlan(this,'plan5')">Plan 5</button>
          <button class="transport-btn" data-plan="postgrad" onclick="setMPlan(this,'postgrad')">Postgrad</button>
        </div>
      </div>
      <div class="field-group">
        <label>Pension (%)</label>
        <div class="slider-wrap">
          <input type="range" id="th_pension_m" min="0" max="20" value="5" step="1" oninput="document.getElementById('th_pension_val_m').textContent=this.value+'%'" />
          <span id="th_pension_val_m" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:52px;">5%</span>
        </div>
      </div>
      <button class="calculate-btn" onclick="runTakeHomeMobile()"><span>Calculate My Take Home</span></button>
    </div>
    <div class="calc-tab-panel" id="th_panel_results">
      <div id="th_m_placeholder" style="text-align:center;padding:40px 0;color:var(--text-dimmer);font-family:var(--font-mono);font-size:12px;">Calculate first to see results</div>
      <div id="th_m_results" class="hidden">
        <div class="verdict-banner">
          <p class="verdict-label">MONTHLY TAKE HOME</p>
          <div class="verdict-number" id="th_m_monthly">£0</div>
          <p class="verdict-sub" id="th_m_yearly">per year</p>
        </div>
        <div class="stat-cards">
          <div class="stat-card"><span class="stat-label">Weekly</span><span class="stat-value" id="th_m_weekly">£0</span></div>
          <div class="stat-card highlight"><span class="stat-label">Deductions</span><span class="stat-value" id="th_m_deductions">£0</span></div>
          <div class="stat-card"><span class="stat-label">Effective Rate</span><span class="stat-value" id="th_m_rate">0%</span></div>
          <div class="stat-card"><span class="stat-label">Daily</span><span class="stat-value" id="th_m_daily">£0</span></div>
        </div>
        <div class="breakdown-block">
          <h3 class="block-title">Full Breakdown</h3>
          <div class="breakdown-row"><span>Gross salary</span><span id="th_m_gross">£0</span></div>
          <div class="breakdown-row"><span>Income tax</span><span id="th_m_tax" style="color:var(--red)">-£0</span></div>
          <div class="breakdown-row"><span>National Insurance</span><span id="th_m_ni" style="color:var(--red)">-£0</span></div>
          <div class="breakdown-row" id="th_m_sl_row" style="display:none"><span>Student loan</span><span id="th_m_sl" style="color:var(--red)">-£0</span></div>
          <div class="breakdown-row" id="th_m_pen_row" style="display:none"><span>Pension</span><span id="th_m_pen" style="color:var(--red)">-£0</span></div>
          <div class="breakdown-row total-row"><span>Take home (yearly)</span><span id="th_m_takehome">£0</span></div>
        </div>
        <div class="comparison-block" style="margin-top:16px;">
          <a href="/" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Calculate Commute Cost →</a>
        </div>
      </div>
    </div>
  </div>

'''

# Insert mobile tabs before closing main tag
content = content.replace('</main>', mobile_tabs + '</main>')

with open(path, 'w') as f:
    f.write(content)
print("Done take_home.html")
PYEOF

# ── Fix Pension Calculator ────────────────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/templates/pension_calculator.html'
with open(path, 'r') as f:
    content = f.read()

mobile_tabs = '''
  <!-- MOBILE TABS -->
  <div class="calc-mobile-tabs">
    <div class="calc-tab-btns">
      <button class="calc-tab-btn active" onclick="penTab('calc')">Calculator</button>
      <button class="calc-tab-btn" onclick="penTab('results')">My Results</button>
    </div>
    <div class="calc-tab-panel active" id="pen_panel_calc">
      <div class="field-group">
        <label>Annual Salary (£)</label>
        <div class="input-wrap"><span class="prefix">£</span><input type="number" id="p_salary_m" placeholder="35000" min="0" inputmode="numeric" /></div>
      </div>
      <div class="field-group">
        <label>Current Age</label>
        <div class="slider-wrap">
          <input type="range" id="p_age_m" min="18" max="65" value="30" step="1" oninput="document.getElementById('p_age_mv').textContent=this.value+' yrs'" />
          <span id="p_age_mv" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:60px;">30 yrs</span>
        </div>
      </div>
      <div class="field-group">
        <label>Retirement Age</label>
        <div class="slider-wrap">
          <input type="range" id="p_retire_m" min="55" max="75" value="67" step="1" oninput="document.getElementById('p_retire_mv').textContent=this.value+' yrs'" />
          <span id="p_retire_mv" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:60px;">67 yrs</span>
        </div>
      </div>
      <div class="field-group">
        <label>Your Contribution (%)</label>
        <div class="slider-wrap">
          <input type="range" id="p_contrib_m" min="0" max="30" value="5" step="1" oninput="document.getElementById('p_contrib_mv').textContent=this.value+'%'" />
          <span id="p_contrib_mv" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:52px;">5%</span>
        </div>
      </div>
      <div class="field-group">
        <label>Employer Contribution (%)</label>
        <div class="slider-wrap">
          <input type="range" id="p_employer_m" min="0" max="20" value="3" step="1" oninput="document.getElementById('p_employer_mv').textContent=this.value+'%'" />
          <span id="p_employer_mv" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:52px;">3%</span>
        </div>
      </div>
      <div class="field-group">
        <label>Current Pension Pot (£) — optional</label>
        <div class="input-wrap"><span class="prefix">£</span><input type="number" id="p_pot_m" placeholder="0" min="0" inputmode="numeric" /></div>
      </div>
      <button class="calculate-btn" onclick="calcPensionMobile()"><span>Calculate My Pension</span></button>
    </div>
    <div class="calc-tab-panel" id="pen_panel_results">
      <div id="pen_m_placeholder" style="text-align:center;padding:40px 0;color:var(--text-dimmer);font-family:var(--font-mono);font-size:12px;">Calculate first to see results</div>
      <div id="pen_m_results" class="hidden">
        <div class="verdict-banner">
          <p class="verdict-label">PROJECTED PENSION POT</p>
          <div class="verdict-number" id="pen_m_pot">£0</div>
          <p class="verdict-sub" id="pen_m_track">at retirement</p>
        </div>
        <div class="stat-cards">
          <div class="stat-card"><span class="stat-label">Monthly Income</span><span class="stat-value" id="pen_m_monthly">£0</span></div>
          <div class="stat-card"><span class="stat-label">+ State Pension</span><span class="stat-value" id="pen_m_state">£958</span></div>
          <div class="stat-card highlight"><span class="stat-label">Total Monthly</span><span class="stat-value" id="pen_m_total">£0</span></div>
          <div class="stat-card"><span class="stat-label">You Save/Month</span><span class="stat-value" id="pen_m_saving">£0</span></div>
        </div>
        <div class="breakdown-block">
          <h3 class="block-title">Breakdown</h3>
          <div class="breakdown-row"><span>Years to retirement</span><span id="pen_m_years">0</span></div>
          <div class="breakdown-row"><span>Projected pot</span><span id="pen_m_pot2">£0</span></div>
          <div class="breakdown-row"><span>Recommended pot</span><span id="pen_m_rec">£0</span></div>
          <div class="breakdown-row total-row"><span>Status</span><span id="pen_m_status">—</span></div>
        </div>
        <div class="savings-callout" id="pen_m_insight"></div>
      </div>
    </div>
  </div>

'''

content = content.replace('</main>', mobile_tabs + '</main>')
with open(path, 'w') as f:
    f.write(content)
print("Done pension_calculator.html")
PYEOF

# ── Fix Student Loan ──────────────────────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/templates/student_loan.html'
with open(path, 'r') as f:
    content = f.read()

mobile_tabs = '''
  <!-- MOBILE TABS -->
  <div class="calc-mobile-tabs">
    <div class="calc-tab-btns">
      <button class="calc-tab-btn active" onclick="slTab('calc')">Calculator</button>
      <button class="calc-tab-btn" onclick="slTab('results')">My Results</button>
    </div>
    <div class="calc-tab-panel active" id="sl_panel_calc">
      <div class="field-group">
        <label>Annual Salary (£)</label>
        <div class="input-wrap"><span class="prefix">£</span><input type="number" id="sl_salary_m" placeholder="35000" min="0" inputmode="numeric" /></div>
      </div>
      <div class="field-group">
        <label>Loan Plan</label>
        <div class="transport-toggle" style="grid-template-columns:1fr 1fr 1fr;">
          <button class="transport-btn active" onclick="setSlPlanM(this,'plan2')">Plan 2</button>
          <button class="transport-btn" onclick="setSlPlanM(this,'plan1')">Plan 1</button>
          <button class="transport-btn" onclick="setSlPlanM(this,'plan4')">Plan 4</button>
          <button class="transport-btn" onclick="setSlPlanM(this,'plan5')">Plan 5</button>
          <button class="transport-btn" onclick="setSlPlanM(this,'postgrad')">Postgrad</button>
        </div>
      </div>
      <div class="field-group">
        <label>Current Balance (£) — optional</label>
        <div class="input-wrap"><span class="prefix">£</span><input type="number" id="sl_balance_m" placeholder="45000" min="0" inputmode="numeric" /></div>
      </div>
      <button class="calculate-btn" onclick="calcSLMobile()"><span>Calculate My Repayments</span></button>
    </div>
    <div class="calc-tab-panel" id="sl_panel_results">
      <div id="sl_m_placeholder" style="text-align:center;padding:40px 0;color:var(--text-dimmer);font-family:var(--font-mono);font-size:12px;">Calculate first to see results</div>
      <div id="sl_m_results" class="hidden">
        <div class="verdict-banner">
          <p class="verdict-label">MONTHLY REPAYMENT</p>
          <div class="verdict-number" id="sl_m_monthly">£0</div>
          <p class="verdict-sub" id="sl_m_yearly">per year</p>
        </div>
        <div class="stat-cards">
          <div class="stat-card"><span class="stat-label">Monthly</span><span class="stat-value" id="sl_m_monthly2">£0</span></div>
          <div class="stat-card highlight"><span class="stat-label">Yearly</span><span class="stat-value" id="sl_m_yearly2">£0</span></div>
          <div class="stat-card"><span class="stat-label">Interest/Year</span><span class="stat-value" id="sl_m_interest">£0</span></div>
          <div class="stat-card"><span class="stat-label">Written Off</span><span class="stat-value" id="sl_m_writeoff">0 yrs</span></div>
        </div>
        <div class="savings-callout" id="sl_m_insight"></div>
      </div>
    </div>
  </div>

'''

content = content.replace('</main>', mobile_tabs + '</main>')
with open(path, 'w') as f:
    f.write(content)
print("Done student_loan.html")
PYEOF

# ── Add mobile JS for all calculators ────────────────────────────────────────
cat >> "$TARGET/static/js/take_home.js" << 'JSEOF'

// ── Mobile take home tab ──────────────────────────────────────────────────────
let thMPlan = "none";

function thTab(tab) {
  document.getElementById("th_panel_calc").classList.toggle("active", tab === "calc");
  document.getElementById("th_panel_results").classList.toggle("active", tab === "results");
  document.querySelectorAll(".calc-tab-btn").forEach((b, i) => b.classList.toggle("active", (i === 0) === (tab === "calc")));
}

function setMPlan(btn, plan) {
  btn.closest(".transport-toggle").querySelectorAll(".transport-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");
  thMPlan = plan;
}

async function runTakeHomeMobile() {
  const salary = parseFloat(document.getElementById("th_salary_m").value) || 0;
  const pension = parseFloat(document.getElementById("th_pension_m").value) || 0;
  if (salary <= 0) { showTHToast("Please enter your salary."); return; }
  try {
    const res = await fetch("/calculate-take-home", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ salary, student_loan: thMPlan, pension_pct: pension }) });
    const r = await res.json();
    const fmt = n => "£" + Math.round(n).toLocaleString("en-GB");
    document.getElementById("th_m_placeholder").classList.add("hidden");
    document.getElementById("th_m_results").classList.remove("hidden");
    document.getElementById("th_m_monthly").textContent = fmt(r.take_home_monthly);
    document.getElementById("th_m_yearly").textContent = fmt(r.take_home_yearly) + " per year";
    document.getElementById("th_m_weekly").textContent = fmt(r.take_home_weekly);
    document.getElementById("th_m_deductions").textContent = fmt(r.total_deductions);
    document.getElementById("th_m_rate").textContent = r.effective_rate + "%";
    document.getElementById("th_m_daily").textContent = fmt(r.take_home_daily);
    document.getElementById("th_m_gross").textContent = fmt(r.gross_yearly);
    document.getElementById("th_m_tax").textContent = "-" + fmt(r.income_tax);
    document.getElementById("th_m_ni").textContent = "-" + fmt(r.national_insurance);
    document.getElementById("th_m_takehome").textContent = fmt(r.take_home_yearly);
    if (r.student_loan > 0) { document.getElementById("th_m_sl_row").style.display = "flex"; document.getElementById("th_m_sl").textContent = "-" + fmt(r.student_loan); }
    if (r.pension > 0) { document.getElementById("th_m_pen_row").style.display = "flex"; document.getElementById("th_m_pen").textContent = "-" + fmt(r.pension); }
    thTab("results");
  } catch(err) { showTHToast("Something went wrong."); }
}
JSEOF

cat >> "$TARGET/static/js/pension_calculator.js" << 'JSEOF'

// ── Mobile pension tab ────────────────────────────────────────────────────────
function penTab(tab) {
  document.getElementById("pen_panel_calc").classList.toggle("active", tab === "calc");
  document.getElementById("pen_panel_results").classList.toggle("active", tab === "results");
  document.querySelectorAll(".calc-mobile-tabs .calc-tab-btn").forEach((b, i) => b.classList.toggle("active", (i === 0) === (tab === "calc")));
}

async function calcPensionMobile() {
  const salary = parseFloat(document.getElementById("p_salary_m").value) || 0;
  if (salary <= 0) { pToast("Please enter your salary."); return; }
  const data = {
    salary,
    current_age: parseInt(document.getElementById("p_age_m").value) || 30,
    retirement_age: parseInt(document.getElementById("p_retire_m").value) || 67,
    contribution_pct: parseFloat(document.getElementById("p_contrib_m").value) || 5,
    employer_pct: parseFloat(document.getElementById("p_employer_m").value) || 3,
    current_pot: parseFloat(document.getElementById("p_pot_m").value) || 0,
    growth_rate: 5,
  };
  try {
    const res = await fetch("/calculate-pension", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data) });
    const r = await res.json();
    const fmt = n => "£" + Math.round(n).toLocaleString("en-GB");
    document.getElementById("pen_m_placeholder").classList.add("hidden");
    document.getElementById("pen_m_results").classList.remove("hidden");
    document.getElementById("pen_m_pot").textContent = fmt(r.projected_pot);
    document.getElementById("pen_m_track").textContent = r.on_track ? "You are on track ✓" : "You may have a shortfall";
    document.getElementById("pen_m_monthly").textContent = fmt(r.monthly_income);
    document.getElementById("pen_m_state").textContent = fmt(r.state_pension_monthly) + "/mo";
    document.getElementById("pen_m_total").textContent = fmt(r.total_monthly_with_state);
    document.getElementById("pen_m_saving").textContent = fmt(r.monthly_contribution) + "/mo";
    document.getElementById("pen_m_years").textContent = r.years_to_retirement + " years";
    document.getElementById("pen_m_pot2").textContent = fmt(r.projected_pot);
    document.getElementById("pen_m_rec").textContent = fmt(r.recommended_pot);
    document.getElementById("pen_m_status").textContent = r.on_track ? "On track ✓" : "Below target";
    document.getElementById("pen_m_status").style.color = r.on_track ? "var(--green)" : "var(--red)";
    document.getElementById("pen_m_insight").textContent = r.shortfall > 0
      ? "You have a projected shortfall of " + fmt(r.shortfall) + ". An extra " + fmt(Math.round(r.shortfall / (r.years_to_retirement * 12))) + "/month would close the gap."
      : "You are on track for a comfortable retirement with " + fmt(r.projected_pot) + " projected.";
    penTab("results");
  } catch(err) { pToast("Something went wrong."); }
}
JSEOF

cat >> "$TARGET/static/js/student_loan.js" << 'JSEOF'

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
JSEOF

echo ""
echo "Testing..."
cd "$TARGET" && python3 -c "import app; print('✅ OK')" 2>&1

echo ""
echo "Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add mobile tabs to all calculators' && git push"
