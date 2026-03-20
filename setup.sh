#!/bin/bash

echo "🚆 Setting up The Commute Tax..."

mkdir -p ~/commute-tax/templates ~/commute-tax/static/css ~/commute-tax/static/js
cd ~/commute-tax

# ============================================================
# app.py
# ============================================================
cat > app.py << 'PYEOF'
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)


def calculate_commute(data):
    salary = float(data.get("salary", 0))
    days_per_week = float(data.get("days_per_week", 5))
    weeks_per_year = float(data.get("weeks_per_year", 48))
    commute_minutes_one_way = float(data.get("commute_minutes", 0))
    transport_cost_daily = float(data.get("transport_cost_daily", 0))
    transport_type = data.get("transport_type", "public")
    miles_one_way = float(data.get("miles_one_way", 0))
    fuel_cost_per_litre = float(data.get("fuel_cost_per_litre", 1.50))
    mpg = float(data.get("mpg", 40))
    is_ev = data.get("is_ev", False)

    working_days = days_per_week * weeks_per_year
    commute_minutes_daily = commute_minutes_one_way * 2
    commute_hours_yearly = (commute_minutes_daily * working_days) / 60
    commute_days_yearly = commute_hours_yearly / 24
    waking_hours_per_year = 16 * 365
    pct_waking_life = (commute_hours_yearly / waking_hours_per_year) * 100

    hourly_rate = salary / (weeks_per_year * days_per_week * 8) if salary > 0 else 0
    time_cost_yearly = commute_hours_yearly * hourly_rate

    if transport_type == "car":
        if is_ev:
            kwh_per_mile = 0.25
            cost_per_kwh = 0.28
            fuel_cost_daily = miles_one_way * 2 * kwh_per_mile * cost_per_kwh
        else:
            litres_per_mile = 1 / (mpg * 4.546)
            fuel_cost_daily = miles_one_way * 2 * litres_per_mile * fuel_cost_per_litre

        miles_yearly = miles_one_way * 2 * working_days
        if miles_yearly <= 10000:
            depreciation_yearly = miles_yearly * 0.45
        else:
            depreciation_yearly = (10000 * 0.45) + ((miles_yearly - 10000) * 0.25)

        transport_cost_yearly = (fuel_cost_daily * working_days) + depreciation_yearly
        transport_cost_daily = transport_cost_yearly / working_days
    else:
        transport_cost_yearly = transport_cost_daily * working_days
        depreciation_yearly = 0
        miles_yearly = 0

    total_yearly_cost = transport_cost_yearly + time_cost_yearly
    working_years_left = 37
    career_commute_hours = commute_hours_yearly * working_years_left
    career_commute_years = (career_commute_hours / 24) / 365

    return {
        "commute_minutes_daily": round(commute_minutes_daily),
        "commute_hours_yearly": round(commute_hours_yearly, 1),
        "commute_days_yearly": round(commute_days_yearly, 1),
        "pct_waking_life": round(pct_waking_life, 1),
        "hourly_rate": round(hourly_rate, 2),
        "time_cost_yearly": round(time_cost_yearly),
        "transport_cost_yearly": round(transport_cost_yearly),
        "transport_cost_monthly": round(transport_cost_yearly / 12),
        "transport_cost_daily": round(transport_cost_daily, 2),
        "depreciation_yearly": round(depreciation_yearly) if transport_type == "car" else 0,
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


@app.route("/calculate", methods=["POST"])
def calculate():
    data = request.get_json()
    result = calculate_commute(data)
    return jsonify(result)


if __name__ == "__main__":
    app.run(debug=True)
PYEOF

# ============================================================
# requirements.txt
# ============================================================
cat > requirements.txt << 'EOF'
flask>=3.0.0
EOF

# ============================================================
# templates/index.html
# ============================================================
cat > templates/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>The Commute Tax — How Much Is Your Commute Really Costing You?</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
</head>
<body>

  <header class="hero">
    <div class="hero-noise"></div>
    <div class="ticker-tape">
      <span>THE COMMUTE TAX &nbsp;·&nbsp; HOW MUCH OF YOUR LIFE IS THE TRAIN STEALING? &nbsp;·&nbsp; THE COMMUTE TAX &nbsp;·&nbsp; YOUR TIME HAS A PRICE &nbsp;·&nbsp; THE COMMUTE TAX &nbsp;·&nbsp;</span>
      <span aria-hidden="true">THE COMMUTE TAX &nbsp;·&nbsp; HOW MUCH OF YOUR LIFE IS THE TRAIN STEALING? &nbsp;·&nbsp; THE COMMUTE TAX &nbsp;·&nbsp; YOUR TIME HAS A PRICE &nbsp;·&nbsp; THE COMMUTE TAX &nbsp;·&nbsp;</span>
    </div>
    <div class="hero-content">
      <p class="hero-eyebrow">UK Financial Reality Check</p>
      <h1 class="hero-title">The<br><em>Commute</em><br>Tax.</h1>
      <p class="hero-sub">Enter your details. Find out how much of your salary, your time, and your <em>life</em> you're handing over to your commute every year.</p>
      <a href="#calculator" class="cta-btn">Calculate My Commute Tax ↓</a>
    </div>
    <div class="hero-stat-strip">
      <div class="stat-pill">Average UK commute: <strong>59 min/day</strong></div>
      <div class="stat-pill">Average commute cost: <strong>£135/month</strong></div>
      <div class="stat-pill">Hours lost per year: <strong>243 hrs</strong></div>
    </div>
  </header>

  <main id="calculator" class="calc-section">
    <div class="calc-wrapper">

      <div class="form-panel">
        <div class="form-header">
          <span class="form-step">STEP 01</span>
          <h2>Your Details</h2>
        </div>

        <div class="field-group">
          <label for="salary">Annual Salary (£)</label>
          <div class="input-wrap">
            <span class="prefix">£</span>
            <input type="number" id="salary" placeholder="35000" min="0" />
          </div>
          <p class="field-hint">Used to calculate the monetary value of your time.</p>
        </div>

        <div class="field-group">
          <label for="commute_minutes">One-Way Commute Time</label>
          <div class="slider-wrap">
            <input type="range" id="commute_minutes" min="5" max="180" value="45" step="5" />
            <span class="slider-val"><span id="commute_minutes_val">45</span> min</span>
          </div>
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

        <div id="car-fields" class="hidden">
          <div class="field-group">
            <label for="miles_one_way">One-Way Distance (miles)</label>
            <div class="input-wrap">
              <input type="number" id="miles_one_way" placeholder="15" min="0" />
            </div>
          </div>
          <div class="field-group">
            <div class="ev-toggle-row">
              <label>Petrol / Diesel or EV?</label>
              <label class="toggle-switch">
                <input type="checkbox" id="is_ev" />
                <span class="toggle-slider"></span>
                <span class="toggle-label">EV</span>
              </label>
            </div>
          </div>
          <div id="petrol-fields">
            <div class="field-group">
              <label for="mpg">Your Car's MPG</label>
              <div class="input-wrap">
                <input type="number" id="mpg" placeholder="40" min="1" />
              </div>
            </div>
            <div class="field-group">
              <label for="fuel_cost_per_litre">Fuel Cost (£/litre)</label>
              <div class="input-wrap">
                <span class="prefix">£</span>
                <input type="number" id="fuel_cost_per_litre" placeholder="1.55" step="0.01" min="0" />
              </div>
            </div>
          </div>
        </div>

        <button class="calculate-btn" id="calculateBtn">
          <span>Calculate My Commute Tax</span>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
        </button>
      </div>

      <div class="results-panel" id="resultsPanel">
        <div class="results-placeholder" id="resultsPlaceholder">
          <div class="placeholder-icon">⏱</div>
          <p>Your results will appear here once you calculate.</p>
        </div>

        <div class="results-content hidden" id="resultsContent">

          <div class="verdict-banner">
            <p class="verdict-label">YOUR ANNUAL COMMUTE TAX</p>
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
              <span class="impact-bar-wrap">
                <span class="impact-bar" id="life-bar"></span>
              </span>
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
            <div class="breakdown-row">
              <span>Transport cost</span><span id="res-monthly-transport">£0</span>
            </div>
            <div class="breakdown-row">
              <span>Time value lost</span><span id="res-monthly-time">£0</span>
            </div>
            <div class="breakdown-row total-row">
              <span>Total monthly tax</span><span id="res-monthly-total">£0</span>
            </div>
          </div>

          <div class="share-block">
            <p class="share-label">Share your result</p>
            <div class="share-card" id="shareCard">
              <div class="share-card-inner">
                <p class="share-card-title">THE COMMUTE TAX</p>
                <p class="share-card-big" id="share-pct">0%</p>
                <p class="share-card-desc" id="share-desc">of my waking life goes on commuting.</p>
                <p class="share-card-url">thecommutetax.co.uk</p>
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
        <h3>How is car depreciation calculated?</h3>
        <p>We use HMRC's approved mileage rates: 45p/mile for the first 10,000 miles, 25p/mile after. This is the standard UK rate that accounts for fuel, wear, insurance, and depreciation combined.</p>
      </div>
      <div class="faq-item">
        <h3>What does "% of waking life" mean?</h3>
        <p>We assume 16 waking hours per day (8hrs sleep). We calculate what percentage of those waking hours are spent commuting each year. It's often a shock.</p>
      </div>
      <div class="faq-item">
        <h3>Is this tool free?</h3>
        <p>Yes. Completely free. No sign-up required.</p>
      </div>
    </div>
  </section>

  <footer class="site-footer">
    <p>© 2025 The Commute Tax · Built for UK commuters</p>
  </footer>

  <script src="/static/js/main.js"></script>
</body>
</html>
EOF

# ============================================================
# static/css/style.css
# ============================================================
cat > static/css/style.css << 'EOF'
:root {
  --black: #0a0a0a;
  --off-black: #111111;
  --panel: #161616;
  --border: #2a2a2a;
  --border-light: #333;
  --text: #e8e8e0;
  --text-dim: #888;
  --text-dimmer: #555;
  --accent: #f0e040;
  --accent-dim: #c9bc1e;
  --red: #ff4444;
  --green: #3ddc84;
  --white: #ffffff;
  --font-display: 'Bebas Neue', sans-serif;
  --font-mono: 'DM Mono', monospace;
  --font-body: 'DM Sans', sans-serif;
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body { background: var(--black); color: var(--text); font-family: var(--font-body); font-size: 16px; line-height: 1.6; overflow-x: hidden; }

.hero { position: relative; min-height: 100vh; display: flex; flex-direction: column; justify-content: center; border-bottom: 1px solid var(--border); overflow: hidden; }
.hero-noise { position: absolute; inset: 0; background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.04'/%3E%3C/svg%3E"); pointer-events: none; opacity: 0.6; }

.ticker-tape { position: absolute; top: 0; left: 0; right: 0; background: var(--accent); color: var(--black); font-family: var(--font-mono); font-size: 11px; font-weight: 500; letter-spacing: 0.08em; padding: 8px 0; white-space: nowrap; overflow: hidden; display: flex; }
.ticker-tape span { display: inline-block; animation: ticker 30s linear infinite; }
@keyframes ticker { from { transform: translateX(0); } to { transform: translateX(-50%); } }

.hero-content { max-width: 760px; margin: 0 auto; padding: 120px 40px 60px; position: relative; z-index: 2; }
.hero-eyebrow { font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.2em; color: var(--accent); text-transform: uppercase; margin-bottom: 20px; display: flex; align-items: center; gap: 12px; }
.hero-eyebrow::before { content: ''; display: inline-block; width: 32px; height: 1px; background: var(--accent); }
.hero-title { font-family: var(--font-display); font-size: clamp(72px, 12vw, 140px); line-height: 0.9; color: var(--white); margin-bottom: 32px; }
.hero-title em { font-style: normal; color: var(--accent); }
.hero-sub { font-size: 18px; font-weight: 300; color: var(--text-dim); max-width: 480px; margin-bottom: 40px; line-height: 1.7; }
.hero-sub em { font-style: italic; color: var(--text); }

.cta-btn { display: inline-block; background: var(--accent); color: var(--black); font-family: var(--font-mono); font-size: 13px; font-weight: 500; letter-spacing: 0.1em; text-decoration: none; padding: 16px 32px; cursor: pointer; transition: background 0.2s, transform 0.15s; text-transform: uppercase; }
.cta-btn:hover { background: var(--white); transform: translateY(-2px); }

.hero-stat-strip { display: flex; border-top: 1px solid var(--border); margin-top: auto; }
.stat-pill { flex: 1; padding: 20px 40px; font-family: var(--font-mono); font-size: 12px; color: var(--text-dim); border-right: 1px solid var(--border); }
.stat-pill:last-child { border-right: none; }
.stat-pill strong { display: block; font-size: 20px; color: var(--white); font-family: var(--font-display); margin-top: 4px; }

.calc-section { padding: 80px 40px; background: var(--off-black); }
.calc-wrapper { max-width: 1100px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1fr; gap: 0; border: 1px solid var(--border); }

.form-panel { padding: 48px; border-right: 1px solid var(--border); background: var(--panel); }
.form-header { margin-bottom: 40px; }
.form-step { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.25em; color: var(--accent); display: block; margin-bottom: 8px; }
.form-header h2 { font-family: var(--font-display); font-size: 36px; color: var(--white); }

.field-group { margin-bottom: 28px; }
.field-group label { display: block; font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.15em; text-transform: uppercase; color: var(--text-dim); margin-bottom: 10px; }
.field-hint { font-size: 12px; color: var(--text-dimmer); margin-top: 6px; }

.input-wrap { display: flex; align-items: center; border: 1px solid var(--border-light); background: var(--off-black); transition: border-color 0.2s; }
.input-wrap:focus-within { border-color: var(--accent); }
.prefix { padding: 0 12px; font-family: var(--font-mono); font-size: 14px; color: var(--text-dim); border-right: 1px solid var(--border); }
.input-wrap input { flex: 1; background: transparent; border: none; outline: none; padding: 14px 16px; color: var(--text); font-family: var(--font-mono); font-size: 16px; }
.input-wrap input::placeholder { color: var(--text-dimmer); }

.slider-wrap { display: flex; align-items: center; gap: 16px; }
.slider-wrap input[type="range"] { -webkit-appearance: none; flex: 1; height: 2px; background: var(--border-light); outline: none; cursor: pointer; }
.slider-wrap input[type="range"]::-webkit-slider-thumb { -webkit-appearance: none; width: 18px; height: 18px; background: var(--accent); cursor: pointer; border-radius: 0; }
.slider-val { font-family: var(--font-display); font-size: 24px; color: var(--accent); min-width: 80px; text-align: right; }

.day-toggle { display: flex; gap: 8px; }
.day-btn { flex: 1; padding: 12px 0; background: var(--off-black); border: 1px solid var(--border-light); color: var(--text-dim); font-family: var(--font-display); font-size: 20px; cursor: pointer; transition: all 0.15s; }
.day-btn.active { background: var(--accent); color: var(--black); border-color: var(--accent); }
.day-btn:hover:not(.active) { border-color: var(--accent); color: var(--accent); }

.transport-toggle { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.transport-btn { padding: 14px; background: var(--off-black); border: 1px solid var(--border-light); color: var(--text-dim); font-family: var(--font-body); font-size: 14px; cursor: pointer; transition: all 0.15s; }
.transport-btn.active { background: #1a1a0a; border-color: var(--accent); color: var(--accent); }

.ev-toggle-row { display: flex; align-items: center; justify-content: space-between; }
.toggle-switch { display: flex; align-items: center; gap: 8px; cursor: pointer; }
.toggle-switch input { display: none; }
.toggle-slider { width: 40px; height: 22px; background: var(--border-light); border-radius: 11px; position: relative; transition: background 0.2s; cursor: pointer; }
.toggle-slider::after { content: ''; position: absolute; top: 3px; left: 3px; width: 16px; height: 16px; background: var(--white); border-radius: 50%; transition: transform 0.2s; }
input:checked + .toggle-slider { background: var(--accent); }
input:checked + .toggle-slider::after { transform: translateX(18px); }
.toggle-label { font-family: var(--font-mono); font-size: 12px; color: var(--text-dim); }

.calculate-btn { width: 100%; padding: 18px 32px; background: var(--accent); border: none; color: var(--black); font-family: var(--font-mono); font-size: 13px; font-weight: 500; letter-spacing: 0.12em; text-transform: uppercase; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 12px; transition: background 0.2s, transform 0.15s; margin-top: 8px; }
.calculate-btn:hover { background: var(--white); transform: translateY(-2px); }
.hidden { display: none !important; }

.results-panel { padding: 48px; background: var(--black); min-height: 600px; display: flex; flex-direction: column; }
.results-placeholder { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; min-height: 400px; gap: 16px; border: 1px dashed var(--border); color: var(--text-dimmer); font-size: 14px; }
.placeholder-icon { font-size: 48px; }

@keyframes fadeSlideIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

.verdict-banner { border: 1px solid var(--accent); padding: 32px; margin-bottom: 32px; text-align: center; background: #0f0f00; animation: fadeSlideIn 0.5s ease forwards; }
.verdict-label { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.25em; color: var(--accent); text-transform: uppercase; margin-bottom: 12px; }
.verdict-number { font-family: var(--font-display); font-size: clamp(52px, 8vw, 80px); color: var(--accent); line-height: 1; }
.verdict-sub { font-size: 12px; color: var(--text-dim); margin-top: 8px; }

.stat-cards { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 28px; animation: fadeSlideIn 0.5s 0.1s ease both; }
.stat-card { padding: 20px; border: 1px solid var(--border); background: var(--panel); display: flex; flex-direction: column; gap: 6px; }
.stat-card.highlight { border-color: var(--red); }
.stat-icon { font-size: 18px; }
.stat-label { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.12em; color: var(--text-dimmer); text-transform: uppercase; }
.stat-value { font-family: var(--font-display); font-size: 28px; color: var(--white); }

.life-impact-block, .comparison-block, .breakdown-block { border: 1px solid var(--border); padding: 24px; margin-bottom: 20px; background: var(--panel); animation: fadeSlideIn 0.5s 0.2s ease both; }
.block-title { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.2em; text-transform: uppercase; color: var(--accent); margin-bottom: 16px; }

.impact-row { display: flex; align-items: center; gap: 16px; margin-bottom: 12px; }
.impact-bar-wrap { flex: 1; height: 6px; background: var(--border); overflow: hidden; display: block; }
.impact-bar { display: block; height: 100%; background: var(--accent); width: 0%; transition: width 1s cubic-bezier(0.25, 0.46, 0.45, 0.94); }
.impact-text { font-family: var(--font-display); font-size: 22px; color: var(--accent); min-width: 80px; text-align: right; }
.impact-career { font-size: 13px; color: var(--text-dim); line-height: 1.5; }

.compare-row { display: flex; align-items: center; gap: 16px; margin-bottom: 16px; }
.compare-col { flex: 1; display: flex; flex-direction: column; gap: 4px; }
.compare-label { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.15em; color: var(--text-dimmer); text-transform: uppercase; }
.compare-amount { font-family: var(--font-display); font-size: 26px; }
.compare-amount.negative { color: var(--red); }
.compare-amount.positive { color: var(--green); }
.compare-note { font-size: 11px; color: var(--text-dimmer); }
.compare-divider { font-family: var(--font-mono); font-size: 12px; color: var(--text-dimmer); }
.savings-callout { background: #081208; border: 1px solid #1a3a1a; padding: 14px 16px; font-size: 13px; color: var(--text-dim); line-height: 1.6; }
.savings-callout strong { color: var(--green); }

.breakdown-row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid var(--border); font-size: 14px; color: var(--text-dim); }
.breakdown-row:last-child { border-bottom: none; }
.breakdown-row span:last-child { font-family: var(--font-mono); color: var(--text); }
.total-row span:last-child { color: var(--accent) !important; font-size: 16px; }

.share-block { margin-bottom: 20px; animation: fadeSlideIn 0.5s 0.3s ease both; }
.share-label { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.2em; text-transform: uppercase; color: var(--text-dimmer); margin-bottom: 12px; }
.share-card { background: var(--accent); padding: 24px; margin-bottom: 12px; }
.share-card-inner { color: var(--black); }
.share-card-title { font-family: var(--font-mono); font-size: 9px; letter-spacing: 0.25em; text-transform: uppercase; opacity: 0.6; margin-bottom: 4px; }
.share-card-big { font-family: var(--font-display); font-size: 52px; line-height: 1; }
.share-card-desc { font-size: 14px; font-weight: 500; margin: 4px 0 8px; }
.share-card-url { font-family: var(--font-mono); font-size: 10px; opacity: 0.5; }
.share-btns { display: flex; gap: 8px; }
.share-btn { flex: 1; padding: 12px; font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.08em; text-transform: uppercase; cursor: pointer; border: none; transition: opacity 0.2s, transform 0.15s; }
.share-btn:hover { opacity: 0.85; transform: translateY(-1px); }
.share-btn.twitter { background: #1a1a1a; color: var(--white); border: 1px solid var(--border-light); }
.share-btn.copy { background: var(--accent); color: var(--black); }

.nudge-block { display: flex; flex-direction: column; gap: 10px; animation: fadeSlideIn 0.5s 0.4s ease both; }
.nudge-card { display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; border: 1px solid var(--border); background: var(--panel); font-size: 13px; gap: 16px; }
.nudge-card p { color: var(--text-dim); }
.nudge-card p strong { color: var(--text); display: block; margin-bottom: 2px; }
.nudge-link { font-family: var(--font-mono); font-size: 11px; color: var(--accent); text-decoration: none; border: 1px solid var(--accent); padding: 6px 12px; white-space: nowrap; transition: background 0.15s, color 0.15s; }
.nudge-link:hover { background: var(--accent); color: var(--black); }

.faq-section { padding: 80px 40px; border-top: 1px solid var(--border); background: var(--off-black); }
.faq-inner { max-width: 720px; margin: 0 auto; }
.faq-title { font-family: var(--font-display); font-size: 48px; color: var(--white); margin-bottom: 48px; }
.faq-item { padding: 28px 0; border-top: 1px solid var(--border); }
.faq-item h3 { font-size: 16px; font-weight: 500; color: var(--text); margin-bottom: 10px; }
.faq-item p { font-size: 14px; color: var(--text-dim); line-height: 1.7; }

.site-footer { padding: 24px 40px; border-top: 1px solid var(--border); text-align: center; font-family: var(--font-mono); font-size: 11px; color: var(--text-dimmer); }

@media (max-width: 900px) {
  .calc-wrapper { grid-template-columns: 1fr; }
  .form-panel { border-right: none; border-bottom: 1px solid var(--border); }
  .hero-content { padding: 100px 24px 40px; }
  .hero-stat-strip { flex-direction: column; }
  .stat-pill { border-right: none; border-top: 1px solid var(--border); }
  .calc-section { padding: 40px 16px; }
  .form-panel, .results-panel { padding: 32px 24px; }
  .stat-cards { grid-template-columns: 1fr; }
}
EOF

# ============================================================
# static/js/main.js
# ============================================================
cat > static/js/main.js << 'EOF'
let selectedDays = 3;
let selectedTransport = "public";
let lastResult = null;

document.addEventListener("DOMContentLoaded", () => {
  const slider = document.getElementById("commute_minutes");
  const display = document.getElementById("commute_minutes_val");
  slider.addEventListener("input", () => { display.textContent = slider.value; });

  document.querySelectorAll(".day-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".day-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      selectedDays = parseInt(btn.dataset.val);
    });
  });

  document.querySelectorAll(".transport-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".transport-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      selectedTransport = btn.dataset.type;
      document.getElementById("public-fields").classList.toggle("hidden", selectedTransport === "car");
      document.getElementById("car-fields").classList.toggle("hidden", selectedTransport === "public");
    });
  });

  document.getElementById("is_ev").addEventListener("change", e => {
    document.getElementById("petrol-fields").classList.toggle("hidden", e.target.checked);
  });

  document.getElementById("calculateBtn").addEventListener("click", runCalculation);
});

function getFormData() {
  return {
    salary: parseFloat(document.getElementById("salary").value) || 0,
    commute_minutes: parseFloat(document.getElementById("commute_minutes").value) || 0,
    days_per_week: selectedDays,
    weeks_per_year: 48,
    transport_type: selectedTransport,
    transport_cost_daily: parseFloat(document.getElementById("transport_cost_daily").value) || 0,
    miles_one_way: parseFloat(document.getElementById("miles_one_way").value) || 0,
    is_ev: document.getElementById("is_ev").checked,
    mpg: parseFloat(document.getElementById("mpg").value) || 40,
    fuel_cost_per_litre: parseFloat(document.getElementById("fuel_cost_per_litre").value) || 1.55,
  };
}

async function runCalculation() {
  const btn = document.getElementById("calculateBtn");
  const data = getFormData();

  if (data.salary <= 0) { showToast("Please enter your annual salary."); return; }
  if (data.commute_minutes <= 0) { showToast("Please set your commute time."); return; }
  if (data.transport_type === "public" && data.transport_cost_daily <= 0) { showToast("Please enter your daily transport cost."); return; }
  if (data.transport_type === "car" && data.miles_one_way <= 0) { showToast("Please enter your one-way distance."); return; }

  btn.querySelector("span").textContent = "Calculating...";
  btn.disabled = true;

  try {
    const res = await fetch("/calculate", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data) });
    const result = await res.json();
    lastResult = result;
    renderResults(result, data);
    document.getElementById("resultsPanel").scrollIntoView({ behavior: "smooth", block: "start" });
  } catch (err) {
    showToast("Something went wrong. Please try again.");
  } finally {
    btn.querySelector("span").textContent = "Calculate My Commute Tax";
    btn.disabled = false;
  }
}

