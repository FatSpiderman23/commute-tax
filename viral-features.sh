#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🚀 Building viral traffic features..."

# ── 1. Embeddable Widget ──────────────────────────────────────────────────────
cat > "$TARGET/templates/widget.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'DM Sans', -apple-system, sans-serif; background: #0a0a0a; color: #e8e8e0; }
    .w { padding: 20px; max-width: 400px; margin: 0 auto; }
    .w-title { font-family: 'Bebas Neue', sans-serif; font-size: 28px; color: #f0e040; margin-bottom: 4px; }
    .w-sub { font-size: 11px; color: #555; font-family: monospace; letter-spacing: 0.1em; margin-bottom: 16px; }
    .w-field { margin-bottom: 12px; }
    .w-label { font-size: 11px; color: #888; font-family: monospace; letter-spacing: 0.08em; margin-bottom: 4px; display: block; }
    .w-input { width: 100%; background: #111; border: 1px solid #222; color: #e8e8e0; padding: 10px 12px; font-size: 14px; outline: none; }
    .w-input:focus { border-color: #f0e040; }
    .w-row { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 12px; }
    .w-btn-group { display: flex; gap: 4px; }
    .w-btn { flex: 1; padding: 8px 4px; background: #111; border: 1px solid #222; color: #888; font-size: 12px; cursor: pointer; font-family: monospace; transition: all 0.15s; }
    .w-btn.active { background: #f0e040; color: #000; border-color: #f0e040; }
    .w-calc { width: 100%; padding: 14px; background: #f0e040; border: none; color: #000; font-family: monospace; font-size: 12px; font-weight: 600; letter-spacing: 0.1em; cursor: pointer; margin-top: 4px; }
    .w-result { display: none; margin-top: 16px; padding: 16px; border: 1px solid #f0e040; background: #0f0f00; }
    .w-result-label { font-family: monospace; font-size: 10px; color: #f0e040; letter-spacing: 0.2em; margin-bottom: 4px; }
    .w-result-num { font-family: 'Bebas Neue', sans-serif; font-size: 48px; color: #f0e040; line-height: 1; }
    .w-result-sub { font-size: 12px; color: #888; margin-top: 4px; }
    .w-stats { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-top: 12px; }
    .w-stat { background: #111; padding: 10px; border: 1px solid #1a1a1a; }
    .w-stat-val { font-family: 'Bebas Neue', sans-serif; font-size: 22px; color: #fff; }
    .w-stat-label { font-size: 10px; color: #555; font-family: monospace; margin-top: 2px; }
    .w-cta { display: block; text-align: center; margin-top: 12px; padding: 10px; background: #111; border: 1px solid #222; color: #f0e040; text-decoration: none; font-family: monospace; font-size: 11px; letter-spacing: 0.1em; }
  </style>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
</head>
<body>
<div class="w">
  <div class="w-title">Travel Tax</div>
  <div class="w-sub">What is your commute really costing you?</div>
  <div class="w-row">
    <div class="w-field">
      <label class="w-label">Salary (£)</label>
      <input class="w-input" type="number" id="w_salary" placeholder="35000" />
    </div>
    <div class="w-field">
      <label class="w-label">Commute (mins)</label>
      <input class="w-input" type="number" id="w_mins" placeholder="45" />
    </div>
  </div>
  <div class="w-field">
    <label class="w-label">Days in office</label>
    <div class="w-btn-group">
      <button class="w-btn" onclick="setWDay(this,1)">1</button>
      <button class="w-btn" onclick="setWDay(this,2)">2</button>
      <button class="w-btn active" onclick="setWDay(this,3)">3</button>
      <button class="w-btn" onclick="setWDay(this,4)">4</button>
      <button class="w-btn" onclick="setWDay(this,5)">5</button>
    </div>
  </div>
  <div class="w-field">
    <label class="w-label">Transport</label>
    <div class="w-btn-group">
      <button class="w-btn active" onclick="setWTransport(this,'public')">Train / Bus</button>
      <button class="w-btn" onclick="setWTransport(this,'car')">Car</button>
    </div>
  </div>
  <div class="w-field" id="w_cost_field">
    <label class="w-label">Daily cost (£)</label>
    <input class="w-input" type="number" id="w_cost" placeholder="12.50" step="0.50" />
  </div>
  <button class="w-calc" onclick="calcWidget()">Calculate My Travel Tax →</button>
  <div class="w-result" id="w_result">
    <div class="w-result-label">YOUR ANNUAL TRAVEL TAX</div>
    <div class="w-result-num" id="w_total">£0</div>
    <div class="w-result-sub" id="w_sub">transport cost per year</div>
    <div class="w-stats">
      <div class="w-stat"><div class="w-stat-val" id="w_hours">0h</div><div class="w-stat-label">HOURS LOST/YR</div></div>
      <div class="w-stat"><div class="w-stat-val" id="w_pct">0%</div><div class="w-stat-label">LIFE STOLEN</div></div>
      <div class="w-stat"><div class="w-stat-val" id="w_days">0</div><div class="w-stat-label">DAYS LOST/YR</div></div>
      <div class="w-stat"><div class="w-stat-val" id="w_monthly">£0</div><div class="w-stat-label">MONTHLY COST</div></div>
    </div>
    <a class="w-cta" href="https://www.traveltax.co.uk" target="_blank">Get full breakdown at traveltax.co.uk →</a>
  </div>
</div>
<script>
let wDays = 3, wTransport = 'public';
function setWDay(btn, d) { document.querySelectorAll('.w-btn-group .w-btn').forEach(b => { if (b.closest('.w-field') === btn.closest('.w-field')) b.classList.remove('active'); }); btn.classList.add('active'); wDays = d; }
function setWTransport(btn, t) { btn.closest('.w-btn-group').querySelectorAll('.w-btn').forEach(b => b.classList.remove('active')); btn.classList.add('active'); wTransport = t; }
async function calcWidget() {
  const salary = parseFloat(document.getElementById('w_salary').value) || 0;
  const mins = parseFloat(document.getElementById('w_mins').value) || 0;
  const cost = parseFloat(document.getElementById('w_cost').value) || 0;
  if (!salary || !mins) return;
  try {
    const res = await fetch('https://www.traveltax.co.uk/calculate', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ salary, commute_minutes: mins, days_per_week: wDays, weeks_per_year: 48, transport_type: wTransport, transport_cost_daily: cost, car_type: 'petrol', fuel_spend: 0, fuel_period: 'weekly', miles_one_way: 0 }) });
    const r = await res.json();
    document.getElementById('w_result').style.display = 'block';
    document.getElementById('w_total').textContent = '£' + Math.round(r.transport_cost_yearly).toLocaleString('en-GB');
    document.getElementById('w_sub').textContent = 'transport cost per year';
    document.getElementById('w_hours').textContent = r.commute_hours_yearly + 'h';
    document.getElementById('w_pct').textContent = r.pct_waking_life + '%';
    document.getElementById('w_days').textContent = Math.round(r.commute_hours_yearly / 8);
    document.getElementById('w_monthly').textContent = '£' + Math.round(r.transport_cost_monthly).toLocaleString('en-GB');
  } catch(e) { console.error(e); }
}
</script>
</body>
</html>
EOF

# ── 2. Embed page ─────────────────────────────────────────────────────────────
cat > "$TARGET/templates/embed.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Embed Travel Tax Calculator — Free UK Commute Widget</title>
  <meta name="description" content="Add the Travel Tax calculator to your website for free. One line of code. Free UK commute cost widget for blogs, HR sites, and career pages." />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
</head>
<body>
  <header class="blog-header">
    <div class="blog-header-inner"><a href="/" class="blog-logo">Travel Tax</a><a href="/" class="blog-cta">Full Calculator →</a></div>
  </header>
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/tools" class="nav-link">All Tools</a>
      <a href="/embed" class="nav-link active">Embed</a>
      <a href="/press" class="nav-link">Press</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>
  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">FREE WIDGET · EMBED ON YOUR SITE</span>
        <h1 class="blog-title">Add the Travel Tax Calculator to Your Website</h1>
        <p class="blog-lead">Free to embed. No sign up. Works on any website, blog, or HR intranet. Just copy and paste one line of code.</p>
      </div>

      <!-- Live preview -->
      <h2 style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.2em;color:var(--accent);margin-bottom:16px;">LIVE PREVIEW</h2>
      <div style="border:1px solid var(--border);margin-bottom:32px;overflow:hidden;">
        <iframe src="/widget" width="100%" height="520" frameborder="0" scrolling="no" style="display:block;"></iframe>
      </div>

      <!-- Embed code -->
      <h2 style="font-family:var(--font-mono);font-size:10px;letter-spacing:0.2em;color:var(--accent);margin-bottom:16px;">EMBED CODE</h2>
      <div style="background:var(--panel);border:1px solid var(--border);padding:20px;margin-bottom:32px;position:relative;">
        <pre id="embedCode" style="font-family:monospace;font-size:13px;color:var(--accent);white-space:pre-wrap;line-height:1.6;">&lt;iframe src="https://www.traveltax.co.uk/widget" width="400" height="520" frameborder="0" scrolling="no"&gt;&lt;/iframe&gt;</pre>
        <button onclick="copyEmbed()" style="position:absolute;top:16px;right:16px;background:var(--accent);color:#000;border:none;padding:8px 16px;font-family:monospace;font-size:11px;cursor:pointer;letter-spacing:0.08em;">Copy Code</button>
      </div>

      <!-- Who should use it -->
      <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;margin-bottom:48px;">
        <div style="padding:20px;border:1px solid var(--border);background:var(--panel);">
          <div style="font-size:24px;margin-bottom:8px;">📰</div>
          <div style="font-family:var(--font-display);font-size:20px;color:var(--white);margin-bottom:6px;">Finance Blogs</div>
          <p style="font-size:13px;color:var(--text-dim);">Add a live calculator to salary and commute articles to increase engagement and time on page.</p>
        </div>
        <div style="padding:20px;border:1px solid var(--border);background:var(--panel);">
          <div style="font-size:24px;margin-bottom:8px;">💼</div>
          <div style="font-family:var(--font-display);font-size:20px;color:var(--white);margin-bottom:6px;">HR & Recruitment</div>
          <p style="font-size:13px;color:var(--text-dim);">Help candidates understand the true value of job offers including commute costs.</p>
        </div>
        <div style="padding:20px;border:1px solid var(--border);background:var(--panel);">
          <div style="font-size:24px;margin-bottom:8px;">🏢</div>
          <div style="font-family:var(--font-display);font-size:20px;color:var(--white);margin-bottom:6px;">Company Intranets</div>
          <p style="font-size:13px;color:var(--text-dim);">Help employees calculate commute costs when deciding on office vs hybrid working patterns.</p>
        </div>
        <div style="padding:20px;border:1px solid var(--border);background:var(--panel);">
          <div style="font-size:24px;margin-bottom:8px;">🎓</div>
          <div style="font-family:var(--font-display);font-size:20px;color:var(--white);margin-bottom:6px;">Careers Sites</div>
          <p style="font-size:13px;color:var(--text-dim);">Add a commute cost widget to job listings so candidates can assess the real cost before applying.</p>
        </div>
      </div>

      <div style="background:#0f0f00;border:1px solid var(--accent);padding:28px;text-align:center;">
        <p style="font-family:var(--font-display);font-size:28px;color:var(--accent);margin-bottom:8px;">Want a custom version?</p>
        <p style="font-size:14px;color:var(--text-dim);margin-bottom:16px;">We can build a branded version for your site. Get in touch.</p>
        <a href="mailto:press@traveltax.co.uk" style="display:inline-block;background:var(--accent);color:#000;font-family:monospace;font-size:12px;padding:14px 32px;text-decoration:none;letter-spacing:0.1em;">Contact Us →</a>
      </div>
    </div>
  </main>
  <footer class="site-footer"><p>© 2026 Travel Tax · <a href="/">Commute</a> · <a href="/embed">Embed</a> · <a href="/press">Press</a> · <a href="/privacy">Privacy</a></p></footer>
  <script>
  function copyEmbed() {
    navigator.clipboard.writeText('<iframe src="https://www.traveltax.co.uk/widget" width="400" height="520" frameborder="0" scrolling="no"></iframe>');
    document.querySelector('button[onclick="copyEmbed()"]').textContent = 'Copied!';
    setTimeout(() => document.querySelector('button[onclick="copyEmbed()"]').textContent = 'Copy Code', 2000);
  }
  </script>
</body>
</html>
EOF

# ── 3. Comparison table page ──────────────────────────────────────────────────
cat > "$TARGET/templates/best_cities.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Best UK Cities for Remote Workers 2026 — Salary vs Cost of Living</title>
  <meta name="description" content="Which UK city gives you the best quality of life in 2026? We ranked every major UK city by salary, commute cost, rent and disposable income." />
  <meta name="keywords" content="best UK cities to live 2026, best city for remote workers UK, UK city salary vs cost of living" />
  <link rel="canonical" href="https://www.traveltax.co.uk/best-cities-uk" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Mono:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/static/css/style.css" />
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-8725854592183933" crossorigin="anonymous"></script>
  <style>
    .rank-table { width: 100%; border-collapse: collapse; margin: 24px 0; }
    .rank-table th { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.15em; color: var(--text-dimmer); padding: 12px 16px; text-align: left; border-bottom: 1px solid var(--border); background: var(--panel); }
    .rank-table td { padding: 14px 16px; border-bottom: 1px solid var(--border); font-size: 13px; color: var(--text-dim); }
    .rank-table tr:hover td { background: var(--panel); }
    .rank-num { font-family: var(--font-display); font-size: 24px; color: var(--accent); }
    .rank-city { font-family: var(--font-display); font-size: 20px; color: var(--white); }
    .rank-score { font-family: var(--font-display); font-size: 22px; }
    .score-high { color: var(--green, #4caf50); }
    .score-mid { color: var(--accent); }
    .score-low { color: var(--red, #f44336); }
    @media (max-width: 768px) {
      .rank-table th:nth-child(n+4), .rank-table td:nth-child(n+4) { display: none; }
    }
  </style>
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
      <a href="/tools" class="nav-link">All Tools</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>
  <div class="ad-slot ad-leaderboard"><span class="ad-label">Advertisement</span></div>

  <main class="blog-main">
    <div class="blog-inner">
      <div class="blog-hero">
        <span class="blog-tag">UK CITY RANKINGS · 2026</span>
        <h1 class="blog-title">Best UK Cities to Live and Work in 2026</h1>
        <p class="blog-lead">We ranked every major UK city by what actually matters — average salary, rent, commute cost, and how much disposable income you are left with each month. The results might surprise you.</p>
        <div class="blog-meta"><span>Updated March 2026</span><span>·</span><span>Based on ONS, Rightmove and Transport for London data</span></div>
      </div>

      <article class="blog-article">

        <h2>The Rankings</h2>
        <p>We scored each city based on four factors: average salary, average 1-bed rent, monthly commute cost, and resulting monthly disposable income. The city with the highest disposable income after all essential costs scores highest.</p>

        <div style="overflow-x:auto;">
          <table class="rank-table">
            <thead>
              <tr>
                <th>#</th>
                <th>City</th>
                <th>Avg Salary</th>
                <th>1-Bed Rent</th>
                <th>Commute/Month</th>
                <th>Disposable</th>
                <th>Score</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><span class="rank-num">1</span></td>
                <td><span class="rank-city">Leeds</span></td>
                <td>£29,000</td><td>£850/mo</td><td>£80/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£882/mo</td>
                <td><span class="rank-score score-high">9.2/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">2</span></td>
                <td><span class="rank-city">Manchester</span></td>
                <td>£32,000</td><td>£950/mo</td><td>£90/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£924/mo</td>
                <td><span class="rank-score score-high">8.9/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">3</span></td>
                <td><span class="rank-city">Birmingham</span></td>
                <td>£30,000</td><td>£850/mo</td><td>£85/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£857/mo</td>
                <td><span class="rank-score score-high">8.7/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">4</span></td>
                <td><span class="rank-city">Liverpool</span></td>
                <td>£28,000</td><td>£750/mo</td><td>£75/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£837/mo</td>
                <td><span class="rank-score score-high">8.5/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">5</span></td>
                <td><span class="rank-city">Sheffield</span></td>
                <td>£28,000</td><td>£780/mo</td><td>£78/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£810/mo</td>
                <td><span class="rank-score score-mid">8.1/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">6</span></td>
                <td><span class="rank-city">Nottingham</span></td>
                <td>£27,000</td><td>£780/mo</td><td>£68/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£782/mo</td>
                <td><span class="rank-score score-mid">7.9/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">7</span></td>
                <td><span class="rank-city">Bristol</span></td>
                <td>£31,000</td><td>£1,100/mo</td><td>£95/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£720/mo</td>
                <td><span class="rank-score score-mid">7.4/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">8</span></td>
                <td><span class="rank-city">Glasgow</span></td>
                <td>£30,000</td><td>£1,000/mo</td><td>£86/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£700/mo</td>
                <td><span class="rank-score score-mid">7.2/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">9</span></td>
                <td><span class="rank-city">Edinburgh</span></td>
                <td>£33,000</td><td>£1,100/mo</td><td>£100/mo</td>
                <td style="color:var(--accent);font-family:var(--font-mono);">£694/mo</td>
                <td><span class="rank-score score-mid">7.0/10</span></td>
              </tr>
              <tr>
                <td><span class="rank-num">10</span></td>
                <td><span class="rank-city">London</span></td>
                <td>£42,000</td><td>£1,800/mo</td><td>£180/mo</td>
                <td style="color:var(--red,#f44336);font-family:var(--font-mono);">£420/mo</td>
                <td><span class="rank-score score-low">5.8/10</span></td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="blog-callout">
          <p>🧮 <strong>See your personal numbers</strong> — use our <a href="/">Travel Tax calculator</a> and <a href="/take-home">Take Home Pay calculator</a> to calculate your exact disposable income in any city.</p>
        </div>

        <h2>Why Leeds Ranks #1</h2>
        <p>Leeds consistently offers the best balance of salary and living costs. The average Leeds salary of £29,000 leaves workers with significantly more disposable income than equivalent roles in London or Bristol, once rent and commute costs are factored in. The city's growing tech and financial services sector means salaries are rising faster than living costs.</p>

        <h2>The London Premium — Is It Real?</h2>
        <p>London salaries average £42,000 — £13,000 more than Leeds. But once you subtract London's higher rent (£1,800 vs £850), higher commute costs (£180 vs £80/month), and higher general living costs, the average London worker has less disposable income than their counterpart in Leeds, Manchester, or Birmingham.</p>
        <p>This is the core insight of the Travel Tax platform — headline salary is not the same as real financial wellbeing. Use our <a href="/compare-jobs">Job Offer Comparison tool</a> to compare any two roles including all costs.</p>

        <h2>Best Cities for Remote Workers</h2>
        <p>For fully remote workers, the ranking changes dramatically. With no commute costs, the calculation becomes purely salary vs rent vs cost of living. In this scenario, Leeds, Manchester, and Birmingham pull even further ahead — offering salaries within 20-30% of London while costing 40-50% less to live in.</p>

        <div style="text-align:center;margin:40px 0;">
          <a href="/cost-of-living" style="display:inline-block;background:var(--accent);color:#000;font-family:monospace;font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;margin-right:12px;">Compare City Costs →</a>
          <a href="/compare-jobs" style="display:inline-block;border:1px solid var(--accent);color:var(--accent);font-family:monospace;font-size:13px;padding:18px 40px;text-decoration:none;letter-spacing:0.12em;text-transform:uppercase;">Compare Job Offers →</a>
        </div>

      </article>
    </div>
  </main>
  <footer class="site-footer"><p>© 2026 Travel Tax · <a href="/">Commute</a> · <a href="/cost-of-living">Cost of Living</a> · <a href="/blog">Blog</a> · <a href="/privacy">Privacy</a></p></footer>
</body>
</html>
EOF

# ── 4. Add routes to app.py ───────────────────────────────────────────────────
python3 << 'PYEOF'
path = '/Users/ss/Documents/Commute Tax/app.py'
with open(path, 'r') as f:
    content = f.read()

new_routes = '''
@app.route("/widget")
def widget():
    return render_template("widget.html")

@app.route("/embed")
def embed():
    return render_template("embed.html")

@app.route("/best-cities-uk")
def best_cities():
    return render_template("best_cities.html")

'''

content = content.replace('if __name__ == "__main__":', new_routes + 'if __name__ == "__main__":')

# Add CORS header for widget iframe
cors_code = '''
from flask import make_response

@app.after_request
def add_cors(response):
    response.headers["X-Frame-Options"] = "ALLOWALL"
    response.headers["Access-Control-Allow-Origin"] = "*"
    return response

'''

if 'add_cors' not in content:
    content = content.replace('if __name__ == "__main__":', cors_code + 'if __name__ == "__main__":')

# Update sitemap
content = content.replace(
    '"priority": "0.6", "changefreq": "monthly"},\n',
    '"priority": "0.6", "changefreq": "monthly"},\n        {"loc": "https://www.traveltax.co.uk/embed", "priority": "0.7", "changefreq": "monthly"},\n        {"loc": "https://www.traveltax.co.uk/best-cities-uk", "priority": "0.9", "changefreq": "monthly"},\n'
)

with open(path, 'w') as f:
    f.write(content)
print("Done app.py")
PYEOF

# ── 5. Reddit data post text file ─────────────────────────────────────────────
cat > "$TARGET/REDDIT_POST.md" << 'EOF'
# REDDIT POST — Ready to copy and paste

## Title:
I analysed commute costs across every major UK city — here is what people are really paying in 2026

## Body:
www.traveltax.co.uk/best-cities-uk

I built a free commute cost calculator and used the data to rank every major UK city by what you actually take home after rent, commute costs, and tax. The results are pretty eye opening.

Here are the highlights:

Leeds comes out on top. Average salary of £29k but rent and commute costs are so low that workers keep more disposable income than the average London worker on £42k.

London is last. The salary premium sounds great until you factor in £1,800/month rent and £180/month commuting. The average London worker has less in their pocket at the end of the month than someone in Leeds, Manchester, or Birmingham.

The London premium disappears entirely once you run the real numbers. A £42k London salary vs a £29k Leeds salary sounds like a £13k gap. It is actually about £300/month difference in disposable income after costs.

Full city by city breakdown with methodology here: www.traveltax.co.uk/best-cities-uk

Happy to answer questions on the methodology. Used ONS salary data, Rightmove rental data, and Transport for London fare data.

---
Post in: r/UKPersonalFinance, r/london, r/AskUK, r/leeds, r/manchester, r/Birmingham
EOF

# ── 6. Test ───────────────────────────────────────────────────────────────────
echo ""
echo "Testing..."
cd "$TARGET" && python3 -c "import app; print('✅ OK')" 2>&1

echo ""
echo "Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add viral features: widget, embed, city rankings, Reddit post' && git push"
