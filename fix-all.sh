#!/bin/bash
TARGET=~/Documents/Commute\ Tax

python3 << 'PYEOF'
import re, time

# ── 1. Rewrite generateShareCard in main.js ──────────────────────────────────
path = '/Users/ss/Documents/Commute Tax/static/js/main.js'
with open(path, 'r') as f:
    content = f.read()

# Find start and end of generateShareCard
start = content.find('function generateShareCard()')
end = content.find('\nfunction showShareCardModal(')
if start == -1 or end == -1:
    print("ERROR: could not find generateShareCard boundaries")
    print("start:", start, "end:", end)
    exit(1)

new_func = r"""function generateShareCard() {
  if (!lastResult) { showToast("Calculate first!"); return; }

  const r = lastResult;
  const hrs = r.commute_hours_yearly;

  // Build fresh AR message based on actual hours
  function getCardFact() {
    if (hrs >= 500) return "You could have completed a full coding bootcamp and be job-ready as a developer.";
    if (hrs >= 300) return "You could have read " + Math.floor(hrs / 8) + " books — more than one every single month.";
    if (hrs >= 120) return "You could have trained for and run a full marathon. Every. Single. Year.";
    if (hrs >= 60)  return "You could have watched Breaking Bad " + Math.floor(hrs / 62) + " times from start to finish.";
    return "You spent " + Math.round(hrs) + " gym sessions commuting. That is " + Math.round(hrs / 48) + " sessions a week.";
  }

  const cardFact = getCardFact();
  const careerYears = r.career_commute_years;
  const careerLine = careerYears + " years of your career lost to commuting";

  const canvas = document.createElement("canvas");
  canvas.width = 1080;
  canvas.height = 1080;
  const ctx = canvas.getContext("2d");
  const W = 1080;
  const H = 1080;

  // ── Background ──
  ctx.fillStyle = "#0a0a0a";
  ctx.fillRect(0, 0, W, H);

  // Grid
  ctx.strokeStyle = "#141414";
  ctx.lineWidth = 1;
  for (let x = 0; x <= W; x += 108) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, H); ctx.stroke(); }
  for (let y = 0; y <= H; y += 108) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(W, y); ctx.stroke(); }

  // Top bar
  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, 0, W, 10);

  // Logo
  ctx.textAlign = "left";
  ctx.textBaseline = "alphabetic";
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 44px Arial";
  ctx.fillText("TRAVEL TAX", 80, 90);
  ctx.fillStyle = "#888";
  ctx.font = "24px Arial";
  ctx.fillText("traveltax.co.uk", 80, 124);

  // Divider
  ctx.strokeStyle = "#222";
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(80, 148); ctx.lineTo(W - 80, 148); ctx.stroke();

  // Main cost
  const totalCost = "\u00A3" + Math.round(r.total_yearly_cost).toLocaleString("en-GB");
  ctx.textAlign = "center";
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 128px Arial";
  ctx.fillText(totalCost, W / 2, 318);

  // Subtitle
  ctx.fillStyle = "#555";
  ctx.font = "22px Arial";
  ctx.fillText("YOUR ANNUAL TRAVEL TAX", W / 2, 358);

  // Divider
  ctx.strokeStyle = "#222";
  ctx.beginPath(); ctx.moveTo(80, 396); ctx.lineTo(W - 80, 396); ctx.stroke();

  // 3 stats
  const stats = [
    { label: "TRANSPORT/YR", value: "\u00A3" + Math.round(r.transport_cost_yearly).toLocaleString("en-GB") },
    { label: "HOURS LOST/YR", value: r.commute_hours_yearly + "h" },
    { label: "LIFE STOLEN",   value: r.pct_waking_life + "%" },
  ];
  const sx = [W / 2 - 300, W / 2, W / 2 + 300];

  ctx.strokeStyle = "#222";
  ctx.beginPath(); ctx.moveTo(W / 2 - 150, 414); ctx.lineTo(W / 2 - 150, 548); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(W / 2 + 150, 414); ctx.lineTo(W / 2 + 150, 548); ctx.stroke();

  stats.forEach((s, i) => {
    ctx.fillStyle = "#fff";
    ctx.font = "bold 54px Arial";
    ctx.textAlign = "center";
    ctx.fillText(s.value, sx[i], 494);
    ctx.fillStyle = "#888";
    ctx.font = "20px Arial";
    ctx.fillText(s.label, sx[i], 530);
  });

  // Divider
  ctx.strokeStyle = "#222";
  ctx.beginPath(); ctx.moveTo(80, 570); ctx.lineTo(W - 80, 570); ctx.stroke();

  // AR header
  ctx.fillStyle = "#f0e040";
  ctx.font = "bold 22px Arial";
  ctx.textAlign = "center";
  ctx.fillText("INSTEAD YOU COULD HAVE...", W / 2, 618);

  // AR fact — dynamic, word wrapped
  ctx.fillStyle = "#e8e8e0";
  ctx.font = "34px Arial";
  ctx.textAlign = "center";
  const words = cardFact.split(" ");
  let line = "";
  let ty = 672;
  for (let w of words) {
    const test = line + w + " ";
    if (ctx.measureText(test).width > 880 && line !== "") {
      ctx.fillText(line.trim(), W / 2, ty);
      line = w + " ";
      ty += 48;
      if (ty > 830) break;
    } else {
      line = test;
    }
  }
  if (line.trim() && ty <= 830) ctx.fillText(line.trim(), W / 2, ty);

  // Career line — dynamic from lastResult
  ctx.fillStyle = "#555";
  ctx.font = "22px Arial";
  ctx.textAlign = "center";
  ctx.fillText(careerLine, W / 2, 960);

  // Bottom bar
  ctx.fillStyle = "#f0e040";
  ctx.fillRect(0, H - 10, W, 10);

  showShareCardModal(canvas);
}
"""

