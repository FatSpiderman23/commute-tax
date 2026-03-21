#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "📱 Building mobile layout..."

# Add mobile-specific CSS
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* =============================================
   MOBILE LAYOUT — full redesign for small screens
   ============================================= */
@media (max-width: 768px) {

  /* Hide desktop calc wrapper, show mobile version */
  .calc-wrapper { display: none !important; }
  .mobile-calc { display: block !important; }

  /* Slim header on mobile */
  .slim-header-inner { padding: 14px 20px; }
  .slim-logo-main { font-size: 24px; }
  .slim-stats { display: none; }
  .ticker-tape { font-size: 10px; padding: 6px 0; }

  /* Mobile calc section */
  .calc-section { padding: 0; background: var(--black); }
}

@media (min-width: 769px) {
  .mobile-calc { display: none !important; }
}

/* Mobile calculator styles */
.mobile-calc {
  display: none;
  background: var(--black);
  min-height: 100vh;
}

/* Mobile tabs */
.mobile-tabs {
  display: flex;
  border-bottom: 1px solid var(--border);
  background: var(--off-black);
  position: sticky;
  top: 0;
  z-index: 50;
}

.mobile-tab {
  flex: 1;
  padding: 16px;
  background: none;
  border: none;
  color: var(--text-dimmer);
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: all 0.2s;
}

.mobile-tab.active {
  color: var(--accent);
  border-bottom-color: var(--accent);
}

/* Mobile form */
.mobile-form-panel {
  padding: 24px 20px;
  background: var(--panel);
}

.mobile-form-panel .field-group { margin-bottom: 24px; }
.mobile-form-panel .calculate-btn { margin-top: 8px; }

/* Mobile results */
.mobile-results-panel {
  padding: 20px;
  background: var(--black);
  display: none;
}

.mobile-results-panel.active { display: block; }

/* Mobile verdict */
.mobile-verdict {
  background: #0f0f00;
  border: 1px solid var(--accent);
  padding: 24px 20px;
  text-align: center;
  margin-bottom: 16px;
}

.mobile-verdict-label {
  font-family: var(--font-mono);
  font-size: 10px;
  letter-spacing: 0.2em;
  color: var(--accent);
  margin-bottom: 8px;
}

.mobile-verdict-number {
  font-family: var(--font-display);
  font-size: 64px;
  color: var(--accent);
  line-height: 1;
}

.mobile-verdict-sub {
  font-size: 12px;
  color: var(--text-dim);
  margin-top: 6px;
}

/* Mobile stat grid */
.mobile-stat-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 16px;
}

.mobile-stat-card {
  background: var(--panel);
  border: 1px solid var(--border);
  padding: 16px 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.mobile-stat-label {
  font-family: var(--font-mono);
  font-size: 9px;
  letter-spacing: 0.1em;
  color: var(--text-dimmer);
  text-transform: uppercase;
}

.mobile-stat-value {
  font-family: var(--font-display);
  font-size: 26px;
  color: var(--white);
  line-height: 1.1;
}

.mobile-stat-tip {
  font-size: 10px;
  color: var(--text-dimmer);
  font-family: var(--font-mono);
  line-height: 1.3;
}

/* Mobile blocks */
.mobile-block {
  background: var(--panel);
  border: 1px solid var(--border);
  padding: 18px 16px;
  margin-bottom: 12px;
}

.mobile-block .block-title {
  font-family: var(--font-mono);
  font-size: 10px;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--accent);
  margin-bottom: 12px;
}

/* Mobile share buttons */
.mobile-share-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin-bottom: 8px;
}

.mobile-share-btn {
  padding: 14px 8px;
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.06em;
  cursor: pointer;
  border: none;
  text-transform: uppercase;
}

.mobile-generate-btn {
  width: 100%;
  padding: 16px;
  background: var(--accent);
  color: var(--black);
  border: none;
  font-family: var(--font-mono);
  font-size: 12px;
  font-weight: 500;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  cursor: pointer;
  margin-bottom: 10px;
}

