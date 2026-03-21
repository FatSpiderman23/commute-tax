#!/bin/bash
TARGET=~/Documents/Commute\ Tax
echo "🔧 Adding navigation and ads to all pages..."

python3 << 'PYEOF'
import os

# Navigation HTML to inject after slim-header or blog-header
NAV_HTML = '''  <!-- TOP NAV -->
  <nav class="top-nav">
    <div class="top-nav-inner">
      <a href="/" class="nav-link">Commute Tax</a>
      <a href="/take-home" class="nav-link">Take Home Pay</a>
      <a href="/compare-jobs" class="nav-link">Compare Jobs</a>
      <a href="/guide" class="nav-link">Commute Guide</a>
      <a href="/blog" class="nav-link">Blog</a>
    </div>
  </nav>

'''

# Ad slot HTML
AD_SLOT = '''  <!-- AD SLOT -->
  <div class="ad-slot ad-leaderboard">
    <span class="ad-label">Advertisement</span>
    <!--
    <ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-8725854592183933" data-ad-slot="1111111111" data-ad-format="auto" data-full-width-responsive="true"></ins>
    <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
    -->
  </div>

'''

templates = [
    'index.html',
    'take_home.html',
    'compare_jobs.html',
    'guide.html',
    'blog_index.html',
    'blog_post.html',
    'city.html',
    'privacy.html',
]

for tmpl in templates:
    path = os.path.join('/Users/ss/Documents/Commute Tax/templates', tmpl)
    if not os.path.exists(path):
        print(f"Skipping {tmpl} - not found")
        continue

    with open(path, 'r') as f:
        content = f.read()

    # Add nav after header closing tag
    if '<nav class="top-nav">' not in content:
        # Find end of header tag
        for header_end in ['</header>\n', '</header>']:
            if header_end in content:
                content = content.replace(
                    header_end,
                    header_end + NAV_HTML,
                    1  # only first occurrence
                )
                break
        print(f"Added nav to {tmpl}")
    else:
        print(f"Nav already exists in {tmpl}")

    # Add ad slot after nav (only if not already there on this page)
    if 'ad-leaderboard' not in content:
        content = content.replace(NAV_HTML, NAV_HTML + AD_SLOT, 1)
        print(f"Added ad slot to {tmpl}")

    with open(path, 'w') as f:
        f.write(content)

print("Done all templates")
PYEOF

# Add nav CSS
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* =============================================
   TOP NAVIGATION
   ============================================= */
.top-nav {
  background: var(--off-black);
  border-bottom: 1px solid var(--border);
  position: sticky;
  top: 0;
  z-index: 100;
}

.top-nav-inner {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 40px;
  display: flex;
  align-items: center;
  gap: 0;
  overflow-x: auto;
  scrollbar-width: none;
}

.top-nav-inner::-webkit-scrollbar { display: none; }

.nav-link {
  display: block;
  padding: 14px 20px;
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--text-dimmer);
  text-decoration: none;
  border-bottom: 2px solid transparent;
  white-space: nowrap;
  transition: color 0.15s, border-color 0.15s;
}

.nav-link:hover {
  color: var(--accent);
  border-bottom-color: var(--accent);
}

.nav-link.active {
  color: var(--accent);
  border-bottom-color: var(--accent);
}

@media (max-width: 768px) {
  .top-nav-inner { padding: 0 16px; gap: 0; }
  .nav-link { padding: 12px 14px; font-size: 10px; }
}
CSSEOF

echo "✅ Nav CSS added"

# Mark active nav link per page using Flask
python3 << 'PYEOF'
import os

# Add active class to nav links per page
page_nav_map = {
    'index.html': 'Commute Tax',
    'take_home.html': 'Take Home Pay',
    'compare_jobs.html': 'Compare Jobs',
    'guide.html': 'Commute Guide',
    'blog_index.html': 'Blog',
    'blog_post.html': 'Blog',
    'city.html': 'Blog',
}

for tmpl, active_label in page_nav_map.items():
    path = os.path.join('/Users/ss/Documents/Commute Tax/templates', tmpl)
    if not os.path.exists(path):
        continue
    with open(path, 'r') as f:
        content = f.read()

    # Find the nav link for this page and add active class
    old = f'>{active_label}</a>'
    new = f' active">{active_label}</a>'
    # Fix: replace class="nav-link"> with class="nav-link active">
    content = content.replace(
        f'"nav-link">{active_label}</a>',
        f'"nav-link active">{active_label}</a>',
        1
    )

    with open(path, 'w') as f:
        f.write(content)

print("Done active states")
PYEOF

echo ""
echo "Testing..."
cd "$TARGET" && python3 -c "import app; print('OK')" 2>&1

echo ""
echo "Push with:"
echo "  cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Add top nav and ads to all pages' && git push"
