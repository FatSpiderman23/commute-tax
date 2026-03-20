#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "🔧 Applying fixes..."

# 1. Fix ticker tape position — move to bottom of header not top
# 2. Fix EV → Electric
# 3. Add manual commute time input
# 4. Replace MPG with simpler car type selector
# 5. Replace boring placeholder with fun facts

cat > "$TARGET/templates/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Travel Tax — What Is Your Commute Really Costing You?</title>
  <meta name="description" content="Find out the real cost of your commute in money, time, and life. Free UK commute calculator." />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
</head>
<body>

  <!-- SLIM HEADER -->
  <header class="slim-header">
    <div class="slim-header-inner">
      <div class="slim-logo">
        <span class="slim-logo-main">Travel Tax.</span>
        <span class="slim-logo-sub">UK Financial Reality Check</span>
      </div>
      <div class="slim-stats">
        <span>Avg UK commute: <strong>59 min/day</strong></span>
        <span>Avg cost: <strong>£135/month</strong></span>
        <span>Hours lost: <strong>243/yr</strong></span>
      </div>
    </div>
    <!-- Ticker BELOW the header content -->
    <div class="ticker-tape">
      <span>TRAVEL TAX &nbsp;·&nbsp; HOW MUCH OF YOUR LIFE IS TRAVEL STEALING? &nbsp;·&nbsp; TRAVEL TAX &nbsp;·&nbsp; YOUR TIME HAS A PRICE &nbsp;·&nbsp; TRAVEL TAX &nbsp;·&nbsp; WHAT IS YOUR COMMUTE REALLY COSTING YOU? &nbsp;·&nbsp;</span>
      <span aria-hidden="true">TRAVEL TAX &nbsp;·&nbsp; HOW MUCH OF YOUR LIFE IS TRAVEL STEALING? &nbsp;·&nbsp; TRAVEL TAX &nbsp;·&nbsp; YOUR TIME HAS A PRICE &nbsp;·&nbsp; TRAVEL TAX &nbsp;·&nbsp; WHAT IS YOUR COMMUTE REALLY COSTING YOU? &nbsp;·&nbsp;</span>
    </div>
  </header>

  <main id="calculator" class="calc-section">
    <div class="calc-wrapper">

      <!-- LEFT: FORM -->
      <div class="form-panel">
        <div class="form-header">
          <h2>Your Details</h2>
          <p class="form-desc">Fill in your details to find out your annual Travel Tax.</p>
        </div>

        <div class="field-group">
          <label for="salary">Annual Salary (£)</label>
          <div class="input-wrap">
            <span class="prefix">£</span>
            <input type="number" id="salary" placeholder="35000" min="0" />
          </div>
          <p class="field-hint">Used to calculate the monetary value of your time.</p>
        </div>

        <!-- COMMUTE TIME: slider + manual input -->
        <div class="field-group">
          <label for="commute_minutes">One-Way Commute Time</label>
          <div class="slider-wrap">
            <input type="range" id="commute_minutes" min="5" max="180" value="45" step="5" />
            <div class="slider-input-wrap">
              <input type="number" id="commute_minutes_manual" value="45" min="1" max="300" />
              <span class="slider-unit">min</span>
            </div>
          </div>
          <p class="field-hint">Drag the slider or type your exact commute time.</p>
        </div>

        <div class="field-group">
          <label>Days in Office Per Week</label>
          <div class="day-toggle">
            <button class="day-btn" data-val="1">1</button>
            <button class="day-btn" data-val="2">2</button>
            <button class="day-btn active" data-val="3">3</button>
            <button class="day-btn" data-val="4">4</button>
            <button class="day-btn" data-val="5">5</button>
          </div>
        </div>

        <div class="field-group">
          <label>How Do You Get There?</label>
          <div class="transport-toggle">
            <button class="transport-btn active" data-type="public">🚆 Train / Bus</button>
            <button class="transport-btn" data-type="car">🚗 Car</button>
          </div>
        </div>

        <!-- PUBLIC TRANSPORT -->
        <div id="public-fields">
          <div class="field-group">
            <label for="transport_cost_daily">Daily Transport Cost (£)</label>
            <div class="input-wrap">
              <span class="prefix">£</span>
              <input type="number" id="transport_cost_daily" placeholder="12.50" min="0" step="0.50" />
            </div>
            <p class="field-hint">Return fare. Check your ticket price.</p>
          </div>
        </div>

        <!-- CAR FIELDS -->
        <div id="car-fields" class="hidden">
          <div class="field-group">
            <label for="miles_one_way">One-Way Distance (miles)</label>
            <div class="input-wrap">
              <input type="number" id="miles_one_way" placeholder="15" min="0" />
            </div>
          </div>

          <!-- Simplified: car type instead of EV toggle + MPG -->
          <div class="field-group">
            <label>What Type of Car?</label>
            <div class="car-type-toggle">
              <button class="car-type-btn active" data-car="petrol_avg">⛽ Petrol (avg)</button>
              <button class="car-type-btn" data-car="petrol_large">⛽ Petrol (large)</button>
              <button class="car-type-btn" data-car="diesel">🛢 Diesel</button>
              <button class="car-type-btn" data-car="electric">⚡ Electric</button>
            </div>
            <p class="field-hint">We use real-world UK averages for each type — no MPG needed.</p>
          </div>

          <!-- Advanced: show fuel cost only for petrol/diesel, hidden for electric -->
          <div id="fuel-cost-field" class="field-group">
            <label for="fuel_cost_per_litre">Current Fuel Cost (£/litre)</label>
            <div class="input-wrap">
              <span class="prefix">£</span>
              <input type="number" id="fuel_cost_per_litre" placeholder="1.55" step="0.01" min="0" value="1.55" />
            </div>
            <p class="field-hint">Check GasPrices.co.uk for current prices near you.</p>
          </div>
        </div>

        <button class="calculate-btn" id="calculateBtn">
          <span>Calculate My Travel Tax</span>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
        </button>
      </div>

      <!-- RIGHT: RESULTS -->
      <div class="results-panel" id="resultsPanel">

        <!-- FUN FACTS PLACEHOLDER -->
        <div class="results-placeholder" id="resultsPlaceholder">
          <div class="fun-facts-wrap">
            <p class="fun-facts-label">⚡ DID YOU KNOW?</p>
            <div class="fun-fact-display" id="funFactDisplay"></div>
            <div class="fun-fact-dots" id="funFactDots"></div>
            <p class="fun-facts-cta">Fill in your details and hit Calculate to find out your personal Travel Tax →</p>
          </div>
        </div>

        <div class="results-content hidden" id="resultsContent">

          <div class="verdict-banner">
            <p class="verdict-label">YOUR ANNUAL TRAVEL TAX</p>
            <div class="verdict-number" id="res-total-cost">£0</div>
            <p class="verdict-sub" id="res-total-sub">Combined cost of transport + the value of your time</p>
          </div>

          <div class="stat-cards">
            <div class="stat-card highlight">
              <span class="stat-icon">💸</span>
              <span class="stat-label">Transport Cost / Year</span>
              <span class="stat-value" id="res-transport-yearly">£0</span>
            </div>
            <div class="stat-card">
              <span class="stat-icon">⏳</span>
              <span class="stat-label">Hours Lost / Year</span>
              <span class="stat-value" id="res-hours-yearly">0h</span>
            </div>
            <div class="stat-card">
              <span class="stat-icon">💼</span>
              <span class="stat-label">Time Worth (£)</span>
              <span class="stat-value" id="res-time-cost">£0</span>
            </div>
            <div class="stat-card">
              <span class="stat-icon">🌅</span>
              <span class="stat-label">% of Waking Life</span>
              <span class="stat-value" id="res-pct-life">0%</span>
            </div>
          </div>

          <div class="life-impact-block">
            <h3 class="block-title">The Life Impact</h3>
            <div class="impact-row">
              <span class="impact-bar-wrap"><span class="impact-bar" id="life-bar"></span></span>
              <span class="impact-text" id="res-life-text"></span>
            </div>
            <p class="impact-career" id="res-career-text"></p>
          </div>

          <div class="comparison-block">
            <h3 class="block-title">Remote vs Office — The Real Gap</h3>
            <div class="compare-row">
              <div class="compare-col office">
                <span class="compare-label">Office</span>
                <span class="compare-amount negative" id="res-office-cost">−£0/yr</span>
                <span class="compare-note">Transport + time value</span>
              </div>
              <div class="compare-divider">vs</div>
              <div class="compare-col remote">
                <span class="compare-label">Remote</span>
                <span class="compare-amount positive">£0/yr</span>
                <span class="compare-note">No commute cost</span>
              </div>
            </div>
            <div class="savings-callout">
              Going fully remote would give you back <strong id="res-remote-hours">0 hours</strong> and <strong id="res-remote-money">£0</strong> of real value per year.
            </div>
          </div>

          <div class="breakdown-block">
            <h3 class="block-title">Monthly Breakdown</h3>
            <div class="breakdown-row"><span>Transport cost</span><span id="res-monthly-transport">£0</span></div>
            <div class="breakdown-row"><span>Time value lost</span><span id="res-monthly-time">£0</span></div>
            <div class="breakdown-row total-row"><span>Total monthly tax</span><span id="res-monthly-total">£0</span></div>
          </div>

          <div class="ad-slot ad-native"><span class="ad-label">Advertisement</span></div>

          <div class="ar-block" id="ar-block"></div>

          <div class="share-block">
            <p class="share-label">Share your result</p>
            <div class="share-card" id="shareCard">
              <div class="share-card-inner">
                <p class="share-card-title">TRAVEL TAX</p>
                <p class="share-card-big" id="share-pct">0%</p>
                <p class="share-card-desc" id="share-desc">of my waking life goes on commuting.</p>
                <p class="share-card-url">traveltax.co.uk</p>
              </div>
            </div>
            <div class="share-btns">
              <button class="share-btn twitter" onclick="shareToTwitter()">Share on X/Twitter</button>
              <button class="share-btn copy" onclick="copyResult()">Copy Result</button>
            </div>
          </div>

          <div class="nudge-block" id="nudgeBlock"></div>

        </div>
      </div>

    </div>
  </main>

  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Frequently Asked Questions</h2>
      <div class="faq-item">
        <h3>How is the "time value" calculated?</h3>
        <p>We divide your annual salary by your total working hours per year (days × 8hrs). This gives your hourly rate. We then multiply by hours spent commuting to show what that time is worth in monetary terms.</p>
      </div>
      <div class="faq-item">
        <h3>How is car cost calculated?</h3>
        <p>We use real-world UK fuel consumption averages for each car type, combined with HMRC's approved mileage rates (45p/mile for the first 10,000 miles, 25p/mile after) to estimate your true driving cost including depreciation.</p>
      </div>
      <div class="faq-item">
        <h3>What does "% of waking life" mean?</h3>
        <p>We assume 16 waking hours per day (8hrs sleep). We calculate what percentage of those waking hours are spent commuting each year.</p>
      </div>
      <div class="faq-item">
        <h3>Is this tool free?</h3>
        <p>Yes. Completely free. No sign-up required.</p>
      </div>
    </div>
  </section>

  <div class="ad-slot ad-mid-content"><span class="ad-label">Advertisement</span></div>

  <footer class="site-footer">
    <p>© 2025 Travel Tax · Built for UK commuters · <a href="/privacy">Privacy</a> · <a href="/guide">Commute Guide</a></p>
  </footer>

  <script src="/static/js/main.js"></script>
