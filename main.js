/* =============================================
   THE COMMUTE TAX — main.js
   ============================================= */

// ---- State ----
let selectedDays = 3;
let selectedTransport = "public";
let lastResult = null;

// =============================================
// ALTERNATIVE REALITY ENGINE
// =============================================
// All benchmarks are researched real-world figures.
// Hours are annual commute hours from the calculation.

const AR_METRICS = [
  // --- SKILLS / LEARNING ---
  {
    id: "spanish",
    category: "skill",
    icon: "🇪🇸",
    label: "Become fluent in Spanish",
    benchmark: 600,        // FSI: 600–750hrs to professional fluency
    unit: "hrs needed",
    getMessage: (hrs, ratio) => {
      if (ratio >= 1) return `You could have become <strong>fluent in Spanish</strong> — and still had ${Math.round(hrs - 600)} hours to spare. (FSI benchmark: 600hrs)`;
      return `You're ${Math.round(ratio * 100)}% of the way to <strong>Spanish fluency</strong>. Just ${Math.round(600 - hrs)} more hours and you'd be conversational.`;
    },
    shareText: (hrs) => `My commute time = ${Math.round(hrs / 600 * 100)}% of learning Spanish. I could be fluent by now.`,
  },
  {
    id: "coding",
    category: "skill",
    icon: "💻",
    label: "Learn to code (job-ready)",
    benchmark: 500,        // Bootcamp average: 400–600hrs
    unit: "hrs needed",
    getMessage: (hrs, ratio) => {
      if (ratio >= 1) return `You could have completed a <strong>full coding bootcamp</strong> and be job-ready as a developer. (Average: 500hrs)`;
      return `You're ${Math.round(ratio * 100)}% through a <strong>coding bootcamp</strong>. ${Math.round(500 - hrs)} hours left to career-change.`;
    },
    shareText: (hrs) => `My commute hours = ${Math.round(hrs)}hrs. That's ${Math.round(hrs / 500 * 100)}% of a full coding bootcamp.`,
  },
  {
    id: "piano",
    category: "skill",
    icon: "🎹",
    label: "Reach Grade 8 piano",
    benchmark: 1200,       // ABRSM Grade 8: ~1200hrs practice
    unit: "hrs needed",
    getMessage: (hrs, ratio) => {
      if (ratio >= 1) return `You could have reached <strong>Grade 8 piano</strong> — the highest ABRSM grade — with hours to spare.`;
      return `You're ${Math.round(ratio * 100)}% of the way to <strong>Grade 8 piano</strong>. You'd currently be around Grade ${Math.min(8, Math.round(ratio * 8))}.`;
    },
    shareText: (hrs) => `${Math.round(hrs)} commute hours/year = Grade ${Math.min(8, Math.round(hrs / 1200 * 8))} piano ability. Instead I stare at a train ceiling.`,
  },
  {
    id: "marathon",
    category: "fitness",
    icon: "🏃",
    label: "Train for a marathon",
    benchmark: 120,        // 16-week plan avg ~120hrs total training
    unit: "hrs needed",
    getMessage: (hrs, ratio) => {
      const times = Math.floor(ratio);
      if (times >= 2) return `You could have trained for and completed <strong>${times} marathons</strong> this year.`;
      if (ratio >= 1) return `You had enough time to <strong>train for and run a full marathon</strong>. Every. Single. Year.`;
      return `You're ${Math.round(ratio * 100)}% through a full <strong>marathon training plan</strong>.`;
    },
    shareText: (hrs) => `My commute = ${Math.round(hrs)}hrs/yr. I could've trained for ${Math.floor(hrs / 120)} marathons instead.`,
  },

  // --- ENTERTAINMENT ---
  {
    id: "breakingbad",
    category: "entertainment",
    icon: "📺",
    label: "Watch Breaking Bad",
    benchmark: 62,         // 62 hours total runtime
    unit: "hrs total",
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
    id: "sopranos",
    category: "entertainment",
    icon: "🎬",
    label: "Watch The Sopranos",
    benchmark: 86,
    unit: "hrs total",
    getMessage: (hrs, ratio) => {
      const times = Math.floor(ratio);
      if (times >= 3) return `You could have watched <strong>The Sopranos ${times} times over</strong>. Woke up this morning...`;
      if (ratio >= 1) return `You could have watched the <strong>entire Sopranos series</strong> — all 6 seasons — start to finish.`;
      return `You're on the equivalent of <strong>Season ${Math.ceil(ratio * 6)} of The Sopranos</strong>.`;
    },
    shareText: (hrs) => `My commute hours = The Sopranos x${Math.floor(hrs / 86)}. Tony Soprano had a shorter commute than me.`,
  },

  // --- MONEY / SIDE HUSTLE ---
  {
    id: "sidehustle",
    category: "money",
    icon: "💰",
    label: "Side hustle earnings",
    benchmark: null,       // dynamic — uses hourly rate
    unit: "at your rate",
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
    id: "coffee",
    category: "money",
    icon: "☕",
    label: "Flat whites",
    benchmark: null,       // dynamic — uses transport cost
    unit: "at £4.50 each",
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
    id: "gym",
    category: "fitness",
    icon: "💪",
    label: "Gym sessions",
    benchmark: 1,          // 1hr per session
    unit: "hrs per session",
    getMessage: (hrs, ratio) => {
      const sessions = Math.round(hrs);
      const perWeek = Math.round(sessions / 48);
      return `You spent the equivalent of <strong>${sessions} gym sessions</strong> commuting this year — that's ${perWeek} sessions every week you'll never get back.`;
    },
    shareText: (hrs) => `My commute = ${Math.round(hrs)} gym sessions a year. My commute is literally stealing my gains.`,
  },

  // --- BOOKS ---
  {
    id: "books",
    category: "skill",
    icon: "📚",
    label: "Books you could read",
    benchmark: 8,          // avg audiobook ~8hrs, reading ~6–10hrs
    unit: "hrs per book",
    getMessage: (hrs, ratio) => {
      const books = Math.floor(hrs / 8);
      return `You could have read <strong>${books} books</strong> this year — that's more than one a month, every month.`;
    },
    shareText: (hrs) => `My commute hours = ${Math.floor(hrs / 8)} books I could've read. Currently at zero.`,
  },
];

