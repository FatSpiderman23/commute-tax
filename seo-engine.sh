#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🚀 Building SEO engine..."

# ── 1. Update app.py with all SEO routes ─────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

seo_code = '''
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
    ]
    for slug in CITIES:
        urls.append({"loc": f"https://www.traveltax.co.uk/commute-cost/{slug}", "priority": "0.8", "changefreq": "monthly"})
    for post in BLOG_POSTS:
        urls.append({"loc": f"https://www.traveltax.co.uk/blog/{post['slug']}", "priority": "0.7", "changefreq": "monthly"})

    xml = \'\'\'<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\'\'\'
    for url in urls:
        xml += f"""
  <url>
    <loc>{url["loc"]}</loc>
    <lastmod>{today}</lastmod>
    <changefreq>{url["changefreq"]}</changefreq>
    <priority>{url["priority"]}</priority>
  </url>"""
    xml += "\n</urlset>"
    return Response(xml, mimetype="application/xml")


@app.route("/robots.txt")
def robots():
    from flask import Response
    txt = """User-agent: *
Allow: /
Sitemap: https://www.traveltax.co.uk/sitemap.xml"""
    return Response(txt, mimetype="text/plain")

'''

# Insert before if __name__
content = content.replace(
    'if __name__ == "__main__":',
    seo_code + '\nif __name__ == "__main__":'
)

with open(path, 'w') as f:
    f.write(content)
print("Done app.py")
PYEOF

