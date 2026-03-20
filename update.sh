#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "🔄 Updating The Commute Tax at $TARGET..."

# ============================================================
# static/js/main.js
# ============================================================
cat > "$TARGET/static/js/main.js" << 'JSEOF'
/* =============================================
   THE COMMUTE TAX — main.js
   ============================================= */

let selectedDays = 3;
let selectedTransport = "public";
let lastResult = null;

// =============================================
// ALTERNATIVE REALITY ENGINE
// =============================================

const AR_METRICS = [
  {
    id: "spanish", category: "skill", icon: "🇪🇸", label: "Become fluent in Spanish", benchmark: 600,
    getMessage: (hrs, ratio) => {
      if (ratio >= 1) return `You could have become <strong>fluent in Spanish</strong> — and still had ${Math.round(hrs - 600)} hours to spare. (FSI benchmark: 600hrs)`;
      return `You're ${Math.round(ratio * 100)}% of the way to <strong>Spanish fluency</strong>. Just ${Math.round(600 - hrs)} more hours and you'd be conversational.`;
    },
    shareText: (hrs) => `My commute time = ${Math.round(hrs / 600 * 100)}% of learning Spanish. I could be fluent by now.`,
  },
  {
    id: "coding", category: "skill", icon: "💻", label: "Learn to code (job-ready)", benchmark: 500,
    getMessage: (hrs, ratio) => {
      if (ratio >= 1) return `You could have completed a <strong>full coding bootcamp</strong> and be job-ready as a developer. (Average: 500hrs)`;
      return `You're ${Math.round(ratio * 100)}% through a <strong>coding bootcamp</strong>. ${Math.round(500 - hrs)} hours left to career-change.`;
    },
    shareText: (hrs) => `My commute hours = ${Math.round(hrs)}hrs. That's ${Math.round(hrs / 500 * 100)}% of a full coding bootcamp.`,
  },
  {
    id: "piano", category: "skill", icon: "🎹", label: "Reach Grade 8 piano", benchmark: 1200,
    getMessage: (hrs, ratio) => {
      if (ratio >= 1) return `You could have reached <strong>Grade 8 piano</strong> — the highest ABRSM grade — with hours to spare.`;
      return `You're ${Math.round(ratio * 100)}% of the way to <strong>Grade 8 piano</strong>. You'd currently be around Grade ${Math.min(8, Math.round(ratio * 8))}.`;
    },
    shareText: (hrs) => `${Math.round(hrs)} commute hours/year = Grade ${Math.min(8, Math.round(hrs / 1200 * 8))} piano ability. Instead I stare at a train ceiling.`,
  },
  {
    id: "marathon", category: "fitness", icon: "🏃", label: "Train for a marathon", benchmark: 120,
    getMessage: (hrs, ratio) => {
      const times = Math.floor(ratio);
      if (times >= 2) return `You could have trained for and completed <strong>${times} marathons</strong> this year.`;
      if (ratio >= 1) return `You had enough time to <strong>train for and run a full marathon</strong>. Every. Single. Year.`;
      return `You're ${Math.round(ratio * 100)}% through a full <strong>marathon training plan</strong>.`;
    },
    shareText: (hrs) => `My commute = ${Math.round(hrs)}hrs/yr. I could've trained for ${Math.floor(hrs / 120)} marathons instead.`,
  },
  {
    id: "breakingbad", category: "entertainment", icon: "📺", label: "Watch Breaking Bad", benchmark: 62,
    getMessage: (hrs, ratio) => {
      const times = Math.floor(ratio);
      if (times >= 5) return `You could have watched <strong>Breaking Bad ${times} times</strong> from start to finish. Say my name.`;
      if (times >= 2) return `You could have watched <strong>Breaking Bad ${times} times over</strong> — and still had time left.`;
      if (ratio >= 1) return `You could have watched the <strong>entire Breaking Bad series</strong> — all 5 seasons — with time to spare.`;
      return `You've watched the equivalent of <strong>Season ${Math.ceil(ratio * 5)} of Breaking Bad</strong>.`;
    },
    shareText: (hrs) => `My commute time = watching Breaking Bad ${Math.floor(hrs / 62)} times. Walter White would be ashamed of my commute.`,
  },
  {
    id: "sidehustle", category: "money", icon: "💰", label: "Side hustle earnings", benchmark: null,
    getMessage: (hrs, ratio, hourlyRate) => {
      const earned = Math.round(hrs * hourlyRate);
      return `If you'd spent those hours <strong>freelancing at your current rate</strong>, you'd have earned an extra <strong>£${earned.toLocaleString()}</strong> this year.`;
    },
    shareText: (hrs, hourlyRate) => {
      const earned = Math.round(hrs * hourlyRate);
      return `My commute hours = £${earned.toLocaleString()} in lost freelance income. The real commute tax.`;
    },
  },
  {
    id: "coffee", category: "money", icon: "☕", label: "Flat whites", benchmark: null,
    getMessage: (hrs, ratio, hourlyRate, transportCost) => {
      const coffees = Math.round(transportCost / 4.50);
      const perWeek = Math.round(coffees / 52);
      return `Your annual commute cost buys <strong>${coffees.toLocaleString()} flat whites</strong> — that's ${perWeek} coffees every single week, just to get to work.`;
    },
    shareText: (hrs, hourlyRate, transportCost) => {
      const coffees = Math.round(transportCost / 4.50);
      return `My commute costs ${coffees.toLocaleString()} flat whites a year. I don't even drink coffee.`;
    },
  },
  {
    id: "gym", category: "fitness", icon: "💪", label: "Gym sessions", benchmark: 1,
    getMessage: (hrs) => {
      const sessions = Math.round(hrs);
      const perWeek = Math.round(sessions / 48);
      return `You spent the equivalent of <strong>${sessions} gym sessions</strong> commuting this year — that's ${perWeek} sessions every week you'll never get back.`;
    },
    shareText: (hrs) => `My commute = ${Math.round(hrs)} gym sessions a year. My commute is literally stealing my gains.`,
  },
  {
    id: "books", category: "skill", icon: "📚", label: "Books you could read", benchmark: 8,
    getMessage: (hrs) => {
      const books = Math.floor(hrs / 8);
      return `You could have read <strong>${books} books</strong> this year — that's more than one a month, every month.`;
    },
    shareText: (hrs) => `My commute hours = ${Math.floor(hrs / 8)} books I could've read. Currently at zero.`,
  },
];

