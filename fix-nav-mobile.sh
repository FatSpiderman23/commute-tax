#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🔧 Fixing nav and mobile tabs..."

# ── 1. Fix nav on ALL pages — dropdown for tools ──────────────────────────────
python3 << 'PYEOF'
import os, re

NAV = '''  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
      <a href="/city-comparison" class="nav-link">City Comparison</a>
      <a href="/buy-vs-rent" class="nav-link">Buy vs Rent</a>
      <div class="nav-dropdown">
        <button class="nav-link nav-dropdown-btn">More Tools ▾</button>
        <div class="nav-dropdown-menu">
          <a href="/student-loan" class="nav-dropdown-item">Student Loan</a>
          <a href="/pension-calculator" class="nav-dropdown-item">Pension Calculator</a>
          <a href="/redundancy-calculator" class="nav-dropdown-item">Redundancy Pay</a>
          <a href="/maternity-calculator" class="nav-dropdown-item">Maternity Pay</a>
          <a href="/self-employed-vs-paye" class="nav-dropdown-item">Self-Employed vs PAYE</a>
          <a href="/tools" class="nav-dropdown-item">All Tools →</a>
        </div>
      </div>
      <a href="/cost-of-living" class="nav-link">Cost of Living</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>'''

ACTIVE_MAP = {
    'index.html': '/">Commute Tax',
    'take_home.html': '/take-home" class="nav-link">Take Home Pay',
    'compare_jobs.html': '/compare-jobs" class="nav-link">Compare Jobs',
    'city_comparison.html': '/city-comparison" class="nav-link">City Comparison',
    'buy_vs_rent.html': '/buy-vs-rent" class="nav-link">Buy vs Rent',
    'student_loan.html': 'Student Loan',
    'pension_calculator.html': 'Pension Calculator',
    'redundancy_calculator.html': 'Redundancy Pay',
    'maternity_calculator.html': 'Maternity Pay',
    'self_employed_vs_paye.html': 'Self-Employed vs PAYE',
    'tools.html': '/tools" class="nav-dropdown-item">All Tools',
    'cost_of_living_index.html': '/cost-of-living" class="nav-link">Cost of Living',
    'cost_of_living.html': '/cost-of-living" class="nav-link">Cost of Living',
    'blog_index.html': '/blog" class="nav-link">Blog',
    'blog_post.html': '/blog" class="nav-link">Blog',
    'city.html': '/blog" class="nav-link">Blog',
    'commuter_town.html': '/blog" class="nav-link">Blog',
    'salary_index.html': '/tools" class="nav-dropdown-item">All Tools',
    'salary_page.html': '/tools" class="nav-dropdown-item">All Tools',
    'press.html': '/blog" class="nav-link">Blog',
    'best_cities.html': '/cost-of-living" class="nav-link">Cost of Living',
}

templates_dir = '/Users/ss/Documents/Commute Tax/templates'
for fname in os.listdir(templates_dir):
    if not fname.endswith('.html'):
        continue
    path = os.path.join(templates_dir, fname)
    with open(path, 'r') as f:
        content = f.read()
    if '<nav class="top-nav">' not in content:
        continue

    # Build active nav for this page
    new_nav = NAV
    active_key = ACTIVE_MAP.get(fname, '')
    if active_key:
        # For dropdown items
        if 'nav-dropdown-item' in NAV and active_key in ['Student Loan', 'Pension Calculator', 'Redundancy Pay', 'Maternity Pay', 'Self-Employed vs PAYE']:
            new_nav = new_nav.replace(
                f'"nav-dropdown-item">{active_key}</a>',
                f'"nav-dropdown-item active">{active_key}</a>'
            )
        else:
            # For regular nav links
            for link_text in ['Commute Tax', 'Take Home Pay', 'Compare Jobs', 'City Comparison', 'Buy vs Rent', 'Cost of Living', 'Blog']:
                if link_text in active_key:
                    new_nav = new_nav.replace(
                        f'"nav-link">{link_text}</a>',
                        f'"nav-link active">{link_text}</a>',
                        1
                    )

    content = re.sub(r'<nav class="top-nav">.*?</nav>', new_nav, content, flags=re.DOTALL)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Updated nav: {fname}")

print("Done all navs")
PYEOF

