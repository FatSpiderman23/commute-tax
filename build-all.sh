#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🚀 Building all new tools and pages..."

# ── 1. Add all routes to app.py ───────────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

new_code = '''
# =============================================
# NEW SALARY PAGES
# =============================================

EXTRA_SALARY_BENCHMARKS = {
    "doctor": {
        "title": "Doctor (NHS)",
        "salary_range": [32000, 120000],
        "avg_salary": 65000,
        "description": "NHS doctors earn between £32,000 as a junior doctor and £120,000+ as a consultant. Foundation year doctors start at £32,398.",
        "keywords": "doctor salary UK, NHS doctor take home pay, doctor salary after tax",
        "sector": "Healthcare",
        "jobs": ["Foundation Year 1", "Foundation Year 2", "Core Trainee", "Specialty Registrar", "Consultant"],
    },
    "lawyer": {
        "title": "Lawyer / Solicitor",
        "salary_range": [30000, 120000],
        "avg_salary": 55000,
        "description": "Solicitors in the UK earn between £30,000 as a newly qualified and £120,000+ at Magic Circle firms. City lawyers command a significant premium.",
        "keywords": "lawyer salary UK, solicitor take home pay, lawyer salary after tax",
        "sector": "Legal",
        "jobs": ["Trainee Solicitor", "NQ Solicitor", "Associate", "Senior Associate", "Partner"],
    },
    "pilot": {
        "title": "Airline Pilot",
        "salary_range": [45000, 180000],
        "avg_salary": 90000,
        "description": "Airline pilots in the UK earn between £45,000 as a first officer and £180,000+ as a senior captain at a major carrier.",
        "keywords": "pilot salary UK, airline pilot take home pay, pilot salary after tax",
        "sector": "Aviation",
        "jobs": ["First Officer", "Senior First Officer", "Captain", "Senior Captain"],
    },
    "engineer": {
        "title": "Engineer",
        "salary_range": [28000, 75000],
        "avg_salary": 45000,
        "description": "Engineers in the UK earn between £28,000 and £75,000 depending on discipline and experience. Civil, mechanical, and electrical engineers are among the most common.",
        "keywords": "engineer salary UK, engineer take home pay, engineering salary after tax",
        "sector": "Engineering",
        "jobs": ["Graduate Engineer", "Junior Engineer", "Engineer", "Senior Engineer", "Principal Engineer"],
    },
    "social-worker": {
        "title": "Social Worker",
        "salary_range": [28000, 45000],
        "avg_salary": 35000,
        "description": "Social workers in the UK typically earn between £28,000 and £45,000. Newly qualified social workers start at around £28,000 rising with experience.",
        "keywords": "social worker salary UK, social worker take home pay, social work salary after tax",
        "sector": "Public Sector",
        "jobs": ["Newly Qualified Social Worker", "Social Worker", "Senior Social Worker", "Team Manager"],
    },
}

# Merge with existing benchmarks
SALARY_BENCHMARKS.update(EXTRA_SALARY_BENCHMARKS)

# =============================================
# COMMUTER TOWN PAGES
# =============================================

COMMUTER_TOWNS = {
    "reading": {
        "name": "Reading",
        "to_city": "London",
        "avg_commute_mins": 27,
        "avg_season_ticket": 5240,
        "avg_salary": 45000,
        "description": "Reading is one of the UK's most popular commuter towns, with fast trains to London Paddington taking as little as 25 minutes.",
        "train_operator": "Great Western Railway",
        "popular_for": ["Tech workers", "Finance professionals", "Consultants"],
    },
    "brighton": {
        "name": "Brighton",
        "to_city": "London",
        "avg_commute_mins": 52,
        "avg_season_ticket": 5760,
        "avg_salary": 42000,
        "description": "Brighton is a popular alternative to London living, but its commuters face some of the highest season ticket costs in the country.",
        "train_operator": "Southern / Thameslink",
        "popular_for": ["Creative professionals", "Tech workers", "Media"],
    },
    "guildford": {
        "name": "Guildford",
        "to_city": "London",
        "avg_commute_mins": 35,
        "avg_season_ticket": 4800,
        "avg_salary": 48000,
        "description": "Guildford offers a high quality of life and relatively fast trains to London Waterloo, making it a popular choice for families.",
        "train_operator": "South Western Railway",
        "popular_for": ["Families", "Finance professionals", "Senior managers"],
    },
    "oxford": {
        "name": "Oxford",
        "to_city": "London",
        "avg_commute_mins": 57,
        "avg_season_ticket": 7200,
        "avg_salary": 44000,
        "description": "Oxford commuters face long journey times and high fares to London Paddington, but benefit from Oxford's exceptional quality of life.",
        "train_operator": "Great Western Railway",
        "popular_for": ["Academia", "Tech workers", "Finance"],
    },
    "cambridge": {
        "name": "Cambridge",
        "to_city": "London",
        "avg_commute_mins": 48,
        "avg_season_ticket": 6100,
        "avg_salary": 46000,
        "description": "Cambridge is home to a thriving tech cluster but many residents commute to London, facing significant costs on the Kings Cross line.",
        "train_operator": "Thameslink / Greater Anglia",
        "popular_for": ["Tech workers", "Scientists", "Finance"],
    },
    "milton-keynes": {
        "name": "Milton Keynes",
        "to_city": "London",
        "avg_commute_mins": 35,
        "avg_season_ticket": 4900,
        "avg_salary": 40000,
        "description": "Milton Keynes offers affordable housing and fast trains to Euston, making it popular with London commuters seeking more space.",
        "train_operator": "Avanti West Coast / London Northwestern",
        "popular_for": ["Families", "Finance workers", "Logistics professionals"],
    },
}


@app.route("/commute-cost/commuter-towns")
def commuter_towns_index():
    return render_template("commuter_towns.html", towns=COMMUTER_TOWNS)


@app.route("/commute-cost/<town_slug>", endpoint="commuter_town_page")
def commuter_town_page(town_slug):
    # Check if it's a commuter town first
    town = COMMUTER_TOWNS.get(town_slug)
    if town:
        hourly = float(town["avg_salary"]) / (48 * 5 * 8)
        time_cost = round((town["avg_commute_mins"] * 2 * 48 * 5 / 60) * hourly)
        return render_template("commuter_town.html", town=town, slug=town_slug,
                             time_cost=time_cost, all_towns=COMMUTER_TOWNS)
    # Fall back to city page
    city = CITIES.get(town_slug)
    if city:
        return render_template("city.html", city=city, slug=town_slug, all_cities=CITIES)
    return "Page not found", 404


# =============================================
# CALCULATORS
# =============================================

def calculate_student_loan(data):
    salary = float(data.get("salary", 0))
    plan = data.get("plan", "plan2")
    balance = float(data.get("balance", 0))

    thresholds = {
        "plan1": {"threshold": 22015, "rate": 0.09, "interest": 0.065},
        "plan2": {"threshold": 27295, "rate": 0.09, "interest": 0.075},
        "plan4": {"threshold": 27660, "rate": 0.09, "interest": 0.065},
        "plan5": {"threshold": 25000, "rate": 0.06, "interest": 0.075},
        "postgrad": {"threshold": 21000, "rate": 0.06, "interest": 0.075},
    }

    p = thresholds.get(plan, thresholds["plan2"])
    yearly_repayment = max(0, (salary - p["threshold"]) * p["rate"]) if salary > p["threshold"] else 0
    monthly_repayment = yearly_repayment / 12
    interest_yearly = balance * p["interest"] if balance > 0 else 0
    net_balance_change = interest_yearly - yearly_repayment

    years_to_repay = None
    if yearly_repayment > interest_yearly and balance > 0:
        years_to_repay = round(balance / (yearly_repayment - interest_yearly), 1)

    write_off_years = {"plan1": 25, "plan2": 30, "plan4": 30, "plan5": 40, "postgrad": 30}
    write_off = write_off_years.get(plan, 30)

    return {
        "monthly_repayment": round(monthly_repayment),
        "yearly_repayment": round(yearly_repayment),
        "interest_yearly": round(interest_yearly),
        "net_balance_change": round(net_balance_change),
        "years_to_repay": years_to_repay,
        "write_off_years": write_off,
        "threshold": p["threshold"],
        "rate": int(p["rate"] * 100),
        "will_repay_before_writeoff": years_to_repay is not None and years_to_repay < write_off,
    }


def calculate_pension(data):
    current_age = int(data.get("current_age", 30))
    retirement_age = int(data.get("retirement_age", 67))
    salary = float(data.get("salary", 35000))
    contribution_pct = float(data.get("contribution_pct", 5))
    employer_pct = float(data.get("employer_pct", 3))
    current_pot = float(data.get("current_pot", 0))
    growth_rate = float(data.get("growth_rate", 5)) / 100

    years = retirement_age - current_age
    annual_contribution = salary * (contribution_pct + employer_pct) / 100
    monthly_contribution = annual_contribution / 12

    # Future value calculation
    future_value = current_pot * ((1 + growth_rate) ** years)
    future_value += annual_contribution * (((1 + growth_rate) ** years - 1) / growth_rate)

    monthly_income = future_value / (25 * 12)  # 4% drawdown rule
    state_pension = 11502  # 2024/25 full state pension
    total_monthly = monthly_income + (state_pension / 12)

    recommended_pot = salary * 25  # 25x salary rule
    on_track = future_value >= recommended_pot * 0.8

    return {
        "years_to_retirement": years,
        "projected_pot": round(future_value),
        "monthly_income": round(monthly_income),
        "total_monthly_with_state": round(total_monthly),
        "monthly_contribution": round(monthly_contribution),
        "annual_contribution": round(annual_contribution),
        "recommended_pot": round(recommended_pot),
        "on_track": on_track,
        "shortfall": round(max(0, recommended_pot - future_value)),
        "state_pension_monthly": round(state_pension / 12),
    }


def calculate_redundancy(data):
    age = int(data.get("age", 35))
    years_service = float(data.get("years_service", 5))
    weekly_pay = float(data.get("weekly_pay", 500))
    weekly_pay_capped = min(weekly_pay, 643)  # 2024/25 cap

    statutory_pay = 0
    for year in range(int(years_service)):
        current_age = age - year
        if current_age >= 41:
            statutory_pay += 1.5 * weekly_pay_capped
        elif current_age >= 22:
            statutory_pay += 1.0 * weekly_pay_capped
        else:
            statutory_pay += 0.5 * weekly_pay_capped

    statutory_pay = min(statutory_pay, 19290)  # 2024/25 max

    return {
        "statutory_pay": round(statutory_pay),
        "weekly_pay_used": round(weekly_pay_capped),
        "weekly_pay_capped": weekly_pay > 643,
        "max_statutory": 19290,
        "taxable_above": max(0, round(statutory_pay - 30000)),
        "tax_free": min(statutory_pay, 30000),
    }


def calculate_maternity(data):
    salary = float(data.get("salary", 35000))
    weeks = int(data.get("weeks", 39))

    weekly_salary = salary / 52
    smp_rate_enhanced = weekly_salary * 0.90  # First 6 weeks
    smp_rate_standard = min(184.03, weekly_salary * 0.90)  # Weeks 7-39 (2024/25 rate)

    week_6_total = smp_rate_enhanced * 6
    remaining_weeks = max(0, weeks - 6)
    remaining_total = smp_rate_standard * remaining_weeks

    total_smp = round(week_6_total + remaining_total)
    total_lost = round((salary / 52) * weeks - total_smp)

    return {
        "total_smp": total_smp,
        "weekly_first_6": round(smp_rate_enhanced),
        "weekly_after_6": round(smp_rate_standard),
        "total_income_lost": total_lost,
        "monthly_during_leave": round(total_smp / (weeks / 4.33)),
        "smp_weeks": weeks,
    }


@app.route("/student-loan")
def student_loan_page():
    return render_template("student_loan.html")


@app.route("/calculate-student-loan", methods=["POST"])
def calculate_student_loan_route():
    return jsonify(calculate_student_loan(request.get_json()))


@app.route("/pension-calculator")
def pension_calculator_page():
    return render_template("pension_calculator.html")


@app.route("/calculate-pension", methods=["POST"])
def calculate_pension_route():
    return jsonify(calculate_pension(request.get_json()))


@app.route("/redundancy-calculator")
def redundancy_calculator_page():
    return render_template("redundancy_calculator.html")


@app.route("/calculate-redundancy", methods=["POST"])
def calculate_redundancy_route():
    return jsonify(calculate_redundancy(request.get_json()))


@app.route("/maternity-calculator")
def maternity_calculator_page():
    return render_template("maternity_calculator.html")


@app.route("/calculate-maternity", methods=["POST"])
def calculate_maternity_route():
    return jsonify(calculate_maternity(request.get_json()))


@app.route("/tax-year-2026")
def tax_year_2026():
    return render_template("tax_year_2026.html")

'''

