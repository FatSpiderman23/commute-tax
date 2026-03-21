#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🔧 Applying fixes..."

# 1. Fix HTML - remove miles field, fix car types for desktop
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/templates/index.html'
with open(path, 'r') as f:
    content = f.read()

# Fix desktop car type toggle - just one petrol
content = content.replace(
    '<button class="car-type-btn active" data-car="petrol_avg">⛽ Petrol</button>\n            <button class="car-type-btn" data-car="diesel">🛢 Diesel</button>\n            <button class="car-type-btn" data-car="electric">⚡ Electric</button>',
    '<button class="car-type-btn active" data-car="petrol">⛽ Petrol</button>\n            <button class="car-type-btn" data-car="diesel">🛢 Diesel</button>\n            <button class="car-type-btn" data-car="electric">⚡ Electric</button>'
)

# Fix mobile car type toggle
content = content.replace(
    '<button class="car-type-btn active" data-car="petrol_avg">Petrol</button>\n            <button class="car-type-btn" data-car="diesel">Diesel</button>\n            <button class="car-type-btn" data-car="electric">Electric</button>',
    '<button class="car-type-btn active" data-car="petrol">Petrol</button>\n            <button class="car-type-btn" data-car="diesel">Diesel</button>\n            <button class="car-type-btn" data-car="electric">Electric</button>'
)

# Remove desktop one-way distance field
content = content.replace(
    '''          <div class="field-group">
            <label for="miles_one_way">One-Way Distance (miles)</label>
            <div class="input-wrap">
              <input type="number" id="miles_one_way" placeholder="15" min="0" />
            </div>
          </div>
          <div class="field-group">
            <label>What Type of Car?</label>''',
    '''          <div class="field-group">
            <label>What Type of Car?</label>'''
)

# Remove mobile one-way distance field
content = content.replace(
    '''        <div class="field-group">
          <label for="m_miles">One-Way Distance (miles)</label>
          <div class="input-wrap">
            <input type="number" id="m_miles" placeholder="15" min="0" inputmode="numeric" />
          </div>
        </div>
        <div class="field-group">
          <label>What Type of Car?</label>''',
    '''        <div class="field-group">
          <label>What Type of Car?</label>'''
)

with open(path, 'w') as f:
    f.write(content)
print("Done index.html")
PYEOF

# 2. Fix app.py - remove miles dependency, use fuel spend only
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

# Update CAR_MPG to have single petrol
content = content.replace(
    '''CAR_MPG = {
    "petrol_avg":   40,
    "petrol_large": 28,
    "diesel":       50,
    "electric":     None,  # handled separately
}''',
    '''CAR_MPG = {
    "petrol":  40,
    "diesel":  50,
    "electric": None,
}'''
)

# Remove miles_one_way from calculation, base car cost purely on fuel spend
old_car_calc = '''    if transport_type == "car":
        is_ev = car_type == "electric"
        fuel_spend = float(data.get("fuel_spend", 0))
        fuel_period = data.get("fuel_period", "weekly")
        if is_ev:
            fuel_cost_daily = miles_one_way * 2 * 0.25 * 0.28
        elif fuel_spend > 0:
            # User told us their weekly or monthly spend
            if fuel_period == "weekly":
                fuel_cost_daily = fuel_spend / 5
            else:
                fuel_cost_daily = (fuel_spend * 12) / (weeks_per_year * days_per_week) if days_per_week > 0 else 0
        else:
            mpg = CAR_MPG.get(car_type, 40)
            litres_per_mile = 1 / (mpg * 4.546)
            fuel_cost_daily = miles_one_way * 2 * litres_per_mile * 1.55

        miles_yearly = miles_one_way * 2 * working_days
        if miles_yearly <= 10000:
            depreciation_yearly = miles_yearly * 0.45
        else:
            depreciation_yearly = (10000 * 0.45) + ((miles_yearly - 10000) * 0.25)

        transport_cost_yearly = (fuel_cost_daily * working_days) + depreciation_yearly
        transport_cost_daily_val = transport_cost_yearly / working_days if working_days > 0 else 0'''

new_car_calc = '''    if transport_type == "car":
        is_ev = car_type == "electric"
        fuel_spend = float(data.get("fuel_spend", 0))
        fuel_period = data.get("fuel_period", "weekly")

        if is_ev:
            # EV flat rate: average UK EV costs ~£3/day to charge for typical commute
            fuel_cost_daily = 3.00
        elif fuel_spend > 0:
            if fuel_period == "weekly":
                fuel_cost_daily = fuel_spend / days_per_week if days_per_week > 0 else fuel_spend / 5
            else:
                fuel_cost_daily = (fuel_spend / 4.33) / days_per_week if days_per_week > 0 else fuel_spend / 21
        else:
            fuel_cost_daily = 10.0  # sensible default if nothing entered

        transport_cost_yearly = fuel_cost_daily * working_days
        transport_cost_daily_val = fuel_cost_daily
        depreciation_yearly = 0'''

content = content.replace(old_car_calc, new_car_calc)

# Remove miles_one_way from inputs since we no longer use it
content = content.replace(
    "    miles_one_way = float(data.get('miles_one_way', 0))\n",
    ""
)
content = content.replace(
    '    miles_one_way = float(data.get("miles_one_way", 0))\n',
    ""
)

# Fix miles_yearly reference
content = content.replace(
    '        "miles_yearly": round(miles_yearly) if transport_type == "car" else 0,',
    '        "miles_yearly": 0,'
)

with open(path, 'w') as f:
    f.write(content)
print("Done app.py")
PYEOF

# 3. Fix share card text sizes and colours
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/static/js/main.js'
with open(path, 'r') as f:
    content = f.read()

# Fix traveltax.co.uk label - bigger and brighter
content = content.replace(
    "ctx.fillStyle = \"#3a3a3a\";\n  ctx.font = \"400 20px monospace\";\n  ctx.fillText(\"traveltax.co.uk\", 80, 116);",
    "ctx.fillStyle = \"#888888\";\n  ctx.font = \"400 24px monospace\";\n  ctx.fillText(\"traveltax.co.uk\", 80, 116);"
)

# Fix stat labels (TRANSPORT/YR etc) - bigger and brighter
content = content.replace(
    "    ctx.fillStyle = \"#444444\";\n    ctx.font = \"400 16px monospace\";\n    ctx.fillText(stat.label, x, statsY + 32);",
    "    ctx.fillStyle = \"#888888\";\n    ctx.font = \"400 20px monospace\";\n    ctx.fillText(stat.label, x, statsY + 36);"
)

# Fix petrol_avg references in JS
content = content.replace('"petrol_avg"', '"petrol"')
content = content.replace("'petrol_avg'", '"petrol"')

# Fix selectedCarType default
content = content.replace(
    'let selectedCarType = "petrol_avg";',
    'let selectedCarType = "petrol";'
)

with open(path, 'w') as f:
    f.write(content)
print("Done main.js")
PYEOF

echo ""
echo "All done! Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Remove miles, fix car options, fix share card text' && git push"
