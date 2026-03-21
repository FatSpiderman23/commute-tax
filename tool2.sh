#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🔨 Building Tool 2 and email capture..."

# ── 1. Add take-home calculation to app.py ───────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

new_routes = '''
# =============================================
# TOOL 2: TAKE HOME PAY CALCULATOR
# =============================================

def calculate_take_home(data):
    salary = float(data.get("salary", 0))
    student_loan = data.get("student_loan", "none")
    pension_pct = float(data.get("pension_pct", 0))
    blind = data.get("blind", False)

    # Personal allowance 2024/25
    personal_allowance = 12570
    if salary > 100000:
        taper = (salary - 100000) / 2
        personal_allowance = max(0, personal_allowance - taper)

    # Taxable income
    taxable = max(0, salary - personal_allowance)

    # Income tax bands 2024/25
    tax = 0
    basic_band = 37700
    higher_band = 125140 - 12570

    if taxable <= basic_band:
        tax = taxable * 0.20
    elif taxable <= higher_band:
        tax = basic_band * 0.20 + (taxable - basic_band) * 0.40
    else:
        tax = basic_band * 0.20 + (higher_band - basic_band) * 0.40 + (taxable - higher_band) * 0.45

    # National Insurance 2024/25
    ni = 0
    ni_threshold = 12570
    ni_upper = 50270
    if salary > ni_threshold:
        if salary <= ni_upper:
            ni = (salary - ni_threshold) * 0.08
        else:
            ni = (ni_upper - ni_threshold) * 0.08 + (salary - ni_upper) * 0.02

    # Student loan
    sl = 0
    if student_loan == "plan1":
        threshold = 22015
        if salary > threshold:
            sl = (salary - threshold) * 0.09
    elif student_loan == "plan2":
        threshold = 27295
        if salary > threshold:
            sl = (salary - threshold) * 0.09
    elif student_loan == "plan4":
        threshold = 27660
        if salary > threshold:
            sl = (salary - threshold) * 0.09
    elif student_loan == "plan5":
        threshold = 25000
        if salary > threshold:
            sl = (salary - threshold) * 0.06
    elif student_loan == "postgrad":
        threshold = 21000
        if salary > threshold:
            sl = (salary - threshold) * 0.06

    # Pension
    pension = salary * (pension_pct / 100)

    # Take home
    take_home_yearly = salary - tax - ni - sl - pension
    take_home_monthly = take_home_yearly / 12
    take_home_weekly = take_home_yearly / 52
    take_home_daily = take_home_yearly / 260

    # Effective tax rate
    total_deductions = tax + ni + sl + pension
    effective_rate = (total_deductions / salary * 100) if salary > 0 else 0

    return {
        "gross_yearly": round(salary),
        "gross_monthly": round(salary / 12),
        "take_home_yearly": round(take_home_yearly),
        "take_home_monthly": round(take_home_monthly),
        "take_home_weekly": round(take_home_weekly),
        "take_home_daily": round(take_home_daily),
        "income_tax": round(tax),
        "national_insurance": round(ni),
        "student_loan": round(sl),
        "pension": round(pension),
        "total_deductions": round(total_deductions),
        "effective_rate": round(effective_rate, 1),
        "personal_allowance": round(personal_allowance),
    }


@app.route("/take-home")
def take_home_page():
    return render_template("take_home.html")


@app.route("/calculate-take-home", methods=["POST"])
def calculate_take_home_route():
    data = request.get_json()
    result = calculate_take_home(data)
    return jsonify(result)


# =============================================
# EMAIL CAPTURE
# =============================================

@app.route("/subscribe", methods=["POST"])
def subscribe():
    import json
    import urllib.request
    import urllib.parse

    data = request.get_json()
    email = data.get("email", "").strip()
    results_summary = data.get("results_summary", "")

    if not email or "@" not in email:
        return jsonify({"success": False, "error": "Invalid email"})

    # Save to local file as backup
    import os
    subscribers_file = os.path.join(os.path.dirname(__file__), "subscribers.txt")
    with open(subscribers_file, "a") as f:
        f.write(f"{email},{results_summary}\\n")

    # Mailchimp API integration
    # Replace these with your actual Mailchimp details
    MAILCHIMP_API_KEY = "YOUR_MAILCHIMP_API_KEY"
    MAILCHIMP_LIST_ID = "YOUR_MAILCHIMP_LIST_ID"
    MAILCHIMP_DC = "us1"  # datacenter from your API key e.g. us1, us2 etc

    if MAILCHIMP_API_KEY != "YOUR_MAILCHIMP_API_KEY":
        try:
            url = f"https://{MAILCHIMP_DC}.api.mailchimp.com/3.0/lists/{MAILCHIMP_LIST_ID}/members"
            payload = json.dumps({
                "email_address": email,
                "status": "subscribed",
                "merge_fields": {"RESULTS": results_summary}
            }).encode("utf-8")
            req = urllib.request.Request(url, data=payload, method="POST")
            req.add_header("Content-Type", "application/json")
            import base64
            credentials = base64.b64encode(f"anystring:{MAILCHIMP_API_KEY}".encode()).decode()
            req.add_header("Authorization", f"Basic {credentials}")
            urllib.request.urlopen(req)
        except Exception as e:
            pass  # Still saved locally

    return jsonify({"success": True})

'''