# ── 2. Add dropdown CSS ───────────────────────────────────────────────────────
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* =============================================
   NAV DROPDOWN
   ============================================= */
.nav-dropdown {
  position: relative;
}

.nav-dropdown-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--text-dimmer);
  padding: 14px 20px;
  border-bottom: 2px solid transparent;
  white-space: nowrap;
  transition: color 0.15s, border-color 0.15s;
}

.nav-dropdown-btn:hover {
  color: var(--accent);
}

.nav-dropdown-menu {
  display: none;
  position: absolute;
  top: 100%;
  left: 0;
  background: var(--off-black);
  border: 1px solid var(--border);
  border-top: 2px solid var(--accent);
  min-width: 200px;
  z-index: 200;
}

.nav-dropdown:hover .nav-dropdown-menu {
  display: block;
}

.nav-dropdown-item {
  display: block;
  padding: 12px 20px;
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--text-dimmer);
  text-decoration: none;
  border-bottom: 1px solid var(--border);
  transition: all 0.15s;
}

.nav-dropdown-item:last-child {
  border-bottom: none;
}

.nav-dropdown-item:hover,
.nav-dropdown-item.active {
  color: var(--accent);
  background: var(--panel);
}

@media (max-width: 768px) {
  .nav-dropdown-menu {
    position: static;
    border: none;
    border-top: 1px solid var(--border);
    display: none;
  }
  .nav-dropdown.open .nav-dropdown-menu {
    display: block;
  }
  .nav-dropdown-btn::after {
    content: '';
  }
}
CSSEOF

# ── 3. Add dropdown JS to all pages ──────────────────────────────────────────
python3 << 'PYEOF'
import os

DROPDOWN_JS = '''
<script>
// Mobile nav dropdown toggle
document.addEventListener("DOMContentLoaded", function() {
  var btn = document.querySelector(".nav-dropdown-btn");
  if (btn) {
    btn.addEventListener("click", function(e) {
      e.stopPropagation();
      btn.closest(".nav-dropdown").classList.toggle("open");
    });
    document.addEventListener("click", function() {
      btn.closest(".nav-dropdown").classList.remove("open");
    });
  }
});
</script>
'''

templates_dir = '/Users/ss/Documents/Commute Tax/templates'
for fname in os.listdir(templates_dir):
    if not fname.endswith('.html'):
        continue
    path = os.path.join(templates_dir, fname)
    with open(path, 'r') as f:
        content = f.read()
    if 'nav-dropdown-btn' in content and 'nav-dropdown").classList.toggle' not in content:
        content = content.replace('</body>', DROPDOWN_JS + '\n</body>')
        with open(path, 'w') as f:
            f.write(content)
        print(f"Added dropdown JS to {fname}")
PYEOF

# ── 4. Add mobile tabs to redundancy, maternity, buy vs rent, self-employed ───
python3 << 'PYEOF'
import os

def add_mobile_tabs(template_file, tab_id, calc_fields_html, results_ids, calc_endpoint, result_renderer):
    path = f'/Users/ss/Documents/Commute Tax/templates/{template_file}'
    with open(path, 'r') as f:
        content = f.read()

    mobile_html = f'''
  <!-- MOBILE TABS -->
  <div class="calc-mobile-tabs">
    <div class="calc-tab-btns">
      <button class="calc-tab-btn active" onclick="{tab_id}Tab('calc')">Calculator</button>
      <button class="calc-tab-btn" onclick="{tab_id}Tab('results')">My Results</button>
    </div>
    <div class="calc-tab-panel active" id="{tab_id}_panel_calc">
{calc_fields_html}
    </div>
    <div class="calc-tab-panel" id="{tab_id}_panel_results">
      <div id="{tab_id}_m_placeholder" style="text-align:center;padding:40px 0;color:var(--text-dimmer);font-family:var(--font-mono);font-size:12px;">Calculate first to see results</div>
      <div id="{tab_id}_m_results" class="hidden">
{results_ids}
      </div>
    </div>
  </div>

  <script>
  function {tab_id}Tab(tab) {{
    document.getElementById("{tab_id}_panel_calc").classList.toggle("active", tab === "calc");
    document.getElementById("{tab_id}_panel_results").classList.toggle("active", tab === "results");
    document.querySelectorAll(".calc-mobile-tabs .calc-tab-btn").forEach((b, i) => b.classList.toggle("active", (i===0)===(tab==="calc")));
  }}
  {result_renderer}
  </script>
'''

    content = content.replace('</main>', mobile_html + '\n</main>')
    with open(path, 'w') as f:
        f.write(content)
    print(f"Done {template_file}")

