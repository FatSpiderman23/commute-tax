/* =============================================
   TRAVEL TAX — main.js
   ============================================= */

let selectedDays = 3;
let selectedTransport = "public";
let selectedCarType = "petrol_avg";
let lastResult = null;

// =============================================
// ALTERNATIVE REALITY ENGINE
// =============================================

const AR_METRICS = [
  {
    id: "spanish", category: "skill", icon: "🇪🇸", benchmark: 600,
    getMessage: (hrs, ratio) => ratio >= 1
      ? `You could have become <strong>fluent in Spanish</strong> — and still had ${Math.round(hrs - 600)} hours to spare.`
      : `You're ${Math.round(ratio * 100)}% of the way to <strong>Spanish fluency</strong>. Just ${Math.round(600 - hrs)} more hours and you'd be conversational.`,
    shareText: (hrs) => `My commute time = ${Math.round(hrs / 600 * 100)}% of learning Spanish. I could be fluent by now.`,
  },
  {
    id: "coding", category: "skill", icon: "💻", benchmark: 500,
    getMessage: (hrs, ratio) => ratio >= 1
      ? `You could have completed a <strong>full coding bootcamp</strong> and be job-ready as a developer.`
      : `You're ${Math.round(ratio * 100)}% through a <strong>coding bootcamp</strong>. ${Math.round(500 - hrs)} hours left to career-change.`,
    shareText: (hrs) => `My commute hours = ${Math.round(hrs)}hrs. That's ${Math.round(hrs / 500 * 100)}% of a full coding bootcamp.`,
  },
  {
    id: "piano", category: "skill", icon: "🎹", benchmark: 1200,
    getMessage: (hrs, ratio) => ratio >= 1
      ? `You could have reached <strong>Grade 8 piano</strong> — the highest ABRSM grade — with hours to spare.`
      : `You're ${Math.round(ratio * 100)}% of the way to <strong>Grade 8 piano</strong>. You'd currently be around Grade ${Math.min(8, Math.round(ratio * 8))}.`,
    shareText: (hrs) => `${Math.round(hrs)} commute hours/year = Grade ${Math.min(8, Math.round(hrs / 1200 * 8))} piano ability. Instead I stare at a train ceiling.`,
  },
  {
    id: "marathon", category: "fitness", icon: "🏃", benchmark: 120,
    getMessage: (hrs, ratio) => {
      const times = Math.floor(ratio);
      if (times >= 2) return `You could have trained for and completed <strong>${times} marathons</strong> this year.`;
      if (ratio >= 1) return `You had enough time to <strong>train for and run a full marathon</strong>. Every. Single. Year.`;
      return `You're ${Math.round(ratio * 100)}% through a full <strong>marathon training plan</strong>.`;
    },
    shareText: (hrs) => `My commute = ${Math.round(hrs)}hrs/yr. I could've trained for ${Math.floor(hrs / 120)} marathons instead.`,
  },
  {
    id: "breakingbad", category: "entertainment", icon: "📺", benchmark: 62,
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
    id: "sidehustle", category: "money", icon: "💰", benchmark: null,
    getMessage: (hrs, ratio, hourlyRate) => {
      const earned = Math.round(hrs * hourlyRate);
      return `If you'd spent those hours <strong>freelancing at your current rate</strong>, you'd have earned an extra <strong>£${earned.toLocaleString()}</strong> this year.`;
    },
    shareText: (hrs, hourlyRate) => `My commute hours = £${Math.round(hrs * hourlyRate).toLocaleString()} in lost freelance income. The real travel tax.`,
  },
  {
    id: "coffee", category: "money", icon: "☕", benchmark: null,
    getMessage: (hrs, ratio, hourlyRate, transportCost) => {
      const coffees = Math.round(transportCost / 4.50);
      const perWeek = Math.round(coffees / 52);
      return `Your annual commute cost buys <strong>${coffees.toLocaleString()} flat whites</strong> — that's ${perWeek} coffees every single week, just to get to work.`;
    },
    shareText: (hrs, hourlyRate, transportCost) => `My commute costs ${Math.round(transportCost / 4.50).toLocaleString()} flat whites a year. I don't even drink coffee.`,
  },
  {
    id: "gym", category: "fitness", icon: "💪", benchmark: 1,
    getMessage: (hrs) => {
      const sessions = Math.round(hrs);
      const perWeek = Math.round(sessions / 48);
      return `You spent the equivalent of <strong>${sessions} gym sessions</strong> commuting — that's ${perWeek} sessions every week you'll never get back.`;
    },
    shareText: (hrs) => `My commute = ${Math.round(hrs)} gym sessions a year. My commute is literally stealing my gains.`,
  },
  {
    id: "books", category: "skill", icon: "📚", benchmark: 8,
    getMessage: (hrs) => {
      const books = Math.floor(hrs / 8);
      return `You could have read <strong>${books} books</strong> this year — more than one a month, every month.`;
    },
    shareText: (hrs) => `My commute hours = ${Math.floor(hrs / 8)} books I could've read. Currently at zero.`,
  },
];