/* Mobile AR cards */
.mobile-ar-grid {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.mobile-ar-card {
  background: var(--off-black);
  border: 1px solid var(--border);
  padding: 14px;
}

.mobile-ar-message {
  font-size: 14px;
  color: var(--text-dim);
  line-height: 1.55;
  margin-bottom: 8px;
}

.mobile-ar-message strong { color: var(--accent); font-weight: 500; }

.mobile-ar-share {
  background: none;
  border: none;
  color: var(--accent);
  font-family: var(--font-mono);
  font-size: 10px;
  cursor: pointer;
  padding: 0;
  letter-spacing: 0.1em;
}

/* Mobile nudge */
.mobile-nudge {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 14px;
  border: 1px solid var(--border);
  background: var(--panel);
  gap: 12px;
  margin-bottom: 8px;
}

.mobile-nudge p { font-size: 12px; color: var(--text-dim); }
.mobile-nudge p strong { color: var(--text); display: block; font-size: 13px; margin-bottom: 2px; }

.mobile-nudge-link {
  font-family: var(--font-mono);
  font-size: 10px;
  color: var(--accent);
  text-decoration: none;
  border: 1px solid var(--accent);
  padding: 6px 10px;
  white-space: nowrap;
}
CSSEOF

echo "✅ Mobile CSS added"

# Add mobile HTML to index.html just before closing </main>
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/templates/index.html'
with open(path, 'r') as f:
    content = f.read()

mobile_html = '''
  </main>

  <!-- MOBILE CALCULATOR — shown only on small screens -->
  <div class="mobile-calc" id="mobileCalc">

    <!-- Tabs -->
    <div class="mobile-tabs">
      <button class="mobile-tab active" id="mTabCalc" onclick="mobileTab('calc')">Calculator</button>
      <button class="mobile-tab" id="mTabResults" onclick="mobileTab('results')">My Results</button>
    </div>

    <!-- FORM TAB -->
    <div class="mobile-form-panel" id="mobileFormPanel">

      <div class="field-group">
        <label for="m_salary">Annual Salary (£)</label>
        <div class="input-wrap">
          <span class="prefix">£</span>
          <input type="number" id="m_salary" placeholder="35000" min="0" inputmode="numeric" />
        </div>
        <p class="field-hint">Used to calculate the monetary value of your time.</p>
      </div>

      <div class="field-group">
        <label>One-Way Commute Time</label>
        <div class="slider-wrap">
          <input type="range" id="m_commute_minutes" min="5" max="180" value="45" step="5" />
          <div class="slider-input-wrap">
            <input type="number" id="m_commute_manual" value="45" min="1" max="300" inputmode="numeric" />
            <span class="slider-unit">min</span>
          </div>
        </div>
      </div>

      <div class="field-group">
        <label>Days in Office Per Week</label>
        <div class="day-toggle" id="m_day_toggle">
          <button class="day-btn" data-val="1">1</button>
          <button class="day-btn" data-val="2">2</button>
          <button class="day-btn active" data-val="3">3</button>
          <button class="day-btn" data-val="4">4</button>
          <button class="day-btn" data-val="5">5</button>
        </div>
      </div>

      <div class="field-group">
        <label>How Do You Get There?</label>
        <div class="transport-toggle" id="m_transport_toggle">
          <button class="transport-btn active" data-type="public">Train / Bus</button>
          <button class="transport-btn" data-type="car">Car</button>
        </div>
      </div>

      <div id="m_public_fields">
        <div class="field-group">
          <label for="m_transport_cost">Daily Transport Cost (£)</label>
          <div class="input-wrap">
            <span class="prefix">£</span>
            <input type="number" id="m_transport_cost" placeholder="12.50" min="0" step="0.50" inputmode="decimal" />
          </div>
          <p class="field-hint">Return fare.</p>
        </div>
      </div>

      <div id="m_car_fields" class="hidden">
        <div class="field-group">
          <label for="m_miles">One-Way Distance (miles)</label>
          <div class="input-wrap">
            <input type="number" id="m_miles" placeholder="15" min="0" inputmode="numeric" />
          </div>
        </div>
        <div class="field-group">
          <label>What Type of Car?</label>
          <div class="car-type-toggle" id="m_car_type_toggle">
            <button class="car-type-btn active" data-car="petrol_avg">Petrol (avg)</button>
            <button class="car-type-btn" data-car="petrol_large">Petrol (large)</button>
            <button class="car-type-btn" data-car="diesel">Diesel</button>
            <button class="car-type-btn" data-car="electric">Electric</button>
          </div>
        </div>
        <div id="m_fuel_field" class="field-group">
          <label for="m_fuel">Fuel Cost (£/litre)</label>
          <div class="input-wrap">
            <span class="prefix">£</span>
            <input type="number" id="m_fuel" placeholder="1.55" step="0.01" value="1.55" inputmode="decimal" />
          </div>
        </div>
      </div>

      <button class="calculate-btn" id="mCalculateBtn" onclick="runMobileCalculation()">
        <span>Calculate My Travel Tax</span>
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
      </button>
    </div>

    <!-- RESULTS TAB -->
    <div class="mobile-results-panel" id="mobileResultsPanel">
      <div id="mResultsPlaceholder" style="text-align:center;padding:60px 20px;color:var(--text-dimmer);font-family:var(--font-mono);font-size:12px;letter-spacing:0.1em;">
        CALCULATE FIRST TO SEE YOUR RESULTS
      </div>
      <div id="mResultsContent" class="hidden">

        <div class="mobile-verdict">
          <p class="mobile-verdict-label">YOUR ANNUAL TRAVEL TAX</p>
          <div class="mobile-verdict-number" id="m_res_total">£0</div>
          <p class="mobile-verdict-sub" id="m_res_sub">transport + time value</p>
        </div>

        <div class="mobile-stat-grid">
          <div class="mobile-stat-card" style="border-color:var(--red)">
            <span class="mobile-stat-label">Transport / Year</span>
            <span class="mobile-stat-value" id="m_res_transport">£0</span>
          </div>
          <div class="mobile-stat-card">
            <span class="mobile-stat-label">Hours Lost / Year</span>
            <span class="mobile-stat-value" id="m_res_hours">0h</span>
          </div>
          <div class="mobile-stat-card">
            <span class="mobile-stat-label">Your Time Lost (£)</span>
            <span class="mobile-stat-value" id="m_res_time">£0</span>
            <span class="mobile-stat-tip">what those hours are worth at your salary</span>
          </div>
          <div class="mobile-stat-card">
            <span class="mobile-stat-label">Life Stolen</span>
            <span class="mobile-stat-value" id="m_res_pct">0%</span>
            <span class="mobile-stat-tip">of your waking hours gone every year</span>
          </div>
        </div>

        <div class="mobile-block">
          <p class="block-title">The Life Impact</p>
          <div class="impact-bar-wrap" style="margin-bottom:10px"><span class="impact-bar" id="m_life_bar"></span></div>
          <p style="font-size:13px;color:var(--text-dim)" id="m_career_text"></p>
        </div>

        <div class="mobile-block">
          <p class="block-title">Monthly Breakdown</p>
          <div class="breakdown-row"><span>Transport cost</span><span id="m_monthly_transport">£0</span></div>
          <div class="breakdown-row"><span>Time value lost</span><span id="m_monthly_time">£0</span></div>
          <div class="breakdown-row total-row"><span>Total monthly tax</span><span id="m_monthly_total">£0</span></div>
        </div>

        <div class="mobile-block">
          <p class="block-title">Instead you could have...</p>
          <div class="mobile-ar-grid" id="m_ar_block"></div>
        </div>

        <div class="mobile-block">
          <p class="block-title">Share your result</p>
          <button class="mobile-generate-btn" onclick="generateShareCard()">Generate Share Card</button>
          <div class="mobile-share-grid">
            <button class="mobile-share-btn" style="background:#000;color:#fff;border:1px solid #333" onclick="shareToTwitter()">X Twitter</button>
            <button class="mobile-share-btn" style="background:#25D366;color:#fff" onclick="shareToWhatsApp()">WhatsApp</button>
            <button class="mobile-share-btn" style="background:#0077B5;color:#fff" onclick="shareToLinkedIn()">LinkedIn</button>
            <button class="mobile-share-btn" style="background:var(--accent);color:var(--black)" onclick="copyResult()">Copy Text</button>
          </div>
        </div>

        <div id="m_nudge_block"></div>

      </div>
    </div>
  </div>'''

# Replace </main> with mobile HTML (insert before FAQ section)
content = content.replace('  </main>\n\n  <section class="faq-section">', mobile_html + '\n\n  <section class="faq-section">')

with open(path, 'w') as f:
    f.write(content)
print("✅ Mobile HTML added to index.html")
PYEOF

# Add mobile JS to main.js
cat >> "$TARGET/static/js/main.js" << 'JSEOF'

// =============================================
// MOBILE CALCULATOR
// =============================================

let mSelectedDays = 3;
let mSelectedTransport = "public";
let mSelectedCarType = "petrol_avg";

document.addEventListener("DOMContentLoaded", () => {
  // Mobile slider sync
  const mSlider = document.getElementById("m_commute_minutes");
  const mManual = document.getElementById("m_commute_manual");
  if (mSlider && mManual) {
    mSlider.addEventListener("input", () => { mManual.value = mSlider.value; });
    mManual.addEventListener("focus", () => { mManual.select(); });
    mManual.addEventListener("input", () => {
      const v = parseInt(mManual.value);
      if (!isNaN(v) && v >= 1) mSlider.value = Math.min(v, 180);
    });
    mManual.addEventListener("blur", () => { if (!mManual.value || parseInt(mManual.value) < 1) mManual.value = 1; });
  }

  // Mobile day toggle
  const mDayToggle = document.getElementById("m_day_toggle");
  if (mDayToggle) {
    mDayToggle.querySelectorAll(".day-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        mDayToggle.querySelectorAll(".day-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        mSelectedDays = parseInt(btn.dataset.val);
      });
    });
  }

  // Mobile transport toggle
  const mTransToggle = document.getElementById("m_transport_toggle");
  if (mTransToggle) {
    mTransToggle.querySelectorAll(".transport-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        mTransToggle.querySelectorAll(".transport-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        mSelectedTransport = btn.dataset.type;
        document.getElementById("m_public_fields").classList.toggle("hidden", mSelectedTransport === "car");
        document.getElementById("m_car_fields").classList.toggle("hidden", mSelectedTransport === "public");
      });
    });
  }

  // Mobile car type toggle
  const mCarToggle = document.getElementById("m_car_type_toggle");
  if (mCarToggle) {
    mCarToggle.querySelectorAll(".car-type-btn").forEach(btn => {
      btn.addEventListener("click", () => {
        mCarToggle.querySelectorAll(".car-type-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        mSelectedCarType = btn.dataset.car;
        const fuelField = document.getElementById("m_fuel_field");
        if (fuelField) fuelField.classList.toggle("hidden", mSelectedCarType === "electric");
      });
    });
  }
});