# Redundancy mobile tabs
add_mobile_tabs(
    'redundancy_calculator.html',
    'red',
    '''      <div class="field-group"><label>Your Age</label><div class="input-wrap"><input type="number" id="r_age_m" placeholder="35" min="18" inputmode="numeric" /></div></div>
      <div class="field-group"><label>Years of Service</label><div class="input-wrap"><input type="number" id="r_years_m" placeholder="5" min="0" step="0.5" inputmode="numeric" /></div><p class="field-hint">Minimum 2 years to qualify.</p></div>
      <div class="field-group"><label>Weekly Gross Pay (£)</label><div class="input-wrap"><span class="prefix">£</span><input type="number" id="r_weekly_m" placeholder="650" min="0" inputmode="numeric" /></div></div>
      <button class="calculate-btn" onclick="calcRedMobile()"><span>Calculate Redundancy Pay</span></button>''',
    '''        <div class="verdict-banner"><p class="verdict-label">YOUR REDUNDANCY PAY</p><div class="verdict-number" id="red_m_total">£0</div></div>
        <div class="breakdown-block">
          <div class="breakdown-row"><span>Tax-free amount</span><span id="red_m_taxfree" style="color:var(--green)">£0</span></div>
          <div class="breakdown-row"><span>Taxable above £30k</span><span id="red_m_taxable">£0</span></div>
          <div class="breakdown-row total-row"><span>Total entitlement</span><span id="red_m_total2">£0</span></div>
        </div>
        <div class="savings-callout" id="red_m_insight"></div>''',
    '/calculate-redundancy',
    '''  async function calcRedMobile() {
    const age = parseInt(document.getElementById("r_age_m").value)||0;
    const years = parseFloat(document.getElementById("r_years_m").value)||0;
    const weekly = parseFloat(document.getElementById("r_weekly_m").value)||0;
    if (!age||years<2||!weekly){alert("Please enter age, at least 2 years service, and weekly pay.");return;}
    try {
      const res = await fetch("/calculate-redundancy",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({age,years_service:years,weekly_pay:weekly})});
      const r = await res.json();
      const fmt=n=>"£"+Math.round(n).toLocaleString("en-GB");
      document.getElementById("red_m_placeholder").classList.add("hidden");
      document.getElementById("red_m_results").classList.remove("hidden");
      document.getElementById("red_m_total").textContent=fmt(r.statutory_pay);
      document.getElementById("red_m_taxfree").textContent=fmt(r.tax_free);
      document.getElementById("red_m_taxable").textContent=r.taxable_above>0?fmt(r.taxable_above):"None";
      document.getElementById("red_m_total2").textContent=fmt(r.statutory_pay);
      document.getElementById("red_m_insight").textContent=r.taxable_above>0?"£"+r.taxable_above.toLocaleString()+" is taxable above the £30,000 tax-free threshold.":"Your full redundancy payment is tax-free.";
      redTab("results");
    } catch(e){alert("Something went wrong.");}
  }'''
)

