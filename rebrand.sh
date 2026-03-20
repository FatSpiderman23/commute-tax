#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "✈️ Rebranding to The Travel Tax..."

# ============================================================
# Update index.html — all branding references
# ============================================================
sed -i '' \
  -e 's/The Commute Tax/The Travel Tax/g' \
  -e 's/THE COMMUTE TAX/THE TRAVEL TAX/g' \
  -e 's/Commute Tax/Travel Tax/g' \
  -e 's/commute tax/travel tax/g' \
  -e 's/thecommutetax\.co\.uk/traveltax.co.uk/g' \
  -e 's/Calculate My Commute Tax/Calculate My Travel Tax/g' \
  -e 's/CALCULATE MY COMMUTE TAX/CALCULATE MY TRAVEL TAX/g' \
  -e 's|The<br><em>Commute</em><br>Tax\.|The<br><em>Travel</em><br>Tax.|g' \
  -e 's/YOUR ANNUAL COMMUTE TAX/YOUR ANNUAL TRAVEL TAX/g' \
  -e 's/HOW MUCH OF YOUR LIFE IS THE TRAIN STEALING?/HOW MUCH IS YOUR TRAVEL REALLY COSTING YOU?/g' \
  -e 's/handing over to your commute every year/handing over to travel every year/g' \
  -e 's/© 2025 The Commute Tax/© 2025 The Travel Tax/g' \
  "$TARGET/templates/index.html"

# ============================================================
# Update main.js — all URL and branding references
# ============================================================
sed -i '' \
  -e 's/thecommutetax\.co\.uk/traveltax.co.uk/g' \
  -e 's/The Commute Tax/The Travel Tax/g' \
  -e 's/THE COMMUTE TAX/THE TRAVEL TAX/g' \
  -e 's/Commute Tax/Travel Tax/g' \
  -e 's/Calculate my Commute Tax/Calculate my Travel Tax/g' \
  "$TARGET/static/js/main.js"

echo ""
echo "✅ Rebranded to The Travel Tax!"
echo ""
echo "Now push to GitHub:"
echo "  cd ~/Documents/Commute\ Tax"
echo "  git add ."
echo "  git commit -m 'Rebrand to The Travel Tax'"
echo "  git push"