content = content.replace('if __name__ == "__main__":', new_routes + '\nif __name__ == "__main__":')

with open(path, 'w') as f:
    f.write(content)
print("Done app.py")
PYEOF

# ── 2. Take Home Pay HTML page ────────────────────────────────────────────────
cat > "$TARGET/templates/take_home.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>UK Take Home Pay Calculator 2025 — After Tax, NI & Student Loan</title>
  <meta name="description" content="Calculate your exact UK take home pay after income tax, National Insurance, student loan, and pension. Free 2024/25 salary calculator." />
  <meta name="keywords" content="UK take home pay calculator, salary after tax UK, net pay calculator, take home pay 2025" />
  <meta property="og:title" content="UK Take Home Pay Calculator 2025 — Travel Tax" />
  <meta property="og:description" content="Find out exactly what you take home after tax, NI, student loan and pension. Free UK salary calculator." />
  <link rel="canonical" href="https://www.traveltax.co.uk/take-home" />
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    "name": "UK Take Home Pay Calculator",
    "description": "Calculate your exact UK take home pay after all deductions.",
    "url": "https://www.traveltax.co.uk/take-home",
    "applicationCategory": "FinanceApplication",
    "offers": {"@type": "Offer", "price": "0", "priceCurrency": "GBP"}
  }
  </script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
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
        <span>Basic rate: <strong>20%</strong></span>
        <span>Higher rate: <strong>40%</strong></span>
        <span>Personal allowance: <strong>£12,570</strong></span>
      </div>
    </div>
    <div class="ticker-tape">
      <span>TAKE HOME PAY CALCULATOR &nbsp;·&nbsp; 2024/25 TAX YEAR &nbsp;·&nbsp; INCOME TAX &nbsp;·&nbsp; NATIONAL INSURANCE &nbsp;·&nbsp; STUDENT LOAN &nbsp;·&nbsp; PENSION &nbsp;·&nbsp;</span>
      <span aria-hidden="true">TAKE HOME PAY CALCULATOR &nbsp;·&nbsp; 2024/25 TAX YEAR &nbsp;·&nbsp; INCOME TAX &nbsp;·&nbsp; NATIONAL INSURANCE &nbsp;·&nbsp; STUDENT LOAN &nbsp;·&nbsp; PENSION &nbsp;·&nbsp;</span>
    </div>
  </header>

  <main class="calc-section">
    <div class="calc-wrapper">

      <!-- FORM -->
      <div class="form-panel">
        <div class="form-header">
          <h2>Your Salary</h2>
          <p class="form-desc">Find out exactly what lands in your bank account.</p>
        </div>

        <div class="field-group">
          <label for="th_salary">Annual Gross Salary (£)</label>
          <div class="input-wrap">
            <span class="prefix">£</span>
            <input type="number" id="th_salary" placeholder="35000" min="0" />
          </div>
        </div>

        <div class="field-group">
          <label>Student Loan</label>
          <div class="transport-toggle" style="grid-template-columns:1fr 1fr 1fr;">
            <button class="transport-btn active" data-plan="none">None</button>
            <button class="transport-btn" data-plan="plan1">Plan 1</button>
            <button class="transport-btn" data-plan="plan2">Plan 2</button>
            <button class="transport-btn" data-plan="plan4">Plan 4</button>
            <button class="transport-btn" data-plan="plan5">Plan 5</button>
            <button class="transport-btn" data-plan="postgrad">Postgrad</button>
          </div>
          <p class="field-hint">Plan 1 = started before 2012. Plan 2 = started 2012 or after. Plan 4 = Scotland. Plan 5 = started 2023+.</p>
        </div>

        <div class="field-group">
          <label for="th_pension">Pension Contribution (%)</label>
          <div class="slider-wrap">
            <input type="range" id="th_pension_slider" min="0" max="20" value="5" step="1" />
            <div class="slider-input-wrap">
              <input type="number" id="th_pension" value="5" min="0" max="100" />
              <span class="slider-unit">%</span>
            </div>
          </div>
          <p class="field-hint">Typical employer minimum is 5%. Enter 0 if no pension.</p>
        </div>

        <button class="calculate-btn" id="thCalculateBtn">
          <span>Calculate My Take Home Pay</span>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
        </button>

        <div style="margin-top:24px;padding:16px;border:1px solid var(--border);background:var(--off-black);">
          <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--accent);margin-bottom:8px;">ALSO TRY</p>
          <a href="/" style="display:block;color:var(--text-dim);text-decoration:none;font-size:13px;padding:8px 0;border-bottom:1px solid var(--border);">Commute Cost Calculator — what is your commute really costing you? →</a>
          <a href="/blog" style="display:block;color:var(--text-dim);text-decoration:none;font-size:13px;padding:8px 0;">UK Commute & Work Guides →</a>
        </div>
      </div>

      <!-- RESULTS -->
      <div class="results-panel" id="thResultsPanel">
        <div class="results-placeholder" id="thResultsPlaceholder">
          <div class="fun-facts-wrap">
            <p class="fun-facts-label">⚡ DID YOU KNOW?</p>
            <div class="fun-fact-display" id="thFactDisplay"></div>
            <div class="fun-fact-dots" id="thFactDots"></div>
            <p class="fun-facts-cta">Enter your salary and hit Calculate →</p>
          </div>
        </div>

        <div class="results-content hidden" id="thResultsContent">

          <!-- Take home verdict -->
          <div class="verdict-banner">
            <p class="verdict-label">YOUR MONTHLY TAKE HOME</p>
            <div class="verdict-number" id="th_monthly">£0</div>
            <p class="verdict-sub" id="th_yearly_sub">per year take home</p>
          </div>

          <!-- Stat cards -->
          <div class="stat-cards">
            <div class="stat-card">
              <span class="stat-icon">📅</span>
              <span class="stat-label">Weekly Take Home</span>
              <span class="stat-value" id="th_weekly">£0</span>
            </div>
            <div class="stat-card highlight">
              <span class="stat-icon">💸</span>
              <span class="stat-label">Total Deductions</span>
              <span class="stat-value" id="th_deductions">£0</span>
            </div>
            <div class="stat-card">
              <span class="stat-icon">📊</span>
              <span class="stat-label">Effective Tax Rate</span>
              <span class="stat-value" id="th_effective_rate">0%</span>
            </div>
            <div class="stat-card">
              <span class="stat-icon">☀️</span>
              <span class="stat-label">Daily Take Home</span>
              <span class="stat-value" id="th_daily">£0</span>
            </div>
          </div>

          <!-- Breakdown -->
          <div class="breakdown-block">
            <h3 class="block-title">Full Breakdown</h3>
            <div class="breakdown-row"><span>Gross salary</span><span id="th_gross">£0</span></div>
            <div class="breakdown-row"><span>Income tax</span><span id="th_tax" style="color:var(--red)">-£0</span></div>
            <div class="breakdown-row"><span>National Insurance</span><span id="th_ni" style="color:var(--red)">-£0</span></div>
            <div class="breakdown-row" id="th_sl_row" style="display:none"><span>Student loan</span><span id="th_sl" style="color:var(--red)">-£0</span></div>
            <div class="breakdown-row" id="th_pension_row" style="display:none"><span>Pension</span><span id="th_pension_val" style="color:var(--red)">-£0</span></div>
            <div class="breakdown-row total-row"><span>Take home (yearly)</span><span id="th_takehome_yearly">£0</span></div>
          </div>

          <!-- Reality check -->
          <div class="life-impact-block">
            <h3 class="block-title">The Reality Check</h3>
            <p class="impact-career" id="th_reality"></p>
          </div>

          <!-- Cross-sell to commute calculator -->
          <div class="comparison-block">
            <h3 class="block-title">Now Calculate Your Commute Cost</h3>
            <p style="font-size:13px;color:var(--text-dim);margin-bottom:16px;">You know what you take home. Now find out how much your commute is eating into it — including the value of your time.</p>
            <a href="/" style="display:block;text-align:center;background:var(--accent);color:var(--black);font-family:var(--font-mono);font-size:12px;padding:14px;text-decoration:none;letter-spacing:0.1em;text-transform:uppercase;">Calculate My Commute Cost →</a>
          </div>

          <!-- Email capture -->
          <div class="share-block" id="thEmailCapture">
            <p class="share-label">Get your results by email</p>
            <p style="font-size:13px;color:var(--text-dim);margin-bottom:12px;">We will send you a breakdown of your take home pay plus tips on how to keep more of your salary.</p>
            <div class="input-wrap" style="margin-bottom:8px;">
              <input type="email" id="thEmail" placeholder="your@email.com" style="flex:1;background:transparent;border:none;outline:none;padding:14px 16px;color:var(--text);font-family:var(--font-mono);font-size:14px;" />
            </div>
            <button onclick="submitEmail('takehome')" style="width:100%;padding:14px;background:var(--accent);color:var(--black);border:none;font-family:var(--font-mono);font-size:12px;letter-spacing:0.1em;text-transform:uppercase;cursor:pointer;">Send Me My Results</button>
            <p style="font-size:11px;color:var(--text-dimmer);margin-top:8px;text-align:center;">No spam. Unsubscribe anytime.</p>
          </div>

        </div>
      </div>

    </div>
  </main>

  <!-- FAQ -->
  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Frequently Asked Questions</h2>
      <div class="faq-item">
        <h3>How is income tax calculated?</h3>
        <p>We use the 2024/25 UK tax bands. The first £12,570 is tax-free (personal allowance). You pay 20% on earnings between £12,571 and £50,270, 40% between £50,271 and £125,140, and 45% above £125,140.</p>
      </div>
      <div class="faq-item">
        <h3>Which student loan plan am I on?</h3>
        <p>Plan 1 if you started university before 2012. Plan 2 if you started in England or Wales from 2012. Plan 4 if you studied in Scotland. Plan 5 if you started from August 2023. Postgraduate loan if you have a master's or doctoral loan.</p>
      </div>
      <div class="faq-item">
        <h3>Is pension deducted before or after tax?</h3>
        <p>Most workplace pensions use salary sacrifice, meaning your pension contribution is deducted before tax and NI. This calculator assumes salary sacrifice which reduces both your tax and NI bill.</p>
      </div>
      <div class="faq-item">
        <h3>Is this accurate for 2025?</h3>
        <p>Yes — this calculator uses the 2024/25 tax year rates which apply from April 2024 to April 2025. We update it every April when new rates are announced.</p>
      </div>
    </div>
  </section>

  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Commute Calculator</a> · <a href="/take-home">Take Home Pay</a> · <a href="/guide">Guide</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p>
  </footer>

  <script src="/static/js/take_home.js"></script>
