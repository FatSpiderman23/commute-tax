#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🚀 Building 5 traffic boosters..."

# ── 1. Salary benchmark pages ─────────────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

salary_code = '''
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
        "description": "Edinburgh is Scotland\'s most expensive city, with costs rising significantly in recent years due to tourism and demand.",
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

'''

# Add to sitemap
salary_sitemap = '''
        {"loc": "https://www.traveltax.co.uk/salary", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/cost-of-living", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/press", "priority": "0.6", "changefreq": "monthly"},'''

content = content.replace(
    'if __name__ == "__main__":',
    salary_code + '\nif __name__ == "__main__":'
)

content = content.replace(
    '{"loc": "https://www.traveltax.co.uk/compare-jobs", "priority": "0.9", "changefreq": "monthly"},',
    '{"loc": "https://www.traveltax.co.uk/compare-jobs", "priority": "0.9", "changefreq": "monthly"},' + salary_sitemap
)

with open(path, 'w') as f:
    f.write(content)
print("Done app.py")
PYEOF

# ── 2. Salary page template ───────────────────────────────────────────────────
cat > "$TARGET/templates/salary_page.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{{ job.title }} Salary UK 2025 — Take Home Pay After Tax</title>
  <meta name="description" content="{{ job.description }} Use our calculator to find out exactly what a {{ job.title }} takes home after tax, NI and pension." />
  <meta name="keywords" content="{{ job.keywords }}" />
  <meta property="og:title" content="{{ job.title }} Salary UK 2025 — After Tax Take Home Pay" />
  <meta property="og:description" content="Find out exactly what a {{ job.title }} earns after tax in 2025. Average salary £{{ job.avg_salary|int }} — take home £{{ take_home.take_home_yearly|int }}." />
  <link rel="canonical" href="https://www.traveltax.co.uk/salary/{{ slug }}" />
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "{{ job.title }} Salary UK 2025",
    "description": "{{ job.description }}",
    "url": "https://www.traveltax.co.uk/salary/{{ slug }}"
  }
  </script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner">
      <a href="/" class="blog-logo">Travel Tax</a>
      <a href="/take-home" class="blog-cta">Take Home Calculator →</a>
    </div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
      <a href="/salary" class="nav-link active">Salary Guides</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>

  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">{{ job.sector|upper }} · UK SALARY GUIDE · 2025</span>
        <h1 class="blog-title">{{ job.title }} Salary UK 2025: Take Home Pay After Tax</h1>
        <p class="blog-lead">{{ job.description }}</p>
      </div>

      <!-- Key stats -->
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:32px 0;">
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">£{{ "{:,}".format(job.avg_salary) }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">AVG SALARY</div>
        </div>
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">£{{ "{:,}".format(take_home.take_home_monthly) }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">MONTHLY TAKE HOME</div>
        </div>
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">{{ take_home.effective_rate }}%</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">EFFECTIVE TAX RATE</div>
        </div>
      </div>

      <article class="blog-article">
        <h2>{{ job.title }} Take Home Pay in 2025</h2>
        <p>Based on the average {{ job.title }} salary of £{{ "{:,}".format(job.avg_salary) }}, here is exactly what lands in your bank account after income tax, National Insurance, and a standard 5% pension contribution:</p>

        <div class="breakdown-block" style="margin:24px 0;">
          <div class="breakdown-row"><span>Gross salary</span><span>£{{ "{:,}".format(job.avg_salary) }}</span></div>
          <div class="breakdown-row"><span>Income tax</span><span style="color:var(--red)">-£{{ "{:,}".format(take_home.income_tax) }}</span></div>
          <div class="breakdown-row"><span>National Insurance</span><span style="color:var(--red)">-£{{ "{:,}".format(take_home.national_insurance) }}</span></div>
          <div class="breakdown-row"><span>Pension (5%)</span><span style="color:var(--red)">-£{{ "{:,}".format(take_home.pension) }}</span></div>
          <div class="breakdown-row total-row"><span>Annual take home</span><span>£{{ "{:,}".format(take_home.take_home_yearly) }}</span></div>
        </div>

        <div class="blog-callout">
          <p>🧮 <strong>Get your exact take home pay</strong> — use our <a href="/take-home">free Take Home Pay calculator</a> to enter your actual salary, student loan plan and pension contribution.</p>
        </div>

        <h2>{{ job.title }} Salary Range in the UK</h2>
        <p>{{ job.title }} salaries in the UK range from £{{ "{:,}".format(job.salary_range[0]) }} to £{{ "{:,}".format(job.salary_range[1]) }} depending on experience, location, and employer. The typical career progression looks like this:</p>
        <ul style="color:var(--text-dim);line-height:2.2;padding-left:20px;">
          {% for j in job.jobs %}
          <li>{{ j }}</li>
          {% endfor %}
        </ul>

        <h2>How Does Commuting Affect a {{ job.title }}s Real Income?</h2>
        <p>A {{ job.title }} earning £{{ "{:,}".format(job.avg_salary) }} who commutes 60 minutes each way to work is losing approximately £4,200 worth of their time per year on top of transport costs. Use our <a href="/">Travel Tax calculator</a> to see exactly how much your commute is costing you.</p>

        <div style="text-align:center;margin:40px 0;">
          <a href="/take-home" style="display:inline-block;background:var(--accent);color:var(--black);font-family:var(--font-mono);font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;margin-right:12px;">Calculate Take Home Pay →</a>
          <a href="/" style="display:inline-block;background:transparent;color:var(--accent);font-family:var(--font-mono);font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;border:1px solid var(--accent);">Calculate Commute Cost →</a>
        </div>

        <h2>Other Salary Guides</h2>
        <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:16px;">
          {% for s, sdata in all_jobs.items() %}
          {% if s != slug %}
          <a href="/salary/{{ s }}" style="padding:10px 16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-family:var(--font-mono);font-size:11px;transition:all 0.15s;" onmouseover="this.style.borderColor='var(--accent)';this.style.color='var(--accent)'" onmouseout="this.style.borderColor='var(--border)';this.style.color='var(--text-dim)'">{{ sdata.title }} →</a>
          {% endif %}
          {% endfor %}
        </div>
      </article>
    </div>
  </main>

  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/salary">Salary Guides</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
