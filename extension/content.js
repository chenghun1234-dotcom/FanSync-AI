// FanSync AI Content Script
let aiButtonInjected = false;

function injectAIButton() {
  // OnlyFans chat input controls area
  const controlsArea = document.querySelector('.b-chat__message-footer .g-user-select-none');
  
  if (controlsArea && !document.querySelector('#fansync-ai-btn')) {
    const aiBtn = document.createElement('button');
    aiBtn.id = 'fansync-ai-btn';
    aiBtn.innerHTML = '<span>🤖</span> FanSync AI';
    aiBtn.type = 'button';
    
    aiBtn.onclick = async () => {
      const messages = getChatContext();
      if (messages.length === 0) return alert("No messages found to analyze.");

      // Scrape Fan Tier Info
      const spending = getFanSpendingInfo();
      updateTierBadge(spending);

      aiBtn.innerHTML = '<span>⏳</span> Analyzing...';
      aiBtn.disabled = true;

      // Communicate with background.js
      chrome.runtime.sendMessage({
        type: "GENERATE_RESPONSE",
        messages: messages,
        spending: spending
      }, (response) => {
        aiBtn.innerHTML = '<span>🤖</span> FanSync AI';
        aiBtn.disabled = false;

        if (response.success) {
          const chatInput = document.querySelector('.b-chat__message-input textarea');
          if (chatInput) {
            // Split reply text and sales tip
            const [replyText, salesTip] = response.data.split('[SALES_TIPS]');
            
            chatInput.value = replyText.trim();
            chatInput.dispatchEvent(new Event('input', { bubbles: true }));

            if (salesTip) {
              showSalesGuide(salesTip.trim());
            }
          }
        } else {
          handleError(response.error);
        }
      });
    };

    controlsArea.prepend(aiBtn);
    console.log("FanSync AI: AI Button injected!");
  }
}

function getChatContext() {
  const messageElements = document.querySelectorAll('.b-chat__message');
  const context = [];
  
  // Get last 5 messages
  const recentMessages = Array.from(messageElements).slice(-5);
  
  recentMessages.forEach(el => {
    // Determine sender (Simplified check, OnlyFans uses 'm-self' for own messages)
    const isSelf = el.classList.contains('m-self'); 
    const textElement = el.querySelector('.b-chat__message__text');
    
    if (textElement) {
      context.push({
        role: isSelf ? 'creator' : 'fan',
        text: textElement.innerText.trim()
      });
    }
  });
  
  return context;
}

function showSalesGuide(tip) {
  let guideBox = document.querySelector('#fansync-sales-guide');
  if (!guideBox) {
    guideBox = document.createElement('div');
    guideBox.id = 'fansync-sales-guide';
    document.body.appendChild(guideBox);
  }
  guideBox.innerHTML = `<strong>💡 AI Sales Tip:</strong> ${tip}`;
  
  // Auto-hide after 10 seconds
  setTimeout(() => {
    if (guideBox) guideBox.remove();
  }, 10000);
}

function handleError(errorCode) {
  const errors = {
    "API_KEY_MISSING": "Gemini API Key is missing. Check extension settings.",
    "INVALID_API_KEY": "Invalid Gemini API Key.",
    "RATE_LIMIT_EXCEEDED": "Gemini API rate limit exceeded.",
    "SUBSCRIPTION_EXPIRED": "Your FanSync AI trial or subscription has expired."
  };
  alert("FanSync AI Error: " + (errors[errorCode] || errorCode));
}

// Determine current platform
const isOnlyFans = window.location.hostname.includes('onlyfans.com');
const isX = window.location.hostname.includes('x.com') || window.location.hostname.includes('twitter.com');

// Observe changes for dynamic loading
const observer = new MutationObserver((mutations) => {
  if (isOnlyFans) {
    injectAIButton();
    injectPostAnalysisButton();
  }
  if (isX) {
    injectXViralButton();
  }
});

observer.observe(document.body, {
  childList: true,
  subtree: true
});

