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
        "slug": "uk-commute-cost-2026",
        "title": "UK Commute Costs 2026: What Are You Really Paying?",
        "description": "UK commute costs have risen 40% since 2010. Here is a complete breakdown of what commuters are paying in 2026 by city, transport type and salary.",
        "keywords": "UK commute cost 2026, commuting costs UK, average commute cost",
    },
    {
        "slug": "railcard-worth-it",
        "title": "Is a Railcard Worth It? The Complete UK Guide for 2026",
        "description": "A Railcard costs £30 and saves 33% on rail fares. Here is exactly when a Railcard is worth it and which one to get.",
        "keywords": "is a railcard worth it, railcard savings, railcard 2026",
    },
    {
        "slug": "remote-vs-office-salary",
        "title": "Remote vs Office Job: Which Pays More After Commute Costs?",
        "description": "A remote job paying £5,000 less could actually be worth more than an office job once you factor in commute costs and time. Here is how to compare.",
        "keywords": "remote vs office salary, remote job worth it, commute cost salary",
    },
]


@app.route("/commute-cost/<city_slug>", endpoint="city_page_old")
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
        {"loc": "https://www.traveltax.co.uk/salary", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/cost-of-living", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/press", "priority": "0.6", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/student-loan", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/pension-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/redundancy-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/maternity-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/tax-year-2026", "priority": "0.9", "changefreq": "weekly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/reading", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/brighton", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/guildford", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/oxford", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/cambridge", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/milton-keynes", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/doctor", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/lawyer", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/pilot", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/engineer", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/social-worker", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/student-loan", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/pension-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/redundancy-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/maternity-calculator", "priority": "0.9", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/tax-year-2026", "priority": "0.9", "changefreq": "weekly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/reading", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/brighton", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/guildford", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/oxford", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/cambridge", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/commute-cost/milton-keynes", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/doctor", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/lawyer", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/pilot", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/engineer", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/salary/social-worker", "priority": "0.8", "changefreq": "monthly"},
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



# =============================================
# SALARY BENCHMARK PAGES
# =============================================

SALARY_BENCHMARKS = {
    "nurse": {
        "title": "NHS Nurse",
        "salary_range": [24000, 40000],
        "avg_salary": 33000,
        "description": "NHS nurses in the UK earn between £24,000 and £40,000 depending on band and experience. Band 5 nurses start at £28,407, Band 6 at £35,392.",
        "keywords": "nurse salary UK, NHS nurse take home pay, nurse salary after tax",
        "sector": "Healthcare",
        "jobs": ["Staff Nurse", "Senior Nurse", "Charge Nurse", "Community Nurse"],
    },
    "teacher": {
        "title": "Teacher",
        "salary_range": [30000, 50000],
        "avg_salary": 38000,
        "description": "Teachers in England earn between £30,000 and £50,000. Newly qualified teachers start at £30,000 outside London, rising to £46,525 for experienced teachers.",
        "keywords": "teacher salary UK, teacher take home pay, teacher salary after tax",
        "sector": "Education",
        "jobs": ["NQT Teacher", "Main Scale Teacher", "Upper Pay Scale Teacher", "Head of Department"],
    },
    "software-developer": {
        "title": "Software Developer",
        "salary_range": [35000, 90000],
        "avg_salary": 55000,
        "description": "Software developers in the UK earn between £35,000 and £90,000+ depending on experience and location. London developers typically earn 20-30% more.",
        "keywords": "software developer salary UK, developer take home pay, software engineer salary after tax",
        "sector": "Technology",
        "jobs": ["Junior Developer", "Mid-level Developer", "Senior Developer", "Lead Developer"],
    },
    "accountant": {
        "title": "Accountant",
        "salary_range": [28000, 70000],
        "avg_salary": 42000,
        "description": "Accountants in the UK earn between £28,000 and £70,000. Newly qualified ACCA/CIMA accountants typically start at £35,000-£45,000.",
        "keywords": "accountant salary UK, accountant take home pay, accountant salary after tax",
        "sector": "Finance",
        "jobs": ["Assistant Accountant", "Management Accountant", "Financial Accountant", "Finance Manager"],
    },
    "police-officer": {
        "title": "Police Officer",
        "salary_range": [28000, 50000],
        "avg_salary": 38000,
        "description": "Police constables in England and Wales start at £28,551, rising to £43,032 with experience. Sergeants earn £46,277 to £48,231.",
        "keywords": "police officer salary UK, police take home pay, police salary after tax",
        "sector": "Public Sector",
        "jobs": ["Police Constable", "Detective Constable", "Sergeant", "Inspector"],
    },
    "marketing-manager": {
        "title": "Marketing Manager",
        "salary_range": [35000, 65000],
        "avg_salary": 45000,
        "description": "Marketing managers in the UK earn between £35,000 and £65,000. Digital marketing specialists and those in London command higher salaries.",
        "keywords": "marketing manager salary UK, marketing salary after tax UK",
        "sector": "Marketing",
        "jobs": ["Marketing Executive", "Marketing Manager", "Senior Marketing Manager", "Marketing Director"],
    },
    "project-manager": {
        "title": "Project Manager",
        "salary_range": [40000, 75000],
        "avg_salary": 52000,
        "description": "Project managers in the UK earn between £40,000 and £75,000. Those with PMP or PRINCE2 qualifications and experience in tech or construction earn more.",
        "keywords": "project manager salary UK, PM take home pay, project manager salary after tax",
        "sector": "Business",
        "jobs": ["Junior PM", "Project Manager", "Senior Project Manager", "Programme Manager"],
    },
    "electrician": {
        "title": "Electrician",
        "salary_range": [30000, 55000],
        "avg_salary": 38000,
        "description": "Electricians in the UK earn between £30,000 and £55,000. Self-employed electricians can earn significantly more. London rates are typically higher.",
        "keywords": "electrician salary UK, electrician take home pay, electrician earnings after tax",
        "sector": "Trades",
        "jobs": ["Apprentice Electrician", "Qualified Electrician", "Senior Electrician", "Electrical Contractor"],
    },
    "hr-manager": {
        "title": "HR Manager",
        "salary_range": [35000, 60000],
        "avg_salary": 45000,
        "description": "HR managers in the UK earn between £35,000 and £60,000. CIPD qualified HR professionals and those in larger organisations earn at the higher end.",
        "keywords": "HR manager salary UK, HR take home pay, human resources salary after tax",
        "sector": "Human Resources",
        "jobs": ["HR Advisor", "HR Manager", "Senior HR Manager", "HR Director"],
    },
    "data-analyst": {
        "title": "Data Analyst",
        "salary_range": [28000, 65000],
        "avg_salary": 42000,
        "description": "Data analysts in the UK earn between £28,000 and £65,000. Those with Python, SQL, and machine learning skills command higher salaries.",
        "keywords": "data analyst salary UK, data analyst take home pay, analyst salary after tax",
        "sector": "Technology",
        "jobs": ["Junior Data Analyst", "Data Analyst", "Senior Data Analyst", "Data Science Manager"],
    },
}

COST_OF_LIVING_CITIES = {
    "london": {
        "name": "London",
        "avg_rent_1bed": 1800,
        "avg_rent_2bed": 2400,
        "avg_grocery_month": 320,
        "avg_transport_month": 180,
        "avg_utilities_month": 120,
        "avg_eating_out": 15,
        "avg_salary": 42000,
        "description": "London is the most expensive city in the UK, with rent accounting for the largest portion of living costs.",
        "tips": ["Zone 2-3 offers better value than Zone 1", "Supermarket own-brands can save £80/month", "Annual Travelcard saves vs monthly"],
    },
    "manchester": {
        "name": "Manchester",
        "avg_rent_1bed": 950,
        "avg_rent_2bed": 1300,
        "avg_grocery_month": 260,
        "avg_transport_month": 90,
        "avg_utilities_month": 110,
        "avg_eating_out": 12,
        "avg_salary": 32000,
        "description": "Manchester offers a significantly lower cost of living than London while maintaining a vibrant city lifestyle.",
        "tips": ["Northern Quarter is trendy but pricier", "Salford offers cheaper rent close to city", "Metrolink is cost-effective for commuting"],
    },
    "birmingham": {
        "name": "Birmingham",
        "avg_rent_1bed": 850,
        "avg_rent_2bed": 1100,
        "avg_grocery_month": 250,
        "avg_transport_month": 85,
        "avg_utilities_month": 105,
        "avg_eating_out": 11,
        "avg_salary": 30000,
        "description": "Birmingham is one of the most affordable major UK cities, with rent costs roughly half those of London.",
        "tips": ["Jewellery Quarter offers good value", "Car ownership is more common than London", "Broad Street area is pricier"],
    },
    "edinburgh": {
        "name": "Edinburgh",
        "avg_rent_1bed": 1100,
        "avg_rent_2bed": 1500,
        "avg_grocery_month": 280,
        "avg_transport_month": 100,
        "avg_utilities_month": 115,
        "avg_eating_out": 13,
        "avg_salary": 33000,
        "description": "Edinburgh is Scotland's most expensive city, with costs rising significantly in recent years due to tourism and demand.",
        "tips": ["Leith offers better value than city centre", "Festival period drives up short-term rents", "Good public transport network"],
    },
    "bristol": {
        "name": "Bristol",
        "avg_rent_1bed": 1100,
        "avg_rent_2bed": 1450,
        "avg_grocery_month": 270,
        "avg_transport_month": 95,
        "avg_utilities_month": 110,
        "avg_eating_out": 13,
        "avg_salary": 31000,
        "description": "Bristol has seen rapid cost increases in recent years, driven by demand from London movers and a thriving tech sector.",
        "tips": ["South Bristol is cheaper than North", "Cycling infrastructure is excellent", "Bath is nearby but pricier"],
    },
    "leeds": {
        "name": "Leeds",
        "avg_rent_1bed": 850,
        "avg_rent_2bed": 1100,
        "avg_grocery_month": 250,
        "avg_transport_month": 80,
        "avg_utilities_month": 105,
        "avg_eating_out": 11,
        "avg_salary": 29000,
        "description": "Leeds offers excellent value for money with a thriving city centre, growing tech scene and significantly lower costs than London.",
        "tips": ["Headingley popular with young professionals", "Good rail links to Manchester and London", "Chapel Allerton is trendy but affordable"],
    },
}


@app.route("/salary/<job_slug>")
def salary_page(job_slug):
    job = SALARY_BENCHMARKS.get(job_slug)
    if not job:
        return "Page not found", 404
    # Pre-calculate take home for avg salary
    from flask import request as freq
    take_home_data = calculate_take_home({"salary": job["avg_salary"], "student_loan": "none", "pension_pct": 5})
    return render_template("salary_page.html", job=job, slug=job_slug,
                         take_home=take_home_data, all_jobs=SALARY_BENCHMARKS)


@app.route("/salary")
def salary_index():
    return render_template("salary_index.html", jobs=SALARY_BENCHMARKS)


@app.route("/cost-of-living/<city_slug>")
def cost_of_living_page(city_slug):
    city = COST_OF_LIVING_CITIES.get(city_slug)
    if not city:
        return "Page not found", 404
    monthly_total = city["avg_rent_1bed"] + city["avg_grocery_month"] + city["avg_transport_month"] + city["avg_utilities_month"]
    take_home = calculate_take_home({"salary": city["avg_salary"], "student_loan": "none", "pension_pct": 5})
    disposable = take_home["take_home_monthly"] - monthly_total
    return render_template("cost_of_living.html", city=city, slug=city_slug,
                         monthly_total=monthly_total, take_home=take_home,
                         disposable=disposable, all_cities=COST_OF_LIVING_CITIES)


@app.route("/cost-of-living")
def cost_of_living_index():
    return render_template("cost_of_living_index.html", cities=COST_OF_LIVING_CITIES)


@app.route("/press")
def press_page():
    return render_template("press.html")



# =============================================
# NEW SALARY PAGES
# =============================================

EXTRA_SALARY_BENCHMARKS = {
    "doctor": {
        "title": "Doctor (NHS)",
        "salary_range": [32000, 120000],
        "avg_salary": 65000,
        "description": "NHS doctors earn between £32,000 as a junior doctor and £120,000+ as a consultant. Foundation year doctors start at £32,398.",
        "keywords": "doctor salary UK, NHS doctor take home pay, doctor salary after tax",
        "sector": "Healthcare",
        "jobs": ["Foundation Year 1", "Foundation Year 2", "Core Trainee", "Specialty Registrar", "Consultant"],
    },
    "lawyer": {
        "title": "Lawyer / Solicitor",
        "salary_range": [30000, 120000],
        "avg_salary": 55000,
        "description": "Solicitors in the UK earn between £30,000 as a newly qualified and £120,000+ at Magic Circle firms. City lawyers command a significant premium.",
        "keywords": "lawyer salary UK, solicitor take home pay, lawyer salary after tax",
        "sector": "Legal",
        "jobs": ["Trainee Solicitor", "NQ Solicitor", "Associate", "Senior Associate", "Partner"],
    },
    "pilot": {
        "title": "Airline Pilot",
        "salary_range": [45000, 180000],
        "avg_salary": 90000,
        "description": "Airline pilots in the UK earn between £45,000 as a first officer and £180,000+ as a senior captain at a major carrier.",
        "keywords": "pilot salary UK, airline pilot take home pay, pilot salary after tax",
        "sector": "Aviation",
        "jobs": ["First Officer", "Senior First Officer", "Captain", "Senior Captain"],
    },
    "engineer": {
        "title": "Engineer",
        "salary_range": [28000, 75000],
        "avg_salary": 45000,
        "description": "Engineers in the UK earn between £28,000 and £75,000 depending on discipline and experience. Civil, mechanical, and electrical engineers are among the most common.",
        "keywords": "engineer salary UK, engineer take home pay, engineering salary after tax",
        "sector": "Engineering",
        "jobs": ["Graduate Engineer", "Junior Engineer", "Engineer", "Senior Engineer", "Principal Engineer"],
    },
    "social-worker": {
        "title": "Social Worker",
        "salary_range": [28000, 45000],
        "avg_salary": 35000,
        "description": "Social workers in the UK typically earn between £28,000 and £45,000. Newly qualified social workers start at around £28,000 rising with experience.",
        "keywords": "social worker salary UK, social worker take home pay, social work salary after tax",
        "sector": "Public Sector",
        "jobs": ["Newly Qualified Social Worker", "Social Worker", "Senior Social Worker", "Team Manager"],
    },
}

# Merge with existing benchmarks
SALARY_BENCHMARKS.update(EXTRA_SALARY_BENCHMARKS)

# =============================================
# COMMUTER TOWN PAGES
# =============================================

COMMUTER_TOWNS = {
    "reading": {
        "name": "Reading",
        "to_city": "London",
        "avg_commute_mins": 27,
        "avg_season_ticket": 5240,
        "avg_salary": 45000,
        "description": "Reading is one of the UK's most popular commuter towns, with fast trains to London Paddington taking as little as 25 minutes.",
        "train_operator": "Great Western Railway",
        "popular_for": ["Tech workers", "Finance professionals", "Consultants"],
    },
    "brighton": {
        "name": "Brighton",
        "to_city": "London",
        "avg_commute_mins": 52,
        "avg_season_ticket": 5760,
        "avg_salary": 42000,
        "description": "Brighton is a popular alternative to London living, but its commuters face some of the highest season ticket costs in the country.",
        "train_operator": "Southern / Thameslink",
        "popular_for": ["Creative professionals", "Tech workers", "Media"],
    },
    "guildford": {
        "name": "Guildford",
        "to_city": "London",
        "avg_commute_mins": 35,
        "avg_season_ticket": 4800,
        "avg_salary": 48000,
        "description": "Guildford offers a high quality of life and relatively fast trains to London Waterloo, making it a popular choice for families.",
        "train_operator": "South Western Railway",
        "popular_for": ["Families", "Finance professionals", "Senior managers"],
    },
    "oxford": {
        "name": "Oxford",
        "to_city": "London",
        "avg_commute_mins": 57,
        "avg_season_ticket": 7200,
        "avg_salary": 44000,
        "description": "Oxford commuters face long journey times and high fares to London Paddington, but benefit from Oxford's exceptional quality of life.",
        "train_operator": "Great Western Railway",
        "popular_for": ["Academia", "Tech workers", "Finance"],
    },
    "cambridge": {
        "name": "Cambridge",
        "to_city": "London",
        "avg_commute_mins": 48,
        "avg_season_ticket": 6100,
        "avg_salary": 46000,
        "description": "Cambridge is home to a thriving tech cluster but many residents commute to London, facing significant costs on the Kings Cross line.",
        "train_operator": "Thameslink / Greater Anglia",
        "popular_for": ["Tech workers", "Scientists", "Finance"],
    },
    "milton-keynes": {
        "name": "Milton Keynes",
        "to_city": "London",
        "avg_commute_mins": 35,
        "avg_season_ticket": 4900,
        "avg_salary": 40000,
        "description": "Milton Keynes offers affordable housing and fast trains to Euston, making it popular with London commuters seeking more space.",
        "train_operator": "Avanti West Coast / London Northwestern",
        "popular_for": ["Families", "Finance workers", "Logistics professionals"],
    },
}


@app.route("/commute-cost/commuter-towns")
def commuter_towns_index():
    return render_template("commuter_towns.html", towns=COMMUTER_TOWNS)


@app.route("/commute-cost/<town_slug>", endpoint="commuter_town_page")
def commuter_town_page(town_slug):
    # Check if it's a commuter town first
    town = COMMUTER_TOWNS.get(town_slug)
    if town:
        hourly = float(town["avg_salary"]) / (48 * 5 * 8)
        time_cost = round((town["avg_commute_mins"] * 2 * 48 * 5 / 60) * hourly)
        return render_template("commuter_town.html", town=town, slug=town_slug,
                             time_cost=time_cost, all_towns=COMMUTER_TOWNS)
    # Fall back to city page
    city = CITIES.get(town_slug)
    if city:
        return render_template("city.html", city=city, slug=town_slug, all_cities=CITIES)
    return "Page not found", 404


# =============================================
# CALCULATORS
# =============================================

def calculate_student_loan(data):
    salary = float(data.get("salary", 0))
    plan = data.get("plan", "plan2")
    balance = float(data.get("balance", 0))

    thresholds = {
        "plan1": {"threshold": 22015, "rate": 0.09, "interest": 0.065},
        "plan2": {"threshold": 27295, "rate": 0.09, "interest": 0.075},
        "plan4": {"threshold": 27660, "rate": 0.09, "interest": 0.065},
        "plan5": {"threshold": 25000, "rate": 0.06, "interest": 0.075},
        "postgrad": {"threshold": 21000, "rate": 0.06, "interest": 0.075},
    }

    p = thresholds.get(plan, thresholds["plan2"])
    yearly_repayment = max(0, (salary - p["threshold"]) * p["rate"]) if salary > p["threshold"] else 0
    monthly_repayment = yearly_repayment / 12
    interest_yearly = balance * p["interest"] if balance > 0 else 0
    net_balance_change = interest_yearly - yearly_repayment

    years_to_repay = None
    if yearly_repayment > interest_yearly and balance > 0:
        years_to_repay = round(balance / (yearly_repayment - interest_yearly), 1)

    write_off_years = {"plan1": 25, "plan2": 30, "plan4": 30, "plan5": 40, "postgrad": 30}
    write_off = write_off_years.get(plan, 30)

    return {
        "monthly_repayment": round(monthly_repayment),
        "yearly_repayment": round(yearly_repayment),
        "interest_yearly": round(interest_yearly),
        "net_balance_change": round(net_balance_change),
        "years_to_repay": years_to_repay,
        "write_off_years": write_off,
        "threshold": p["threshold"],
        "rate": int(p["rate"] * 100),
        "will_repay_before_writeoff": years_to_repay is not None and years_to_repay < write_off,
    }


def calculate_pension(data):
    current_age = int(data.get("current_age", 30))
    retirement_age = int(data.get("retirement_age", 67))
    salary = float(data.get("salary", 35000))
    contribution_pct = float(data.get("contribution_pct", 5))
    employer_pct = float(data.get("employer_pct", 3))
    current_pot = float(data.get("current_pot", 0))
    growth_rate = float(data.get("growth_rate", 5)) / 100

    years = retirement_age - current_age
    annual_contribution = salary * (contribution_pct + employer_pct) / 100
    monthly_contribution = annual_contribution / 12

    # Future value calculation
    future_value = current_pot * ((1 + growth_rate) ** years)
    future_value += annual_contribution * (((1 + growth_rate) ** years - 1) / growth_rate)

    monthly_income = future_value / (25 * 12)  # 4% drawdown rule
    state_pension = 11502  # 2024/25 full state pension
    total_monthly = monthly_income + (state_pension / 12)

    recommended_pot = salary * 25  # 25x salary rule
    on_track = future_value >= recommended_pot * 0.8

    return {
        "years_to_retirement": years,
        "projected_pot": round(future_value),
        "monthly_income": round(monthly_income),
        "total_monthly_with_state": round(total_monthly),
        "monthly_contribution": round(monthly_contribution),
        "annual_contribution": round(annual_contribution),
        "recommended_pot": round(recommended_pot),
        "on_track": on_track,
        "shortfall": round(max(0, recommended_pot - future_value)),
        "state_pension_monthly": round(state_pension / 12),
    }


def calculate_redundancy(data):
    age = int(data.get("age", 35))
    years_service = float(data.get("years_service", 5))
    weekly_pay = float(data.get("weekly_pay", 500))
    weekly_pay_capped = min(weekly_pay, 643)  # 2024/25 cap

    statutory_pay = 0
    for year in range(int(years_service)):
        current_age = age - year
        if current_age >= 41:
            statutory_pay += 1.5 * weekly_pay_capped
        elif current_age >= 22:
            statutory_pay += 1.0 * weekly_pay_capped
        else:
            statutory_pay += 0.5 * weekly_pay_capped

    statutory_pay = min(statutory_pay, 19290)  # 2024/25 max

    return {
        "statutory_pay": round(statutory_pay),
        "weekly_pay_used": round(weekly_pay_capped),
        "weekly_pay_capped": weekly_pay > 643,
        "max_statutory": 19290,
        "taxable_above": max(0, round(statutory_pay - 30000)),
        "tax_free": min(statutory_pay, 30000),
    }


def calculate_maternity(data):
    salary = float(data.get("salary", 35000))
    weeks = int(data.get("weeks", 39))

    weekly_salary = salary / 52
    smp_rate_enhanced = weekly_salary * 0.90  # First 6 weeks
    smp_rate_standard = min(184.03, weekly_salary * 0.90)  # Weeks 7-39 (2024/25 rate)

    week_6_total = smp_rate_enhanced * 6
    remaining_weeks = max(0, weeks - 6)
    remaining_total = smp_rate_standard * remaining_weeks

    total_smp = round(week_6_total + remaining_total)
    total_lost = round((salary / 52) * weeks - total_smp)

    return {
        "total_smp": total_smp,
        "weekly_first_6": round(smp_rate_enhanced),
        "weekly_after_6": round(smp_rate_standard),
        "total_income_lost": total_lost,
        "monthly_during_leave": round(total_smp / (weeks / 4.33)),
        "smp_weeks": weeks,
    }


@app.route("/student-loan")
def student_loan_page():
    return render_template("student_loan.html")


@app.route("/calculate-student-loan", methods=["POST"])
def calculate_student_loan_route():
    return jsonify(calculate_student_loan(request.get_json()))


@app.route("/pension-calculator")
def pension_calculator_page():
    return render_template("pension_calculator.html")


@app.route("/calculate-pension", methods=["POST"])
def calculate_pension_route():
    return jsonify(calculate_pension(request.get_json()))


@app.route("/redundancy-calculator")
def redundancy_calculator_page():
    return render_template("redundancy_calculator.html")


@app.route("/calculate-redundancy", methods=["POST"])
def calculate_redundancy_route():
    return jsonify(calculate_redundancy(request.get_json()))


@app.route("/maternity-calculator")
def maternity_calculator_page():
    return render_template("maternity_calculator.html")


@app.route("/calculate-maternity", methods=["POST"])
def calculate_maternity_route():
    return jsonify(calculate_maternity(request.get_json()))


@app.route("/tax-year-2026")
def tax_year_2026():
    return render_template("tax_year_2026.html")



@app.route("/tools")
def tools_page():
    all_jobs = {**SALARY_BENCHMARKS}
    return render_template("tools.html", jobs=all_jobs, cities=CITIES, col_cities=COST_OF_LIVING_CITIES)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