# ── 2. City page template ─────────────────────────────────────────────────────
cat > "$TARGET/templates/city.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{{ city.name }} Commute Cost Calculator 2025 — Travel Tax</title>
  <meta name="description" content="How much does commuting to {{ city.name }} cost in 2025? The average {{ city.name }} commuter spends £{{ city.yearly_cost }}/year on transport alone. Calculate your personal commute cost." />
  <meta name="keywords" content="{{ city.name }} commute cost, commuting to {{ city.name }}, {{ city.name }} travel cost, {{ city.name }} commute calculator" />
  <meta property="og:title" content="{{ city.name }} Commute Cost 2025 — Travel Tax" />
  <meta property="og:description" content="The average {{ city.name }} commuter spends £{{ city.yearly_cost }}/year. Find out your true commute cost including time value." />
  <meta property="og:url" content="https://www.traveltax.co.uk/commute-cost/{{ slug }}" />
  <link rel="canonical" href="https://www.traveltax.co.uk/commute-cost/{{ slug }}" />
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "{{ city.name }} Commute Cost Calculator",
    "description": "{{ city.description }}",
    "url": "https://www.traveltax.co.uk/commute-cost/{{ slug }}",
    "mainEntity": {
      "@type": "SoftwareApplication",
      "name": "Travel Tax Calculator",
      "applicationCategory": "FinanceApplication",
      "offers": {"@type": "Offer", "price": "0", "priceCurrency": "GBP"}
    }
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
      <a href="/" class="blog-cta">Calculate Yours →</a>
    </div>
  </header>

  <main class="blog-main">
    <div class="blog-inner">

      <div class="blog-hero">
        <span class="blog-tag">COMMUTE COST GUIDE · {{ city.name|upper }} · 2025</span>
        <h1 class="blog-title">{{ city.name }} Commute Cost 2025: What Are You Really Paying?</h1>
        <p class="blog-lead">The average {{ city.name }} commuter spends <strong>£{{ city.yearly_cost }}/year</strong> on transport alone — and that is before counting the value of their time. Here is what commuting to {{ city.name }} is really costing you.</p>
        <div class="blog-meta"><span>Updated 2025</span><span>·</span><span>5 min read</span></div>
      </div>

      <!-- Key stats -->
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:32px 0;">
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">{{ city.avg_commute_mins }} min</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">AVG COMMUTE</div>
        </div>
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">£{{ city.yearly_cost }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">AVG YEARLY COST</div>
        </div>
        <div style="background:var(--panel);border:1px solid var(--border);padding:20px;text-align:center;">
          <div style="font-family:var(--font-display);font-size:36px;color:var(--accent);">£{{ city.monthly_cost }}</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);letter-spacing:0.15em;margin-top:4px;">AVG MONTHLY COST</div>
        </div>
      </div>

      <article class="blog-article">

        <h2>The True Cost of Commuting to {{ city.name }}</h2>
        <p>{{ city.description }} But the transport cost is only half the story. When you factor in the monetary value of the time you spend commuting — calculated at your hourly salary rate — the true annual cost of commuting to {{ city.name }} is significantly higher.</p>
        <p>For someone earning £{{ city.avg_salary|int }} per year with an average {{ city.avg_commute_mins }}-minute commute, the time cost alone adds up to over £{{ (city.avg_salary / 52 / 5 / 8 * city.avg_commute_mins / 30 * 2 * 48 * 5)|int }} per year. Combined with transport costs, the true annual commute tax for an average {{ city.name }} worker exceeds <strong>£{{ (city.yearly_cost + city.avg_salary / 52 / 5 / 8 * city.avg_commute_mins / 30 * 2 * 48 * 5)|int }}</strong>.</p>

        <div class="blog-callout">
          <p>🧮 <strong>Calculate your exact {{ city.name }} commute cost</strong> — including transport, time value, and life impact — using our free <a href="/">Travel Tax calculator</a>. Takes 60 seconds.</p>
        </div>

        <h2>Popular {{ city.name }} Commuter Routes</h2>
        <p>The {{ city.name }} commuter belt has grown significantly as housing prices push workers further from the city. The most common commuter routes into {{ city.name }} include:</p>
        <ul style="color:var(--text-dim);line-height:2;padding-left:20px;">
          {% for route in city.popular_routes %}
          <li>{{ route }}</li>
          {% endfor %}
        </ul>
        <p>Workers on these routes often face the highest commute costs, with some spending over £{{ (city.yearly_cost * 1.5)|int }} per year on season tickets.</p>

        <h2>How to Reduce Your {{ city.name }} Commute Cost</h2>
        <p><strong>Get a Railcard.</strong> If you commute by rail into {{ city.name }}, a Railcard could save you up to £{{ (city.yearly_cost * 0.33)|int }} per year. The 26-30 Railcard and Two Together Railcard are the most useful for regular commuters buying individual tickets.</p>
        <p><strong>Negotiate hybrid working.</strong> Each day you work from home saves you approximately £{{ city.avg_daily_cost }} in transport costs. Two remote days per week saves over £{{ (city.avg_daily_cost * 2 * 48)|int }} per year — the equivalent of a pay rise.</p>
        <p><strong>Buy an annual season ticket.</strong> Annual tickets are priced at 40 weeks of daily fares, giving you 12 weeks free. If your employer offers a season ticket loan, you can spread the cost interest-free.</p>

        <h2>Calculate Your Personal {{ city.name }} Commute Cost</h2>
        <p>The figures above are averages. Your actual commute cost depends on your specific route, salary, and working pattern. Use our free calculator to get your exact number — including what your commute time is worth in monetary terms and what percentage of your waking life you spend travelling.</p>

        <div style="text-align:center;margin:40px 0;">
          <a href="/" style="display:inline-block;background:var(--accent);color:var(--black);font-family:var(--font-mono);font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;">Calculate My {{ city.name }} Commute Cost →</a>
        </div>

        <h2>{{ city.name }} Commute Cost FAQs</h2>
        <div class="blog-faq">
          <div class="blog-faq-item">
            <h3>How much does it cost to commute to {{ city.name }}?</h3>
            <p>The average {{ city.name }} commuter spends £{{ city.monthly_cost }}/month or £{{ city.yearly_cost }}/year on transport. However, when the time cost is included — valued at the commuter's hourly salary rate — the true annual cost typically exceeds £{{ (city.yearly_cost * 2.2)|int }}.</p>
          </div>
          <div class="blog-faq-item">
            <h3>What is the average commute time to {{ city.name }}?</h3>
            <p>The average one-way commute to {{ city.name }} is {{ city.avg_commute_mins }} minutes, making a round trip of {{ city.avg_commute_mins * 2 }} minutes per day. Over a working year, this adds up to {{ (city.avg_commute_mins * 2 * 5 * 48 / 60)|int }} hours lost to commuting.</p>
          </div>
          <div class="blog-faq-item">
            <h3>Is it worth commuting to {{ city.name }}?</h3>
            <p>It depends on your salary, route, and working pattern. Use our <a href="/">Travel Tax calculator</a> to calculate your personal commute cost and compare it to the salary premium of working in {{ city.name }} versus closer to home or remotely.</p>
          </div>
        </div>

      </article>

      <!-- Other cities -->
      <div style="margin-top:48px;padding-top:32px;border-top:1px solid var(--border);">
        <p style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.2em;color:var(--accent);margin-bottom:16px;">COMMUTE COSTS BY CITY</p>
        <div style="display:flex;flex-wrap:wrap;gap:8px;">
          {% for city_slug, city_data in all_cities.items() %}
          <a href="/commute-cost/{{ city_slug }}" style="padding:8px 16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-family:var(--font-mono);font-size:11px;transition:all 0.15s;" onmouseover="this.style.borderColor='var(--accent)';this.style.color='var(--accent)'" onmouseout="this.style.borderColor='var(--border)';this.style.color='var(--text-dim)'">{{ city_data.name }}</a>
          {% endfor %}
        </div>
      </div>

    </div>
  </main>

  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Calculator</a> · <a href="/guide">Commute Guide</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