</body>
</html>
EOF
echo "✅ index.html updated"

# Update app.py to handle new car types
cat > "$TARGET/app.py" << 'PYEOF'
import os
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

# Real-world UK MPG averages by car type
CAR_MPG = {
    "petrol_avg":   40,
    "petrol_large": 28,
    "diesel":       50,
    "electric":     None,  # handled separately
}

def calculate_commute(data):
    salary = float(data.get("salary", 0))
    days_per_week = float(data.get("days_per_week", 5))
    weeks_per_year = float(data.get("weeks_per_year", 48))
    commute_minutes_one_way = float(data.get("commute_minutes", 0))
    transport_cost_daily = float(data.get("transport_cost_daily", 0))
    transport_type = data.get("transport_type", "public")
    miles_one_way = float(data.get("miles_one_way", 0))
    fuel_cost_per_litre = float(data.get("fuel_cost_per_litre", 1.55))
    car_type = data.get("car_type", "petrol_avg")

    working_days = days_per_week * weeks_per_year
    commute_minutes_daily = commute_minutes_one_way * 2
    commute_hours_yearly = (commute_minutes_daily * working_days) / 60
    commute_days_yearly = commute_hours_yearly / 24
    waking_hours_per_year = 16 * 365
    pct_waking_life = (commute_hours_yearly / waking_hours_per_year) * 100
    hourly_rate = salary / (weeks_per_year * days_per_week * 8) if salary > 0 else 0
    time_cost_yearly = commute_hours_yearly * hourly_rate

    if transport_type == "car":
        is_ev = car_type == "electric"
        if is_ev:
            # EV: ~0.25 kWh/mile, ~28p/kWh avg UK home charging
            fuel_cost_daily = miles_one_way * 2 * 0.25 * 0.28
        else:
            mpg = CAR_MPG.get(car_type, 40)
            litres_per_mile = 1 / (mpg * 4.546)
            fuel_cost_daily = miles_one_way * 2 * litres_per_mile * fuel_cost_per_litre

        miles_yearly = miles_one_way * 2 * working_days
        if miles_yearly <= 10000:
            depreciation_yearly = miles_yearly * 0.45
        else:
            depreciation_yearly = (10000 * 0.45) + ((miles_yearly - 10000) * 0.25)

        transport_cost_yearly = (fuel_cost_daily * working_days) + depreciation_yearly
        transport_cost_daily_val = transport_cost_yearly / working_days if working_days > 0 else 0
    else:
        transport_cost_yearly = transport_cost_daily * working_days
        depreciation_yearly = 0
        miles_yearly = 0
        transport_cost_daily_val = transport_cost_daily

    total_yearly_cost = transport_cost_yearly + time_cost_yearly
    career_commute_years = ((commute_hours_yearly * 37) / 24) / 365

    return {
        "commute_minutes_daily": round(commute_minutes_daily),
        "commute_hours_yearly": round(commute_hours_yearly, 1),
        "commute_days_yearly": round(commute_days_yearly, 1),
        "pct_waking_life": round(pct_waking_life, 1),
        "hourly_rate": round(hourly_rate, 2),
        "time_cost_yearly": round(time_cost_yearly),
        "transport_cost_yearly": round(transport_cost_yearly),
        "transport_cost_monthly": round(transport_cost_yearly / 12),
        "transport_cost_daily": round(transport_cost_daily_val, 2),
        "total_yearly_cost": round(total_yearly_cost),
        "total_monthly_cost": round(total_yearly_cost / 12),
        "remote_savings_transport": round(transport_cost_yearly),
        "remote_savings_time_hours": round(commute_hours_yearly, 1),
        "remote_savings_time_value": round(time_cost_yearly),
        "remote_total_value": round(transport_cost_yearly + time_cost_yearly),
        "career_commute_years": round(career_commute_years, 1),
        "working_days": round(working_days),
        "miles_yearly": round(miles_yearly) if transport_type == "car" else 0,
    }


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/guide")
def guide():
    return render_template("guide.html")