function mobileTab(tab) {
  const calcTab = document.getElementById("mTabCalc");
  const resultsTab = document.getElementById("mTabResults");
  const formPanel = document.getElementById("mobileFormPanel");
  const resultsPanel = document.getElementById("mobileResultsPanel");

  if (tab === "calc") {
    calcTab.classList.add("active");
    resultsTab.classList.remove("active");
    formPanel.style.display = "block";
    resultsPanel.style.display = "none";
  } else {
    resultsTab.classList.add("active");
    calcTab.classList.remove("active");
    formPanel.style.display = "none";
    resultsPanel.style.display = "block";
  }
}

function getMobileFormData() {
  const mManual = document.getElementById("m_commute_manual");
  const mSlider = document.getElementById("m_commute_minutes");
  const minutes = parseFloat((mManual && mManual.value) ? mManual.value : mSlider.value) || 0;
  return {
    salary: parseFloat(document.getElementById("m_salary").value) || 0,
    commute_minutes: minutes,
    days_per_week: mSelectedDays,
    weeks_per_year: 48,
    transport_type: mSelectedTransport,
    transport_cost_daily: parseFloat(document.getElementById("m_transport_cost").value) || 0,
    miles_one_way: parseFloat(document.getElementById("m_miles").value) || 0,
    car_type: mSelectedCarType,
    fuel_cost_per_litre: parseFloat(document.getElementById("m_fuel").value) || 1.55,
  };
}