function buildAlternativeReality(hours, hourlyRate, transportCost) {
  const results = AR_METRICS.map(metric => {
    const ratio = metric.benchmark ? hours / metric.benchmark : 1;
    const message = metric.getMessage(hours, ratio, hourlyRate, transportCost);
    const shareText = metric.shareText(hours, hourlyRate, transportCost);
    return { ...metric, ratio, message, shareText };
  });
  results.sort((a, b) => {
    const scoreA = a.ratio >= 0.5 && a.ratio <= 3 ? 1 : 0;
    const scoreB = b.ratio >= 0.5 && b.ratio <= 3 ? 1 : 0;
    return scoreB - scoreA;
  });
  return results;
}

function renderAlternativeReality(hours, hourlyRate, transportCost) {
  const block = document.getElementById("ar-block");
  if (!block) return;
  const metrics = buildAlternativeReality(hours, hourlyRate, transportCost);
  const top = metrics.slice(0, 6);
  block.innerHTML = `
    <h3 class="block-title">Instead of commuting, you could have...</h3>
    <p class="ar-subtitle">Based on ${Math.round(hours)} hours lost this year</p>
    <div class="ar-grid">
      ${top.map((m, i) => `
        <div class="ar-card" data-index="${i}">
          <div class="ar-card-top">
            <span class="ar-icon">${m.icon}</span>
            <span class="ar-category">${m.category.toUpperCase()}</span>
          </div>
          <p class="ar-message">${m.message}</p>
          ${m.ratio >= 0.8 ? `
            <div class="ar-bar-wrap">
              <div class="ar-bar" style="width:0%" data-target="${Math.min(m.ratio * 100, 100)}"></div>
            </div>
            <p class="ar-bar-label">${m.ratio >= 1 ? '✓ Achievable this year' : Math.round(m.ratio * 100) + '% there'}</p>
          ` : ''}
          <button class="ar-share-btn" onclick="shareARMetric(${i})">Share this stat →</button>
        </div>
      `).join('')}
    </div>
    <div class="ar-share-all">
      <button class="ar-share-all-btn" onclick="shareAllAR()">📤 Share my full Alternative Reality report</button>
    </div>
  `;
  window._arMetrics = top;
  window._arHours = hours;
  window._arHourlyRate = hourlyRate;
  window._arTransportCost = transportCost;
  setTimeout(() => {
    block.querySelectorAll(".ar-bar").forEach(bar => {
      bar.style.width = bar.dataset.target + "%";
    });
  }, 150);
}