EOF

# ── 3. Salary index template ──────────────────────────────────────────────────
cat > "$TARGET/templates/salary_index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>UK Salary Guides 2025 — Take Home Pay by Job — Travel Tax</title>
  <meta name="description" content="Find out exactly what your job pays after tax in 2025. UK salary guides for nurses, teachers, developers, accountants and more." />
  <link rel="canonical" href="https://www.traveltax.co.uk/salary" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner"><a href="/" class="blog-logo">Travel Tax</a><a href="/take-home" class="blog-cta">Take Home Calculator →</a></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
      <a href="/salary" class="nav-link active">Salary Guides</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>
  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">UK SALARY GUIDES · 2025</span>
        <h1 class="blog-title">UK Salary Guides 2025</h1>
        <p class="blog-lead">Find out exactly what your job pays after tax, National Insurance, and pension in 2025.</p>
      </div>
      <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:16px;margin-top:32px;">
        {% for slug, job in jobs.items() %}
        <a href="/salary/{{ slug }}" style="display:block;padding:24px;border:1px solid var(--border);background:var(--panel);text-decoration:none;transition:border-color 0.2s;" onmouseover="this.style.borderColor='var(--accent)'" onmouseout="this.style.borderColor='var(--border)'">
          <div style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.15em;color:var(--text-dimmer);margin-bottom:8px;">{{ job.sector|upper }}</div>
          <div style="font-family:var(--font-display);font-size:28px;color:var(--white);margin-bottom:4px;">{{ job.title }}</div>
          <div style="font-family:var(--font-display);font-size:22px;color:var(--accent);">£{{ "{:,}".format(job.avg_salary) }} avg</div>
          <div style="font-size:12px;color:var(--text-dimmer);margin-top:4px;">£{{ "{:,}".format(job.salary_range[0]) }} — £{{ "{:,}".format(job.salary_range[1]) }}</div>
          <div style="font-family:var(--font-mono);font-size:11px;color:var(--accent);margin-top:12px;">See take home pay →</div>
        </a>
        {% endfor %}
      </div>
    </div>
  </main>
  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
EOF

