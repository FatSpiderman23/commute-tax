#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "🔧 Applying fixes..."

# 1. Remove STEP 01
sed -i '' 's|<span class="form-step">STEP 01</span>||g' "$TARGET/templates/index.html"
echo "✅ Removed STEP 01"

# 2. Replace entire index.html with calculator-first design
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
    <div class="ticker-tape">
      <span>TRAVEL TAX &nbsp;·&nbsp; HOW MUCH OF YOUR LIFE IS TRAVEL STEALING? &nbsp;·&nbsp; TRAVEL TAX &nbsp;·&nbsp; YOUR TIME HAS A PRICE &nbsp;·&nbsp; TRAVEL TAX &nbsp;·&nbsp; WHAT IS YOUR COMMUTE REALLY COSTING YOU? &nbsp;·&nbsp;</span>
      <span aria-hidden="true">TRAVEL TAX &nbsp;·&nbsp; HOW MUCH OF YOUR LIFE IS TRAVEL STEALING? &nbsp;·&nbsp; TRAVEL TAX &nbsp;·&nbsp; YOUR TIME HAS A PRICE &nbsp;·&nbsp; TRAVEL TAX &nbsp;·&nbsp; WHAT IS YOUR COMMUTE REALLY COSTING YOU? &nbsp;·&nbsp;</span>
    </div>
  </header>

  <!-- CALCULATOR — straight to action -->
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
          <span>Calculate My Travel Tax</span>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
        </button>
      </div>

      <!-- RIGHT: RESULTS -->
      <div class="results-panel" id="resultsPanel">
        <div class="results-placeholder" id="resultsPlaceholder">
          <div class="placeholder-icon">⏱</div>
          <p>Your results will appear here once you calculate.</p>
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

          <!-- AD SLOT 2: Native mid-results -->
          <div class="ad-slot ad-native">
            <span class="ad-label">Advertisement</span>
          </div>

          <!-- ALTERNATIVE REALITY BLOCK -->
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

  <!-- FAQ -->
  <section class="faq-section">
    <div class="faq-inner">
      <h2 class="faq-title">Frequently Asked Questions</h2>
      <div class="faq-item">
        <h3>How is the "time value" calculated?</h3>
        <p>We divide your annual salary by your total working hours per year (days × 8hrs). This gives your hourly rate. We then multiply by hours spent commuting to show what that time is worth in monetary terms.</p>
      </div>
      <div class="faq-item">
        <h3>How is car depreciation calculated?</h3>
        <p>We use HMRC's approved mileage rates: 45p/mile for the first 10,000 miles, 25p/mile after.</p>
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

  <!-- AD SLOT 3 -->
  <div class="ad-slot ad-mid-content">
    <span class="ad-label">Advertisement</span>
  </div>

  <footer class="site-footer">
    <p>© 2025 Travel Tax · Built for UK commuters · <a href="/privacy">Privacy</a> · <a href="/guide">Commute Guide</a></p>
  </footer>

  <script src="/static/js/main.js"></script>
</body>
</html>
EOF
echo "✅ Homepage updated — calculator first"

# 3. Fix blog CTA button so it's always visible
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* Slim header replaces hero */
.slim-header { background: var(--black); border-bottom: 1px solid var(--border); }
.slim-header-inner { max-width: 1100px; margin: 0 auto; padding: 20px 40px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.slim-logo-main { font-family: var(--font-display); font-size: 32px; color: var(--accent); letter-spacing: 0.03em; display: block; line-height: 1; }
.slim-logo-sub { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.2em; color: var(--text-dimmer); text-transform: uppercase; }
.slim-stats { display: flex; gap: 24px; font-family: var(--font-mono); font-size: 11px; color: var(--text-dimmer); flex-wrap: wrap; }
.slim-stats strong { color: var(--text); }
.form-desc { font-size: 13px; color: var(--text-dimmer); margin-top: 4px; }

/* Fix blog CTA button */
.blog-cta-block .cta-btn {
  color: var(--black) !important;
  background: var(--accent);
  display: inline-block;
  padding: 16px 32px;
  text-decoration: none;
  font-family: var(--font-mono);
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  border: none;
  transition: background 0.2s;
}
.blog-cta-block .cta-btn:hover { background: var(--white); border-bottom: none; }

@media (max-width: 700px) {
  .slim-header-inner { padding: 16px 20px; }
  .slim-stats { display: none; }
}
CSSEOF
echo "✅ Fixed blog CTA button"

echo ""
echo "All done! Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Calculator first, fix button' && git push"