EOF

# ── 3. Blog index template ────────────────────────────────────────────────────
cat > "$TARGET/templates/blog_index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>UK Commute & Work Blog 2025 — Travel Tax</title>
  <meta name="description" content="Guides, calculators and insights on UK commuting costs, hybrid working savings, and making smarter career decisions." />
  <link rel="canonical" href="https://www.traveltax.co.uk/blog" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner">
      <a href="/" class="blog-logo">Travel Tax</a>
      <a href="/" class="blog-cta">Calculator →</a>
    </div>
  </header>
  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">UK COMMUTE INSIGHTS</span>
        <h1 class="blog-title">Commute & Work Guides</h1>
        <p class="blog-lead">Research, guides and insights to help UK workers make smarter decisions about commuting, hybrid working, and salary.</p>
      </div>

      <h2 style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.2em;color:var(--accent);margin-bottom:20px;">GUIDES & ARTICLES</h2>
      <div style="display:flex;flex-direction:column;gap:16px;margin-bottom:48px;">
        {% for post in posts %}
        <a href="/blog/{{ post.slug }}" style="display:block;padding:24px;border:1px solid var(--border);background:var(--panel);text-decoration:none;transition:border-color 0.2s;" onmouseover="this.style.borderColor='var(--accent)'" onmouseout="this.style.borderColor='var(--border)'">
          <h2 style="font-family:var(--font-display);font-size:28px;color:var(--white);margin-bottom:8px;letter-spacing:0.02em;">{{ post.title }}</h2>
          <p style="font-size:14px;color:var(--text-dim);line-height:1.6;">{{ post.description }}</p>
          <span style="font-family:var(--font-mono);font-size:11px;color:var(--accent);margin-top:12px;display:block;">Read more →</span>
        </a>
        {% endfor %}
      </div>

      <h2 style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.2em;color:var(--accent);margin-bottom:20px;">COMMUTE COSTS BY CITY</h2>
      <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:12px;">
        {% for slug, city in cities.items() %}
        <a href="/commute-cost/{{ slug }}" style="display:block;padding:20px;border:1px solid var(--border);background:var(--panel);text-decoration:none;transition:border-color 0.2s;" onmouseover="this.style.borderColor='var(--accent)'" onmouseout="this.style.borderColor='var(--border)'">
          <div style="font-family:var(--font-display);font-size:24px;color:var(--white);">{{ city.name }}</div>
          <div style="font-family:var(--font-mono);font-size:11px;color:var(--accent);margin-top:4px;">£{{ city.yearly_cost }}/year avg</div>
          <div style="font-family:var(--font-mono);font-size:10px;color:var(--text-dimmer);margin-top:4px;">{{ city.avg_commute_mins }} min avg commute</div>
        </a>
        {% endfor %}
      </div>
    </div>
  </main>
  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Calculator</a> · <a href="/guide">Guide</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