# Maternity mobile tabs
add_mobile_tabs(
    'maternity_calculator.html',
    'mat',
    '''      <div class="field-group"><label>Annual Salary (£)</label><div class="input-wrap"><span class="prefix">£</span><input type="number" id="m_salary_mat" placeholder="35000" min="0" inputmode="numeric" /></div></div>
      <div class="field-group"><label>Leave Length</label>
        <div class="day-toggle" id="mat_weeks_toggle">
          <button class="day-btn active" data-val="39" onclick="setMatWeeks(this,39)">39 wks</button>
          <button class="day-btn" data-val="26" onclick="setMatWeeks(this,26)">26 wks</button>
          <button class="day-btn" data-val="52" onclick="setMatWeeks(this,52)">52 wks</button>
        </div>
      </div>
      <button class="calculate-btn" onclick="calcMatMobile()"><span>Calculate Maternity Pay</span></button>''',
    '''        <div class="verdict-banner"><p class="verdict-label">TOTAL MATERNITY PAY</p><div class="verdict-number" id="mat_m_total">£0</div></div>
        <div class="stat-cards">
          <div class="stat-card"><span class="stat-label">First 6 Weeks</span><span class="stat-value" id="mat_m_first6">£0/wk</span></div>
          <div class="stat-card highlight"><span class="stat-label">After 6 Weeks</span><span class="stat-value" id="mat_m_after6">£0/wk</span></div>
          <div class="stat-card"><span class="stat-label">Monthly During Leave</span><span class="stat-value" id="mat_m_monthly">£0</span></div>
          <div class="stat-card"><span class="stat-label">Income Lost</span><span class="stat-value" id="mat_m_lost">£0</span></div>
        </div>
        <div class="savings-callout" id="mat_m_insight"></div>''',
    '/calculate-maternity',
    '''  let matWeeksM = 39;
  function setMatWeeks(btn, w) {
    document.querySelectorAll("#mat_weeks_toggle .day-btn").forEach(b=>b.classList.remove("active"));
    btn.classList.add("active"); matWeeksM=w;
  }
  async function calcMatMobile() {
    const salary = parseFloat(document.getElementById("m_salary_mat").value)||0;
    if (!salary){alert("Please enter your salary.");return;}
    try {
      const res = await fetch("/calculate-maternity",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({salary,weeks:matWeeksM})});
      const r = await res.json();
      const fmt=n=>"£"+Math.round(n).toLocaleString("en-GB");
      document.getElementById("mat_m_placeholder").classList.add("hidden");
      document.getElementById("mat_m_results").classList.remove("hidden");
      document.getElementById("mat_m_total").textContent=fmt(r.total_smp);
      document.getElementById("mat_m_first6").textContent=fmt(r.weekly_first_6)+"/wk";
      document.getElementById("mat_m_after6").textContent=fmt(r.weekly_after_6)+"/wk";
      document.getElementById("mat_m_monthly").textContent=fmt(r.monthly_during_leave);
      document.getElementById("mat_m_lost").textContent=fmt(r.total_income_lost);
      document.getElementById("mat_m_insight").textContent="You will receive "+fmt(r.total_smp)+" over "+r.smp_weeks+" weeks — "+fmt(r.total_income_lost)+" less than your normal salary.";
      matTab("results");
    } catch(e){alert("Something went wrong.");}
  }'''
)