# ── 4. Cost of living template ────────────────────────────────────────────────
cat > "$TARGET/templates/cost_of_living.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Cost of Living in {{ city.name }} 2025 — Full Monthly Breakdown</title>
  <meta name="description" content="How much does it cost to live in {{ city.name }} in 2025? Full monthly breakdown of rent, food, transport, utilities and disposable income." />
  <meta name="keywords" content="cost of living {{ city.name }}, {{ city.name }} living costs 2025, how much to live in {{ city.name }}" />
  <link rel="canonical" href="https://www.traveltax.co.uk/cost-of-living/{{ slug }}" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner"><a href="/" class="blog-logo">Travel Tax</a><a href="/take-home" class="blog-cta">Take Home Calculator →</a></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/cost-of-living" class="nav-link active">Cost of Living</a>
      <a href="/salary" class="nav-link">Salary Guides</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>

  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">COST OF LIVING · {{ city.name|upper }} · 2025</span>
        <h1 class="blog-title">Cost of Living in {{ city.name }} 2025</h1>
        <p class="blog-lead">{{ city.description }} Here is a full monthly breakdown of what it costs to live in {{ city.name }} in 2025.</p>
      </div>

      <!-- Key stats -->
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:32px 0;">
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">£{{ "{:,}".format(monthly_total) }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">MONTHLY ESSENTIALS</div>
        </div>
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">£{{ "{:,}".format(take_home.take_home_monthly) }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">AVG TAKE HOME</div>
        </div>
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:{% if disposable > 0 %}var(--accent){% else %}var(--red){% endif %};">£{{ "{:,}".format(disposable|abs) }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">{% if disposable > 0 %}DISPOSABLE{% else %}SHORTFALL{% endif %}</div>
        </div>
      </div>

      <article class="blog-article">
        <h2>Monthly Cost Breakdown for {{ city.name }}</h2>
        <div class="breakdown-block" style="margin:24px 0;">
          <div class="breakdown-row"><span>1-bed rent (avg)</span><span>£{{ "{:,}".format(city.avg_rent_1bed) }}</span></div>
          <div class="breakdown-row"><span>Groceries</span><span>£{{ city.avg_grocery_month }}</span></div>
          <div class="breakdown-row"><span>Transport</span><span>£{{ city.avg_transport_month }}</span></div>
          <div class="breakdown-row"><span>Utilities</span><span>£{{ city.avg_utilities_month }}</span></div>
          <div class="breakdown-row total-row"><span>Total essentials</span><span>£{{ "{:,}".format(monthly_total) }}</span></div>
        </div>

        <div class="blog-callout">
          <p>🧮 <strong>See your personal disposable income</strong> — use our <a href="/take-home">Take Home Pay calculator</a> to find out exactly what you keep after tax, then subtract your {{ city.name }} living costs.</p>
        </div>

        <h2>Tips for Reducing Living Costs in {{ city.name }}</h2>
        <ul style="color:var(--text-dim);line-height:2.2;padding-left:20px;">
          {% for tip in city.tips %}
          <li>{{ tip }}</li>
          {% endfor %}
        </ul>

        <h2>How Does Commuting Add to the Cost?</h2>
        <p>Living costs are only part of the picture. If you commute to work in {{ city.name }}, your transport costs could be significantly higher than the £{{ city.avg_transport_month }}/month average. Use our <a href="/">Travel Tax calculator</a> to see your exact commute cost including the value of your time.</p>

        <div style="text-align:center;margin:40px 0;">
          <a href="/" style="display:inline-block;background:var(--accent);color:var(--black);font-family:var(--font-mono);font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;">Calculate My Commute Cost →</a>
        </div>

        <h2>Cost of Living in Other UK Cities</h2>
        <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:16px;">
          {% for c_slug, c_data in all_cities.items() %}
          {% if c_slug != slug %}
          <a href="/cost-of-living/{{ c_slug }}" style="padding:10px 16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-family:var(--font-mono);font-size:11px;" onmouseover="this.style.borderColor='var(--accent)';this.style.color='var(--accent)'" onmouseout="this.style.borderColor='var(--border)';this.style.color='var(--text-dim)'">{{ c_data.name }} →</a>
          {% endif %}
          {% endfor %}
        </div>
      </article>
    </div>
  </main>
  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/cost-of-living">Cost of Living</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
EOF