if (isOnlyFans) {
  injectAIButton();
  injectPostAnalysisButton();
  detectRevenuePage();
}

if (isX) {
  injectXViralButton();
}

function detectRevenuePage() {
  if (window.location.href.includes('onlyfans.com/my/statistics/statements')) {
    console.log("FanSync AI: Revenue page detected. Capturing data...");
    
    // Wait for data to load
    setTimeout(() => {
      const revenueRows = document.querySelectorAll('.b-statistics__table tbody tr');
      const capturedData = [];
      
      revenueRows.forEach(row => {
        const columns = row.querySelectorAll('td');
        if (columns.length >= 3) {
          capturedData.push({
            date: columns[0].innerText.trim(),
            amount: columns[2].innerText.replace('$', '').trim(),
            source: columns[1].innerText.trim()
          });
        }
      });
      
      if (capturedData.length > 0) {
        chrome.runtime.sendMessage({
          type: "SYNC_REVENUE",
          revenueData: capturedData
        });
      }
    }, 3000);
  }
}

function injectPostAnalysisButton() {
  // OnlyFans Post Composer controls (Where images appear)
  const composerFooter = document.querySelector('.b-post-composer__footer .b-post-composer__action-group');
  
  if (composerFooter && !document.querySelector('#fansync-post-btn')) {
    const postBtn = document.createElement('button');
    postBtn.id = 'fansync-post-btn';
    postBtn.className = 'g-btn m-rounded m-flex-center'; // OF style classes
    postBtn.innerHTML = '<span>📸</span> AI Multi-Platform Analysis';
    postBtn.style.marginLeft = '10px';
    postBtn.style.backgroundColor = '#008fdb';
    postBtn.style.color = 'white';
    postBtn.style.border = 'none';
    postBtn.style.padding = '8px 16px';
    postBtn.style.borderRadius = '20px';
    postBtn.style.fontSize = '12px';
    postBtn.style.fontWeight = 'bold';
    postBtn.style.cursor = 'pointer';

    postBtn.onclick = async () => {
      // Find the first image preview in the composer
      const imgPreview = document.querySelector('.b-post-composer__item-img img');
      if (!imgPreview) return alert("Please upload an image first.");

      postBtn.innerText = '⏳ Analyzing Image...';
      postBtn.disabled = true;

      try {
        // Convert image to base64
        const base64Image = await getBase64FromUrl(imgPreview.src);

        chrome.runtime.sendMessage({
          type: "ANALYZE_IMAGE",
          imageData: base64Image,
          platform: 'all'
        }, (response) => {
          postBtn.innerHTML = '<span>📸</span> AI Multi-Platform Analysis';
          postBtn.disabled = false;

          if (response.success) {
            alert("Analysis Complete! Check the dashboard or use these tips:\n\n" + response.data);
            // In a better version, we'd open a side panel or populate the text area
          } else {
            handleError(response.error);
          }
        });
      } catch (err) {
        alert("Failed to capture image: " + err.message);
        postBtn.disabled = false;
      }
    };

    composerFooter.appendChild(postBtn);
  }
}