async function runMobileCalculation() {
  const btn = document.getElementById("mCalculateBtn");
  const data = getMobileFormData();

  if (data.salary <= 0) { showToast("Please enter your annual salary."); return; }
  if (data.commute_minutes <= 0) { showToast("Please set your commute time."); return; }
  if (data.transport_type === "public" && data.transport_cost_daily <= 0) { showToast("Please enter your daily transport cost."); return; }
  if (data.transport_type === "car" && data.miles_one_way <= 0) { showToast("Please enter your one-way distance."); return; }

  btn.querySelector("span").textContent = "Calculating...";
  btn.disabled = true;

  try {
    const res = await fetch("/calculate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    const result = await res.json();
    lastResult = result;
    renderMobileResults(result, data);
    mobileTab("results");
  } catch (err) {
    showToast("Something went wrong. Please try again.");
  } finally {
    btn.querySelector("span").textContent = "Calculate My Travel Tax";
    btn.disabled = false;
  }
}

function renderMobileResults(r, data) {
  document.getElementById("mResultsPlaceholder").classList.add("hidden");
  document.getElementById("mResultsContent").classList.remove("hidden");

  document.getElementById("m_res_total").textContent = fmt(r.total_yearly_cost);
  document.getElementById("m_res_sub").textContent = fmt(r.transport_cost_yearly) + " transport + " + fmt(r.time_cost_yearly) + " of your time";
  document.getElementById("m_res_transport").textContent = fmt(r.transport_cost_yearly);
  document.getElementById("m_res_hours").textContent = r.commute_hours_yearly + "h";
  document.getElementById("m_res_time").textContent = fmt(r.time_cost_yearly);
  document.getElementById("m_res_pct").textContent = r.pct_waking_life + "%";

  setTimeout(() => { document.getElementById("m_life_bar").style.width = Math.min(r.pct_waking_life * 2, 100) + "%"; }, 100);
  document.getElementById("m_career_text").textContent = "That is " + r.commute_days_yearly + " days/year — and " + r.career_commute_years + " years of your career lost to commuting.";

  document.getElementById("m_monthly_transport").textContent = fmt(r.transport_cost_monthly);
  document.getElementById("m_monthly_time").textContent = fmt(Math.round(r.time_cost_yearly / 12));
  document.getElementById("m_monthly_total").textContent = fmt(r.total_monthly_cost);

  // Mobile AR block
  const metrics = buildAlternativeReality(r.commute_hours_yearly, r.hourly_rate, r.transport_cost_yearly);
  const top = metrics.slice(0, 4);
  window._arMetrics = top;
  window._arHours = r.commute_hours_yearly;
  window._arHourlyRate = r.hourly_rate;
  window._arTransportCost = r.transport_cost_yearly;

  const mArBlock = document.getElementById("m_ar_block");
  mArBlock.innerHTML = top.map((m, i) =>
    "<div class=\"mobile-ar-card\">" +
      "<p class=\"mobile-ar-message\">" + m.message + "</p>" +
      "<button class=\"mobile-ar-share\" onclick=\"shareARMetric(" + i + ")\">Share this stat</button>" +
    "</div>"
  ).join("");

  // Mobile nudges
  const nudgeBlock = document.getElementById("m_nudge_block");
  nudgeBlock.innerHTML = "";
  if (data.transport_type === "public" && data.days_per_week >= 3) {
    nudgeBlock.innerHTML += "<div class=\"mobile-nudge\"><p><strong>Save up to £200/year</strong>A Railcard could cut your fares by a third.</p><a class=\"mobile-nudge-link\" href=\"https://www.trainline.com/railcards\" target=\"_blank\">Railcard</a></div>";
  }
  if (r.pct_waking_life > 8 || r.commute_hours_yearly > 200) {
    nudgeBlock.innerHTML += "<div class=\"mobile-nudge\"><p><strong>Find remote roles</strong>Cut your commute to zero.</p><a class=\"mobile-nudge-link\" href=\"https://www.reed.co.uk/jobs/remote-jobs\" target=\"_blank\">Browse Jobs</a></div>";
  }
}
JSEOF

echo "✅ Mobile JS added"
echo ""
echo "Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add proper mobile layout' && git push"
