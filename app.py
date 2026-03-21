import os
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

# Real-world UK MPG averages by car type
CAR_MPG = {
    "petrol_avg":   40,
    "petrol_large": 28,
    "diesel":       50,
    "electric":     None,  # handled separately
}

def calculate_commute(data):
    salary = float(data.get("salary", 0))
    days_per_week = float(data.get("days_per_week", 5))
    weeks_per_year = float(data.get("weeks_per_year", 48))
    commute_minutes_one_way = float(data.get("commute_minutes", 0))
    transport_cost_daily = float(data.get("transport_cost_daily", 0))
    transport_type = data.get("transport_type", "public")
    miles_one_way = float(data.get("miles_one_way", 0))
    fuel_cost_per_litre = float(data.get("fuel_cost_per_litre", 1.55))
    car_type = data.get("car_type", "petrol_avg")

    working_days = days_per_week * weeks_per_year
    commute_minutes_daily = commute_minutes_one_way * 2
    commute_hours_yearly = (commute_minutes_daily * working_days) / 60
    commute_days_yearly = commute_hours_yearly / 24
    waking_hours_per_year = 16 * 365
    pct_waking_life = (commute_hours_yearly / waking_hours_per_year) * 100
    hourly_rate = salary / (weeks_per_year * days_per_week * 8) if salary > 0 else 0
    time_cost_yearly = commute_hours_yearly * hourly_rate

    if transport_type == "car":
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
        transport_cost_daily_val = transport_cost_yearly / working_days if working_days > 0 else 0
    else:
        transport_cost_yearly = transport_cost_daily * working_days
        depreciation_yearly = 0
        miles_yearly = 0
        transport_cost_daily_val = transport_cost_daily

    total_yearly_cost = transport_cost_yearly + time_cost_yearly
    career_commute_years = ((commute_hours_yearly * 37) / 24) / 365

    return {
        "commute_minutes_daily": round(commute_minutes_daily),
        "commute_hours_yearly": round(commute_hours_yearly, 1),
        "commute_days_yearly": round(commute_days_yearly, 1),
        "pct_waking_life": round(pct_waking_life, 1),
        "hourly_rate": round(hourly_rate, 2),
        "time_cost_yearly": round(time_cost_yearly),
        "transport_cost_yearly": round(transport_cost_yearly),
        "transport_cost_monthly": round(transport_cost_yearly / 12),
        "transport_cost_daily": round(transport_cost_daily_val, 2),
        "total_yearly_cost": round(total_yearly_cost),
        "total_monthly_cost": round(total_yearly_cost / 12),
        "remote_savings_transport": round(transport_cost_yearly),
        "remote_savings_time_hours": round(commute_hours_yearly, 1),
        "remote_savings_time_value": round(time_cost_yearly),
        "remote_total_value": round(transport_cost_yearly + time_cost_yearly),
        "career_commute_years": round(career_commute_years, 1),
        "working_days": round(working_days),
        "miles_yearly": round(miles_yearly) if transport_type == "car" else 0,
    }


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/guide")
def guide():
    return render_template("guide.html")


@app.route("/privacy")
def privacy():
    return render_template("privacy.html")


@app.route("/calculate", methods=["POST"])
def calculate():
    data = request.get_json()
    result = calculate_commute(data)
    return jsonify(result)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