content = content.replace('if __name__ == "__main__":', new_code + '\nif __name__ == "__main__":')

# Fix duplicate route conflict - remove old commuter_town endpoint
content = content.replace(
    '@app.route("/commute-cost/<city_slug>")\ndef city_page(city_slug):',
    '@app.route("/commute-cost/<city_slug>", endpoint="city_page_old")\ndef city_page(city_slug):'
)

with open(path, 'w') as f:
    f.write(content)
print("Done app.py")
PYEOF

# ── 2. Student Loan Calculator ────────────────────────────────────────────────
cat > "$TARGET/templates/student_loan.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Student Loan Repayment Calculator UK 2025 — Travel Tax</title>
  <meta name="description" content="Calculate your UK student loan monthly repayments, interest and when you will pay it off. Covers Plan 1, 2, 4, 5 and Postgraduate loans." />
  <meta name="keywords" content="student loan repayment calculator UK, student loan calculator 2025, when will I pay off student loan" />
  <link rel="canonical" href="https://www.traveltax.co.uk/student-loan" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="slim-header">
    <div class="slim-header-inner">
      <div class="slim-logo"><a href="/" style="text-decoration:none"><span class="slim-logo-main">Travel Tax.</span><span class="slim-logo-sub">UK Financial Reality Check</span></a></div>
    </div>
    <div class="ticker-tape">
      <span>STUDENT LOAN CALCULATOR &nbsp;·&nbsp; PLAN 1 · PLAN 2 · PLAN 4 · PLAN 5 &nbsp;·&nbsp; WHEN WILL I PAY OFF MY STUDENT LOAN? &nbsp;·&nbsp;</span>
      <span aria-hidden="true">STUDENT LOAN CALCULATOR &nbsp;·&nbsp; PLAN 1 · PLAN 2 · PLAN 4 · PLAN 5 &nbsp;·&nbsp; WHEN WILL I PAY OFF MY STUDENT LOAN? &nbsp;·&nbsp;</span>
    </div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/student-loan" class="nav-link active">Student Loan</a>
      <a href="/pension-calculator" class="nav-link">Pension</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>

  <main class="calc-section">
    <div class="calc-wrapper">
      <div class="form-panel">
        <div class="form-header"><h2>Your Student Loan</h2><p class="form-desc">Find out your monthly repayments and when you will clear it.</p></div>

        <div class="field-group">
          <label for="sl_salary">Annual Salary (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="sl_salary" placeholder="35000" min="0" /></div>
        </div>

        <div class="field-group">
          <label>Loan Plan</label>
          <div class="transport-toggle" style="grid-template-columns:1fr 1fr 1fr;">
            <button class="transport-btn active" data-plan="plan2">Plan 2</button>
            <button class="transport-btn" data-plan="plan1">Plan 1</button>
            <button class="transport-btn" data-plan="plan4">Plan 4</button>
            <button class="transport-btn" data-plan="plan5">Plan 5</button>
            <button class="transport-btn" data-plan="postgrad">Postgrad</button>
          </div>
          <p class="field-hint">Plan 2 = England/Wales from 2012. Plan 1 = before 2012. Plan 4 = Scotland. Plan 5 = from 2023.</p>
        </div>

        <div class="field-group">
          <label for="sl_balance">Current Loan Balance (£) — optional</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="sl_balance" placeholder="45000" min="0" /></div>
          <p class="field-hint">Check your balance at studentloans.co.uk</p>
        </div>

        <button class="calculate-btn" id="slCalculateBtn"><span>Calculate My Repayments</span><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg></button>
      </div>

      <div class="results-panel" id="slResultsPanel">
        <div class="results-placeholder" id="slPlaceholder">
          <div class="fun-facts-wrap">
            <p class="fun-facts-label">⚡ DID YOU KNOW?</p>
            <div style="font-family:var(--font-display);font-size:22px;color:var(--white);line-height:1.3;text-align:center;padding:0 20px;">Only 25% of Plan 2 graduates will repay their loan in full before it is written off after 30 years.</div>
            <p class="fun-facts-cta" style="margin-top:24px;">Enter your salary to see your repayments →</p>
          </div>
        </div>
        <div class="results-content hidden" id="slResults">
          <div class="verdict-banner">
            <p class="verdict-label">YOUR MONTHLY REPAYMENT</p>
            <div class="verdict-number" id="sl_monthly">£0</div>
            <p class="verdict-sub" id="sl_yearly_sub">per year</p>
          </div>
          <div class="stat-cards">
            <div class="stat-card"><span class="stat-icon">📅</span><span class="stat-label">Monthly Repayment</span><span class="stat-value" id="sl_monthly2">£0</span></div>
            <div class="stat-card highlight"><span class="stat-icon">💰</span><span class="stat-label">Yearly Repayment</span><span class="stat-value" id="sl_yearly">£0</span></div>
            <div class="stat-card"><span class="stat-icon">📈</span><span class="stat-label">Interest / Year</span><span class="stat-value" id="sl_interest">£0</span></div>
            <div class="stat-card"><span class="stat-icon">🗓</span><span class="stat-label">Written Off After</span><span class="stat-value" id="sl_writeoff">0 yrs</span></div>
          </div>
          <div class="breakdown-block">
            <h3 class="block-title">Your Repayment Summary</h3>
            <div class="breakdown-row"><span>Repayment threshold</span><span id="sl_threshold">£0</span></div>
            <div class="breakdown-row"><span>Repayment rate</span><span id="sl_rate">9%</span></div>
            <div class="breakdown-row"><span>Monthly repayment</span><span id="sl_monthly3">£0</span></div>
            <div class="breakdown-row"><span>Annual interest added</span><span id="sl_interest2" style="color:var(--red)">£0</span></div>
            <div class="breakdown-row total-row"><span id="sl_verdict_label">Years to repay</span><span id="sl_years">—</span></div>
          </div>
          <div class="savings-callout" id="sl_insight"></div>
          <div class="comparison-block">
            <h3 class="block-title">Also Calculate</h3>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:4px;">
              <a href="/take-home" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Take Home Pay →</a>
              <a href="/pension-calculator" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Pension Calculator →</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Student Loan FAQs</h2>
      <div class="faq-item"><h3>When do I start repaying my student loan?</h3><p>You start repaying in the April after you graduate or leave your course, but only once your income is above the repayment threshold for your plan. Repayments are automatically deducted from your salary by your employer.</p></div>
      <div class="faq-item"><h3>What happens if I never pay it off?</h3><p>Your student loan is written off after a set number of years — 25 years for Plan 1, 30 years for Plan 2 and Plan 4, 40 years for Plan 5. Any remaining balance is cancelled and does not affect your credit score.</p></div>
      <div class="faq-item"><h3>Should I overpay my student loan?</h3><p>For most Plan 2 graduates, overpaying is not financially beneficial since the loan is likely to be written off before full repayment. However, if you are on track to repay in full, overpaying can save on interest. Use this calculator to check your situation.</p></div>
    </div>
  </section>
  <footer class="site-footer"><p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/student-loan">Student Loan</a> · <a href="/privacy">Privacy</a></p></footer>
  <script src="/static/js/student_loan.js"></script>
</body>
</html>
EOF

# ── 3. Student Loan JS ────────────────────────────────────────────────────────
cat > "$TARGET/static/js/student_loan.js" << 'EOF'
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
EOF

# ── 4. Pension Calculator ─────────────────────────────────────────────────────
cat > "$TARGET/templates/pension_calculator.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>UK Pension Calculator 2025 — How Much Should I Save?</title>
  <meta name="description" content="Calculate how much your pension will be worth at retirement. Find out if you are on track and how much you need to save each month." />
  <meta name="keywords" content="pension calculator UK, how much pension will I get, am I saving enough pension, pension pot calculator" />
  <link rel="canonical" href="https://www.traveltax.co.uk/pension-calculator" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="slim-header">
    <div class="slim-header-inner">
      <div class="slim-logo"><a href="/" style="text-decoration:none"><span class="slim-logo-main">Travel Tax.</span><span class="slim-logo-sub">UK Financial Reality Check</span></a></div>
    </div>
    <div class="ticker-tape">
      <span>PENSION CALCULATOR &nbsp;·&nbsp; AM I SAVING ENOUGH? &nbsp;·&nbsp; UK PENSION 2025 &nbsp;·&nbsp; HOW MUCH WILL MY PENSION BE WORTH? &nbsp;·&nbsp;</span>
      <span aria-hidden="true">PENSION CALCULATOR &nbsp;·&nbsp; AM I SAVING ENOUGH? &nbsp;·&nbsp; UK PENSION 2025 &nbsp;·&nbsp; HOW MUCH WILL MY PENSION BE WORTH? &nbsp;·&nbsp;</span>
    </div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/student-loan" class="nav-link">Student Loan</a>
      <a href="/pension-calculator" class="nav-link active">Pension</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>

  <main class="calc-section">
    <div class="calc-wrapper">
      <div class="form-panel">
        <div class="form-header"><h2>Your Pension</h2><p class="form-desc">Find out if you are on track for retirement.</p></div>

        <div class="field-group">
          <label for="p_salary">Annual Salary (£)</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="p_salary" placeholder="35000" min="0" /></div>
        </div>
        <div class="field-group">
          <label for="p_age">Current Age</label>
          <div class="slider-wrap">
            <input type="range" id="p_age_slider" min="18" max="65" value="30" step="1" oninput="document.getElementById('p_age').value=this.value" />
            <div class="slider-input-wrap"><input type="number" id="p_age" value="30" min="18" max="65" oninput="document.getElementById('p_age_slider').value=this.value" /><span class="slider-unit">yrs</span></div>
          </div>
        </div>
        <div class="field-group">
          <label for="p_retire">Retirement Age</label>
          <div class="slider-wrap">
            <input type="range" id="p_retire_slider" min="55" max="75" value="67" step="1" oninput="document.getElementById('p_retire').value=this.value" />
            <div class="slider-input-wrap"><input type="number" id="p_retire" value="67" min="55" max="75" oninput="document.getElementById('p_retire_slider').value=this.value" /><span class="slider-unit">yrs</span></div>
          </div>
        </div>
        <div class="field-group">
          <label for="p_contrib">Your Contribution (%)</label>
          <div class="slider-wrap">
            <input type="range" id="p_contrib_slider" min="0" max="30" value="5" step="1" oninput="document.getElementById('p_contrib').value=this.value" />
            <div class="slider-input-wrap"><input type="number" id="p_contrib" value="5" min="0" max="100" oninput="document.getElementById('p_contrib_slider').value=Math.min(this.value,30)" /><span class="slider-unit">%</span></div>
          </div>
        </div>
        <div class="field-group">
          <label for="p_employer">Employer Contribution (%)</label>
          <div class="slider-wrap">
            <input type="range" id="p_employer_slider" min="0" max="20" value="3" step="1" oninput="document.getElementById('p_employer').value=this.value" />
            <div class="slider-input-wrap"><input type="number" id="p_employer" value="3" min="0" max="100" oninput="document.getElementById('p_employer_slider').value=Math.min(this.value,20)" /><span class="slider-unit">%</span></div>
          </div>
        </div>
        <div class="field-group">
          <label for="p_pot">Current Pension Pot (£) — optional</label>
          <div class="input-wrap"><span class="prefix">£</span><input type="number" id="p_pot" placeholder="0" min="0" /></div>
        </div>

        <button class="calculate-btn" id="pCalculateBtn"><span>Calculate My Pension</span><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg></button>
      </div>

      <div class="results-panel" id="pResultsPanel">
        <div class="results-placeholder" id="pPlaceholder">
          <div class="fun-facts-wrap">
            <p class="fun-facts-label">⚡ DID YOU KNOW?</p>
            <div style="font-family:var(--font-display);font-size:22px;color:var(--white);line-height:1.3;text-align:center;padding:0 20px;">The recommended pension pot at retirement is 25x your annual salary — the 4% drawdown rule.</div>
            <p class="fun-facts-cta" style="margin-top:24px;">Enter your details to see if you are on track →</p>
          </div>
        </div>
        <div class="results-content hidden" id="pResults">
          <div class="verdict-banner">
            <p class="verdict-label">PROJECTED PENSION POT</p>
            <div class="verdict-number" id="p_pot_result">£0</div>
            <p class="verdict-sub" id="p_track_sub">at retirement</p>
          </div>
          <div class="stat-cards">
            <div class="stat-card"><span class="stat-icon">📅</span><span class="stat-label">Monthly Income</span><span class="stat-value" id="p_monthly">£0</span></div>
            <div class="stat-card"><span class="stat-icon">🏛</span><span class="stat-label">+ State Pension</span><span class="stat-value" id="p_state">£958</span></div>
            <div class="stat-card highlight"><span class="stat-icon">💰</span><span class="stat-label">Total Monthly</span><span class="stat-value" id="p_total_monthly">£0</span></div>
            <div class="stat-card"><span class="stat-icon">📈</span><span class="stat-label">Monthly Saving</span><span class="stat-value" id="p_saving">£0</span></div>
          </div>
          <div class="breakdown-block">
            <h3 class="block-title">Retirement Breakdown</h3>
            <div class="breakdown-row"><span>Years to retirement</span><span id="p_years">0</span></div>
            <div class="breakdown-row"><span>Projected pot</span><span id="p_pot2">£0</span></div>
            <div class="breakdown-row"><span>Recommended pot</span><span id="p_recommended">£0</span></div>
            <div class="breakdown-row" id="p_shortfall_row"><span>Shortfall</span><span id="p_shortfall" style="color:var(--red)">£0</span></div>
            <div class="breakdown-row total-row"><span>Status</span><span id="p_status">—</span></div>
          </div>
          <div class="savings-callout" id="p_insight"></div>
          <div class="comparison-block">
            <h3 class="block-title">Also Calculate</h3>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:4px;">
              <a href="/take-home" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Take Home Pay →</a>
              <a href="/student-loan" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Student Loan →</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Pension FAQs</h2>
      <div class="faq-item"><h3>How much should I have in my pension by age?</h3><p>A common rule of thumb is to have 1x your salary saved by age 30, 3x by 40, 6x by 50, and 8x by 60. Use our calculator to see if you are on track based on your specific salary and contribution rate.</p></div>
      <div class="faq-item"><h3>What is the state pension in 2025?</h3><p>The full new state pension is £11,502 per year (£221.20 per week) in 2024/25. You need at least 35 qualifying years of National Insurance contributions to receive the full amount.</p></div>
      <div class="faq-item"><h3>What growth rate should I use?</h3><p>We use 5% as a default, which is a conservative estimate for a balanced pension fund after inflation. Higher-risk funds may return more; lower-risk funds may return less. The actual return will depend on your fund choices.</p></div>
    </div>
  </section>
  <footer class="site-footer"><p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/pension-calculator">Pension</a> · <a href="/privacy">Privacy</a></p></footer>
  <script src="/static/js/pension_calculator.js"></script>
</body>
</html>
EOF

# ── 5. Pension JS ─────────────────────────────────────────────────────────────
cat > "$TARGET/static/js/pension_calculator.js" << 'EOF'
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
EOF

# ── 6. Redundancy Calculator ──────────────────────────────────────────────────
cat > "$TARGET/templates/redundancy_calculator.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>UK Redundancy Pay Calculator 2025 — Statutory Redundancy</title>
  <meta name="description" content="Calculate your statutory redundancy pay in the UK. Find out exactly how much you are entitled to based on your age, years of service and weekly pay." />
  <meta name="keywords" content="redundancy pay calculator UK, statutory redundancy pay 2025, how much redundancy am I entitled to" />
  <link rel="canonical" href="https://www.traveltax.co.uk/redundancy-calculator" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="slim-header">
    <div class="slim-header-inner"><div class="slim-logo"><a href="/" style="text-decoration:none"><span class="slim-logo-main">Travel Tax.</span></a></div></div>
    <div class="ticker-tape"><span>REDUNDANCY CALCULATOR &nbsp;·&nbsp; STATUTORY REDUNDANCY PAY 2025 &nbsp;·&nbsp; KNOW YOUR RIGHTS &nbsp;·&nbsp;</span><span aria-hidden="true">REDUNDANCY CALCULATOR &nbsp;·&nbsp; STATUTORY REDUNDANCY PAY 2025 &nbsp;·&nbsp; KNOW YOUR RIGHTS &nbsp;·&nbsp;</span></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/redundancy-calculator" class="nav-link active">Redundancy</a>
      <a href="/maternity-calculator" class="nav-link">Maternity Pay</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>
  <main class="calc-section">
    <div class="calc-wrapper">
      <div class="form-panel">
        <div class="form-header"><h2>Your Redundancy Pay</h2><p class="form-desc">Calculate your statutory entitlement.</p></div>
        <div class="field-group"><label for="r_age">Your Age</label><div class="input-wrap"><input type="number" id="r_age" placeholder="35" min="18" max="80" /></div></div>
        <div class="field-group"><label for="r_years">Years of Service</label><div class="input-wrap"><input type="number" id="r_years" placeholder="5" min="0" step="0.5" /></div><p class="field-hint">You need at least 2 years to qualify for statutory redundancy pay.</p></div>
        <div class="field-group"><label for="r_weekly">Weekly Gross Pay (£)</label><div class="input-wrap"><span class="prefix">£</span><input type="number" id="r_weekly" placeholder="650" min="0" /></div><p class="field-hint">Capped at £643/week for 2024/25. Divide your annual salary by 52.</p></div>
        <button class="calculate-btn" id="rCalculateBtn"><span>Calculate My Redundancy Pay</span><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg></button>
      </div>
      <div class="results-panel" id="rResultsPanel">
        <div class="results-placeholder" id="rPlaceholder">
          <div class="fun-facts-wrap">
            <p class="fun-facts-label">⚡ DID YOU KNOW?</p>
            <div style="font-family:var(--font-display);font-size:22px;color:var(--white);line-height:1.3;text-align:center;padding:0 20px;">The first £30,000 of redundancy pay is tax-free in the UK.</div>
            <p class="fun-facts-cta" style="margin-top:24px;">Enter your details to calculate your entitlement →</p>
          </div>
        </div>
        <div class="results-content hidden" id="rResults">
          <div class="verdict-banner"><p class="verdict-label">YOUR STATUTORY REDUNDANCY PAY</p><div class="verdict-number" id="r_total">£0</div><p class="verdict-sub">based on your age, service and pay</p></div>
          <div class="breakdown-block">
            <h3 class="block-title">Redundancy Breakdown</h3>
            <div class="breakdown-row"><span>Weekly pay used</span><span id="r_weekly_used">£0</span></div>
            <div class="breakdown-row"><span>Statutory redundancy pay</span><span id="r_statutory">£0</span></div>
            <div class="breakdown-row"><span>Tax-free portion</span><span id="r_taxfree" style="color:var(--green)">£0</span></div>
            <div class="breakdown-row"><span>Taxable above £30,000</span><span id="r_taxable">£0</span></div>
            <div class="breakdown-row total-row"><span>Your entitlement</span><span id="r_total2">£0</span></div>
          </div>
          <div class="savings-callout" id="r_insight"></div>
        </div>
      </div>
    </div>
  </main>
  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Redundancy FAQs</h2>
      <div class="faq-item"><h3>How is statutory redundancy pay calculated?</h3><p>You get half a week's pay for each year under 22, one week's pay for each year between 22-40, and one and a half week's pay for each year over 41. Weekly pay is capped at £643 in 2024/25.</p></div>
      <div class="faq-item"><h3>Is redundancy pay taxable?</h3><p>The first £30,000 of redundancy pay is tax-free. Any amount above £30,000 is subject to income tax but not National Insurance.</p></div>
      <div class="faq-item"><h3>Can my employer pay more than statutory?</h3><p>Yes — many employers offer enhanced redundancy pay above the statutory minimum. Check your employment contract or staff handbook for details.</p></div>
    </div>
  </section>
  <footer class="site-footer"><p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/redundancy-calculator">Redundancy</a> · <a href="/privacy">Privacy</a></p></footer>
  <script>
    document.addEventListener("DOMContentLoaded", () => {
      document.getElementById("rCalculateBtn").addEventListener("click", async () => {
        const btn = document.getElementById("rCalculateBtn");
        const age = parseInt(document.getElementById("r_age").value) || 0;
        const years = parseFloat(document.getElementById("r_years").value) || 0;
        const weekly = parseFloat(document.getElementById("r_weekly").value) || 0;
        if (age <= 0 || years < 2 || weekly <= 0) { alert("Please enter your age, at least 2 years service, and weekly pay."); return; }
        btn.querySelector("span").textContent = "Calculating...";
        btn.disabled = true;
        try {
          const res = await fetch("/calculate-redundancy", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ age, years_service: years, weekly_pay: weekly }) });
          const r = await res.json();
          const fmt = n => "£" + Math.round(n).toLocaleString("en-GB");
          document.getElementById("rPlaceholder").classList.add("hidden");
          document.getElementById("rResults").classList.remove("hidden");
          document.getElementById("r_total").textContent = fmt(r.statutory_pay);
          document.getElementById("r_weekly_used").textContent = fmt(r.weekly_pay_used) + (r.weekly_pay_capped ? " (capped)" : "");
          document.getElementById("r_statutory").textContent = fmt(r.statutory_pay);
          document.getElementById("r_taxfree").textContent = fmt(r.tax_free);
          document.getElementById("r_taxable").textContent = r.taxable_above > 0 ? fmt(r.taxable_above) : "None";
          document.getElementById("r_total2").textContent = fmt(r.statutory_pay);
          document.getElementById("r_insight").textContent = r.taxable_above > 0
            ? "Your redundancy pay exceeds £30,000. The first £30,000 is tax-free, but " + fmt(r.taxable_above) + " will be subject to income tax at your marginal rate."
            : "Your full redundancy payment of " + fmt(r.statutory_pay) + " is below £30,000 and is completely tax-free. Note this is the statutory minimum — check your contract for any enhanced entitlement.";
        } catch(err) { alert("Something went wrong."); }
        finally { btn.querySelector("span").textContent = "Calculate My Redundancy Pay"; btn.disabled = false; }
      });
    });
  </script>
