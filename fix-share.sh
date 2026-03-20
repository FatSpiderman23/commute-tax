#!/bin/bash

TARGET=~/Documents/Commute\ Tax
echo "🔧 Fixing share buttons and updating affiliate links..."

# Update the share block in index.html
cat > /tmp/share_block.txt << 'SHAREEOF'
          <div class="share-block">
            <p class="share-label">Share your result</p>
            <div class="share-card" id="shareCard">
              <div class="share-card-inner">
                <p class="share-card-title">TRAVEL TAX</p>
                <p class="share-card-big" id="share-pct">0%</p>
                <p class="share-card-desc" id="share-desc">of my waking life goes on commuting.</p>
                <p class="share-card-url">traveltax.co.uk</p>
              </div>
            </div>
            <div class="share-btns-grid">
              <button class="share-btn s-twitter" onclick="shareToTwitter()">𝕏 Twitter</button>
              <button class="share-btn s-whatsapp" onclick="shareToWhatsApp()">💬 WhatsApp</button>
              <button class="share-btn s-linkedin" onclick="shareToLinkedIn()">in LinkedIn</button>
              <button class="share-btn s-copy" onclick="copyResult()">📋 Copy</button>
            </div>
            <p class="share-instagram-note">📸 Instagram: tap Copy, then paste into your story caption</p>
          </div>
SHAREEOF
echo "✅ Share block template ready"

# Add new share CSS
cat >> "$TARGET/static/css/style.css" << 'CSSEOF'

/* === UPDATED SHARE BUTTONS === */
.share-btns-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 10px; }
.share-btn { padding: 13px 8px; font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.06em; text-transform: uppercase; cursor: pointer; border: none; transition: opacity 0.2s, transform 0.15s; font-weight: 500; }
.share-btn:hover { opacity: 0.85; transform: translateY(-1px); }
.s-twitter  { background: #000; color: #fff; border: 1px solid #333; }
.s-whatsapp { background: #25D366; color: #fff; }
.s-linkedin { background: #0077B5; color: #fff; }
.s-copy     { background: var(--accent); color: var(--black); }
.share-instagram-note { font-family: var(--font-mono); font-size: 10px; color: var(--text-dimmer); letter-spacing: 0.05em; text-align: center; }
CSSEOF
echo "✅ Share CSS added"

# Update the nudge links in main.js to better UK affiliates
sed -i '' 's|https://www.workingnomads.com/jobs|https://www.reed.co.uk/jobs/remote-jobs|g' "$TARGET/static/js/main.js"
sed -i '' 's|Browse Remote Jobs →|Browse Remote Jobs on Reed →|g' "$TARGET/static/js/main.js"
sed -i '' 's|https://www.railcard.co.uk|https://www.trainline.com/railcards|g' "$TARGET/static/js/main.js"
sed -i '' 's|https://www.zap-map.com|https://www.autotrader.co.uk/electric-cars|g' "$TARGET/static/js/main.js"
echo "✅ Affiliate links updated to UK platforms"

# Add share functions to main.js
cat >> "$TARGET/static/js/main.js" << 'JSEOF'

// =============================================
// UPDATED SHARE FUNCTIONS
// =============================================

function getShareText(short) {
  if (!lastResult) return "";
  const pct = lastResult.pct_waking_life;
  const cost = fmt(lastResult.total_yearly_cost);
  const hrs = lastResult.commute_hours_yearly;
  if (short) {
    return `I spend ${pct}% of my waking life commuting — ${cost}/year I'll never get back. What's your Travel Tax?`;
  }
  const arLines = (window._arMetrics || []).slice(0, 3).map(m =>
    `• ${m.icon} ${m.shareText(window._arHours, window._arHourlyRate, window._arTransportCost)}`
  ).join('\n');
  return `My Travel Tax results:\n\n💸 Annual cost: ${cost}\n⏳ Hours lost: ${hrs}h/year\n🌅 Waking life: ${pct}%\n\nInstead I could have:\n${arLines}\n\ntraveltax.co.uk`;
}

function shareToTwitter() {
  if (!lastResult) return;
  const text = getShareText(true) + " 👇\ntraveltax.co.uk";
  window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`, "_blank");
}

function shareToWhatsApp() {
  if (!lastResult) return;
  const text = getShareText(false);
  window.open(`https://wa.me/?text=${encodeURIComponent(text)}`, "_blank");
}

function shareToLinkedIn() {
  if (!lastResult) return;
  // LinkedIn sharing via share URL
  const url = "https://traveltax.co.uk";
  const title = `I just calculated my Travel Tax — ${fmt(lastResult.total_yearly_cost)}/year`;
  window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`, "_blank");
}

function copyResult() {
  if (!lastResult) return;
  const text = getShareText(false);
  navigator.clipboard.writeText(text).then(() => showToast("Copied! Paste into Instagram, email, anywhere 📋"));
}
JSEOF
echo "✅ Share functions added"

echo ""
echo "✅ All done! Now:"
echo "  1. Manually update the share block in index.html (see instructions below)"
echo "  2. Push: cd ~/Documents/Commute\ Tax && git add . && git commit -m 'Fix sharing, update affiliates' && git push"
echo ""
echo "Share block to paste into index.html (replace the existing share-block div):"
cat /tmp/share_block.txt