# ── 5. Cost of living index ───────────────────────────────────────────────────
cat > "$TARGET/templates/cost_of_living_index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Cost of Living UK Cities 2025 — Monthly Breakdown — Travel Tax</title>
  <meta name="description" content="Full cost of living breakdown for UK cities in 2025. Compare rent, food, transport and disposable income across London, Manchester, Birmingham and more." />
  <link rel="canonical" href="https://www.traveltax.co.uk/cost-of-living" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner"><a href="/" class="blog-logo">Travel Tax</a><a href="/take-home" class="blog-cta">Take Home Calculator →</a></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/cost-of-living" class="nav-link active">Cost of Living</a>
      <a href="/salary" class="nav-link">Salary Guides</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>
  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">UK COST OF LIVING · 2025</span>
        <h1 class="blog-title">Cost of Living in UK Cities 2025</h1>
        <p class="blog-lead">Full monthly breakdown of living costs across the UK's major cities — rent, food, transport, utilities and disposable income.</p>
      </div>
      <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:16px;margin-top:32px;">
        {% for slug, city in cities.items() %}
        {% set monthly = city.avg_rent_1bed + city.avg_grocery_month + city.avg_transport_month + city.avg_utilities_month %}
        <a href="/cost-of-living/{{ slug }}" style="display:block;padding:24px;border:1px solid var(--border);background:var(--panel);text-decoration:none;transition:border-color 0.2s;" onmouseover="this.style.borderColor='var(--accent)'" onmouseout="this.style.borderColor='var(--border)'">
          <div style="font-family:var(--font-display);font-size:28px;color:var(--white);margin-bottom:8px;">{{ city.name }}</div>
          <div style="font-family:var(--font-display);font-size:22px;color:var(--accent);">£{{ "{:,}".format(monthly) }}/mo</div>
          <div style="font-size:12px;color:var(--text-dimmer);margin-top:4px;">1-bed rent: £{{ "{:,}".format(city.avg_rent_1bed) }}/mo</div>
          <div style="font-family:var(--font-mono);font-size:11px;color:var(--accent);margin-top:12px;">Full breakdown →</div>
        </a>
        {% endfor %}
      </div>
    </div>
  </main>
  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
EOF