</body>
</html>
EOF

# ── 7. Maternity Calculator ───────────────────────────────────────────────────
cat > "$TARGET/templates/maternity_calculator.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>UK Maternity Pay Calculator 2025 — SMP Calculator</title>
  <meta name="description" content="Calculate your UK statutory maternity pay (SMP) week by week. Find out your total maternity pay and how much income you will lose during leave." />
  <meta name="keywords" content="maternity pay calculator UK, SMP calculator 2025, statutory maternity pay calculator" />
  <link rel="canonical" href="https://www.traveltax.co.uk/maternity-calculator" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="slim-header">
    <div class="slim-header-inner"><div class="slim-logo"><a href="/" style="text-decoration:none"><span class="slim-logo-main">Travel Tax.</span></a></div></div>
    <div class="ticker-tape"><span>MATERNITY PAY CALCULATOR &nbsp;·&nbsp; SMP 2025 &nbsp;·&nbsp; STATUTORY MATERNITY PAY &nbsp;·&nbsp;</span><span aria-hidden="true">MATERNITY PAY CALCULATOR &nbsp;·&nbsp; SMP 2025 &nbsp;·&nbsp; STATUTORY MATERNITY PAY &nbsp;·&nbsp;</span></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/redundancy-calculator" class="nav-link">Redundancy</a>
      <a href="/maternity-calculator" class="nav-link active">Maternity Pay</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>
  <main class="calc-section">
    <div class="calc-wrapper">
      <div class="form-panel">
        <div class="form-header"><h2>Your Maternity Pay</h2><p class="form-desc">Calculate your statutory maternity pay and income during leave.</p></div>
        <div class="field-group"><label for="m_salary">Annual Salary (£)</label><div class="input-wrap"><span class="prefix">£</span><input type="number" id="m_salary" placeholder="35000" min="0" /></div></div>
        <div class="field-group">
          <label>Maternity Leave Length</label>
          <div class="day-toggle" id="m_weeks_toggle">
            <button class="day-btn active" data-val="39">39 wks SMP</button>
            <button class="day-btn" data-val="26">26 wks</button>
            <button class="day-btn" data-val="52">52 wks full</button>
          </div>
          <p class="field-hint">SMP is paid for up to 39 weeks. You can take up to 52 weeks total but the last 13 are unpaid.</p>
        </div>
        <button class="calculate-btn" id="mCalculateBtn"><span>Calculate My Maternity Pay</span><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg></button>
      </div>
      <div class="results-panel" id="mResultsPanel">
        <div class="results-placeholder" id="mPlaceholder">
          <div class="fun-facts-wrap">
            <p class="fun-facts-label">⚡ DID YOU KNOW?</p>
            <div style="font-family:var(--font-display);font-size:22px;color:var(--white);line-height:1.3;text-align:center;padding:0 20px;">Statutory maternity pay is just £184.03/week from week 7 — regardless of your salary.</div>
            <p class="fun-facts-cta" style="margin-top:24px;">Enter your salary to see your full picture →</p>
          </div>
        </div>
        <div class="results-content hidden" id="mResults">
          <div class="verdict-banner"><p class="verdict-label">TOTAL MATERNITY PAY</p><div class="verdict-number" id="m_total">£0</div><p class="verdict-sub" id="m_sub">during your leave</p></div>
          <div class="stat-cards">
            <div class="stat-card"><span class="stat-icon">1️⃣</span><span class="stat-label">First 6 Weeks</span><span class="stat-value" id="m_first6">£0/wk</span></div>
            <div class="stat-card highlight"><span class="stat-icon">📅</span><span class="stat-label">After 6 Weeks</span><span class="stat-value" id="m_after6">£0/wk</span></div>
            <div class="stat-card"><span class="stat-icon">💸</span><span class="stat-label">Monthly During Leave</span><span class="stat-value" id="m_monthly">£0</span></div>
            <div class="stat-card"><span class="stat-icon">⚠️</span><span class="stat-label">Income Lost</span><span class="stat-value" id="m_lost">£0</span></div>
          </div>
          <div class="savings-callout" id="m_insight"></div>
          <div class="comparison-block">
            <h3 class="block-title">Also Calculate</h3>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:4px;">
              <a href="/take-home" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Take Home Pay →</a>
              <a href="/compare-jobs" style="display:block;padding:14px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;text-align:center;">Compare Jobs →</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Maternity Pay FAQs</h2>
      <div class="faq-item"><h3>How is statutory maternity pay calculated?</h3><p>For the first 6 weeks, SMP is 90% of your average weekly earnings. For weeks 7-39, it is the lower of 90% of your average weekly earnings or £184.03 per week (2024/25 rate).</p></div>
      <div class="faq-item"><h3>Can my employer pay more than statutory?</h3><p>Yes — many employers offer enhanced maternity pay above the statutory minimum. Check your employment contract. Some offer full pay for a period before dropping to SMP.</p></div>
      <div class="faq-item"><h3>Is maternity pay taxable?</h3><p>Yes, statutory maternity pay is taxable and subject to National Insurance in the same way as normal wages.</p></div>
    </div>
  </section>
  <footer class="site-footer"><p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/maternity-calculator">Maternity Pay</a> · <a href="/privacy">Privacy</a></p></footer>
  <script>
    let mWeeks = 39;
    document.addEventListener("DOMContentLoaded", () => {
      document.querySelectorAll("#m_weeks_toggle .day-btn").forEach(btn => {
        btn.addEventListener("click", () => {
          document.querySelectorAll("#m_weeks_toggle .day-btn").forEach(b => b.classList.remove("active"));
          btn.classList.add("active");
          mWeeks = parseInt(btn.dataset.val);
        });
      });
      document.getElementById("mCalculateBtn").addEventListener("click", async () => {
        const btn = document.getElementById("mCalculateBtn");
        const salary = parseFloat(document.getElementById("m_salary").value) || 0;
        if (salary <= 0) { alert("Please enter your salary."); return; }
        btn.querySelector("span").textContent = "Calculating...";
        btn.disabled = true;
        try {
          const res = await fetch("/calculate-maternity", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ salary, weeks: mWeeks }) });
          const r = await res.json();
          const fmt = n => "£" + Math.round(n).toLocaleString("en-GB");
          document.getElementById("mPlaceholder").classList.add("hidden");
          document.getElementById("mResults").classList.remove("hidden");
          document.getElementById("m_total").textContent = fmt(r.total_smp);
          document.getElementById("m_sub").textContent = "over " + r.smp_weeks + " weeks of leave";
          document.getElementById("m_first6").textContent = fmt(r.weekly_first_6) + "/wk";
          document.getElementById("m_after6").textContent = fmt(r.weekly_after_6) + "/wk";
          document.getElementById("m_monthly").textContent = fmt(r.monthly_during_leave);
          document.getElementById("m_lost").textContent = fmt(r.total_income_lost);
          document.getElementById("m_insight").textContent = "During your " + r.smp_weeks + "-week leave, you will receive " + fmt(r.total_smp) + " in statutory maternity pay — " + fmt(r.total_income_lost) + " less than your normal salary. Many employers offer enhanced maternity pay so check your contract for any additional entitlement.";
        } catch(err) { alert("Something went wrong."); }
        finally { btn.querySelector("span").textContent = "Calculate My Maternity Pay"; btn.disabled = false; }
      });
    });
  </script>
