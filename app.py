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
    hourly_rate = salary / (weeks_per_year * 5 * 8) if salary > 0 else 0
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
        "distance_facts": _distance_fact(float(data.get("miles_one_way", 0)), days_per_week, weeks_per_year) if float(data.get("miles_one_way", 0)) > 0 else [],
    }


def _distance_fact(miles_one_way, days_per_week, weeks_per_year):
    total_miles = round(miles_one_way * 2 * days_per_week * weeks_per_year)
    moon_miles = 238855
    earth_circumference = 24901
    london_sydney = 10573
    london_ny = 3459
    london_tokyo = 5944
    facts = []
    if total_miles >= moon_miles:
        times = round(total_miles / moon_miles, 1)
        facts.append("Far enough to reach the moon " + str(times) + "x over")
    if total_miles >= earth_circumference:
        times = round(total_miles / earth_circumference, 1)
        facts.append("Could have circled the Earth " + str(times) + " times")
    if total_miles >= london_sydney * 2:
        times = round(total_miles / (london_sydney * 2), 1)
        facts.append("Could have flown London to Sydney " + str(times) + "x return")
    if total_miles >= london_tokyo * 2:
        times = round(total_miles / (london_tokyo * 2), 1)
        facts.append("Could have flown London to Tokyo " + str(times) + "x return")
    if total_miles >= london_ny * 2:
        times = round(total_miles / (london_ny * 2), 1)
        facts.append("Could have flown London to New York " + str(times) + "x return")
    if total_miles >= 2000:
        facts.append("Further than London to Cairo and back")
    if not facts:
        facts.append("Travelled " + str(total_miles) + " miles commuting")
    # Return all facts so JS can rotate them
    return facts


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



# =============================================
# SEO DATA
# =============================================