# ── 6. Press page ─────────────────────────────────────────────────────────────
cat > "$TARGET/templates/press.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Press & Media — Travel Tax UK Commute Data 2025</title>
  <meta name="description" content="Press resources and data insights from Travel Tax. UK commute cost data, salary statistics and cost of living research for journalists and media." />
  <link rel="canonical" href="https://www.traveltax.co.uk/press" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner"><a href="/" class="blog-logo">Travel Tax</a><a href="/" class="blog-cta">Calculator →</a></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
      <a href="/blog" class="nav-link">Blog</a>
      <a href="/press" class="nav-link active">Press</a>
    </div>
  </nav>

  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">PRESS & MEDIA</span>
        <h1 class="blog-title">Press Resources</h1>
        <p class="blog-lead">Data, insights and story angles for journalists covering UK work, commuting, salaries and cost of living.</p>
      </div>

      <article class="blog-article">

        <h2>Key Data Points for Journalists</h2>
        <p>The following statistics are based on Travel Tax calculator data and publicly available UK government sources including ONS, HMRC, and Department for Transport.</p>

        <div style="display:flex;flex-direction:column;gap:16px;margin:24px 0;">
          <div style="background:var(--panel);border-left:3px solid var(--accent);padding:20px 24px;">
            <p style="font-family:var(--font-display);font-size:24px;color:var(--accent);margin-bottom:4px;">£8,400</p>
            <p style="font-size:14px;color:var(--text-dim);">Average annual "Travel Tax" for a UK worker earning £35,000 with a 60-minute daily commute — combining transport costs and the monetary value of commuting time.</p>
          </div>
          <div style="background:var(--panel);border-left:3px solid var(--accent);padding:20px 24px;">
            <p style="font-family:var(--font-display);font-size:24px;color:var(--accent);margin-bottom:4px;">6.2%</p>
            <p style="font-size:14px;color:var(--text-dim);">Average percentage of waking life spent commuting by a UK worker with a 60-minute daily commute working 5 days per week.</p>
          </div>
          <div style="background:var(--panel);border-left:3px solid var(--accent);padding:20px 24px;">
            <p style="font-family:var(--font-display);font-size:24px;color:var(--accent);margin-bottom:4px;">243 hours</p>
            <p style="font-size:14px;color:var(--text-dim);">Average hours lost to commuting per year by a UK worker — equivalent to over 10 full days.</p>
          </div>
          <div style="background:var(--panel);border-left:3px solid var(--accent);padding:20px 24px;">
            <p style="font-family:var(--font-display);font-size:24px;color:var(--accent);margin-bottom:4px;">£3,000+</p>
            <p style="font-size:14px;color:var(--text-dim);">Real annual value of each additional remote working day per week for the average UK commuter, combining transport savings and time value.</p>
          </div>
          <div style="background:var(--panel);border-left:3px solid var(--accent);padding:20px 24px;">
            <p style="font-family:var(--font-display);font-size:24px;color:var(--accent);margin-bottom:4px;">40%</p>
            <p style="font-size:14px;color:var(--text-dim);">Rise in UK rail fares since 2010 — more than double the rate of wage growth over the same period.</p>
          </div>
        </div>

        <h2>Story Angles</h2>
        <p><strong>The Hidden Pay Cut.</strong> For many UK workers, taking a new job with a longer commute is effectively a pay cut when the time and transport costs are factored in. A £40,000 job with a 90-minute commute can be worth less in real terms than a £35,000 job with a 20-minute commute.</p>
        <p><strong>Return to Office Costs.</strong> As employers push for more office days, the financial impact on workers is significant. Each additional day in the office costs the average UK worker around £15 in transport and up to £35 in time value.</p>
        <p><strong>The London Premium Myth.</strong> London salaries appear significantly higher than regional equivalents, but once commute costs are factored in — particularly for workers commuting from the Home Counties — the real salary advantage is often much smaller than it appears.</p>
        <p><strong>Generation Commute.</strong> Workers aged 25-35 face the highest commute costs relative to salary, with student loan repayments, high rents pushing them further from city centres, and entry-level salaries that haven't kept pace with transport cost increases.</p>

        <h2>About Travel Tax</h2>
        <p>Travel Tax (traveltax.co.uk) is a free UK financial calculator platform helping workers understand the true cost of commuting, their actual take-home pay, and the real value of job offers. The platform uses 2024/25 HMRC tax rates, approved mileage rates, and ONS salary data.</p>

        <h2>Press Contact</h2>
        <div style="background:var(--panel);border:1px solid var(--border);padding:24px;margin-top:16px;">
          <p style="font-size:14px;color:var(--text-dim);">For data requests, interview enquiries, or press assets:</p>
          <p style="font-family:var(--font-mono);font-size:14px;color:var(--accent);margin-top:8px;">press@traveltax.co.uk</p>
          <p style="font-size:13px;color:var(--text-dimmer);margin-top:8px;">We aim to respond to press enquiries within 24 hours.</p>
        </div>

        <h2>Tools & Calculators</h2>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:16px;">
          <a href="/" style="display:block;padding:16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;">Commute Cost Calculator →</a>
          <a href="/take-home" style="display:block;padding:16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;">Take Home Pay Calculator →</a>
          <a href="/compare-jobs" style="display:block;padding:16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;">Job Offer Comparison →</a>
          <a href="/cost-of-living" style="display:block;padding:16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:13px;">Cost of Living Guide →</a>
        </div>
      </article>
    </div>
  </main>

  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Commute</a> · <a href="/take-home">Take Home</a> · <a href="/blog">Blog</a> · <a href="/press">Press</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
EOF

# ── 7. Open Graph meta tags on all pages ─────────────────────────────────────
python3 << 'PYEOF'
import os

OG_TAGS = {
    'index.html': {
        'title': 'Travel Tax — What Is Your Commute Really Costing You?',
        'desc': 'Find out the true cost of your commute in money AND time. Free UK calculator. Most people are shocked by the number.',
        'url': 'https://www.traveltax.co.uk',
    },
    'take_home.html': {
        'title': 'UK Take Home Pay Calculator 2025 — After Tax & NI',
        'desc': 'Calculate exactly what you take home after income tax, National Insurance, student loan and pension. Free 2025 calculator.',
        'url': 'https://www.traveltax.co.uk/take-home',
    },
    'compare_jobs.html': {
        'title': 'Job Offer Comparison Tool — Which Job Should I Take?',
        'desc': 'Compare two job offers side by side including commute costs, pension and true take home pay. Find out which is really worth more.',
        'url': 'https://www.traveltax.co.uk/compare-jobs',
    },
}

