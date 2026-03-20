#!/bin/bash
TARGET=~/Documents/Commute\ Tax

cat > "$TARGET/static/js/main.js" << 'JSEOF'
/* TRAVEL TAX — main.js */

let selectedDays = 3;
let selectedTransport = "public";
let selectedCarType = "petrol_avg";
let lastResult = null;

const AR_METRICS = [
  {
    id: "spanish", category: "skill", icon: "ES",
    getMessage: (hrs, ratio) => ratio >= 1
      ? "You could have become <strong>fluent in Spanish</strong> — FSI benchmark: 600hrs."
      : "You are " + Math.round(ratio * 100) + "% of the way to <strong>Spanish fluency</strong>. Just " + Math.round(600 - hrs) + " more hours.",
    shareText: (hrs) => "My commute time = " + Math.round(hrs / 600 * 100) + "% of learning Spanish. I could be fluent by now.",
  },
  {
    id: "coding", category: "skill", icon: "PC",
    getMessage: (hrs, ratio) => ratio >= 1
      ? "You could have completed a <strong>full coding bootcamp</strong> and be job-ready as a developer."
      : "You are " + Math.round(ratio * 100) + "% through a <strong>coding bootcamp</strong>. " + Math.round(500 - hrs) + " hours left.",
    shareText: (hrs) => "My commute = " + Math.round(hrs) + "hrs. That is " + Math.round(hrs / 500 * 100) + "% of a full coding bootcamp.",
  },
  {
    id: "marathon", category: "fitness", icon: "RUN",
    getMessage: (hrs, ratio) => {
      const times = Math.floor(ratio);
      if (times >= 2) return "You could have trained for and completed <strong>" + times + " marathons</strong> this year.";
      if (ratio >= 1) return "You had enough time to <strong>train for and run a full marathon</strong>. Every. Single. Year.";
      return "You are " + Math.round(ratio * 100) + "% through a full <strong>marathon training plan</strong>.";
    },
    shareText: (hrs) => "My commute = " + Math.round(hrs) + "hrs/yr. I could have trained for " + Math.floor(hrs / 120) + " marathons instead.",
  },
  {
    id: "breakingbad", category: "entertainment", icon: "TV",
    getMessage: (hrs, ratio) => {
      const times = Math.floor(ratio);
      if (times >= 5) return "You could have watched <strong>Breaking Bad " + times + " times</strong> from start to finish. Say my name.";
      if (times >= 2) return "You could have watched <strong>Breaking Bad " + times + " times over</strong> — and still had time left.";
      if (ratio >= 1) return "You could have watched the <strong>entire Breaking Bad series</strong> — all 5 seasons — with time to spare.";
      return "You have watched the equivalent of <strong>Season " + Math.ceil(ratio * 5) + " of Breaking Bad</strong>.";
    },
    shareText: (hrs) => "My commute time = watching Breaking Bad " + Math.floor(hrs / 62) + " times. Walter White would be ashamed of my commute.",
  },
  {
    id: "sidehustle", category: "money", icon: "GBP",
    getMessage: (hrs, ratio, hourlyRate) => {
      const earned = Math.round(hrs * hourlyRate);
      return "If you had spent those hours <strong>freelancing at your current rate</strong>, you would have earned an extra <strong>£" + earned.toLocaleString() + "</strong> this year.";
    },
    shareText: (hrs, hourlyRate) => "My commute hours = £" + Math.round(hrs * hourlyRate).toLocaleString() + " in lost freelance income. The real travel tax.",
  },
  {
    id: "coffee", category: "money", icon: "COF",
    getMessage: (hrs, ratio, hourlyRate, transportCost) => {
      const coffees = Math.round(transportCost / 4.50);
      const perWeek = Math.round(coffees / 52);
      return "Your annual commute cost buys <strong>" + coffees.toLocaleString() + " flat whites</strong> — that is " + perWeek + " coffees every single week, just to get to work.";
    },
    shareText: (hrs, hourlyRate, transportCost) => "My commute costs " + Math.round(transportCost / 4.50).toLocaleString() + " flat whites a year. I do not even drink coffee.",
  },
  {
    id: "gym", category: "fitness", icon: "GYM",
    getMessage: (hrs) => {
      const sessions = Math.round(hrs);
      const perWeek = Math.round(sessions / 48);
      return "You spent the equivalent of <strong>" + sessions + " gym sessions</strong> commuting — that is " + perWeek + " sessions every week you will never get back.";
    },
    shareText: (hrs) => "My commute = " + Math.round(hrs) + " gym sessions a year. My commute is literally stealing my gains.",
  },
  {
    id: "books", category: "skill", icon: "BK",
    getMessage: (hrs) => {
      const books = Math.floor(hrs / 8);
      return "You could have read <strong>" + books + " books</strong> this year — more than one a month, every month.";
    },
    shareText: (hrs) => "My commute hours = " + Math.floor(hrs / 8) + " books I could have read. Currently at zero.",
  },
];