CITIES = {
    "london": {
        "name": "London",
        "avg_commute_mins": 74,
        "avg_daily_cost": 14.80,
        "avg_salary": 42000,
        "zones": "Zone 1-3 Travelcard",
        "popular_routes": ["Reading to London", "Brighton to London", "Guildford to London", "St Albans to London"],
        "description": "London commuters face the highest commute costs in the UK, with the average worker spending over £3,500/year on transport alone.",
        "monthly_cost": 290,
        "yearly_cost": 3480,
    },
    "manchester": {
        "name": "Manchester",
        "avg_commute_mins": 58,
        "avg_daily_cost": 9.20,
        "avg_salary": 32000,
        "zones": "Metrolink and Northern Rail",
        "popular_routes": ["Bolton to Manchester", "Stockport to Manchester", "Salford to Manchester"],
        "description": "Manchester commuters benefit from the Metrolink network but face rising rail costs from surrounding towns.",
        "monthly_cost": 184,
        "yearly_cost": 2208,
    },
    "birmingham": {
        "name": "Birmingham",
        "avg_commute_mins": 55,
        "avg_daily_cost": 8.40,
        "avg_salary": 30000,
        "zones": "West Midlands Rail",
        "popular_routes": ["Coventry to Birmingham", "Wolverhampton to Birmingham", "Solihull to Birmingham"],
        "description": "Birmingham commuters have seen costs rise steadily, with West Midlands Rail fares increasing year on year.",
        "monthly_cost": 168,
        "yearly_cost": 2016,
    },
    "leeds": {
        "name": "Leeds",
        "avg_commute_mins": 52,
        "avg_daily_cost": 7.80,
        "avg_salary": 29000,
        "zones": "West Yorkshire rail network",
        "popular_routes": ["Bradford to Leeds", "York to Leeds", "Harrogate to Leeds"],
        "description": "Leeds commuters face growing costs as housing prices push workers further from the city centre.",
        "monthly_cost": 156,
        "yearly_cost": 1872,
    },
    "edinburgh": {
        "name": "Edinburgh",
        "avg_commute_mins": 56,
        "avg_daily_cost": 9.80,
        "avg_salary": 33000,
        "zones": "ScotRail network",
        "popular_routes": ["Glasgow to Edinburgh", "Livingston to Edinburgh", "Falkirk to Edinburgh"],
        "description": "Edinburgh commuters pay some of the highest costs relative to local salaries in Scotland.",
        "monthly_cost": 196,
        "yearly_cost": 2352,
    },
    "glasgow": {
        "name": "Glasgow",
        "avg_commute_mins": 50,
        "avg_daily_cost": 8.60,
        "avg_salary": 30000,
        "zones": "SPT and ScotRail",
        "popular_routes": ["Paisley to Glasgow", "Hamilton to Glasgow", "Motherwell to Glasgow"],
        "description": "Glasgow commuters benefit from the SPT subway but face rising costs on longer rail commutes.",
        "monthly_cost": 172,
        "yearly_cost": 2064,
    },
    "bristol": {
        "name": "Bristol",
        "avg_commute_mins": 54,
        "avg_daily_cost": 8.20,
        "avg_salary": 31000,
        "zones": "Great Western Railway",
        "popular_routes": ["Bath to Bristol", "Cardiff to Bristol", "Weston-super-Mare to Bristol"],
        "description": "Bristol commuters face unique challenges with limited rail options and heavy road congestion.",
        "monthly_cost": 164,
        "yearly_cost": 1968,
    },
    "liverpool": {
        "name": "Liverpool",
        "avg_commute_mins": 48,
        "avg_daily_cost": 7.20,
        "avg_salary": 28000,
        "zones": "Merseyrail network",
        "popular_routes": ["Wirral to Liverpool", "Southport to Liverpool", "Chester to Liverpool"],
        "description": "Liverpool benefits from the Merseyrail network, one of the most used commuter rail networks outside London.",
        "monthly_cost": 144,
        "yearly_cost": 1728,
    },
    "nottingham": {
        "name": "Nottingham",
        "avg_commute_mins": 46,
        "avg_daily_cost": 6.80,
        "avg_salary": 27000,
        "zones": "East Midlands Railway",
        "popular_routes": ["Derby to Nottingham", "Leicester to Nottingham", "Loughborough to Nottingham"],
        "description": "Nottingham commuters have access to one of the best tram networks outside London.",
        "monthly_cost": 136,
        "yearly_cost": 1632,
    },
    "sheffield": {
        "name": "Sheffield",
        "avg_commute_mins": 49,
        "avg_daily_cost": 7.40,
        "avg_salary": 28000,
        "zones": "South Yorkshire rail",
        "popular_routes": ["Rotherham to Sheffield", "Barnsley to Sheffield", "Chesterfield to Sheffield"],
        "description": "Sheffield commuters use the Supertram network alongside Northern Rail services.",
        "monthly_cost": 148,
        "yearly_cost": 1776,
    },
}

BLOG_POSTS = [
    {
        "slug": "is-my-commute-worth-it",
        "title": "Is My Commute Worth It? How to Calculate the True Cost",
        "description": "Most UK workers underestimate their commute cost by 50%. Here is how to calculate the real financial and time impact of your daily commute.",
        "keywords": "is my commute worth it, commute cost calculator, should I work from home",
    },
    {
        "slug": "hybrid-working-savings",
        "title": "How Much Does Hybrid Working Save You? The Complete UK Guide",
        "description": "Switching from 5 days to 3 days in the office could save the average UK worker over £2,000 a year. Find out exactly how much hybrid working saves you.",
        "keywords": "hybrid working savings, work from home savings, hybrid commute cost",
    },
    {
        "slug": "uk-commute-cost-2025",
        "title": "UK Commute Costs 2025: What Are You Really Paying?",
        "description": "UK commute costs have risen 40% since 2010. Here is a complete breakdown of what commuters are paying in 2025 by city, transport type and salary.",
        "keywords": "UK commute cost 2025, commuting costs UK, average commute cost",
    },
    {
        "slug": "railcard-worth-it",
        "title": "Is a Railcard Worth It? The Complete UK Guide for 2025",
        "description": "A Railcard costs £30 and saves 33% on rail fares. Here is exactly when a Railcard is worth it and which one to get.",
        "keywords": "is a railcard worth it, railcard savings, railcard 2025",
    },
    {
        "slug": "remote-vs-office-salary",
        "title": "Remote vs Office Job: Which Pays More After Commute Costs?",
        "description": "A remote job paying £5,000 less could actually be worth more than an office job once you factor in commute costs and time. Here is how to compare.",
        "keywords": "remote vs office salary, remote job worth it, commute cost salary",
    },
]