function shareARMetric(index) {
  const metric = window._arMetrics[index];
  if (!metric) return;
  const text = metric.shareText(window._arHours, window._arHourlyRate, window._arTransportCost);
  const fullText = `${text}\n\nCalculate your own Commute Tax 👇\nhttps://thecommutetax.co.uk`;
  window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(fullText)}`, "_blank");
}

function shareAllAR() {
  if (!window._arMetrics) return;
  const hours = Math.round(window._arHours);
  const lines = window._arMetrics.slice(0, 3).map(m =>
    `• ${m.icon} ${m.shareText(window._arHours, window._arHourlyRate, window._arTransportCost)}`
  ).join('\n');
  const text = `My ${hours} commute hours this year could have been used to:\n\n${lines}\n\nInstead I commuted. Calculate yours 👇\nhttps://thecommutetax.co.uk`;
  window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`, "_blank");
}

// ---- DOM Ready ----
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

  renderAlternativeReality(r.commute_hours_yearly, r.hourly_rate, r.transport_cost_yearly);
  renderNudges(r, data);
}

function renderNudges(r, data) {
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
  const arLines = (window._arMetrics || []).slice(0, 3).map(m =>
    `  ${m.icon} ${m.shareText(window._arHours, window._arHourlyRate, window._arTransportCost)}`
  ).join('\n');
  const text = `My Commute Tax:\n• Annual cost: ${fmt(lastResult.total_yearly_cost)}\n• Hours lost/year: ${lastResult.commute_hours_yearly}h\n• % of waking life: ${lastResult.pct_waking_life}%\n• Career total: ${lastResult.career_commute_years} years\n\nInstead I could have:\n${arLines}\n\nCalculate yours: thecommutetax.co.uk`;
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
JSEOF

# ============================================================
# templates/index.html
# ============================================================
cat > "$TARGET/templates/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>The Commute Tax — How Much Is Your Commute Really Costing You?</title>
  <meta name="description" content="Find out the real cost of your commute in money, time, and life. UK commute calculator." />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <!-- Google AdSense: replace ca-pub-XXXXXXXXXXXXXXXX with your Publisher ID when approved -->
  <!-- <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXXXXXXXX" crossorigin="anonymous"></script> -->
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

  <!-- AD SLOT 1: Leaderboard below hero -->
  <div class="ad-slot ad-leaderboard">
    <span class="ad-label">Advertisement</span>
    <!--
    <ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-XXXXXXXXXXXXXXXX" data-ad-slot="1111111111" data-ad-format="auto" data-full-width-responsive="true"></ins>
    <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
    -->
  </div>

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
            <!--
            <ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-XXXXXXXXXXXXXXXX" data-ad-slot="2222222222" data-ad-format="auto" data-full-width-responsive="true"></ins>
            <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
            -->
          </div>

          <!-- ALTERNATIVE REALITY BLOCK -->
          <div class="ar-block" id="ar-block"></div>

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

  <!-- AD SLOT 3: Mid-content above footer -->
  <div class="ad-slot ad-mid-content">
    <span class="ad-label">Advertisement</span>
    <!--
    <ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-XXXXXXXXXXXXXXXX" data-ad-slot="3333333333" data-ad-format="auto" data-full-width-responsive="true"></ins>
    <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
    -->
  </div>

  <footer class="site-footer">
    <p>© 2025 The Commute Tax · Built for UK commuters · <a href="#">Privacy</a></p>
  </footer>

  <script src="/static/js/main.js"></script>
</body>
</html>
HTMLEOF

# ============================================================
# static/css/style.css — append new rules
# ============================================================
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* === ALTERNATIVE REALITY === */
.ar-block { border:1px solid var(--border); padding:24px; margin-bottom:20px; background:var(--panel); animation:fadeSlideIn 0.5s 0.25s ease both; }
.ar-subtitle { font-family:var(--font-mono); font-size:11px; color:var(--text-dimmer); margin-bottom:20px; letter-spacing:0.08em; }
.ar-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.ar-card { background:var(--off-black); border:1px solid var(--border); padding:16px; display:flex; flex-direction:column; gap:8px; transition:border-color 0.2s; }
.ar-card:hover { border-color:var(--border-light); }
.ar-card-top { display:flex; align-items:center; justify-content:space-between; }
.ar-icon { font-size:20px; }
.ar-category { font-family:var(--font-mono); font-size:9px; letter-spacing:0.18em; color:var(--text-dimmer); }
.ar-message { font-size:13px; color:var(--text-dim); line-height:1.55; flex:1; }
.ar-message strong { color:var(--accent); font-weight:500; }
.ar-bar-wrap { height:3px; background:var(--border); overflow:hidden; }
.ar-bar { height:100%; background:var(--accent); width:0%; transition:width 1.1s cubic-bezier(0.25,0.46,0.45,0.94); }
.ar-bar-label { font-family:var(--font-mono); font-size:10px; color:var(--text-dimmer); letter-spacing:0.08em; }
.ar-share-btn { background:none; border:none; color:var(--accent); font-family:var(--font-mono); font-size:10px; letter-spacing:0.1em; cursor:pointer; padding:0; text-align:left; margin-top:4px; opacity:0.7; transition:opacity 0.15s; }
.ar-share-btn:hover { opacity:1; }
.ar-share-all { margin-top:16px; padding-top:16px; border-top:1px solid var(--border); }
.ar-share-all-btn { width:100%; padding:12px; background:transparent; border:1px solid var(--accent); color:var(--accent); font-family:var(--font-mono); font-size:11px; letter-spacing:0.1em; cursor:pointer; transition:background 0.15s,color 0.15s; text-transform:uppercase; }
.ar-share-all-btn:hover { background:var(--accent); color:var(--black); }

/* === AD SLOTS === */
.ad-slot { position:relative; background:var(--off-black); border:1px dashed var(--border); display:flex; align-items:center; justify-content:center; min-height:90px; color:var(--text-dimmer); font-family:var(--font-mono); font-size:11px; letter-spacing:0.1em; }
.ad-label { position:absolute; top:6px; left:10px; font-size:9px; letter-spacing:0.15em; color:var(--text-dimmer); text-transform:uppercase; opacity:0.5; }
.ad-leaderboard { margin:0; min-height:90px; border-left:none; border-right:none; }
.ad-native { margin-bottom:20px; min-height:120px; }
.ad-mid-content { margin:0; min-height:90px; border-left:none; border-right:none; }

@media(max-width:900px){ .ar-grid { grid-template-columns:1fr; } }
CSSEOF

echo ""
echo "✅ All files updated!"
echo ""
echo "Now restart your app:"
echo "  cd ~/Documents/Commute\ Tax && python3 app.py"