content = content[:start] + new_func + content[end:]

# ── 2. Cache bust ─────────────────────────────────────────────────────────────
v = str(int(time.time()))
with open(path, 'w') as f:
    f.write(content)
print("Done main.js - generateShareCard rewritten")

# ── 3. Fix index.html ─────────────────────────────────────────────────────────
path2 = '/Users/ss/Documents/Commute Tax/templates/index.html'
with open(path2, 'r') as f:
    html = f.read()

# Make miles optional on desktop
html = html.replace(
    '<label for="miles_one_way">One-Way Distance (miles)</label>\n            <div class="input-wrap">\n              <input type="number" id="miles_one_way" placeholder="15" min="0" />',
    '<label for="miles_one_way">One-Way Distance — optional (miles)</label>\n            <div class="input-wrap">\n              <input type="number" id="miles_one_way" placeholder="Leave blank if unsure" min="0" />'
)

# Make miles optional on mobile
html = html.replace(
    '<label for="m_miles">One-Way Distance (miles)</label>\n          <div class="input-wrap">\n            <input type="number" id="m_miles" placeholder="15" min="0" inputmode="numeric" />',
    '<label for="m_miles">One-Way Distance — optional (miles)</label>\n          <div class="input-wrap">\n            <input type="number" id="m_miles" placeholder="Leave blank if unsure" min="0" inputmode="numeric" />'
)

# Cache bust script tag
html = re.sub(
    r'<script src="/static/js/main\.js[^"]*"></script>',
    '<script src="/static/js/main.js?v=' + v + '"></script>',
    html
)

with open(path2, 'w') as f:
    f.write(html)
print("Done index.html")

# ── 4. Fix app.py — combine petrol+diesel, add distance fun fact ──────────────
path3 = '/Users/ss/Documents/Commute Tax/app.py'
with open(path3, 'r') as f:
    app = f.read()

# Combine petrol and diesel into one option
app = app.replace(
    '''CAR_MPG = {
    "petrol":  40,
    "diesel":  50,
    "electric": None,
}''',
    '''CAR_MPG = {
    "petrol":   40,
    "diesel":   40,
    "petrol_diesel": 40,
    "electric": None,
}'''
)

# Add distance fun fact to results
old_return = '        "miles_yearly": 0,'
new_return = '''        "miles_yearly": 0,
        "distance_fact": _distance_fact(commute_hours_yearly, days_per_week, weeks_per_year),'''
app = app.replace(old_return, new_return)

# Add distance fact function before the routes
if 'def _distance_fact' not in app:
    app = app.replace(
        '@app.route("/")',
        '''def _distance_fact(hours, days_per_week, weeks_per_year):
    working_days = days_per_week * weeks_per_year
    # Assume average 30mph commute speed
    avg_speed_mph = 30
    total_miles = hours * avg_speed_mph
    moon_miles = 238855
    earth_circumference = 24901
    if total_miles >= moon_miles:
        times = round(total_miles / moon_miles, 1)
        return "You could have travelled to the moon " + str(times) + "x"
    elif total_miles >= earth_circumference:
        times = round(total_miles / earth_circumference, 1)
        return "You could have circled the Earth " + str(times) + "x"
    elif total_miles >= 1000:
        return "You travelled ~" + str(round(total_miles)) + " miles commuting — London to Moscow and back"
    else:
        return "You travelled ~" + str(round(total_miles)) + " miles commuting this year"


@app.route("/")'''
    )

with open(path3, 'w') as f:
    f.write(app)
print("Done app.py")
PYEOF

echo ""
echo "Done! Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Fix share card, distance fun fact, optional miles' && git push"