@app.route("/privacy")
def privacy():
    return render_template("privacy.html")


@app.route("/calculate", methods=["POST"])
def calculate():
    data = request.get_json()
    result = calculate_commute(data)
    return jsonify(result)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
PYEOF
echo "✅ app.py updated with car types"

# Add new CSS
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* === TICKER BELOW HEADER === */
.slim-header .ticker-tape { position: static; }

/* === COMMUTE MANUAL INPUT === */
.slider-input-wrap { display: flex; align-items: center; gap: 4px; }
.slider-input-wrap input[type="number"] {
  width: 64px; background: var(--off-black); border: 1px solid var(--border-light);
  color: var(--accent); font-family: var(--font-display); font-size: 22px;
  padding: 4px 8px; outline: none; text-align: center;
}
.slider-input-wrap input[type="number"]:focus { border-color: var(--accent); }
.slider-unit { font-family: var(--font-display); font-size: 22px; color: var(--accent); }

/* === CAR TYPE TOGGLE === */
.car-type-toggle { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.car-type-btn {
  padding: 10px 8px; background: var(--off-black); border: 1px solid var(--border-light);
  color: var(--text-dim); font-family: var(--font-body); font-size: 13px;
  cursor: pointer; transition: all 0.15s; text-align: center;
}
.car-type-btn.active { background: #1a1a0a; border-color: var(--accent); color: var(--accent); }
.car-type-btn:hover:not(.active) { border-color: var(--accent); color: var(--accent); }

/* === FUN FACTS PLACEHOLDER === */
.fun-facts-wrap {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  height: 100%; min-height: 400px; padding: 40px 32px; text-align: center;
  border: 1px dashed var(--border);
}
.fun-facts-label {
  font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.25em;
  color: var(--accent); margin-bottom: 24px;
}
.fun-fact-display {
  font-family: var(--font-display); font-size: clamp(18px, 3vw, 26px);
  color: var(--white); line-height: 1.3; margin-bottom: 20px; min-height: 80px;
  transition: opacity 0.4s ease;
}
.fun-fact-display em { color: var(--accent); font-style: normal; }
.fun-fact-dots { display: flex; gap: 6px; margin-bottom: 28px; }
.fun-fact-dot {
  width: 6px; height: 6px; border-radius: 50%;
  background: var(--border-light); transition: background 0.3s;
}
.fun-fact-dot.active { background: var(--accent); }
.fun-facts-cta { font-size: 13px; color: var(--text-dimmer); font-family: var(--font-mono); letter-spacing: 0.05em; }

/* Fix blog CTA button */
.blog-cta-block .cta-btn {
  color: var(--black) !important; background: var(--accent);
  display: inline-block; padding: 16px 32px; text-decoration: none;
  font-family: var(--font-mono); font-size: 13px; font-weight: 500;
  letter-spacing: 0.1em; text-transform: uppercase; border-bottom: none !important;
  transition: background 0.2s;
}
.blog-cta-block .cta-btn:hover { background: var(--white); }
CSSEOF
echo "✅ CSS updated"

# Update main.js to handle new inputs
cat >> "$TARGET/static/js/main.js" << 'JSEOF'

// ---- Overrides for new features ----

// Car type toggle
let selectedCarType = "petrol_avg";
document.addEventListener("DOMContentLoaded", () => {
  // Car type buttons
  document.querySelectorAll(".car-type-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".car-type-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      selectedCarType = btn.dataset.car;
      // Hide fuel cost for electric
      const fuelField = document.getElementById("fuel-cost-field");
      if (fuelField) fuelField.classList.toggle("hidden", selectedCarType === "electric");
    });
  });

  // Sync slider and manual input
  const slider = document.getElementById("commute_minutes");
  const manual = document.getElementById("commute_minutes_manual");
  if (slider && manual) {
    slider.addEventListener("input", () => { manual.value = slider.value; });
    manual.addEventListener("input", () => {
      let v = parseInt(manual.value) || 1;
      v = Math.max(1, Math.min(300, v));
      slider.value = Math.min(v, 180);
      manual.value = v;
    });
  }

  // Fun facts rotator
  initFunFacts();
});