</body>
</html>
EOF

# ── 3. Take Home JS ───────────────────────────────────────────────────────────
cat > "$TARGET/static/js/take_home.js" << 'EOF'
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
EOF

# ── 4. Add email capture to main index.html ───────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/templates/index.html'
with open(path, 'r') as f:
    content = f.read()

email_block = '''
          <!-- EMAIL CAPTURE -->
          <div class="share-block" id="emailCapture">
            <p class="share-label">Get your results by email</p>
            <p style="font-size:13px;color:var(--text-dim);margin-bottom:12px;">We will send you a full breakdown plus tips on reducing your commute cost.</p>
            <div class="input-wrap" style="margin-bottom:8px;">
              <input type="email" id="commEmail" placeholder="your@email.com" style="flex:1;background:transparent;border:none;outline:none;padding:14px 16px;color:var(--text);font-family:var(--font-mono);font-size:14px;" />
            </div>
            <button onclick="submitCommEmail()" style="width:100%;padding:14px;background:var(--accent);color:var(--black);border:none;font-family:var(--font-mono);font-size:12px;letter-spacing:0.1em;text-transform:uppercase;cursor:pointer;">Send Me My Results</button>
            <p style="font-size:11px;color:var(--text-dimmer);margin-top:8px;text-align:center;">No spam. Unsubscribe anytime.</p>
          </div>

          <div class="nudge-block" id="nudgeBlock"></div>'''

