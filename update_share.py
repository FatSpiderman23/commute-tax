#!/usr/bin/env python3
import re

path = os.path.expanduser("~/Documents/Commute Tax/templates/index.html")

import os
path = os.path.expanduser("~/Documents/Commute Tax/templates/index.html")

with open(path, "r") as f:
    content = f.read()

new_share_block = '''          <div class="share-block">
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
              <button class="share-btn s-twitter" onclick="shareToTwitter()">&#x1D54F; Twitter</button>
              <button class="share-btn s-whatsapp" onclick="shareToWhatsApp()">&#x1F4AC; WhatsApp</button>
              <button class="share-btn s-linkedin" onclick="shareToLinkedIn()">in LinkedIn</button>
              <button class="share-btn s-copy" onclick="copyResult()">&#x1F4CB; Copy</button>
            </div>
            <p class="share-instagram-note">&#x1F4F8; Instagram: tap Copy, then paste into your story caption</p>
          </div>'''

# Replace the share block
pattern = r'<div class="share-block">.*?</div>\s*</div>\s*\n\s*<div class="nudge-block"'
replacement = new_share_block + '\n\n          <div class="nudge-block"'

new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open(path, "w") as f:
    f.write(new_content)

print("✅ Share block updated in index.html")
