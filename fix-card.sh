#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "🎨 Fixing share card..."

python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/static/js/main.js'
with open(path, 'r') as f:
    content = f.read()

# Remove the shareAllAR button from renderAlternativeReality
content = content.replace(
    '''    <div class="ar-share-all">
      <button class="ar-share-all-btn" onclick="shareAllAR()">📤 Share my full Alternative Reality report</button>
    </div>''',
    ''
)

# Replace the entire generateShareCard and showShareCardModal functions
old_start = "// =============================================\n// VISUAL SHARE CARD (Spotify Wrapped style)"
old_end = "}"  # last closing brace of showShareCardModal

# Find and replace everything from generateShareCard to end of showShareCardModal
import re
pattern = r'// ={40,}\n// VISUAL SHARE CARD.*?(?=\n// =|\Z)'
new_code = '''// =============================================
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

  // Background
  ctx.fillStyle = "#0a0a0a";
  ctx.fillRect(0, 0, 1080, 1080);

  // Subtle grid
  ctx.strokeStyle = "#161616";
  ctx.lineWidth = 1;
  for (let x = 0; x < 1080; x += 108) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, 1080); ctx.stroke(); }
  for (let y = 0; y < 1080; y += 108) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(1080, y); ctx.stroke(); }

  // Top accent bar
  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, 0, 1080, 10);

  // Logo top left
  ctx.textAlign = "left";
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 38px monospace";
  ctx.fillText("TRAVEL TAX", 80, 90);
  ctx.fillStyle = "#444";
  ctx.font = "22px monospace";
  ctx.fillText("traveltax.co.uk", 80, 125);

  // Main cost — centred, large
  const totalCost = "\u00A3" + Math.round(r.total_yearly_cost).toLocaleString("en-GB");
  ctx.textAlign = "center";
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 160px Arial Black, Arial";
  ctx.fillText(totalCost, 540, 330);

  // Subheading
  ctx.fillStyle = "#666";
  ctx.font = "bold 26px monospace";
  ctx.fillText("YOUR ANNUAL TRAVEL TAX", 540, 375);

  // Thin divider
  ctx.strokeStyle = "#222";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(80, 415); ctx.lineTo(1000, 415); ctx.stroke();

  // 3 stat boxes
  const stats = [
    { label: "TRANSPORT/YR", value: "\u00A3" + Math.round(r.transport_cost_yearly).toLocaleString("en-GB") },
    { label: "HOURS LOST/YR", value: r.commute_hours_yearly + "h" },
    { label: "LIFE STOLEN", value: r.pct_waking_life + "%" },
  ];

  stats.forEach((stat, i) => {
    const x = 190 + i * 270;
    const y = 490;
    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 58px Arial Black, Arial";
    ctx.textAlign = "center";
    ctx.fillText(stat.value, x, y);
    ctx.fillStyle = "#444";
    ctx.font = "18px monospace";
    ctx.fillText(stat.label, x, y + 36);
  });

  // Divider
  ctx.strokeStyle = "#222";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(80, 570); ctx.lineTo(1000, 570); ctx.stroke();

  // Alternative reality section
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 24px monospace";
  ctx.textAlign = "center";
  ctx.fillText("INSTEAD YOU COULD HAVE...", 540, 625);

  if (arMetric) {
    const cleanMsg = arMetric.message.replace(/<[^>]*>/g, "");
    ctx.fillStyle = "#e8e8e0";
    ctx.font = "34px Arial";
    ctx.textAlign = "center";

    // Word wrap function
    function wrapText(text, maxWidth, x, startY, lineH) {
      const words = text.split(" ");
      let line = "";
      let y = startY;
      for (let w of words) {
        const test = line + w + " ";
        if (ctx.measureText(test).width > maxWidth && line !== "") {
          ctx.fillText(line.trim(), x, y);
          line = w + " ";
          y += lineH;
        } else {
          line = test;
        }
      }
      if (line.trim()) ctx.fillText(line.trim(), x, y);
      return y;
    }
    wrapText(cleanMsg, 880, 540, 680, 48);
  }

  // Career line at bottom
  ctx.fillStyle = "#333";
  ctx.font = "22px monospace";
  ctx.textAlign = "center";
  ctx.fillText(r.career_commute_years + " years of your career lost to commuting", 540, 960);

  // Bottom accent bar
  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, 1070, 1080, 10);

  showShareCardModal(canvas);
}

function showShareCardModal(canvas) {
  const existing = document.getElementById("shareCardModal");
  if (existing) existing.remove();

  const modal = document.createElement("div");
  modal.id = "shareCardModal";
  modal.style.cssText = "position:fixed;inset:0;background:rgba(0,0,0,0.9);display:flex;flex-direction:column;align-items:center;justify-content:center;z-index:10000;padding:20px;overflow-y:auto;";

  const img = document.createElement("img");
  img.src = canvas.toDataURL("image/png");
  img.style.cssText = "max-width:min(480px,90vw);border:2px solid #f0e040;display:block;";

  const label = document.createElement("p");
  label.textContent = "Download and share anywhere";
  label.style.cssText = "font-family:monospace;font-size:11px;color:#555;letter-spacing:0.15em;text-transform:uppercase;margin:16px 0 12px;";

  const btnRow = document.createElement("div");
  btnRow.style.cssText = "display:grid;grid-template-columns:1fr 1fr;gap:10px;width:min(480px,90vw);";

  function makeBtn(text, bg, color, border, fn) {
    const b = document.createElement("button");
    b.textContent = text;
    b.style.cssText = `background:${bg};color:${color};border:${border};padding:14px 8px;font-family:monospace;font-size:12px;cursor:pointer;letter-spacing:0.08em;transition:opacity 0.2s;`;
    b.onmouseenter = () => b.style.opacity = "0.8";
    b.onmouseleave = () => b.style.opacity = "1";
    b.onclick = fn;
    return b;
  }

  const dlBtn = document.createElement("a");
  dlBtn.href = canvas.toDataURL("image/png");
  dlBtn.download = "my-travel-tax.png";
  dlBtn.textContent = "⬇ Download PNG";
  dlBtn.style.cssText = "background:#f0e040;color:#000;padding:14px 8px;font-family:monospace;font-size:12px;text-decoration:none;letter-spacing:0.08em;text-align:center;grid-column:span 2;";

  const igBtn = makeBtn("📸 Instagram", "#E1306C", "#fff", "none", () => {
    // Download image then show instruction
    const a = document.createElement("a");
    a.href = canvas.toDataURL("image/png");
    a.download = "my-travel-tax.png";
    a.click();
    setTimeout(() => showToast("Image downloaded! Open Instagram and add it to your Story or post 📸"), 500);
  });

  const twtBtn = makeBtn("𝕏 Twitter", "#000", "#fff", "1px solid #333", () => {
    const text = "I spend " + lastResult.pct_waking_life + "% of my waking life commuting — that's \u00A3" + Math.round(lastResult.total_yearly_cost).toLocaleString("en-GB") + "/year I'll never get back. What's your Travel Tax? \uD83D\uDC47";
    window.open("https://twitter.com/intent/tweet?text=" + encodeURIComponent(text) + "&url=" + encodeURIComponent("https://traveltax.co.uk"), "_blank");
  });

  const waBtn = makeBtn("💬 WhatsApp", "#25D366", "#fff", "none", () => {
    window.open("https://wa.me/?text=" + encodeURIComponent(buildShareMessage(false)), "_blank");
  });

  const liBtn = makeBtn("in LinkedIn", "#0077B5", "#fff", "none", () => {
    window.open("https://www.linkedin.com/sharing/share-offsite/?url=" + encodeURIComponent("https://traveltax.co.uk"), "_blank");
  });

  const closeBtn = makeBtn("✕ Close", "transparent", "#666", "1px solid #333", () => modal.remove());
  closeBtn.style.cssText += "grid-column:span 2;";

  modal.onclick = (e) => { if (e.target === modal) modal.remove(); };

  btnRow.append(dlBtn, igBtn, twtBtn, waBtn, liBtn, closeBtn);
  modal.append(img, label, btnRow);
  document.body.appendChild(modal);
}
'''

content = re.sub(pattern, new_code.rstrip(), content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)
print("Done")
PYEOF

echo "✅ Share card fixed"
echo ""
echo "Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Fix share card layout and add Instagram' && git push"