</body>
</html>
EOF

# ── 8. Tax Year 2026 page ─────────────────────────────────────────────────────
cat > "$TARGET/templates/tax_year_2026.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>What Changes in the New Tax Year April 2026 — UK Tax Changes</title>
  <meta name="description" content="Everything changing in the UK tax year from April 2026. Income tax bands, National Insurance, student loan thresholds, minimum wage and more." />
  <meta name="keywords" content="what changes April 2026, new tax year 2026, UK tax changes 2026, income tax 2026" />
  <link rel="canonical" href="https://www.traveltax.co.uk/tax-year-2026" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner"><a href="/" class="blog-logo">Travel Tax</a><a href="/take-home" class="blog-cta">Take Home Calculator →</a></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link active">Take Home Pay</a>
      <a href="/student-loan" class="nav-link">Student Loan</a>
      <a href="/pension-calculator" class="nav-link">Pension</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>
  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">TAX YEAR 2026 · WHAT CHANGES IN APRIL</span>
        <h1 class="blog-title">What Changes in the New Tax Year April 2026?</h1>
        <p class="blog-lead">Every April the UK tax year resets and a number of thresholds, rates and allowances change. Here is everything you need to know about what changes from April 2026 and how it affects your take home pay.</p>
        <div class="blog-meta"><span>Updated March 2026</span><span>·</span><span>5 min read</span></div>
      </div>

      <article class="blog-article">
        <h2>Income Tax — What Changes in April 2026</h2>
        <p>The income tax personal allowance remains frozen at £12,570 until at least 2028, as announced in the Autumn Budget. This means that as wages rise, more of your income falls into taxable bands — a stealth tax increase known as fiscal drag.</p>
        <p>The basic rate band (20%) runs from £12,571 to £50,270. The higher rate (40%) applies from £50,271 to £125,140. The additional rate of 45% applies above £125,140. These thresholds are unchanged from 2025/26.</p>

        <h2>National Insurance — What Changes in April 2026</h2>
        <p>The main National Insurance rate for employees remains at 8% on earnings between £12,570 and £50,270, and 2% above £50,270. Employer NI contributions increased from 13.8% to 15% in April 2025, which has led many employers to reduce hiring or limit pay rises.</p>

        <h2>Minimum Wage — What Changes in April 2026</h2>
        <p>The National Living Wage for workers aged 21 and over increases in April 2026. The exact figure is announced each autumn. For 2025/26, the rate was £12.21 per hour. The 2026/27 rate will be confirmed by the Low Pay Commission.</p>

        <h2>Student Loan Thresholds — What Changes in April 2026</h2>
        <p>Student loan repayment thresholds are typically uprated each April in line with average earnings. Plan 2 borrowers currently repay 9% of income above £27,295. This threshold may increase slightly from April 2026. Use our <a href="/student-loan">student loan calculator</a> to see your exact repayments.</p>

        <h2>Pension Auto-Enrolment — What Changes in April 2026</h2>
        <p>The government has signalled plans to extend auto-enrolment to workers from age 18 (currently 22) and to remove the lower earnings limit. This would mean more workers start saving into a pension earlier and on a higher percentage of their earnings. The exact implementation date has not been confirmed.</p>

        <h2>Calculate Your New Take Home Pay</h2>
        <p>Use our free calculator to see exactly what you will take home from April 2026 based on the updated rates.</p>
        <div style="text-align:center;margin:40px 0;">
          <a href="/take-home" style="display:inline-block;background:var(--accent);color:var(--black);font-family:var(--font-mono);font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;">Calculate My 2026 Take Home Pay →</a>
        </div>
      </article>
    </div>
  </main>
  <footer class="site-footer"><p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p></footer>
