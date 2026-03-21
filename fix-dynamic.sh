#!/bin/bash
TARGET=~/Documents/Commute\ Tax

python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/static/js/main.js'
with open(path, 'r') as f:
    content = f.read()

# Fix 1: Share card career line - make it use canvas variable not hardcoded
# Find the career line in generateShareCard and fix it
old_career = '  ctx.fillText(r.career_commute_years + " years of your career lost to commuting", W / 2, 958);'
new_career = '  ctx.fillText(lastResult.career_commute_years + " years of your career lost to commuting", W / 2, 958);'
content = content.replace(old_career, new_career)

# Fix 2: Make sure bestMetric uses lastResult not stale arMetric
old_best = '''  let bestMetric = arMetric;
  if (window._arMetrics && window._arMetrics.length > 0) {
    const hrs = r.commute_hours_yearly;'''
new_best = '''  let bestMetric = null;
  if (window._arMetrics && window._arMetrics.length > 0) {
    const hrs = lastResult.commute_hours_yearly;'''
content = content.replace(old_best, new_best)

# Fix 3: Fix fallback references from arMetric to first _arMetrics item
content = content.replace(
    'bestMetric = window._arMetrics.find(m => m.id === "spanish") || arMetric;',
    'bestMetric = window._arMetrics.find(m => m.id === "spanish") || window._arMetrics[0];'
)
content = content.replace(
    'bestMetric = window._arMetrics.find(m => m.id === "coding") || arMetric;',
    'bestMetric = window._arMetrics.find(m => m.id === "coding") || window._arMetrics[0];'
)
content = content.replace(
    'bestMetric = window._arMetrics.find(m => m.id === "books") || arMetric;',
    'bestMetric = window._arMetrics.find(m => m.id === "books") || window._arMetrics[0];'
)
content = content.replace(
    'bestMetric = window._arMetrics.find(m => m.id === "marathon") || arMetric;',
    'bestMetric = window._arMetrics.find(m => m.id === "marathon") || window._arMetrics[0];'
)
content = content.replace(
    'bestMetric = window._arMetrics.find(m => m.id === "gym") || arMetric;',
    'bestMetric = window._arMetrics.find(m => m.id === "gym") || window._arMetrics[0];'
)

# Fix 4: Final fallback if bestMetric still null
content = content.replace(
    '  if (bestMetric) {\n    const cleanMsg = bestMetric.message.replace(/<[^>]*>/g, "");',
    '  if (!bestMetric && window._arMetrics) bestMetric = window._arMetrics[0];\n  if (bestMetric) {\n    const cleanMsg = bestMetric.message.replace(/<[^>]*>/g, "");'
)

# Fix 5: Mobile calculate button - find runMobileCalculation and check it exists
# The issue is the button calls runMobileCalculation but it might not be defined yet
# Move the function definition check
if 'async function runMobileCalculation' not in content:
    print("ERROR: runMobileCalculation not found!")
else:
    print("runMobileCalculation found OK")

# Fix 6: Make sure mobile button onclick is wired correctly
# Check if mCalculateBtn has event listener vs onclick
if 'mCalculateBtn' in content:
    # Add DOMContentLoaded listener for mobile button as backup
    old_mobile_init = "document.addEventListener(\"DOMContentLoaded\", () => {\n  // Mobile slider sync"
    new_mobile_init = """document.addEventListener("DOMContentLoaded", () => {
  // Wire mobile calculate button
  const mCalcBtn = document.getElementById("mCalculateBtn");
  if (mCalcBtn) {
    mCalcBtn.addEventListener("click", runMobileCalculation);
  }
  // Mobile slider sync"""
    content = content.replace(old_mobile_init, new_mobile_init)
    print("Mobile button listener added")

# Fix 7: Cache bust
import time
v = str(int(time.time()))

with open(path, 'w') as f:
    f.write(content)
print("Done main.js")
PYEOF

# Cache bust the script tag
python3 << 'PYEOF'
import re, time
path = '/Users/ss/Documents/Commute Tax/templates/index.html'
with open(path, 'r') as f:
    content = f.read()
v = str(int(time.time()))
content = re.sub(
    r'<script src="/static/js/main\.js[^"]*"></script>',
    '<script src="/static/js/main.js?v=' + v + '"></script>',
    content
)
with open(path, 'w') as f:
    f.write(content)
print("Cache bust: v=" + v)
PYEOF

echo ""
echo "Done! Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Fix share card dynamic content and mobile button' && git push"