function buildAlternativeReality(hours, hourlyRate, transportCost) {
  const results = AR_METRICS.map(metric => {
    const ratio = metric.benchmark ? hours / metric.benchmark : 1;
    const message = metric.getMessage(hours, ratio, hourlyRate, transportCost);
    const shareText = metric.shareText(hours, hourlyRate, transportCost);
    return { ...metric, ratio, message, shareResult: shareText };
  });
  results.sort((a, b) => {
    const sA = a.ratio >= 0.5 && a.ratio <= 3 ? 1 : 0;
    const sB = b.ratio >= 0.5 && b.ratio <= 3 ? 1 : 0;
    return sB - sA;
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
        <div class="ar-card">
          <div class="ar-card-top">
            <span class="ar-icon">${m.icon}</span>
            <span class="ar-category">${m.category.toUpperCase()}</span>
          </div>
          <p class="ar-message">${m.message}</p>
          ${m.ratio >= 0.8 ? `
            <div class="ar-bar-wrap"><div class="ar-bar" style="width:0%" data-target="${Math.min(m.ratio * 100, 100)}"></div></div>
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
  const text = metric.shareResult + "\n\ntraveltax.co.uk";
  window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`, "_blank");
}

function shareAllAR() {
  if (!window._arMetrics) { showToast("Calculate first to see your results!"); return; }
  const lines = window._arMetrics.slice(0, 3).map(m => {
    const txt = m.shareResult;
    return "• " + m.icon + " " + txt;
  }).join("\n");
  const text = "My " + Math.round(window._arHours) + " commute hours this year could have been:\n\n" + lines + "\n\nInstead I commuted.\n\ntraveltax.co.uk";
  navigator.clipboard.writeText(text).then(() => showToast("Copied! Share anywhere 📤")).catch(() => {
    window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(text), "_blank");
  });
}

// =============================================
// FUN FACTS
// =============================================

const FUN_FACTS = [
  { text: 'The average UK worker spends <em>3 years</em> of their career just getting to work.' },
  { text: 'London commuters spend an average of <em>£5,000/year</em> on train fares alone.' },
  { text: 'A 60-min daily commute is worth <em>£4,200/year</em> of your time if you earn £35k.' },
  { text: 'Going fully remote gives back the equivalent of <em>6 weeks of holidays</em> per year.' },
  { text: 'UK rail fares have risen <em>40% since 2010</em> — double the rate of wage growth.' },
  { text: 'The UK has the <em>longest average commute</em> in Europe at 59 minutes per day.' },
  { text: 'A 90-min commute 5 days/week = <em>360 hours</em> lost per year. That\'s 15 full days.' },
  { text: 'Every extra 20 mins of commuting has the same effect as a <em>19% pay cut</em>.' },
];

function initFunFacts() {
  const display = document.getElementById("funFactDisplay");
  const dotsWrap = document.getElementById("funFactDots");
  if (!display || !dotsWrap) return;
  dotsWrap.innerHTML = "";
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
      dotsWrap.querySelectorAll(".fun-fact-dot").forEach((d, i) => d.classList.toggle("active", i === index));
    }, 400);
  }
  showFact(0);
  setInterval(() => { current = (current + 1) % FUN_FACTS.length; showFact(current); }, 4000);
}

// =============================================
// DOM INIT
// =============================================