function buildAlternativeReality(hours, hourlyRate, transportCost) {
  const results = AR_METRICS.map(metric => {
    const benchmarks = { spanish: 600, coding: 500, marathon: 120, breakingbad: 62, gym: 1, books: 8 };
    const bm = benchmarks[metric.id];
    const ratio = bm ? hours / bm : 1;
    const message = metric.getMessage(hours, ratio, hourlyRate, transportCost);
    const shareResult = metric.shareText(hours, hourlyRate, transportCost);
    return { ...metric, ratio, message, shareResult };
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
  block.innerHTML = "<h3 class=\"block-title\">Instead of commuting, you could have...</h3>" +
    "<p class=\"ar-subtitle\">Based on " + Math.round(hours) + " hours lost this year</p>" +
    "<div class=\"ar-grid\">" +
    top.map((m, i) =>
      "<div class=\"ar-card\">" +
        "<div class=\"ar-card-top\">" +
          "<span class=\"ar-category\">" + m.category.toUpperCase() + "</span>" +
        "</div>" +
        "<p class=\"ar-message\">" + m.message + "</p>" +
        (m.ratio >= 0.8 ?
          "<div class=\"ar-bar-wrap\"><div class=\"ar-bar\" style=\"width:0%\" data-target=\"" + Math.min(m.ratio * 100, 100) + "\"></div></div>" +
          "<p class=\"ar-bar-label\">" + (m.ratio >= 1 ? "Done this year" : Math.round(m.ratio * 100) + "% there") + "</p>"
        : "") +
        "<button class=\"ar-share-btn\" onclick=\"shareARMetric(" + i + ")\">Share this stat</button>" +
      "</div>"
    ).join("") +
    "</div>";
  window._arMetrics = top;
  window._arHours = hours;
  window._arHourlyRate = hourlyRate;
  window._arTransportCost = transportCost;
  setTimeout(() => {
    block.querySelectorAll(".ar-bar").forEach(bar => { bar.style.width = bar.dataset.target + "%"; });
  }, 150);
}

function shareARMetric(index) {
  const metric = window._arMetrics[index];
  if (!metric) return;
  const text = metric.shareResult + " traveltax.co.uk";
  window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(text), "_blank");
}

const FUN_FACTS = [
  { text: "The average UK worker spends <em>3 years</em> of their career just getting to work." },
  { text: "London commuters spend an average of <em>£5,000/year</em> on train fares alone." },
  { text: "A 60-min daily commute is worth <em>£4,200/year</em> of your time if you earn £35k." },
  { text: "Going fully remote gives back the equivalent of <em>6 weeks of holidays</em> per year." },
  { text: "UK rail fares have risen <em>40% since 2010</em> — double the rate of wage growth." },
  { text: "The UK has the <em>longest average commute</em> in Europe at 59 minutes per day." },
  { text: "A 90-min commute 5 days/week = <em>360 hours</em> lost per year. That is 15 full days." },
  { text: "Every extra 20 mins of commuting has the same effect as a <em>19% pay cut</em>." },
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

document.addEventListener("DOMContentLoaded", () => {
  const slider = document.getElementById("commute_minutes");
  const manual = document.getElementById("commute_minutes_manual");
  if (slider && manual) {
    slider.addEventListener("input", () => { manual.value = slider.value; });
    manual.addEventListener("focus", () => { manual.select(); });
    manual.addEventListener("input", () => {
      const v = parseInt(manual.value);
      if (!isNaN(v) && v >= 1) slider.value = Math.min(v, 180);
    });
    manual.addEventListener("blur", () => { if (!manual.value || parseInt(manual.value) < 1) manual.value = 1; });
  }

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

  document.querySelectorAll(".car-type-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".car-type-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      selectedCarType = btn.dataset.car;
      const fuelField = document.getElementById("fuel-cost-field");
      if (fuelField) fuelField.classList.toggle("hidden", selectedCarType === "electric");
    });
  });

  document.getElementById("calculateBtn").addEventListener("click", runCalculation);
  initFunFacts();
});

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