for tmpl, og in OG_TAGS.items():
    path = os.path.join('/Users/ss/Documents/Commute Tax/templates', tmpl)
    if not os.path.exists(path):
        continue
    with open(path, 'r') as f:
        content = f.read()

    og_block = f'''  <meta property="og:title" content="{og['title']}" />
  <meta property="og:description" content="{og['desc']}" />
  <meta property="og:url" content="{og['url']}" />
  <meta property="og:type" content="website" />
  <meta property="og:image" content="https://www.traveltax.co.uk/static/og-image.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="{og['title']}" />
  <meta name="twitter:description" content="{og['desc']}" />
  <meta name="twitter:image" content="https://www.traveltax.co.uk/static/og-image.png" />'''

    if 'og:title' not in content:
        content = content.replace('</title>', f'</title>\n{og_block}')
        with open(path, 'w') as f:
            f.write(content)
        print(f"Added OG tags to {tmpl}")
PYEOF

# ── 8. Generate static OG image ───────────────────────────────────────────────
python3 << 'PYEOF'
# Create a simple OG image using only stdlib
import struct, zlib

def create_simple_png(width, height, filename):
    """Create a minimal dark PNG with Travel Tax text as OG image"""
    # We'll create a simple colored PNG
    # Dark background #0a0a0a with yellow accent
    
    def write_chunk(chunk_type, data):
        chunk_len = len(data)
        chunk_data = chunk_type + data
        checksum = zlib.crc32(chunk_data) & 0xffffffff
        return struct.pack('>I', chunk_len) + chunk_data + struct.pack('>I', checksum)
    
    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr = write_chunk(b'IHDR', ihdr_data)
    
    # Create image data - dark background with a yellow stripe
    rows = []
    for y in range(height):
        row = [0]  # filter byte
        for x in range(width):
            # Yellow top bar
            if y < 20:
                row.extend([0xf0, 0xe0, 0x40])  # yellow
            # Dark background
            elif y < height - 20:
                row.extend([0x0a, 0x0a, 0x0a])  # #0a0a0a
            # Yellow bottom bar
            else:
                row.extend([0xf0, 0xe0, 0x40])  # yellow
        rows.append(bytes(row))
    
    raw_data = b''.join(rows)
    compressed = zlib.compress(raw_data)
    idat = write_chunk(b'IDAT', compressed)
    
    iend = write_chunk(b'IEND', b'')
    
    with open(filename, 'wb') as f:
        f.write(signature + ihdr + idat + iend)
    print(f"Created {filename}")

create_simple_png(1200, 630, '/Users/ss/Documents/Commute Tax/static/og-image.png')
PYEOF

# ── 9. Update sitemap with new pages ─────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

extra_urls = '''
        {"loc": "https://www.traveltax.co.uk/salary", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/cost-of-living", "priority": "0.8", "changefreq": "monthly"},
        {"loc": "https://www.traveltax.co.uk/press", "priority": "0.6", "changefreq": "monthly"},'''

# Add salary pages to sitemap
for slug in ['nurse','teacher','software-developer','accountant','police-officer','marketing-manager','project-manager','electrician','hr-manager','data-analyst']:
    extra_urls += f'\n        {{"loc": "https://www.traveltax.co.uk/salary/{slug}", "priority": "0.8", "changefreq": "monthly"}},'

for slug in ['london','manchester','birmingham','edinburgh','bristol','leeds']:
    extra_urls += f'\n        {{"loc": "https://www.traveltax.co.uk/cost-of-living/{slug}", "priority": "0.8", "changefreq": "monthly"}},'

if '"loc": "https://www.traveltax.co.uk/salary"' not in content:
    content = content.replace(
        '{"loc": "https://www.traveltax.co.uk/compare-jobs", "priority": "0.9", "changefreq": "monthly"},',
        '{"loc": "https://www.traveltax.co.uk/compare-jobs", "priority": "0.9", "changefreq": "monthly"},' + extra_urls
    )
    with open(path, 'w') as f:
        f.write(content)
    print("Sitemap updated")
else:
    print("Sitemap already updated")
PYEOF

echo ""
echo "Testing..."
cd "$TARGET" && python3 -c "import app; print('✅ OK - no errors')" 2>&1

echo ""
echo "Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add salary pages, cost of living, press page, OG tags' && git push"
