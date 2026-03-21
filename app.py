import os
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

# Real-world UK MPG averages by car type
CAR_MPG = {
    "petrol":   40,
    "diesel":   40,
    "petrol_diesel": 40,
    "electric": None,
}

def calculate_commute(data):
    salary = float(data.get("salary", 0))
    days_per_week = float(data.get("days_per_week", 5))
    weeks_per_year = float(data.get("weeks_per_year", 48))
    commute_minutes_one_way = float(data.get("commute_minutes", 0))
    transport_cost_daily = float(data.get("transport_cost_daily", 0))
    transport_type = data.get("transport_type", "public")
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
        depreciation_yearly = 0
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
        "miles_yearly": 0,
        "distance_fact": _distance_fact(commute_hours_yearly, days_per_week, weeks_per_year),
    }


def _distance_fact(hours, days_per_week, weeks_per_year):
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