function renderResults(r, data) {
  document.getElementById("resultsPlaceholder").classList.add("hidden");
  document.getElementById("resultsContent").classList.remove("hidden");
  document.getElementById("res-total-cost").textContent = fmt(r.total_yearly_cost);
  document.getElementById("res-total-sub").textContent = fmt(r.transport_cost_yearly) + " transport + " + fmt(r.time_cost_yearly) + " of your time";
  document.getElementById("res-transport-yearly").textContent = fmt(r.transport_cost_yearly);
  document.getElementById("res-hours-yearly").textContent = r.commute_hours_yearly + "h";
  document.getElementById("res-time-cost").textContent = fmt(r.time_cost_yearly);
  document.getElementById("res-pct-life").textContent = r.pct_waking_life + "%";
  setTimeout(() => { document.getElementById("life-bar").style.width = Math.min(r.pct_waking_life * 2, 100) + "%"; }, 100);
  document.getElementById("res-life-text").textContent = r.pct_waking_life + "%";
  document.getElementById("res-career-text").textContent = "That is " + r.commute_days_yearly + " days per year — and " + r.career_commute_years + " years of your entire career lost to commuting.";
  document.getElementById("res-office-cost").textContent = "-" + fmt(r.remote_total_value) + "/yr";
  document.getElementById("res-remote-hours").textContent = r.remote_savings_time_hours + " hours";
  document.getElementById("res-remote-money").textContent = fmt(r.remote_total_value);
  document.getElementById("res-monthly-transport").textContent = fmt(r.transport_cost_monthly);
  document.getElementById("res-monthly-time").textContent = fmt(Math.round(r.time_cost_yearly / 12));
  document.getElementById("res-monthly-total").textContent = fmt(r.total_monthly_cost);
  document.getElementById("share-pct").textContent = r.pct_waking_life + "%";
  document.getElementById("share-desc").textContent = "of my waking life goes on commuting. That is " + r.commute_days_yearly + " days/year & " + fmt(r.total_yearly_cost) + " I will never get back.";
  renderAlternativeReality(r.commute_hours_yearly, r.hourly_rate, r.transport_cost_yearly);
  renderNudges(r, data);
}

function renderNudges(r, data) {
  const block = document.getElementById("nudgeBlock");
  block.innerHTML = "";
  if (data.transport_type === "public" && data.days_per_week >= 3) {
    block.innerHTML += nudgeCard("Save up to £200/year", "A Railcard could cut your train fares by a third.", "https://www.trainline.com/railcards", "Get a Railcard");
  }
  if (r.pct_waking_life > 8 || r.commute_hours_yearly > 200) {
    block.innerHTML += nudgeCard("Find remote and hybrid roles", "Cut your commute to zero. Browse remote jobs on Reed.", "https://www.reed.co.uk/jobs/remote-jobs", "Browse Remote Jobs");
  }
  if (data.transport_type === "car" && selectedCarType !== "electric" && r.transport_cost_yearly > 2000) {
    block.innerHTML += nudgeCard("Could an electric car save you money?", "Your car costs approx " + fmt(r.transport_cost_yearly) + "/yr. Electric cars typically cost 70% less to run.", "https://www.autotrader.co.uk/electric-cars", "Compare Electric Cars");
  }
}

function nudgeCard(title, desc, link, cta) {
  return "<div class=\"nudge-card\"><p><strong>" + title + "</strong>" + desc + "</p><a class=\"nudge-link\" href=\"" + link + "\" target=\"_blank\" rel=\"noopener\">" + cta + "</a></div>";
}