function buildAlternativeReality(hours, hourlyRate, transportCost) {
  // Pick the most impactful / surprising metrics dynamically
  const results = AR_METRICS.map(metric => {
    const ratio = metric.benchmark ? hours / metric.benchmark : 1;
    const message = metric.getMessage(hours, ratio, hourlyRate, transportCost);
    const shareText = metric.shareText(hours, hourlyRate, transportCost);
    return { ...metric, ratio, message, shareText };
  });

  // Sort: show "achievable" ones first (ratio 0.5–2.0 = most emotionally resonant)
  // Then big multiples, then tiny ratios
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

  // Show top 6 metrics
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
              <div class="ar-bar" style="width: 0%" data-target="${Math.min(m.ratio * 100, 100)}"></div>
            </div>
            <p class="ar-bar-label">${m.ratio >= 1 ? '✓ Achievable this year' : Math.round(m.ratio * 100) + '% there'}</p>
          ` : ''}
          <button class="ar-share-btn" onclick="shareARMetric(${i})">Share this stat →</button>
        </div>
      `).join('')}
    </div>
    <div class="ar-share-all">
      <button class="ar-share-all-btn" onclick="shareAllAR()">
        📤 Share my full Alternative Reality report
      </button>
    </div>
  `;

  // Store for sharing
  window._arMetrics = top;
  window._arHours = hours;
  window._arHourlyRate = hourlyRate;
  window._arTransportCost = transportCost;

  // Animate bars after render
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
  window.open(
    `https://twitter.com/intent/tweet?text=${encodeURIComponent(fullText)}`,
    "_blank"
  );
}

function shareAllAR() {
  if (!window._arMetrics) return;
  const hours = Math.round(window._arHours);
  const lines = window._arMetrics.slice(0, 3).map(m =>
    `• ${m.icon} ${m.shareText(window._arHours, window._arHourlyRate, window._arTransportCost)}`
  ).join('\n');
  const text = `My ${hours} commute hours this year could have been used to:\n\n${lines}\n\nInstead I commuted. Calculate yours 👇\nhttps://thecommutetax.co.uk`;
  window.open(
    `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`,
    "_blank"
  );
}

// ---- DOM Ready ----
document.addEventListener("DOMContentLoaded", () => {
  initSlider();
  initDayToggle();
  initTransportToggle();
  initEVToggle();
  document.getElementById("calculateBtn").addEventListener("click", runCalculation);
});