EOF

# ── 4. Blog post template ─────────────────────────────────────────────────────
cat > "$TARGET/templates/blog_post.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{{ post.title }} — Travel Tax</title>
  <meta name="description" content="{{ post.description }}" />
  <meta name="keywords" content="{{ post.keywords }}" />
  <meta property="og:title" content="{{ post.title }}" />
  <meta property="og:description" content="{{ post.description }}" />
  <meta property="og:url" content="https://www.traveltax.co.uk/blog/{{ post.slug }}" />
  <link rel="canonical" href="https://www.traveltax.co.uk/blog/{{ post.slug }}" />
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "{{ post.title }}",
    "description": "{{ post.description }}",
    "url": "https://www.traveltax.co.uk/blog/{{ post.slug }}",
    "publisher": {"@type": "Organization", "name": "Travel Tax", "url": "https://www.traveltax.co.uk"}
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
      <a href="/" class="blog-cta">Calculate Yours →</a>
    </div>
  </header>
  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">TRAVEL TAX · UK GUIDE · 2025</span>
        <h1 class="blog-title">{{ post.title }}</h1>
        <p class="blog-lead">{{ post.description }}</p>
        <div class="blog-meta"><span>Updated 2025</span><span>·</span><span>6 min read</span></div>
      </div>
      <article class="blog-article">
        <div class="blog-callout">
          <p>🧮 <strong>Get your personal answer instantly</strong> — use our free <a href="/">Travel Tax calculator</a> to calculate your exact commute cost in under 60 seconds.</p>
        </div>

        {% if post.slug == "is-my-commute-worth-it" %}
        <h2>The Hidden Cost Most People Ignore</h2>
        <p>When people think about their commute cost, they think about their train ticket or petrol. But this is only half the true cost. The other half — the part most people never calculate — is the value of their time.</p>
        <p>If you earn £35,000 per year and spend 90 minutes commuting each day, your hourly rate works out at approximately £17.50. Those 90 minutes of commuting are therefore worth £26.25 every single day. Over a working year, that adds up to over £5,000 of your time — on top of your transport costs.</p>
        <p>This is what we call the Travel Tax. It is the true, combined cost of your commute in both money and time.</p>
        <h2>How to Calculate If Your Commute Is Worth It</h2>
        <p>To work out if your commute is worth it, you need to compare three things: the salary premium of your job versus a closer or remote alternative, your annual transport cost, and the annual monetary value of your commute time.</p>
        <p>If the salary premium is greater than the transport cost plus time cost, your commute is financially worth it. If not, you may be better off finding a role closer to home or negotiating remote working days.</p>
        <h2>The Hybrid Working Calculation</h2>
        <p>For many UK workers, the question is not whether to commute at all, but how many days. Each additional day working from home saves the average UK commuter around £15 in transport costs and 90 minutes of time. Over a year, one extra remote day per week saves over £700 in transport and the equivalent of 72 hours of your life.</p>
        <h2>When Is a Commute Worth It?</h2>
        <p>A commute is financially worth it when the salary you earn as a result of commuting exceeds the true cost of commuting — transport plus time value. For most UK workers, a commute is worth it when the salary premium over a remote or local role exceeds £5,000 to £8,000 per year, depending on commute length.</p>

        {% elif post.slug == "hybrid-working-savings" %}
        <h2>The Real Financial Value of Hybrid Working</h2>
        <p>Hybrid working has transformed UK workplaces since 2020. But most workers have never calculated exactly how much it saves them. The answer is often surprising.</p>
        <p>For a typical London commuter spending £14.80 per day on transport, working from home two days per week saves £1,420 per year in transport alone. When the time saving is valued at the commuter's hourly salary rate, the total annual value of two remote days per week often exceeds £3,000.</p>
        <h2>Hybrid Working Savings by City</h2>
        <p>The savings from hybrid working vary significantly by city. London commuters save the most — up to £2,800 per year in transport alone for two remote days per week. Manchester commuters save around £880 per year, while Birmingham commuters save approximately £800.</p>
        <h2>How to Negotiate More Remote Days</h2>
        <p>The most effective approach is to frame the request in terms of productivity rather than personal preference. Research shows that remote workers are typically 13% more productive than office workers. Present your employer with data on your output and propose a trial period of increased remote working.</p>
        <p>Use our <a href="/">Travel Tax calculator</a> to calculate the exact financial value of additional remote days — this can be a powerful negotiating tool when discussing salary or working arrangements.</p>

        {% elif post.slug == "uk-commute-cost-2025" %}
        <h2>UK Commute Costs in 2025</h2>
        <p>UK commute costs have risen significantly over the past decade. Rail fares have increased by over 40% since 2010, consistently outpacing wage growth. In 2025, the average UK commuter spends between £1,800 and £6,800 per year on transport, depending on location and mode of transport.</p>
        <h2>Commute Costs by Transport Type</h2>
        <p>Train commuters face the highest costs, with London rail commuters spending an average of £3,480 per year. Car commuters face lower direct costs but must account for fuel, depreciation, and maintenance. Electric vehicle commuters pay significantly less — around £400 to £600 per year in energy costs for a typical commute.</p>
        <h2>The Time Cost Employers Do Not Tell You About</h2>
        <p>Beyond transport costs, the time spent commuting has a significant monetary value. For a worker earning £35,000 per year, each hour spent commuting is worth £17.50. The average UK commuter loses over £4,000 worth of time per year — a hidden cost that rarely appears in job offer comparisons.</p>

        {% elif post.slug == "railcard-worth-it" %}
        <h2>What Is a Railcard?</h2>
        <p>A Railcard is a discount card that saves 33% on most UK rail fares. There are several types available, costing between £30 and £35 per year. The most popular for commuters are the 16-25 Railcard, the 26-30 Railcard, and the Two Together Railcard.</p>
        <h2>When Is a Railcard Worth It?</h2>
        <p>A Railcard pays for itself as soon as you have saved more than its cost in discounts. At 33% off, a £30 Railcard pays for itself after you have spent £91 on eligible rail fares. For most regular commuters buying individual tickets, this happens within the first two weeks.</p>
        <p>Note that Railcard discounts do not apply to season tickets, so they are most valuable for flexible or part-time commuters buying individual tickets rather than season ticket holders.</p>
        <h2>Which Railcard Should I Get?</h2>
        <p>If you are aged 16-25, get the 16-25 Railcard. If you are aged 26-30, get the 26-30 Railcard. If you regularly travel with the same person, the Two Together Railcard saves both of you 33% and costs £30 in total. If you commute in the South East, the Network Railcard at £35 covers most routes in the region.</p>

        {% elif post.slug == "remote-vs-office-salary" %}
        <h2>Why Salary Alone Does Not Tell the Full Story</h2>
        <p>A job paying £40,000 with a 90-minute daily commute is not the same as a remote job paying £35,000. Once you account for transport costs and the value of commuting time, the remote role may actually be worth more in real terms.</p>
        <h2>How to Compare Remote vs Office Salaries</h2>
        <p>To compare accurately, calculate the true annual cost of your commute — transport plus time value at your hourly rate. Subtract this from your office salary. The result is your effective take-home value. Compare this to the remote salary to see which is actually worth more.</p>
        <p>For example: £40,000 office salary minus £8,000 commute tax (transport plus time) equals an effective value of £32,000. A remote role paying £35,000 is therefore worth £3,000 more in real terms — despite appearing to pay £5,000 less.</p>
        <h2>Other Factors to Consider</h2>
        <p>Beyond the financial calculation, consider the wellbeing value of not commuting. Research shows that long commutes are associated with higher stress, poorer sleep, and reduced job satisfaction. Some workers value reclaiming their commute time at significantly more than their hourly salary rate suggests.</p>
        {% endif %}

        <div style="text-align:center;margin:48px 0 32px;">
          <p style="font-size:14px;color:var(--text-dim);margin-bottom:20px;">Calculate your exact commute cost and compare your options</p>
          <a href="/" style="display:inline-block;background:var(--accent);color:var(--black);font-family:var(--font-mono);font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;">Calculate My Travel Tax →</a>
        </div>

        <h2>More Guides</h2>
        <div style="display:flex;flex-direction:column;gap:10px;">
          {% for other in all_posts %}
          {% if other.slug != post.slug %}
          <a href="/blog/{{ other.slug }}" style="display:block;padding:16px;border:1px solid var(--border);color:var(--text-dim);text-decoration:none;font-size:14px;transition:border-color 0.2s;" onmouseover="this.style.borderColor='var(--accent)'" onmouseout="this.style.borderColor='var(--border)'">{{ other.title }} →</a>
          {% endif %}
          {% endfor %}
        </div>
      </article>
    </div>
  </main>
  <footer class="site-footer">
    <p>© 2025 Travel Tax · <a href="/">Calculator</a> · <a href="/guide">Guide</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