function buildShareMessage(short) {
  if (!lastResult) return "";
  const pct = lastResult.pct_waking_life;
  const cost = fmt(lastResult.total_yearly_cost);
  const hrs = lastResult.commute_hours_yearly;
  if (short) {
    return "I spend " + pct + "% of my waking life commuting — that is " + cost + "/year I will never get back. What is your Travel Tax? traveltax.co.uk";
  }
  const arLines = (window._arMetrics || []).slice(0, 3).map(m => "- " + m.shareResult).join("\n");
  return "My Travel Tax results:\n\nAnnual cost: " + cost + "\nHours lost: " + hrs + "h/year\nLife stolen: " + pct + "%\n\nInstead I could have:\n" + arLines + "\n\ntraveltax.co.uk";
}

function shareToTwitter() {
  if (!lastResult) return;
  window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(buildShareMessage(true)), "_blank");
}

function shareToWhatsApp() {
  if (!lastResult) return;
  window.open("https://wa.me/?text=" + encodeURIComponent(buildShareMessage(false)), "_blank");
}

function shareToLinkedIn() {
  if (!lastResult) return;
  window.open("https://www.linkedin.com/sharing/share-offsite/?url=" + encodeURIComponent("https://traveltax.co.uk"), "_blank");
}

function copyResult() {
  if (!lastResult) return;
  navigator.clipboard.writeText(buildShareMessage(false))
    .then(() => showToast("Copied! Paste into Instagram, email, anywhere"))
    .catch(() => showToast("Copy failed — try manually selecting the text"));
}

function generateShareCard() {
  if (!lastResult) return;
  const canvas = document.createElement("canvas");
  canvas.width = 1080;
  canvas.height = 1080;
  const ctx = canvas.getContext("2d");
  const r = lastResult;
  const arMetric = window._arMetrics ? window._arMetrics[0] : null;

  ctx.fillStyle = "#0a0a0a";
  ctx.fillRect(0, 0, 1080, 1080);

  ctx.strokeStyle = "#161616";
  ctx.lineWidth = 1;
  for (let x = 0; x < 1080; x += 108) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, 1080); ctx.stroke(); }
  for (let y = 0; y < 1080; y += 108) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(1080, y); ctx.stroke(); }

  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, 0, 1080, 10);

  ctx.textAlign = "left";
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 40px monospace";
  ctx.fillText("TRAVEL TAX", 80, 90);
  ctx.fillStyle = "#444";
  ctx.font = "22px monospace";
  ctx.fillText("traveltax.co.uk", 80, 128);

  const totalCost = "£" + Math.round(r.total_yearly_cost).toLocaleString("en-GB");
  ctx.textAlign = "center";
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 148px Arial";
  ctx.fillText(totalCost, 540, 320);

  ctx.fillStyle = "#555";
  ctx.font = "bold 24px monospace";
  ctx.fillText("YOUR ANNUAL TRAVEL TAX", 540, 368);

  ctx.strokeStyle = "#222";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(80, 405); ctx.lineTo(1000, 405); ctx.stroke();

  const stats = [
    { label: "TRANSPORT/YR", value: "£" + Math.round(r.transport_cost_yearly).toLocaleString("en-GB") },
    { label: "HOURS LOST/YR", value: r.commute_hours_yearly + "h" },
    { label: "LIFE STOLEN", value: r.pct_waking_life + "%" },
  ];
  stats.forEach((stat, i) => {
    const x = 190 + i * 270;
    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 56px Arial";
    ctx.textAlign = "center";
    ctx.fillText(stat.value, x, 490);
    ctx.fillStyle = "#444";
    ctx.font = "18px monospace";
    ctx.fillText(stat.label, x, 526);
  });

  ctx.strokeStyle = "#222";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(80, 566); ctx.lineTo(1000, 566); ctx.stroke();

  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 22px monospace";
  ctx.textAlign = "center";
  ctx.fillText("INSTEAD YOU COULD HAVE...", 540, 616);

  if (arMetric) {
    const cleanMsg = arMetric.message.replace(/<[^>]*>/g, "");
    ctx.fillStyle = "#e8e8e0";
    ctx.font = "32px Arial";
    ctx.textAlign = "center";
    const words = cleanMsg.split(" ");
    let line = "";
    let y = 672;
    for (let w of words) {
      const test = line + w + " ";
      if (ctx.measureText(test).width > 880 && line !== "") {
        ctx.fillText(line.trim(), 540, y);
        line = w + " ";
        y += 46;
      } else {
        line = test;
      }
    }
    if (line.trim()) ctx.fillText(line.trim(), 540, y);
  }

  ctx.fillStyle = "#333";
  ctx.font = "22px monospace";
  ctx.textAlign = "center";
  ctx.fillText(r.career_commute_years + " years of your career lost to commuting", 540, 960);

  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, 1070, 1080, 10);

  showShareCardModal(canvas);
}