# Buy vs Rent mobile tabs
add_mobile_tabs(
    'buy_vs_rent.html',
    'bvr_m',
    '''      <div class="field-group"><label>Property Price (£)</label><div class="input-wrap"><span class="prefix">£</span><input type="number" id="bvr_price_m" placeholder="300000" min="0" inputmode="numeric" /></div></div>
      <div class="field-group"><label>Deposit (%)</label><div class="slider-wrap"><input type="range" id="bvr_dep_m" min="5" max="40" value="10" step="1" oninput="document.getElementById('bvr_dep_mv').textContent=this.value+'%'" /><span id="bvr_dep_mv" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:52px;">10%</span></div></div>
      <div class="field-group"><label>Mortgage Rate (%)</label><div class="slider-wrap"><input type="range" id="bvr_rate_m" min="1" max="10" value="4.5" step="0.1" oninput="document.getElementById('bvr_rate_mv').textContent=this.value+'%'" /><span id="bvr_rate_mv" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:52px;">4.5%</span></div></div>
      <div class="field-group"><label>Monthly Rent Alternative (£)</label><div class="input-wrap"><span class="prefix">£</span><input type="number" id="bvr_rent_m" placeholder="1500" min="0" inputmode="numeric" /></div></div>
      <div class="field-group"><label>Comparison Period (years)</label><div class="slider-wrap"><input type="range" id="bvr_yrs_m" min="1" max="30" value="10" step="1" oninput="document.getElementById('bvr_yrs_mv').textContent=this.value+' yrs'" /><span id="bvr_yrs_mv" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:60px;">10 yrs</span></div></div>
      <button class="calculate-btn" onclick="calcBVRMobile()"><span>Calculate Buy vs Rent</span></button>''',
    '''        <div class="verdict-banner"><p class="verdict-label" id="bvr_m_verdict">BUYING WINS</p><div class="verdict-number" id="bvr_m_margin">£0</div><p class="verdict-sub" id="bvr_m_sub">over 10 years</p></div>
        <div class="stat-cards">
          <div class="stat-card"><span class="stat-label">Monthly Mortgage</span><span class="stat-value" id="bvr_m_mortgage">£0</span></div>
          <div class="stat-card highlight"><span class="stat-label">Break Even</span><span class="stat-value" id="bvr_m_breakeven">0 yrs</span></div>
          <div class="stat-card"><span class="stat-label">Property Value</span><span class="stat-value" id="bvr_m_propval">£0</span></div>
          <div class="stat-card"><span class="stat-label">Equity Built</span><span class="stat-value" id="bvr_m_equity">£0</span></div>
        </div>
        <div class="savings-callout" id="bvr_m_insight"></div>''',
    '/calculate-buy-vs-rent',
    '''  async function calcBVRMobile() {
    const price = parseFloat(document.getElementById("bvr_price_m").value)||0;
    const rent = parseFloat(document.getElementById("bvr_rent_m").value)||0;
    if (!price||!rent){alert("Please enter property price and monthly rent.");return;}
    try {
      const res = await fetch("/calculate-buy-vs-rent",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({
        property_price:price,
        deposit_pct:parseFloat(document.getElementById("bvr_dep_m").value)||10,
        mortgage_rate:parseFloat(document.getElementById("bvr_rate_m").value)||4.5,
        mortgage_term:25,monthly_rent:rent,
        house_price_growth:3,stock_return:7,
        years:parseInt(document.getElementById("bvr_yrs_m").value)||10,
      })});
      const r = await res.json();
      const fmt=n=>"£"+Math.round(Math.abs(n)).toLocaleString("en-GB");
      document.getElementById("bvr_m_placeholder").classList.add("hidden");
      document.getElementById("bvr_m_results").classList.remove("hidden");
      document.getElementById("bvr_m_verdict").textContent=r.buying_wins?"BUYING WINS":"RENTING WINS";
      document.getElementById("bvr_m_margin").textContent=fmt(r.margin);
      document.getElementById("bvr_m_sub").textContent=(r.buying_wins?"better off buying":"better off renting")+" over "+r.years+" years";
      document.getElementById("bvr_m_mortgage").textContent=fmt(r.monthly_mortgage)+"/mo";
      document.getElementById("bvr_m_breakeven").textContent=(r.break_even_years||"30+")+' yrs';
      document.getElementById("bvr_m_propval").textContent=fmt(r.future_property_value);
      document.getElementById("bvr_m_equity").textContent=fmt(r.equity_after_years);
      document.getElementById("bvr_m_insight").textContent=r.buying_wins?"Buying wins by "+fmt(r.margin)+" over "+r.years+" years. Break-even point is around "+(r.break_even_years||"30+")+" years.":"Renting and investing your deposit wins by "+fmt(r.margin)+" over "+r.years+" years.";
      bvr_mTab("results");
    } catch(e){alert("Something went wrong.");}
  }'''
)