</body>
</html>
EOF

# ── 9. Commuter town template ─────────────────────────────────────────────────
cat > "$TARGET/templates/commuter_town.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{{ town.name }} to {{ town.to_city }} Commute Cost 2025 — Travel Tax</title>
  <meta name="description" content="How much does it cost to commute from {{ town.name }} to {{ town.to_city }} in 2025? Average season ticket £{{ town.avg_season_ticket|int }}/year. Calculate your exact commute cost." />
  <meta name="keywords" content="{{ town.name }} to {{ town.to_city }} commute, commuting from {{ town.name }}, {{ town.name }} season ticket cost" />
  <link rel="canonical" href="https://www.traveltax.co.uk/commute-cost/{{ slug }}" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner"><a href="/" class="blog-logo">Travel Tax</a><a href="/" class="blog-cta">Calculate Yours →</a></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
      <a href="/blog" class="nav-link active">Guides</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>
  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">COMMUTER TOWN · {{ town.name|upper }} TO {{ town.to_city|upper }} · 2025</span>
        <h1 class="blog-title">{{ town.name }} to {{ town.to_city }} Commute Cost 2025</h1>
        <p class="blog-lead">{{ town.description }}</p>
      </div>
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:32px 0;">
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">{{ town.avg_commute_mins }} min</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">AVG JOURNEY</div>
        </div>
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">£{{ "{:,}".format(town.avg_season_ticket) }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">AVG SEASON TICKET</div>
        </div>
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">£{{ "{:,}".format(time_cost) }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">TIME COST / YEAR</div>
        </div>
      </div>
      <article class="blog-article">
        <h2>The True Cost of Commuting from {{ town.name }} to {{ town.to_city }}</h2>
        <p>The average season ticket from {{ town.name }} to {{ town.to_city }} costs £{{ "{:,}".format(town.avg_season_ticket) }} per year. But this is only the direct transport cost. When you include the monetary value of your commuting time — calculated at the average {{ town.name }} salary of £{{ "{:,}".format(town.avg_salary) }} — the true annual commute cost exceeds £{{ "{:,}".format(town.avg_season_ticket + time_cost) }}.</p>
        <p>{{ town.name }} is popular with {{ town.popular_for | join(", ") }} who want to be within commuting distance of {{ town.to_city }} while enjoying lower housing costs and a different lifestyle.</p>
        <div class="blog-callout">
          <p>🧮 <strong>Calculate your exact commute cost</strong> — use our free <a href="/">Travel Tax calculator</a> to see your personal travel tax including time value.</p>
        </div>
        <h2>{{ town.name }} Commuter Tips</h2>
        <p>Trains from {{ town.name }} are operated by <strong>{{ town.train_operator }}</strong>. To reduce your commute cost, consider an annual season ticket (saves approximately 12 weeks of daily fares), a Railcard if you buy flexible tickets, or negotiating hybrid working to reduce the number of days you commute.</p>
        <div style="text-align:center;margin:40px 0;">
          <a href="/" style="display:inline-block;background:var(--accent);color:var(--black);font-family:var(--font-mono);font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;">Calculate My Commute Cost →</a>
        </div>
        <h2>Other Commuter Towns</h2>
        <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:16px;">
          {% for t_slug, t_data in all_towns.items() %}
          {% if t_slug != slug %}
          <a href="/commute-cost/{{ t_slug }}" style="padding:10px 16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-family:var(--font-mono);font-size:11px;" onmouseover="this.style.borderColor='var(--accent)';this.style.color='var(--accent)'" onmouseout="this.style.borderColor='var(--border)';this.style.color='var(--text-dim)'">{{ t_data.name }} to {{ t_data.to_city }} →</a>
          {% endif %}
          {% endfor %}
        </div>
      </article>
    </div>
  </main>
  <footer class="site-footer"><p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/guide">Guide</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p></footer>