function showShareCardModal(canvas) {
  const existing = document.getElementById("shareCardModal");
  if (existing) existing.remove();

  const modal = document.createElement("div");
  modal.id = "shareCardModal";
  modal.style.cssText = "position:fixed;inset:0;background:rgba(0,0,0,0.92);display:flex;flex-direction:column;align-items:center;justify-content:center;z-index:10000;padding:20px;overflow-y:auto;";

  const img = document.createElement("img");
  img.src = canvas.toDataURL("image/png");
  img.style.cssText = "max-width:min(440px,88vw);border:2px solid #f0e040;display:block;";

  const label = document.createElement("p");
  label.textContent = "DOWNLOAD AND SHARE ANYWHERE";
  label.style.cssText = "font-family:monospace;font-size:10px;color:#444;letter-spacing:0.2em;margin:16px 0 12px;";

  const btnRow = document.createElement("div");
  btnRow.style.cssText = "display:grid;grid-template-columns:1fr 1fr;gap:10px;width:min(440px,88vw);";

  function makeBtn(text, bg, color, border, fn) {
    const b = document.createElement("button");
    b.textContent = text;
    b.style.cssText = "background:" + bg + ";color:" + color + ";border:" + border + ";padding:14px 8px;font-family:monospace;font-size:12px;cursor:pointer;letter-spacing:0.08em;";
    b.onclick = fn;
    return b;
  }

  const dlBtn = document.createElement("a");
  dlBtn.href = canvas.toDataURL("image/png");
  dlBtn.download = "my-travel-tax.png";
  dlBtn.textContent = "Download Image";
  dlBtn.style.cssText = "background:#f0e040;color:#000;padding:14px 8px;font-family:monospace;font-size:12px;text-decoration:none;letter-spacing:0.08em;text-align:center;grid-column:span 2;";

  const igBtn = makeBtn("Instagram", "#E1306C", "#fff", "none", () => {
    const a = document.createElement("a");
    a.href = canvas.toDataURL("image/png");
    a.download = "my-travel-tax.png";
    a.click();
    setTimeout(() => showToast("Image downloaded — open Instagram and add to your Story"), 600);
  });

  const twtBtn = makeBtn("X Twitter", "#000", "#fff", "1px solid #333", () => {
    window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(buildShareMessage(true)), "_blank");
  });

  const waBtn = makeBtn("WhatsApp", "#25D366", "#fff", "none", () => {
    window.open("https://wa.me/?text=" + encodeURIComponent(buildShareMessage(false)), "_blank");
  });

  const liBtn = makeBtn("LinkedIn", "#0077B5", "#fff", "none", () => {
    window.open("https://www.linkedin.com/sharing/share-offsite/?url=" + encodeURIComponent("https://traveltax.co.uk"), "_blank");
  });

  const closeBtn = makeBtn("Close", "transparent", "#666", "1px solid #333", () => modal.remove());
  closeBtn.style.gridColumn = "span 2";

  modal.onclick = (e) => { if (e.target === modal) modal.remove(); };
  btnRow.append(dlBtn, igBtn, twtBtn, waBtn, liBtn, closeBtn);
  modal.append(img, label, btnRow);
  document.body.appendChild(modal);
}

function fmt(n) { return "£" + Math.round(n).toLocaleString("en-GB"); }

function showToast(msg) {
  const existing = document.querySelector(".toast");
  if (existing) existing.remove();
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = msg;
  toast.style.cssText = "position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#f0e040;color:#0a0a0a;padding:12px 24px;font-family:monospace;font-size:12px;letter-spacing:0.08em;z-index:9999;max-width:400px;text-align:center;";
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3500);
}
JSEOF

echo "Done"
echo ""
echo "Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Clean rewrite fix all issues' && git push"