// Override getFormData to include car_type
const _origGetFormData = getFormData;
getFormData = function() {
  const data = _origGetFormData();
  data.car_type = selectedCarType;
  // Use manual input value for commute minutes
  const manual = document.getElementById("commute_minutes_manual");
  if (manual && manual.value) data.commute_minutes = parseFloat(manual.value) || data.commute_minutes;
  return data;
};

// Fun facts
const FUN_FACTS = [
  { text: 'The average UK worker spends <em>3 years</em> of their career just getting to work.' },
  { text: 'London commuters spend an average of <em>£5,000/year</em> on train fares alone.' },
  { text: 'A 60-minute daily commute is worth <em>£4,200/year</em> of your time if you earn £35k.' },
  { text: 'Switching to fully remote work gives back the equivalent of <em>6 weeks of holidays</em> per year.' },
  { text: 'UK rail fares have risen <em>40% since 2010</em> — more than double the rate of wage growth.' },
  { text: 'The UK has the <em>longest average commute</em> in Europe at 59 minutes per day.' },
  { text: 'A 90-minute commute 5 days a week = <em>360 hours</em> lost per year. That\'s 15 full days.' },
  { text: 'Every extra 20 minutes of commuting has the same effect on job satisfaction as a <em>19% pay cut</em>.' },
];

function initFunFacts() {
  const display = document.getElementById("funFactDisplay");
  const dotsWrap = document.getElementById("funFactDots");
  if (!display || !dotsWrap) return;

  // Create dots
  FUN_FACTS.forEach((_, i) => {
    const dot = document.createElement("div");
    dot.className = "fun-fact-dot" + (i === 0 ? " active" : "");
    dotsWrap.appendChild(dot);
  });

  let current = 0;
  function showFact(index) {
    display.style.opacity = "0";
    setTimeout(() => {
      display.innerHTML = FUN_FACTS[index].text;
      display.style.opacity = "1";
      dotsWrap.querySelectorAll(".fun-fact-dot").forEach((d, i) => {
        d.classList.toggle("active", i === index);
      });
    }, 400);
  }

  showFact(0);
  setInterval(() => {
    current = (current + 1) % FUN_FACTS.length;
    showFact(current);
  }, 4000);
}
JSEOF
echo "✅ main.js updated"

echo ""
echo "✅ All done! Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'UX improvements' && git push"