# Self-Employed mobile tabs
add_mobile_tabs(
    'self_employed_vs_paye.html',
    'se_m',
    '''      <div class="field-group"><label>PAYE Salary (£)</label><div class="input-wrap"><span class="prefix">£</span><input type="number" id="se_paye_m" placeholder="50000" min="0" inputmode="numeric" /></div></div>
      <div class="field-group"><label>Contract Day Rate (£)</label><div class="input-wrap"><span class="prefix">£</span><input type="number" id="se_rate_m" placeholder="350" min="0" inputmode="numeric" /></div></div>
      <div class="field-group"><label>Billable Days / Year</label><div class="slider-wrap"><input type="range" id="se_days_m" min="100" max="250" value="220" step="5" oninput="document.getElementById('se_days_mv').textContent=this.value+' days'" /><span id="se_days_mv" style="font-family:var(--font-display);font-size:22px;color:var(--accent);min-width:70px;">220 days</span></div></div>
      <div class="field-group"><label>Structure</label>
        <div class="transport-toggle" style="grid-template-columns:1fr 1fr;">
          <button class="transport-btn active" onclick="setSEMStructure(this,true)">Ltd Company</button>
          <button class="transport-btn" onclick="setSEMStructure(this,false)">Sole Trader</button>
        </div>
      </div>
      <button class="calculate-btn" onclick="calcSEMobile()"><span>Compare Self-Employed vs PAYE</span></button>''',
    '''        <div class="verdict-banner"><p class="verdict-label" id="se_m_verdict">SELF-EMPLOYED WINS</p><div class="verdict-number" id="se_m_diff">£0</div><p class="verdict-sub" id="se_m_sub">more per year</p></div>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:16px;">
          <div style="background:var(--panel);border:1px solid var(--border);padding:16px;">
            <p style="font-family:var(--font-mono);font-size:9px;color:var(--text-dimmer);">PAYE</p>
            <div style="font-family:var(--font-display);font-size:28px;color:var(--white);" id="se_m_paye">£0</div>
            <p style="font-size:11px;color:var(--text-dimmer);" id="se_m_paye_mo">£0/mo</p>
          </div>
          <div style="background:var(--panel);border:1px solid var(--border);padding:16px;">
            <p style="font-family:var(--font-mono);font-size:9px;color:var(--text-dimmer);" id="se_m_struct_label">LTD CO</p>
            <div style="font-family:var(--font-display);font-size:28px;color:var(--accent);" id="se_m_se">£0</div>
            <p style="font-size:11px;color:var(--text-dimmer);" id="se_m_se_mo">£0/mo</p>
          </div>
        </div>
        <div class="savings-callout" id="se_m_insight"></div>''',
    '/calculate-self-employed',
    '''  let seLtdM = true;
  function setSEMStructure(btn, ltd) {
    btn.closest(".transport-toggle").querySelectorAll(".transport-btn").forEach(b=>b.classList.remove("active"));
    btn.classList.add("active"); seLtdM=ltd;
  }
  async function calcSEMobile() {
    const paye=parseFloat(document.getElementById("se_paye_m").value)||0;
    const rate=parseFloat(document.getElementById("se_rate_m").value)||0;
    if (!paye||!rate){alert("Please enter salary and day rate.");return;}
    try {
      const res=await fetch("/calculate-self-employed",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({
        paye_salary:paye,day_rate:rate,
        days_per_year:parseInt(document.getElementById("se_days_m").value)||220,
        limited_company:seLtdM,expenses:0
      })});
      const r=await res.json();
      const fmt=n=>"£"+Math.round(Math.abs(n)).toLocaleString("en-GB");
      document.getElementById("se_m_placeholder").classList.add("hidden");
      document.getElementById("se_m_results").classList.remove("hidden");
      document.getElementById("se_m_verdict").textContent=r.se_wins?"SELF-EMPLOYED WINS":"PAYE WINS";
      document.getElementById("se_m_diff").textContent=fmt(r.difference);
      document.getElementById("se_m_sub").textContent=(r.se_wins?"more as "+r.structure:"more as PAYE employee");
      document.getElementById("se_m_paye").textContent=fmt(r.paye_take_home);
      document.getElementById("se_m_paye_mo").textContent=fmt(r.paye_monthly)+"/mo";
      document.getElementById("se_m_struct_label").textContent=r.structure.toUpperCase();
      document.getElementById("se_m_se").textContent=fmt(r.se_take_home);
      document.getElementById("se_m_se").style.color=r.se_wins?"var(--accent)":"var(--white)";
      document.getElementById("se_m_se_mo").textContent=fmt(r.se_monthly)+"/mo";
      document.getElementById("se_m_insight").textContent=r.se_wins?"As a "+r.structure+" you keep "+fmt(r.difference)+" more per year. Effective tax rate: "+r.effective_rate+"%.":"PAYE wins by "+fmt(Math.abs(r.difference))+" — you would need around "+fmt(r.day_rate_needed)+"/day to match your PAYE take-home.";
      se_mTab("results");
    } catch(e){alert("Something went wrong.");}
  }'''
)

print("All mobile tabs done")
PYEOF

echo ""
echo "Testing..."
cd "$TARGET" && python3 -c "import app; print('✅ OK')" 2>&1

echo ""
echo "Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Fix nav dropdown, add mobile tabs to all calculators' && git push"