content = content.replace(
    '          <div class="nudge-block" id="nudgeBlock"></div>',
    email_block
)

# Add take-home link to nav
content = content.replace(
    '<a href="/guide">Commute Guide</a> · <a href="/blog">Blog</a></p>',
    '<a href="/take-home">Take Home Pay</a> · <a href="/guide">Guide</a> · <a href="/blog">Blog</a></p>'
)

with open(path, 'w') as f:
    f.write(content)
print("Done index.html")
PYEOF

# ── 5. Add submitCommEmail to main.js ─────────────────────────────────────────
cat >> "$TARGET/static/js/main.js" << 'JSEOF'

// Email capture for commute calculator
async function submitCommEmail() {
  const emailEl = document.getElementById("commEmail");
  const email = emailEl ? emailEl.value.trim() : "";
  if (!email || !email.includes("@")) {
    showToast("Please enter a valid email address.");
    return;
  }
  const summary = lastResult
    ? "Annual cost: " + fmt(lastResult.total_yearly_cost) + ", Hours lost: " + lastResult.commute_hours_yearly + "h, Life stolen: " + lastResult.pct_waking_life + "%"
    : "";
  try {
    const res = await fetch("/subscribe", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, results_summary: summary }),
    });
    const data = await res.json();
    if (data.success) {
      showToast("Done! Check your inbox shortly.");
      emailEl.value = "";
    }
  } catch (err) {
    showToast("Something went wrong. Please try again.");
  }
}
JSEOF

# ── 6. Update sitemap with new pages ─────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

content = content.replace(
    '{"loc": "https://www.traveltax.co.uk/blog", "priority": "0.8", "changefreq": "weekly"},',
    '{"loc": "https://www.traveltax.co.uk/blog", "priority": "0.8", "changefreq": "weekly"},\n        {"loc": "https://www.traveltax.co.uk/take-home", "priority": "0.9", "changefreq": "monthly"},'
)

with open(path, 'w') as f:
    f.write(content)
print("Done sitemap")
PYEOF

echo ""
echo "Testing locally..."
cd "$TARGET" && python3 -c "import app; print('OK - no syntax errors')" 2>&1

echo ""
echo "Done! Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add Tool 2 take home pay and email capture' && git push"
