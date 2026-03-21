#!/bin/bash
TARGET=~/Documents/Commute\ Tax

python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/static/js/main.js'
with open(path, 'r') as f:
    content = f.read()

# Find and replace the generateShareCard function
start = content.find('function generateShareCard()')
end = content.find('\nfunction showShareCardModal(')
if start == -1 or end == -1:
    print("ERROR: Could not find generateShareCard function")
    print("start:", start, "end:", end)
    exit(1)

new_func = '''function generateShareCard() {
  if (!lastResult) return;
  const canvas = document.createElement("canvas");
  const scale = 2; // retina quality — sharper text
  canvas.width = 1080 * scale;
  canvas.height = 1080 * scale;
  canvas.style.width = "1080px";
  canvas.style.height = "1080px";
  const ctx = canvas.getContext("2d");
  ctx.scale(scale, scale);
  const r = lastResult;
  const arMetric = window._arMetrics ? window._arMetrics[0] : null;
  const W = 1080;
  const H = 1080;

  // Background
  ctx.fillStyle = "#0a0a0a";
  ctx.fillRect(0, 0, W, H);

  // Subtle grid
  ctx.strokeStyle = "#141414";
  ctx.lineWidth = 1;
  for (let x = 0; x <= W; x += 108) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, H); ctx.stroke(); }
  for (let y = 0; y <= H; y += 108) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(W, y); ctx.stroke(); }

  // Top accent bar
  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, 0, W, 10);

  // Logo
  ctx.textAlign = "left";
  ctx.textBaseline = "alphabetic";
  ctx.fillStyle = "#f0e040";
  ctx.font = "700 42px monospace";
  ctx.fillText("TRAVEL TAX", 80, 86);
  ctx.fillStyle = "#3a3a3a";
  ctx.font = "400 20px monospace";
  ctx.fillText("traveltax.co.uk", 80, 116);

  // Divider below logo
  ctx.strokeStyle = "#1e1e1e";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(80, 136); ctx.lineTo(W - 80, 136); ctx.stroke();

  // Main cost number — centred
  const totalCost = "£" + Math.round(r.total_yearly_cost).toLocaleString("en-GB");
  ctx.textAlign = "center";
  ctx.textBaseline = "alphabetic";
  ctx.fillStyle = "#f0e040";
  ctx.font = "700 130px Arial";
  ctx.fillText(totalCost, W / 2, 310);

  // Subtitle below cost
  ctx.fillStyle = "#555555";
  ctx.font = "400 22px monospace";
  ctx.fillText("YOUR ANNUAL TRAVEL TAX", W / 2, 352);

  // Divider
  ctx.strokeStyle = "#1e1e1e";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(80, 390); ctx.lineTo(W - 80, 390); ctx.stroke();

  // 3 stats — evenly spaced, centred
  const statsY = 490;
  const statPositions = [W / 2 - 300, W / 2, W / 2 + 300];
  const stats = [
    { label: "TRANSPORT / YR", value: "£" + Math.round(r.transport_cost_yearly).toLocaleString("en-GB") },
    { label: "HOURS LOST / YR", value: r.commute_hours_yearly + "h" },
    { label: "LIFE STOLEN", value: r.pct_waking_life + "%" },
  ];

  // Vertical dividers between stats
  ctx.strokeStyle = "#1e1e1e";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(W / 2 - 150, 410); ctx.lineTo(W / 2 - 150, 540); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(W / 2 + 150, 410); ctx.lineTo(W / 2 + 150, 540); ctx.stroke();

  stats.forEach((stat, i) => {
    const x = statPositions[i];
    ctx.fillStyle = "#ffffff";
    ctx.font = "700 52px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "alphabetic";
    ctx.fillText(stat.value, x, statsY);
    ctx.fillStyle = "#444444";
    ctx.font = "400 16px monospace";
    ctx.fillText(stat.label, x, statsY + 32);
  });

  // Divider
  ctx.strokeStyle = "#1e1e1e";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(80, 568); ctx.lineTo(W - 80, 568); ctx.stroke();

  // AR section header
  ctx.fillStyle = "#f0e040";
  ctx.font = "700 20px monospace";
  ctx.textAlign = "center";
  ctx.textBaseline = "alphabetic";
  ctx.fillText("INSTEAD YOU COULD HAVE...", W / 2, 614);

  // AR message
  if (arMetric) {
    const cleanMsg = arMetric.message.replace(/<[^>]*>/g, "");
    ctx.fillStyle = "#cccccc";
    ctx.font = "400 30px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "alphabetic";

    // Word wrap
    const words = cleanMsg.split(" ");
    let line = "";
    let y = 666;
    const maxW = 860;
    for (let w of words) {
      const test = line + w + " ";
      if (ctx.measureText(test).width > maxW && line !== "") {
        ctx.fillText(line.trim(), W / 2, y);
        line = w + " ";
        y += 44;
        if (y > 820) break;
      } else {
        line = test;
      }
    }
    if (line.trim() && y <= 820) ctx.fillText(line.trim(), W / 2, y);
  }

  // Career line
  ctx.fillStyle = "#2a2a2a";
  ctx.font = "400 20px monospace";
  ctx.textAlign = "center";
  ctx.textBaseline = "alphabetic";
  ctx.fillText(r.career_commute_years + " years of your career lost to commuting", W / 2, 958);

  // Bottom accent bar
  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, H - 10, W, 10);

  showShareCardModal(canvas);
}
'''

content = content[:start] + new_func + content[end:]

with open(path, 'w') as f:
    f.write(content)
print("Done - share card function replaced")
PYEOF

echo "✅ Share card fixed"
echo ""
echo "Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Fix share card quality and layout' && git push"