</body>
</html>
EOF

# ── 10. Update sitemap ────────────────────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

new_urls = '''
        {"loc": "https://www.traveltax.co.uk/student-loan", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/pension-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/redundancy-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/maternity-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/tax-year-2026", "priority": "0.9", "changefreq": "weekly"},'''

for slug in ['reading','brighton','guildford','oxford','cambridge','milton-keynes']:
    new_urls += f'\n        {{"loc": "https://www.traveltax.co.uk/commute-cost/{slug}", "priority": "0.8", "changefreq": "monthly"}},'

for slug in ['doctor','lawyer','pilot','engineer','social-worker']:
    new_urls += f'\n        {{"loc": "https://www.traveltax.co.uk/salary/{slug}", "priority": "0.8", "changefreq": "monthly"}},'

if '"loc": "https://www.traveltax.co.uk/student-loan"' not in content:
    content = content.replace(
        '{"loc": "https://www.traveltax.co.uk/press"',
        '{"loc": "https://www.traveltax.co.uk/press"' + new_urls.replace(new_urls[:1], ',\n        {"loc": "https://www.traveltax.co.uk/press"'[:-len('{"loc": "https://www.traveltax.co.uk/press"')], 1)
    )
    # simpler approach
    content = content.replace(
        '"priority": "0.6", "changefreq": "monthly"},\n',
        '"priority": "0.6", "changefreq": "monthly"},' + new_urls + '\n'
    )
    with open(path, 'w') as f:
        f.write(content)
    print("Sitemap updated")
PYEOF

# ── 11. Test ──────────────────────────────────────────────────────────────────
echo ""
echo "Testing..."
cd "$TARGET" && python3 -c "
import app
print('✅ OK - no syntax errors')
" 2>&1

echo ""
echo "Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add 5 calculators, commuter towns, salary pages' && git push"