// ---- Slider ----
function initSlider() {
  const slider = document.getElementById("commute_minutes");
  const display = document.getElementById("commute_minutes_val");
  slider.addEventListener("input", () => {
    display.textContent = slider.value;
  });
}

// ---- Day Toggle ----
function initDayToggle() {
  document.querySelectorAll(".day-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".day-btn").forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      selectedDays = parseInt(btn.dataset.val);
    });
  });
}

// ---- Transport Toggle ----
function initTransportToggle() {
  document.querySelectorAll(".transport-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".transport-btn").forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      selectedTransport = btn.dataset.type;

      if (selectedTransport === "car") {
        document.getElementById("public-fields").classList.add("hidden");
        document.getElementById("car-fields").classList.remove("hidden");
      } else {
        document.getElementById("public-fields").classList.remove("hidden");
        document.getElementById("car-fields").classList.add("hidden");
      }
    });
  });
}

// ---- EV Toggle ----
function initEVToggle() {
  document.getElementById("is_ev").addEventListener("change", (e) => {
    if (e.target.checked) {
      document.getElementById("petrol-fields").classList.add("hidden");
    } else {
      document.getElementById("petrol-fields").classList.remove("hidden");
    }
  });
}

// ---- Gather Form Data ----
function getFormData() {
  return {
    salary: parseFloat(document.getElementById("salary").value) || 0,
    commute_minutes: parseFloat(document.getElementById("commute_minutes").value) || 0,
    days_per_week: selectedDays,
    weeks_per_year: 48,
    transport_type: selectedTransport,
    // Public
    transport_cost_daily: parseFloat(document.getElementById("transport_cost_daily").value) || 0,
    // Car
    miles_one_way: parseFloat(document.getElementById("miles_one_way").value) || 0,
    is_ev: document.getElementById("is_ev").checked,
    mpg: parseFloat(document.getElementById("mpg").value) || 40,
    fuel_cost_per_litre: parseFloat(document.getElementById("fuel_cost_per_litre").value) || 1.55,
  };
}

// ---- Validation ----
function validate(data) {
  if (data.salary <= 0) return "Please enter your annual salary.";
  if (data.commute_minutes <= 0) return "Please set your commute time.";
  if (data.transport_type === "public" && data.transport_cost_daily <= 0)
    return "Please enter your daily transport cost.";
  if (data.transport_type === "car" && data.miles_one_way <= 0)
    return "Please enter your one-way distance.";
  return null;
}

// ---- Main Calculation ----
async function runCalculation() {
  const btn = document.getElementById("calculateBtn");
  const data = getFormData();

  const error = validate(data);
  if (error) {
    showToast(error);
    return;
  }

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
    renderResults(result, data);
    document.getElementById("resultsPanel").scrollIntoView({ behavior: "smooth", block: "start" });
  } catch (err) {
    showToast("Something went wrong. Please try again.");
  } finally {
    btn.querySelector("span").textContent = "Calculate My Commute Tax";
    btn.disabled = false;
  }
}

// ---- Render Results ----
function renderResults(r, data) {
  // Show results panel
  document.getElementById("resultsPlaceholder").classList.add("hidden");
  document.getElementById("resultsContent").classList.remove("hidden");

  // Verdict
  document.getElementById("res-total-cost").textContent = fmt(r.total_yearly_cost);
  document.getElementById("res-total-sub").textContent =
    `£${r.transport_cost_yearly.toLocaleString()} transport + £${r.time_cost_yearly.toLocaleString()} of your time`;

  // Stat cards
  document.getElementById("res-transport-yearly").textContent = fmt(r.transport_cost_yearly);
  document.getElementById("res-hours-yearly").textContent = r.commute_hours_yearly + "h";
  document.getElementById("res-time-cost").textContent = fmt(r.time_cost_yearly);
  document.getElementById("res-pct-life").textContent = r.pct_waking_life + "%";

  // Life impact bar (animate)
  setTimeout(() => {
    document.getElementById("life-bar").style.width = Math.min(r.pct_waking_life * 2, 100) + "%";
  }, 100);

  document.getElementById("res-life-text").textContent = r.pct_waking_life + "%";

  const days = r.commute_days_yearly;
  document.getElementById("res-life-text").textContent = r.pct_waking_life + "%";
  document.getElementById("res-career-text").textContent =
    `That's ${days} days per year — and ${r.career_commute_years} years of your entire career lost to commuting.`;

  // Remote vs office
  document.getElementById("res-office-cost").textContent = `−${fmt(r.remote_total_value)}/yr`;
  document.getElementById("res-remote-hours").textContent = r.remote_savings_time_hours + " hours";
  document.getElementById("res-remote-money").textContent = fmt(r.remote_total_value);

  // Monthly breakdown
  document.getElementById("res-monthly-transport").textContent = fmt(r.transport_cost_monthly);
  document.getElementById("res-monthly-time").textContent = fmt(Math.round(r.time_cost_yearly / 12));
  document.getElementById("res-monthly-total").textContent = fmt(r.total_monthly_cost);

  // Share card
  document.getElementById("share-pct").textContent = r.pct_waking_life + "%";
  document.getElementById("share-desc").textContent =
    `of my waking life goes on commuting. That's ${days} days/year & ${fmt(r.total_yearly_cost)} I'll never get back.`;

  // Alternative Reality Engine
  renderAlternativeReality(r.commute_hours_yearly, r.hourly_rate, r.transport_cost_yearly);

  // Affiliate nudges
  renderNudges(r, data);
}

