#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "📝 Adding guide page..."

# Copy guide.html
cp ~/Downloads/guide.html "$TARGET/templates/guide.html" 2>/dev/null || echo "Note: copy guide.html manually if needed"

# Add /guide route to app.py if not already there
if ! grep -q "def guide" "$TARGET/app.py"; then
  sed -i '' 's|@app.route("/calculate")|@app.route("/guide")\ndef guide():\n    return render_template("guide.html")\n\n@app.route("/calculate")|' "$TARGET/app.py"
  echo "✅ Added /guide route to app.py"
else
  echo "✅ /guide route already exists"
fi

# Append blog CSS if not already there
if ! grep -q "blog-header" "$TARGET/static/css/style.css"; then
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* =============================================
   BLOG / GUIDE PAGE
   ============================================= */
.blog-header { border-bottom: 1px solid var(--border); background: var(--black); position: sticky; top: 0; z-index: 100; }
.blog-header-inner { max-width: 800px; margin: 0 auto; padding: 16px 40px; display: flex; align-items: center; justify-content: space-between; }
.blog-logo { font-family: var(--font-display); font-size: 24px; color: var(--accent); text-decoration: none; letter-spacing: 0.05em; }
.blog-cta { font-family: var(--font-mono); font-size: 11px; color: var(--black); background: var(--accent); padding: 8px 16px; text-decoration: none; letter-spacing: 0.1em; transition: background 0.2s; }
.blog-cta:hover { background: var(--white); }
.blog-main { background: var(--off-black); min-height: 100vh; padding: 60px 40px; }
.blog-inner { max-width: 800px; margin: 0 auto; }
.blog-hero { margin-bottom: 40px; }
.blog-tag { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.25em; color: var(--accent); display: block; margin-bottom: 16px; }
.blog-title { font-family: var(--font-display); font-size: clamp(36px, 6vw, 64px); line-height: 1.0; color: var(--white); margin-bottom: 20px; }
.blog-lead { font-size: 18px; color: var(--text-dim); line-height: 1.7; margin-bottom: 16px; font-weight: 300; max-width: 640px; }
.blog-meta { font-family: var(--font-mono); font-size: 11px; color: var(--text-dimmer); display: flex; gap: 8px; }
.blog-article h2 { font-family: var(--font-display); font-size: 32px; color: var(--white); margin: 40px 0 16px; }
.blog-article h3 { font-size: 16px; font-weight: 500; color: var(--text); margin: 24px 0 8px; }
.blog-article p { font-size: 15px; color: var(--text-dim); line-height: 1.8; margin-bottom: 16px; }
.blog-article a { color: var(--accent); text-decoration: none; border-bottom: 1px solid var(--accent-dim); }
.blog-article a:hover { color: var(--white); }
.blog-article strong { color: var(--text); font-weight: 500; }
.blog-callout { background: #0f0f00; border: 1px solid var(--accent); padding: 20px 24px; margin: 32px 0; }
.blog-callout p { margin: 0; color: var(--text-dim); font-size: 14px; }
.blog-table-wrap { overflow-x: auto; margin: 24px 0; }
.blog-table { width: 100%; border-collapse: collapse; font-size: 13px; }
.blog-table th { font-family: var(--font-mono); font-size: 10px; letter-spacing: 0.12em; color: var(--text-dimmer); text-transform: uppercase; padding: 10px 16px; border-bottom: 1px solid var(--border); text-align: left; background: var(--panel); }
.blog-table td { padding: 12px 16px; border-bottom: 1px solid var(--border); color: var(--text-dim); font-family: var(--font-mono); font-size: 12px; }
.blog-table tr:hover td { background: var(--panel); }
.blog-table-note { font-size: 11px; color: var(--text-dimmer); font-family: var(--font-mono); margin-top: 8px; }
.blog-tips { display: flex; flex-direction: column; gap: 16px; margin: 24px 0; }
.blog-tip { display: flex; gap: 20px; padding: 20px; background: var(--panel); border: 1px solid var(--border); }
.tip-num { font-family: var(--font-display); font-size: 32px; color: var(--accent); min-width: 40px; line-height: 1; }
.blog-tip strong { display: block; color: var(--text); font-weight: 500; margin-bottom: 6px; }
.blog-tip p { margin: 0; font-size: 13px; }
.blog-faq { display: flex; flex-direction: column; }
.blog-faq-item { padding: 24px 0; border-top: 1px solid var(--border); }
.blog-faq-item h3 { font-size: 15px; font-weight: 500; color: var(--text); margin-bottom: 10px; }
.blog-faq-item p { font-size: 14px; margin: 0; }
.blog-cta-block { background: var(--panel); border: 1px solid var(--accent); padding: 32px; margin-top: 48px; text-align: center; }
.blog-cta-block h3 { font-family: var(--font-display); font-size: 28px; color: var(--white); margin-bottom: 12px; }
.blog-cta-block p { font-size: 14px; color: var(--text-dim); margin-bottom: 24px; }
@media (max-width: 600px) { .blog-main { padding: 40px 16px; } .blog-header-inner { padding: 16px 20px; } .blog-tip { flex-direction: column; gap: 8px; } }
CSSEOF
  echo "✅ Added blog CSS"
fi

# Add guide link to footer in index.html
sed -i '' 's|Built for UK commuters · <a href="#">Privacy</a>|Built for UK commuters · <a href="#">Privacy</a> · <a href="/guide">Commute Guide</a>|' "$TARGET/templates/index.html"

echo ""
echo "✅ Guide page ready!"
echo ""
echo "Now push to GitHub:"
echo "  cd ~/Documents/Commute\ Tax"
echo "  git add ."
echo "  git commit -m 'Add guide page for AdSense approval'"
echo "  git push"