document.addEventListener("DOMContentLoaded", () => {

  // Slider + manual input sync
  const slider = document.getElementById("commute_minutes");
  const manual = document.getElementById("commute_minutes_manual");
  if (slider && manual) {
    slider.addEventListener("input", () => { manual.value = slider.value; });
    manual.addEventListener("focus", () => { manual.select(); });
    manual.addEventListener("input", () => {
      const v = parseInt(manual.value);
      if (!isNaN(v) && v >= 1) slider.value = Math.min(v, 180);
    });
    manual.addEventListener("blur", () => {
      if (!manual.value || parseInt(manual.value) < 1) manual.value = 1;
    });
  }

  // Day toggle
  document.querySelectorAll(".day-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".day-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      selectedDays = parseInt(btn.dataset.val);
    });
  });

  // Transport toggle
  document.querySelectorAll(".transport-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".transport-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      selectedTransport = btn.dataset.type;
      document.getElementById("public-fields").classList.toggle("hidden", selectedTransport === "car");
      document.getElementById("car-fields").classList.toggle("hidden", selectedTransport === "public");
    });
  });

  // Car type toggle
  document.querySelectorAll(".car-type-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".car-type-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      selectedCarType = btn.dataset.car;
      const fuelField = document.getElementById("fuel-cost-field");
      if (fuelField) fuelField.classList.toggle("hidden", selectedCarType === "electric");
    });
  });

  // Calculate button
  document.getElementById("calculateBtn").addEventListener("click", runCalculation);

  // Fun facts
  initFunFacts();
});

// =============================================
// FORM DATA
// =============================================

function getFormData() {
  const manual = document.getElementById("commute_minutes_manual");
  const slider = document.getElementById("commute_minutes");
  const minutes = parseFloat((manual && manual.value) ? manual.value : slider.value) || 0;
  return {
    salary: parseFloat(document.getElementById("salary").value) || 0,
    commute_minutes: minutes,
    days_per_week: selectedDays,
    weeks_per_year: 48,
    transport_type: selectedTransport,
    transport_cost_daily: parseFloat(document.getElementById("transport_cost_daily").value) || 0,
    miles_one_way: parseFloat(document.getElementById("miles_one_way").value) || 0,
    car_type: selectedCarType,
    fuel_cost_per_litre: parseFloat(document.getElementById("fuel_cost_per_litre").value) || 1.55,
  };
}

// =============================================
// CALCULATE
// =============================================

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
    btn.querySelector("span").textContent = "Calculate My Travel Tax";
    btn.disabled = false;
  }
}

// =============================================
// RENDER RESULTS
// =============================================

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

// =============================================
// NUDGES
// =============================================

function renderNudges(r, data) {
  const block = document.getElementById("nudgeBlock");
  block.innerHTML = "";
  if (data.transport_type === "public" && data.days_per_week >= 3) {
    block.innerHTML += nudgeCard("Save up to £200/year", "A Railcard could cut your train fares by a third.", "https://www.trainline.com/railcards", "Get a Railcard →");
  }
  if (r.pct_waking_life > 8 || r.commute_hours_yearly > 200) {
    block.innerHTML += nudgeCard("Find remote & hybrid roles", "Cut your commute to zero. Browse remote jobs on Reed.", "https://www.reed.co.uk/jobs/remote-jobs", "Browse Remote Jobs →");
  }
  if (data.transport_type === "car" && selectedCarType !== "electric" && r.transport_cost_yearly > 2000) {
    block.innerHTML += nudgeCard("Could an electric car save you money?", `Your car costs ~${fmt(r.transport_cost_yearly)}/yr. Electric cars typically cost 70% less to run.`, "https://www.autotrader.co.uk/electric-cars", "Compare Electric Cars →");
  }
}

function nudgeCard(title, desc, link, cta) {
  return `<div class="nudge-card"><p><strong>${title}</strong>${desc}</p><a class="nudge-link" href="${link}" target="_blank" rel="noopener">${cta}</a></div>`;
}

// =============================================
// SHARE FUNCTIONS
// =============================================

function buildShareMessage(short) {
  if (!lastResult) return "";
  const pct = lastResult.pct_waking_life;
  const cost = fmt(lastResult.total_yearly_cost);
  const hrs = lastResult.commute_hours_yearly;

  if (short) {
    return `I spend ${pct}% of my waking life commuting — that's ${cost}/year I'll never get back. What's your Travel Tax? traveltax.co.uk`;
  }

  const arLines = (window._arMetrics || []).slice(0, 3).map(m => {
    const txt = m.shareResult;
    return "• " + m.icon + " " + txt;
  }).join("\n");

  return `My Travel Tax results:\n\n💸 Annual cost: ${cost}\n⏳ Hours lost: ${hrs}h/year\n🌅 Life stolen: ${pct}%\n\nInstead I could have:\n${arLines}\n\ntraveltax.co.uk`;
}

