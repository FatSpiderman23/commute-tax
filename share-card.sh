#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "🎨 Adding visual share card..."

cat >> "$TARGET/static/js/main.js" << 'JSEOF'

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
JSEOF

echo "✅ Share card added to main.js"

# Update the share buttons in index.html to add the visual card button
python3 << 'PYEOF'
import re
path = '/Users/ss/Documents/Commute Tax/templates/index.html'
with open(path, 'r') as f:
    content = f.read()

old = '<div class="share-btns-grid">'
new = '''<button class="generate-card-btn" onclick="generateShareCard()">🎨 Generate My Share Card</button>
            <div class="share-btns-grid">'''
content = content.replace(old, new, 1)

with open(path, 'w') as f:
    f.write(content)
print("✅ index.html updated")
PYEOF

# Add CSS for the generate button
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* === GENERATE SHARE CARD BUTTON === */
.generate-card-btn {
  width: 100%;
  padding: 16px;
  background: var(--accent);
  color: var(--black);
  border: none;
  font-family: var(--font-mono);
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  cursor: pointer;
  margin-bottom: 12px;
  transition: background 0.2s, transform 0.15s;
}
.generate-card-btn:hover { background: var(--white); transform: translateY(-1px); }
CSSEOF

echo "✅ CSS added"
echo ""
echo "Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add visual share card' && git push"