function renderResults(r, data) {
  document.getElementById("resultsPlaceholder").classList.add("hidden");
  document.getElementById("resultsContent").classList.remove("hidden");

  document.getElementById("res-total-cost").textContent = fmt(r.total_yearly_cost);
  document.getElementById("res-total-sub").textContent = `£${r.transport_cost_yearly.toLocaleString()} transport + £${r.time_cost_yearly.toLocaleString()} of your time`;
  document.getElementById("res-transport-yearly").textContent = fmt(r.transport_cost_yearly);
  document.getElementById("res-hours-yearly").textContent = r.commute_hours_yearly + "h";
  document.getElementById("res-time-cost").textContent = fmt(r.time_cost_yearly);
  document.getElementById("res-pct-life").textContent = r.pct_waking_life + "%";

  setTimeout(() => { document.getElementById("life-bar").style.width = Math.min(r.pct_waking_life * 2, 100) + "%"; }, 100);
  document.getElementById("res-life-text").textContent = r.pct_waking_life + "%";
  document.getElementById("res-career-text").textContent = `That's ${r.commute_days_yearly} days per year — and ${r.career_commute_years} years of your entire career lost to commuting.`;
  document.getElementById("res-office-cost").textContent = `−${fmt(r.remote_total_value)}/yr`;
  document.getElementById("res-remote-hours").textContent = r.remote_savings_time_hours + " hours";
  document.getElementById("res-remote-money").textContent = fmt(r.remote_total_value);
  document.getElementById("res-monthly-transport").textContent = fmt(r.transport_cost_monthly);
  document.getElementById("res-monthly-time").textContent = fmt(Math.round(r.time_cost_yearly / 12));
  document.getElementById("res-monthly-total").textContent = fmt(r.total_monthly_cost);
  document.getElementById("share-pct").textContent = r.pct_waking_life + "%";
  document.getElementById("share-desc").textContent = `of my waking life goes on commuting. That's ${r.commute_days_yearly} days/year & ${fmt(r.total_yearly_cost)} I'll never get back.`;

  const block = document.getElementById("nudgeBlock");
  block.innerHTML = "";
  if (data.transport_type === "public" && data.days_per_week >= 3) {
    block.innerHTML += nudgeCard("Save up to £200/year", "A Railcard could cut your train fares by a third.", "https://www.railcard.co.uk", "Get a Railcard →");
  }
  if (r.pct_waking_life > 8 || r.commute_hours_yearly > 200) {
    block.innerHTML += nudgeCard("Find remote & hybrid roles", "Cut your commute to zero. Browse remote jobs in your field.", "https://www.workingnomads.com/jobs", "Browse Remote Jobs →");
  }
  if (data.transport_type === "car" && !data.is_ev && r.transport_cost_yearly > 2000) {
    block.innerHTML += nudgeCard("Could an EV save you money?", `Your car costs ~${fmt(r.transport_cost_yearly)}/yr. EVs typically cost 70% less to run.`, "https://www.zap-map.com", "Compare EVs →");
  }
}