function doShare(text) {
  // Generic share — tries Web Share API first (mobile), falls back to clipboard
  if (navigator.share) {
    navigator.share({ text, url: "https://traveltax.co.uk" }).catch(() => {});
  } else {
    navigator.clipboard.writeText(text).then(() => showToast("Copied to clipboard!"));
  }
}

function shareToTwitter() {
  if (!lastResult) return;
  window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(buildShareMessage(true))}`, "_blank");
}

function shareToWhatsApp() {
  if (!lastResult) return;
  window.open(`https://wa.me/?text=${encodeURIComponent(buildShareMessage(false))}`, "_blank");
}

function shareToLinkedIn() {
  if (!lastResult) return;
  window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent("https://traveltax.co.uk")}`, "_blank");
}

function copyResult() {
  if (!lastResult) return;
  navigator.clipboard.writeText(buildShareMessage(false))
    .then(() => showToast("Copied! Paste into Instagram, email, anywhere 📋"))
    .catch(() => showToast("Copy failed — try manually selecting the text"));
}

// =============================================
// HELPERS
// =============================================

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

// =============================================
// VISUAL SHARE CARD (Spotify Wrapped style)
// =============================================

function generateShareCard() {
  if (!lastResult) return;

  const canvas = document.createElement("canvas");
  canvas.width = 1080;
  canvas.height = 1080;
  const ctx = canvas.getContext("2d");

  const r = lastResult;
  const arMetric = window._arMetrics ? window._arMetrics[0] : null;

  // --- Background ---
  ctx.fillStyle = "#0a0a0a";
  ctx.fillRect(0, 0, 1080, 1080);

  // --- Accent bar top ---
  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, 0, 1080, 12);

  // --- Grid lines (subtle) ---
  ctx.strokeStyle = "#1a1a1a";
  ctx.lineWidth = 1;
  for (let x = 0; x < 1080; x += 120) {
    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, 1080); ctx.stroke();
  }
  for (let y = 0; y < 1080; y += 120) {
    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(1080, y); ctx.stroke();
  }

  // --- Logo ---
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 36px monospace";
  ctx.letterSpacing = "4px";
  ctx.fillText("TRAVEL TAX", 80, 100);

  ctx.fillStyle = "#555";
  ctx.font = "22px monospace";
  ctx.fillText("traveltax.co.uk", 80, 140);

  // --- Big headline number ---
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 180px Arial";
  ctx.textAlign = "center";
  const totalCost = "£" + Math.round(r.total_yearly_cost).toLocaleString("en-GB");
  ctx.fillText(totalCost, 540, 380);

  ctx.fillStyle = "#888";
  ctx.font = "32px monospace";
  ctx.fillText("YOUR ANNUAL TRAVEL TAX", 540, 430);

  // --- Divider ---
  ctx.strokeStyle = "#2a2a2a";
  ctx.lineWidth = 2;
  ctx.beginPath(); ctx.moveTo(80, 470); ctx.lineTo(1000, 470); ctx.stroke();

  // --- Stats row ---
  const stats = [
    { label: "TRANSPORT/YR", value: "£" + Math.round(r.transport_cost_yearly).toLocaleString("en-GB") },
    { label: "HOURS LOST", value: r.commute_hours_yearly + "h" },
    { label: "LIFE STOLEN", value: r.pct_waking_life + "%" },
  ];

  stats.forEach((stat, i) => {
    const x = 180 + i * 280;
    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 64px Arial";
    ctx.textAlign = "center";
    ctx.fillText(stat.value, x, 580);
    ctx.fillStyle = "#555";
    ctx.font = "20px monospace";
    ctx.fillText(stat.label, x, 620);
  });

  // --- Divider ---
  ctx.strokeStyle = "#2a2a2a";
  ctx.lineWidth = 2;
  ctx.beginPath(); ctx.moveTo(80, 660); ctx.lineTo(1000, 660); ctx.stroke();

  // --- Alternative Reality highlight ---
  if (arMetric) {
    ctx.fillStyle = "#f0e040";
    ctx.font = "bold 28px monospace";
    ctx.textAlign = "center";
    ctx.fillText("INSTEAD YOU COULD HAVE...", 540, 720);

    // Strip HTML tags from message
    const cleanMsg = arMetric.message.replace(/<[^>]*>/g, '');
    ctx.fillStyle = "#e8e8e0";
    ctx.font = "32px Arial";
    // Word wrap
    const words = cleanMsg.split(' ');
    let line = '';
    let y = 770;
    for (let w of words) {
      const test = line + w + ' ';
      if (ctx.measureText(test).width > 880 && line !== '') {
        ctx.fillText(line.trim(), 540, y);
        line = w + ' ';
        y += 44;
      } else {
        line = test;
      }
    }
    if (line) ctx.fillText(line.trim(), 540, y);
  }

  // --- Career stat ---
  ctx.fillStyle = "#444";
  ctx.font = "24px monospace";
  ctx.textAlign = "center";
  ctx.fillText(`${r.career_commute_years} years of your career lost to commuting`, 540, 980);

  // --- Accent bar bottom ---
  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, 1068, 1080, 12);

  // --- Show modal with download + share options ---
  showShareCardModal(canvas);
}

function showShareCardModal(canvas) {
  // Remove existing modal
  const existing = document.getElementById("shareCardModal");
  if (existing) existing.remove();

  const modal = document.createElement("div");
  modal.id = "shareCardModal";
  modal.style.cssText = `
    position: fixed; inset: 0; background: rgba(0,0,0,0.85);
    display: flex; flex-direction: column; align-items: center;
    justify-content: center; z-index: 10000; padding: 20px;
  `;

  const img = document.createElement("img");
  img.src = canvas.toDataURL("image/png");
  img.style.cssText = "max-width: 100%; max-height: 60vh; border: 2px solid #f0e040;";

  const btnRow = document.createElement("div");
  btnRow.style.cssText = "display: flex; gap: 12px; margin-top: 20px; flex-wrap: wrap; justify-content: center;";

  // Download button
  const dlBtn = document.createElement("a");
  dlBtn.href = canvas.toDataURL("image/png");
  dlBtn.download = "my-travel-tax.png";
  dlBtn.textContent = "⬇ Download Image";
  dlBtn.style.cssText = "background: #f0e040; color: #000; padding: 14px 24px; font-family: monospace; font-size: 13px; text-decoration: none; letter-spacing: 0.1em; cursor: pointer;";

  // Share to Twitter with image note
  const tweetBtn = document.createElement("button");
  tweetBtn.textContent = "𝕏 Share on Twitter";
  tweetBtn.style.cssText = "background: #000; color: #fff; border: 1px solid #333; padding: 14px 24px; font-family: monospace; font-size: 13px; cursor: pointer; letter-spacing: 0.1em;";
  tweetBtn.onclick = () => {
    const text = `I spend ${lastResult.pct_waking_life}% of my waking life commuting — that's £${Math.round(lastResult.total_yearly_cost).toLocaleString('en-GB')}/year I'll never get back. What's your Travel Tax? 👇`;
    window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent("https://traveltax.co.uk")}`, "_blank");
  };

  // WhatsApp
  const waBtn = document.createElement("button");
  waBtn.textContent = "💬 Share on WhatsApp";
  waBtn.style.cssText = "background: #25D366; color: #fff; border: none; padding: 14px 24px; font-family: monospace; font-size: 13px; cursor: pointer; letter-spacing: 0.1em;";
  waBtn.onclick = () => {
    const text = buildShareMessage(false);
    window.open(`https://wa.me/?text=${encodeURIComponent(text)}`, "_blank");
  };

  // Close
  const closeBtn = document.createElement("button");
  closeBtn.textContent = "✕ Close";
  closeBtn.style.cssText = "background: transparent; color: #888; border: 1px solid #333; padding: 14px 24px; font-family: monospace; font-size: 13px; cursor: pointer;";
  closeBtn.onclick = () => modal.remove();

  // Close on background click
  modal.onclick = (e) => { if (e.target === modal) modal.remove(); };

  btnRow.append(dlBtn, tweetBtn, waBtn, closeBtn);
  modal.append(img, btnRow);
  document.body.appendChild(modal);
}