EOF

# ── 5. Update main index.html meta tags and schema ────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/templates/index.html'
with open(path, 'r') as f:
    content = f.read()

# Add schema markup and better meta tags
schema = '''  <meta name="keywords" content="commute cost calculator, travel tax, UK commute calculator, how much does commuting cost, commute time calculator, is my commute worth it" />
  <meta property="og:title" content="Travel Tax — What Is Your Commute Really Costing You?" />
  <meta property="og:description" content="Calculate the true cost of your commute in money AND time. Find out what % of your waking life you spend commuting. Free UK calculator." />
  <meta property="og:url" content="https://www.traveltax.co.uk" />
  <meta property="og:type" content="website" />
  <link rel="canonical" href="https://www.traveltax.co.uk/" />
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    "name": "Travel Tax Calculator",
    "description": "Calculate the true cost of your commute in money and time. Free UK commute calculator.",
    "url": "https://www.traveltax.co.uk",
    "applicationCategory": "FinanceApplication",
    "operatingSystem": "Any",
    "offers": {"@type": "Offer", "price": "0", "priceCurrency": "GBP"},
    "publisher": {"@type": "Organization", "name": "Travel Tax", "url": "https://www.traveltax.co.uk"}
  }
  </script>'''

content = content.replace('<link rel="canonical" href="https://www.traveltax.co.uk/" />', '')
content = content.replace('</title>\n  <meta name="description"', '</title>\n' + schema + '\n  <meta name="description"')

# Add blog link to footer
content = content.replace(
    '<a href="/guide">Commute Guide</a></p>',
    '<a href="/guide">Commute Guide</a> · <a href="/blog">Blog</a></p>'
)

with open(path, 'w') as f:
    f.write(content)
print("Done index.html")
PYEOF

echo "✅ SEO engine built!"
echo ""
echo "New pages:"
echo "  /blog — blog index"
echo "  /blog/is-my-commute-worth-it"
echo "  /blog/hybrid-working-savings"
echo "  /blog/uk-commute-cost-2025"
echo "  /blog/railcard-worth-it"
echo "  /blog/remote-vs-office-salary"
echo "  /commute-cost/london"
echo "  /commute-cost/manchester"
echo "  /commute-cost/birmingham"
echo "  /commute-cost/leeds"
echo "  /commute-cost/edinburgh"
echo "  /commute-cost/glasgow"
echo "  /commute-cost/bristol"
echo "  /commute-cost/liverpool"
echo "  /commute-cost/nottingham"
echo "  /commute-cost/sheffield"
echo "  /sitemap.xml"
echo "  /robots.txt"
echo ""
echo "Now push:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add SEO engine - 15 new pages' && git push"