@app.route("/commute-cost/<city_slug>")
def city_page(city_slug):
    city = CITIES.get(city_slug)
    if not city:
        return "Page not found", 404
    return render_template("city.html", city=city, slug=city_slug, all_cities=CITIES)


@app.route("/blog/<post_slug>")
def blog_post(post_slug):
    post = next((p for p in BLOG_POSTS if p["slug"] == post_slug), None)
    if not post:
        return "Page not found", 404
    return render_template("blog_post.html", post=post, all_posts=BLOG_POSTS)


@app.route("/blog")
def blog_index():
    return render_template("blog_index.html", posts=BLOG_POSTS, cities=CITIES)


@app.route("/sitemap.xml")
def sitemap():
    from flask import Response
    import datetime
    today = datetime.date.today().isoformat()
    urls = [
        {"loc": "https://www.traveltax.co.uk/", "priority": "1.0", "changefreq": "weekly"},
        {"loc": "https://www.traveltax.co.uk/guide", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/blog", "priority": "0.8", "changefreq": "weekly"},
        {"loc": "https://www.traveltax.co.uk/take-home", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/compare-jobs", "priority": "0.9", "changefreq": "monthly"},
    ]
    for slug in CITIES:
        urls.append({"loc": f"https://www.traveltax.co.uk/commute-cost/{slug}", "priority": "0.8", "changefreq": "monthly"})
    for post in BLOG_POSTS:
        urls.append({"loc": f"https://www.traveltax.co.uk/blog/{post['slug']}", "priority": "0.7", "changefreq": "monthly"})

    xml = '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    for url in urls:
        xml += f"""
  <url>
    <loc>{url["loc"]}</loc>
    <lastmod>{today}</lastmod>
    <changefreq>{url["changefreq"]}</changefreq>
    <priority>{url["priority"]}</priority>
  </url>"""
    xml += "</urlset>"
    return Response(xml, mimetype="application/xml")


@app.route("/robots.txt")
def robots():
    from flask import Response
    txt = """User-agent: *
Allow: /
Sitemap: https://www.traveltax.co.uk/sitemap.xml"""
    return Response(txt, mimetype="text/plain")




@app.route("/google4897a903300840f0.html")
def google_verify():
    return "google-site-verification: google4897a903300840f0.html"


@app.route("/BingSiteAuth.xml")
def bing_verify():
    from flask import Response
    xml = '''<?xml version="1.0"?>
<users>
    <user>33E58A74CBE9401602924B227FAFAC98</user>
</users>'''
    return Response(xml, mimetype="application/xml")


# =============================================
# TOOL 2: TAKE HOME PAY CALCULATOR
# =============================================

def calculate_take_home(data):
    salary = float(data.get("salary", 0))
    student_loan = data.get("student_loan", "none")
    pension_pct = float(data.get("pension_pct", 0))
    blind = data.get("blind", False)

    # Personal allowance 2024/25
    personal_allowance = 12570
    if salary > 100000:
        taper = (salary - 100000) / 2
        personal_allowance = max(0, personal_allowance - taper)

    # Taxable income
    taxable = max(0, salary - personal_allowance)

    # Income tax bands 2024/25
    tax = 0
    basic_band = 37700
    higher_band = 125140 - 12570

    if taxable <= basic_band:
        tax = taxable * 0.20
    elif taxable <= higher_band:
        tax = basic_band * 0.20 + (taxable - basic_band) * 0.40
    else:
        tax = basic_band * 0.20 + (higher_band - basic_band) * 0.40 + (taxable - higher_band) * 0.45

    # National Insurance 2024/25
    ni = 0
    ni_threshold = 12570
    ni_upper = 50270
    if salary > ni_threshold:
        if salary <= ni_upper:
            ni = (salary - ni_threshold) * 0.08
        else:
            ni = (ni_upper - ni_threshold) * 0.08 + (salary - ni_upper) * 0.02

    # Student loan
    sl = 0
    if student_loan == "plan1":
        threshold = 22015
        if salary > threshold:
            sl = (salary - threshold) * 0.09
    elif student_loan == "plan2":
        threshold = 27295
        if salary > threshold:
            sl = (salary - threshold) * 0.09
    elif student_loan == "plan4":
        threshold = 27660
        if salary > threshold:
            sl = (salary - threshold) * 0.09
    elif student_loan == "plan5":
        threshold = 25000
        if salary > threshold:
            sl = (salary - threshold) * 0.06
    elif student_loan == "postgrad":
        threshold = 21000
        if salary > threshold:
            sl = (salary - threshold) * 0.06

    # Pension
    pension = salary * (pension_pct / 100)

    # Take home
    take_home_yearly = salary - tax - ni - sl - pension
    take_home_monthly = take_home_yearly / 12
    take_home_weekly = take_home_yearly / 52
    take_home_daily = take_home_yearly / 260

    # Effective tax rate
    total_deductions = tax + ni + sl + pension
    effective_rate = (total_deductions / salary * 100) if salary > 0 else 0

    return {
        "gross_yearly": round(salary),
        "gross_monthly": round(salary / 12),
        "take_home_yearly": round(take_home_yearly),
        "take_home_monthly": round(take_home_monthly),
        "take_home_weekly": round(take_home_weekly),
        "take_home_daily": round(take_home_daily),
        "income_tax": round(tax),
        "national_insurance": round(ni),
        "student_loan": round(sl),
        "pension": round(pension),
        "total_deductions": round(total_deductions),
        "effective_rate": round(effective_rate, 1),
        "personal_allowance": round(personal_allowance),
    }


@app.route("/take-home")
def take_home_page():
    return render_template("take_home.html")


@app.route("/calculate-take-home", methods=["POST"])
def calculate_take_home_route():
    data = request.get_json()
    result = calculate_take_home(data)
    return jsonify(result)


# =============================================
# EMAIL CAPTURE
# =============================================

@app.route("/subscribe", methods=["POST"])
def subscribe():
    import json
    import urllib.request
    import urllib.parse

    data = request.get_json()
    email = data.get("email", "").strip()
    results_summary = data.get("results_summary", "")

    if not email or "@" not in email:
        return jsonify({"success": False, "error": "Invalid email"})

    # Save to local file as backup
    import os
    subscribers_file = os.path.join(os.path.dirname(__file__), "subscribers.txt")
    with open(subscribers_file, "a") as f:
        f.write(f"{email},{results_summary}\n")

    # Mailchimp API integration
    # Replace these with your actual Mailchimp details
    MAILCHIMP_API_KEY = "YOUR_MAILCHIMP_API_KEY"
    MAILCHIMP_LIST_ID = "YOUR_MAILCHIMP_LIST_ID"
    MAILCHIMP_DC = "us1"  # datacenter from your API key e.g. us1, us2 etc

    if MAILCHIMP_API_KEY != "YOUR_MAILCHIMP_API_KEY":
        try:
            url = f"https://{MAILCHIMP_DC}.api.mailchimp.com/3.0/lists/{MAILCHIMP_LIST_ID}/members"
            payload = json.dumps({
                "email_address": email,
                "status": "subscribed",
                "merge_fields": {"RESULTS": results_summary}
            }).encode("utf-8")
            req = urllib.request.Request(url, data=payload, method="POST")
            req.add_header("Content-Type", "application/json")
            import base64
            credentials = base64.b64encode(f"anystring:{MAILCHIMP_API_KEY}".encode()).decode()
            req.add_header("Authorization", f"Basic {credentials}")
            urllib.request.urlopen(req)
        except Exception as e:
            pass  # Still saved locally

    return jsonify({"success": True})



# =============================================
# TOOL 3: JOB OFFER COMPARISON
# =============================================

def calculate_job_comparison(data):
    weeks = 48

    def calc_job(job):
        salary = float(job.get("salary", 0))
        bonus = float(job.get("bonus", 0))
        pension_pct = float(job.get("pension_pct", 0))
        holiday_days = float(job.get("holiday_days", 25))
        remote_days = float(job.get("remote_days", 0))
        commute_mins = float(job.get("commute_mins", 0))
        commute_cost_daily = float(job.get("commute_cost_daily", 0))
        culture_score = float(job.get("culture_score", 5))

        office_days = 5 - remote_days
        working_days = office_days * weeks

        # Take home (simplified)
        personal_allowance = 12570
        taxable = max(0, salary - personal_allowance)
        if taxable <= 37700:
            tax = taxable * 0.20
        elif taxable <= 112570:
            tax = 37700 * 0.20 + (taxable - 37700) * 0.40
        else:
            tax = 37700 * 0.20 + 74870 * 0.40 + (taxable - 112570) * 0.45

        ni = 0
        if salary > 12570:
            if salary <= 50270:
                ni = (salary - 12570) * 0.08
            else:
                ni = (50270 - 12570) * 0.08 + (salary - 50270) * 0.02

        pension = salary * (pension_pct / 100)
        take_home = salary - tax - ni - pension

        # Commute costs
        commute_cost_yearly = commute_cost_daily * working_days
        commute_hours_yearly = (commute_mins * 2 * working_days) / 60
        hourly_rate = salary / (weeks * 5 * 8) if salary > 0 else 0
        commute_time_value = commute_hours_yearly * hourly_rate

        # Total real value
        total_commute_cost = commute_cost_yearly + commute_time_value
        real_value = take_home + bonus - total_commute_cost

        # Holiday value
        daily_rate = salary / 260
        holiday_value = holiday_days * daily_rate

        # Remote value (time saved)
        remote_time_hours = remote_days * weeks * (commute_mins * 2 / 60)
        remote_time_value = remote_time_hours * hourly_rate

        # Culture adjusted value
        culture_multiplier = culture_score / 5
        happiness_adjusted = real_value * (0.7 + culture_multiplier * 0.3)

        return {
            "salary": round(salary),
            "bonus": round(bonus),
            "take_home": round(take_home),
            "take_home_monthly": round(take_home / 12),
            "pension": round(pension),
            "commute_cost_yearly": round(commute_cost_yearly),
            "commute_time_value": round(commute_time_value),
            "total_commute_cost": round(total_commute_cost),
            "real_value": round(real_value),
            "holiday_value": round(holiday_value),
            "remote_time_value": round(remote_time_value),
            "happiness_adjusted": round(happiness_adjusted),
            "commute_hours_yearly": round(commute_hours_yearly),
            "total_package": round(salary + bonus + pension + holiday_value),
        }

    job_a = calc_job(data.get("job_a", {}))
    job_b = calc_job(data.get("job_b", {}))

    diff = job_a["real_value"] - job_b["real_value"]
    winner = "A" if diff > 0 else "B"
    margin = abs(diff)

    return {
        "job_a": job_a,
        "job_b": job_b,
        "winner": winner,
        "margin": round(margin),
        "diff_take_home": round(job_a["take_home"] - job_b["take_home"]),
        "diff_commute": round(job_b["total_commute_cost"] - job_a["total_commute_cost"]),
        "diff_real_value": round(diff),
    }


@app.route("/compare-jobs")
def compare_jobs_page():
    return render_template("compare_jobs.html")


@app.route("/calculate-comparison", methods=["POST"])
def calculate_comparison():
    data = request.get_json()
    result = calculate_job_comparison(data)
    return jsonify(result)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