async function getBase64FromUrl(url) {
  const response = await fetch(url);
  const blob = await response.blob();
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

function getFanSpendingInfo() {
  // Try to find spending in sidebar/header (simplified selector for OF)
  const statsElements = document.querySelectorAll('.b-user-info__stats-item, .b-profile__header__stats-item');
  let totalSpent = 0;

  statsElements.forEach(el => {
    if (el.innerText.toLowerCase().includes('spent')) {
      const value = el.querySelector('.b-user-info__stats-value, .b-profile__header__stats-value')?.innerText;
      if (value) {
        totalSpent = parseFloat(value.replace('$', '').replace(',', '')) || 0;
      }
    }
  });

  return totalSpent;
}

function updateTierBadge(spending) {
  let badge = document.querySelector('#fansync-tier-badge');
  if (!badge) {
    badge = document.createElement('div');
    badge.id = 'fansync-tier-badge';
    badge.style.display = 'inline-block';
    badge.style.marginLeft = '10px';
    badge.style.padding = '4px 8px';
    badge.style.borderRadius = '12px';
    badge.style.fontSize = '10px';
    badge.style.fontWeight = 'bold';
    badge.style.color = 'white';
    badge.style.verticalAlign = 'middle';
    
    const controlsArea = document.querySelector('.b-chat__message-footer .g-user-select-none');
    if (controlsArea) controlsArea.appendChild(badge);
  }

  let tier = "BRONZE";
  let color = "#A52A2A";

  if (spending >= 2000) { tier = "VVIP"; color = "#FF00FF"; }
  else if (spending >= 1000) { tier = "VIP"; color = "#8A2BE2"; }
  else if (spending >= 500) { tier = "GOLD"; color = "#FFD700"; }
  else if (spending >= 100) { tier = "SILVER"; color = "#C0C0C0"; }

  badge.innerText = `[TIER: ${tier}]`;
  badge.style.backgroundColor = color;
  badge.title = `Total Spent: $${spending}`;
}

function injectXViralButton() {
  // X (Twitter) Tweet/Reply composer selector
  const composerFooters = document.querySelectorAll('[data-testid="toolBar"]');
  
  composerFooters.forEach(toolbar => {
    if (!toolbar.querySelector('#fansync-x-btn')) {
      const xBtn = document.createElement('button');
      xBtn.id = 'fansync-x-btn';
      xBtn.innerHTML = '<span>🚀</span> AI Viral';
      xBtn.type = 'button';
      
      // Bold Branded Style (Blue Gradient)
      xBtn.style.background = 'linear-gradient(135deg, #008fdb 0%, #00c6ff 100%)';
      xBtn.style.color = 'white';
      xBtn.style.border = 'none';
      xBtn.style.padding = '6px 14px';
      xBtn.style.borderRadius = '20px';
      xBtn.style.fontSize = '12px';
      xBtn.style.fontWeight = 'bold';
      xBtn.style.cursor = 'pointer';
      xBtn.style.marginLeft = '8px';
      xBtn.style.boxShadow = '0 4px 10px rgba(0, 143, 219, 0.3)';
      xBtn.style.transition = 'all 0.2s ease';

      xBtn.onclick = async () => {
        const parentTweet = getXContext();
        xBtn.innerText = '⏳ Viralizing...';
        xBtn.disabled = true;

        chrome.runtime.sendMessage({
          type: "GENERATE_X_VIRAL",
          context: parentTweet
        }, (response) => {
          xBtn.innerHTML = '<span>🚀</span> AI Viral';
          xBtn.disabled = false;

          if (response.success) {
            const editor = toolbar.closest('[data-viewportview="true"]')?.parentElement?.querySelector('[data-testid="tweetTextarea_0"]');
            if (editor) {
              // X usesDraftJS/Lexical, so we simulate typing
              editor.focus();
              document.execCommand('insertText', false, response.data);
            } else {
              // Fallback for different X layouts
              const textarea = document.querySelector('[role="textbox"]');
              if (textarea) textarea.innerText = response.data;
            }
          } else {
            handleError(response.error);
          }
        });
      };

      toolbar.appendChild(xBtn);
    }
  });
}

function getXContext() {
  // Get text of the tweet we are replying to
  const tweetText = document.querySelector('[data-testid="tweetText"]')?.innerText || "";
  const author = document.querySelector('[data-testid="User-Name"]')?.innerText || "Someone";
  
  return `Tweet by ${author}: "${tweetText}"`;
}

window.addEventListener("message", (event) => {
  // Sync login status from Flutter Web Dashboard to Extension
  if (event.data && event.data.type === 'FANSYNC_LOGIN_SUCCESS') {
    const token = event.data.token;
    
    chrome.runtime.sendMessage({
      type: "SAVE_AUTH_TOKEN",
      token: token
    }, (response) => {
      console.log("FanSync AI: Login synchronized with extension.");
    });
  }
});