// ---- Affiliate Nudges (contextual) ----
function renderNudges(r, data) {
  const block = document.getElementById("nudgeBlock");
  block.innerHTML = "";

  const nudges = [];

  if (data.transport_type === "public" && data.days_per_week >= 3) {
    nudges.push({
      title: "Save up to £200/year",
      desc: "A Railcard could cut your train fares by a third.",
      link: "https://www.railcard.co.uk",
      cta: "Get a Railcard →",
    });
  }

  if (r.pct_waking_life > 8 || r.commute_hours_yearly > 200) {
    nudges.push({
      title: "Find remote & hybrid roles",
      desc: "Cut your commute to zero. Browse remote jobs in your field.",
      link: "https://www.workingnomads.com/jobs",
      cta: "Browse Remote Jobs →",
    });
  }

  if (data.transport_type === "car" && !data.is_ev && r.transport_cost_yearly > 2000) {
    nudges.push({
      title: "Could an EV save you money?",
      desc: `Your petrol costs ~${fmt(r.transport_cost_yearly)}/yr. EVs typically cost 70% less to run.`,
      link: "https://www.zap-map.com",
      cta: "Compare EVs →",
    });
  }

  nudges.forEach((n) => {
    block.innerHTML += `
      <div class="nudge-card">
        <p>
          <strong>${n.title}</strong>
          ${n.desc}
        </p>
        <a class="nudge-link" href="${n.link}" target="_blank" rel="noopener">${n.cta}</a>
      </div>
    `;
  });
}

// ---- Share ----
function shareToTwitter() {
  if (!lastResult) return;
  const text = `I spend ${lastResult.pct_waking_life}% of my waking life commuting — that's ${fmt(lastResult.total_yearly_cost)} a year I'll never get back. Find out your Commute Tax 👇`;
  const url = "https://thecommutetax.co.uk";
  window.open(
    `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(url)}`,
    "_blank"
  );
}

function copyResult() {
  if (!lastResult) return;
  const arLines = (window._arMetrics || []).slice(0, 3).map(m =>
    `  ${m.icon} ${m.shareText(window._arHours, window._arHourlyRate, window._arTransportCost)}`
  ).join('\n');

  const text = `My Commute Tax Results:
• Annual commute cost: ${fmt(lastResult.total_yearly_cost)}
• Hours lost per year: ${lastResult.commute_hours_yearly}h
• % of waking life: ${lastResult.pct_waking_life}%
• Career commute time: ${lastResult.career_commute_years} years

Instead of commuting I could have:
${arLines}

Calculate yours at thecommutetax.co.uk`;

  navigator.clipboard.writeText(text).then(() => showToast("Copied to clipboard!"));
}

// ---- Helpers ----
function fmt(n) {
  return "£" + Math.round(n).toLocaleString("en-GB");
}

function showToast(msg) {
  const existing = document.querySelector(".toast");
  if (existing) existing.remove();

  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = msg;
  toast.style.cssText = `
    position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%);
    background: #f0e040; color: #0a0a0a;
    padding: 12px 24px; font-family: 'DM Mono', monospace;
    font-size: 12px; letter-spacing: 0.08em;
    z-index: 9999; animation: fadeSlideIn 0.3s ease;
    max-width: 400px; text-align: center;
  `;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3500);
}