function nudgeCard(title, desc, link, cta) {
  return `<div class="nudge-card"><p><strong>${title}</strong>${desc}</p><a class="nudge-link" href="${link}" target="_blank" rel="noopener">${cta}</a></div>`;
}

function shareToTwitter() {
  if (!lastResult) return;
  const text = `I spend ${lastResult.pct_waking_life}% of my waking life commuting — that's ${fmt(lastResult.total_yearly_cost)} a year I'll never get back. Find out your Commute Tax 👇`;
  window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent("https://thecommutetax.co.uk")}`, "_blank");
}

function copyResult() {
  if (!lastResult) return;
  const text = `My Commute Tax:\n• Annual cost: ${fmt(lastResult.total_yearly_cost)}\n• Hours lost/year: ${lastResult.commute_hours_yearly}h\n• % of waking life: ${lastResult.pct_waking_life}%\n• Career total: ${lastResult.career_commute_years} years\n\nCalculate yours: thecommutetax.co.uk`;
  navigator.clipboard.writeText(text).then(() => showToast("Copied to clipboard!"));
}

function fmt(n) { return "£" + Math.round(n).toLocaleString("en-GB"); }

function showToast(msg) {
  const existing = document.querySelector(".toast");
  if (existing) existing.remove();
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = msg;
  toast.style.cssText = "position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#f0e040;color:#0a0a0a;padding:12px 24px;font-family:'DM Mono',monospace;font-size:12px;letter-spacing:0.08em;z-index:9999;max-width:400px;text-align:center;";
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3500);
}
EOF

echo ""
echo "✅ Project created at ~/commute-tax"
echo ""
echo "Now run:"
echo "  pip3 install flask"
echo "  python3 app.py"
echo ""
echo "Then open: http://localhost:5000"
