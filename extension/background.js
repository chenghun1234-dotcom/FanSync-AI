// FanSync AI Background Service Worker
import { PERSONA_ENGINE } from './personas.js';

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === "GENERATE_RESPONSE") {
    handleResponseGeneration(request.messages, request.spending || 0)
      .then(data => sendResponse({ success: true, data }))
      .catch(error => sendResponse({ success: false, error: error.message }));
    return true; // Keep channel open for async response
  }
  
  if (request.type === "ANALYZE_IMAGE") {
    handleImageAnalysis(request.imageData, request.platform || 'all')
      .then(data => sendResponse({ success: true, data }))
      .catch(error => sendResponse({ success: false, error: error.message }));
    return true;
  }
  
  if (request.type === "SAVE_AUTH_TOKEN") {
    chrome.storage.local.set({ 'auth_token': request.token }, () => {
      sendResponse({ success: true });
    });
    return true;
  }

  if (request.type === "SYNC_REVENUE") {
    handleRevenueSync(request.revenueData)
      .then(data => sendResponse({ success: true, data }))
      .catch(error => sendResponse({ success: false, error: error.message }));
    return true;
  }

  if (request.type === "GENERATE_X_VIRAL") {
    handleXViralGeneration(request.context)
      .then(data => sendResponse({ success: true, data }))
      .catch(error => sendResponse({ success: false, error: error.message }));
    return true;
  }

  if (request.type === "TEST_CONNECTION") {
    handleTestConnection()
      .then(() => sendResponse({ success: true }))
      .catch(error => sendResponse({ success: false, error: error.message }));
    return true;
  }
});

async function handleTestConnection() {
  const settings = await chrome.storage.local.get(['gemini_api_key']);
  if (!settings.gemini_api_key) throw new Error("API Key missing in storage.");
  
  const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${settings.gemini_api_key}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ contents: [{ parts: [{ text: "ping" }] }] })
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(errorData.error ? errorData.error.message : response.statusText);
  }
}

async function handleResponseGeneration(messages, spending) {
  // 1. Get settings from storage
  const settings = await chrome.storage.local.get(['gemini_api_key', 'ai_persona', 'target_lang', 'subscription_status', 'learned_style']);
  
  const apiKey = settings.gemini_api_key;
  const personaKey = settings.ai_persona || 'tsundere';
  const lang = settings.target_lang || "Japanese";
  const learnedStyle = settings.learned_style || {};
  
  const tierInfo = getTierPersona(spending);
  
  const langCode = lang === 'ja' ? 'ja' : 'en';
  
  // 2. Select optimal persona variant (Casual vs Sales)
  const selectedPersonaVariant = await getOptimalPersona(messages, settings.persona_variants || {});
  const systemPrompt = PERSONA_ENGINE.generateSystemPrompt(personaKey, langCode);

  if (!apiKey) throw new Error("API_KEY_MISSING");
  const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

  const prompt = `
    ${systemPrompt}

    [FAN TIER: ${tierInfo.tier}]
    - Fan Loyalty Level: ${tierInfo.tier}
    - Interaction Tone: ${tierInfo.tone}
    - Sales Strategy: ${tierInfo.strategy}

    [SPECIFIC TONE FOR CURRENT CONTEXT]
    ${selectedPersonaVariant || 'Maintain general creator persona.'}

    [학습된 나의 스타일]
    - 자주 쓰는 이모지: ${learnedStyle.topEmojis || 'N/A'}
    - 문장 톤: ${learnedStyle.sentenceTone || 'N/A'}
    - 선호 슬랭: ${learnedStyle.favoriteSlangs || 'N/A'}
    
    위의 페르소나, 상황별 어조, 학습된 스타일을 100% 반영하여 팬에게 답장을 작성하세요.
    - 한국어로 작성할 필요는 없으며, 팬이 사용하는 언어 감성을 유지하세요.
    - 대화의 목적이 결제 유도인지 일상 대화인지 파악하여 어조를 조절하세요.
    - 답변 끝에 반드시 [SALES_TIPS] 태그를 달고 에이전시 관리자를 위한 조언을 추가하세요.

    대화 맥락: ${JSON.stringify(messages)}
    답변:
  `;

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }]
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      if (response.status === 401) throw new Error("INVALID_API_KEY");
      if (response.status === 429) throw new Error("RATE_LIMIT_EXCEEDED");
      throw new Error(errorData.error?.message || "AI_REQUEST_FAILED");
    }

    const data = await response.json();
    return data.candidates[0].content.parts[0].text.trim();
  } catch (error) {
    console.error("FanSync AI Gemini Error:", error);
    throw error;
  }
}

async function handleImageAnalysis(imageData, platform) {
  const settings = await chrome.storage.local.get(['gemini_api_key', 'target_lang']);
  const apiKey = settings.gemini_api_key;
  const lang = settings.target_lang || "Japanese";

  if (!apiKey) throw new Error("API_KEY_MISSING");

  const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

  const prompt = `
    Analyze this image and generate optimized creator content for ${platform === 'all' ? 'Instagram, X (Twitter), and OnlyFans' : platform}.
    The target audience speaks ${lang}.
    
    [INSTAGRAM]: Aesthetic caption, Reels music suggestion, and 30 relevant hashtags.
    [X]: Short, viral hooks, and 2-3 trending keywords.
    [ONLYFANS]: Teaser text and a suggested PPV (Pay-Per-View) price.
    
    Respond in a clear format using tags: [INSTAGRAM], [X], [ONLYFANS].
  `;

  // Remove base64 prefix if exists
  const base64Data = imageData.split(',')[1] || imageData;

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              { text: prompt },
              {
                inline_data: {
                  mime_type: "image/jpeg",
                  data: base64Data
                }
              }
            ]
          }
        ]
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error?.message || "VISION_API_FAILED");
    }

    const data = await response.json();
    return data.candidates[0].content.parts[0].text.trim();
  } catch (error) {
    console.error("FanSync AI Vision Error:", error);
    throw error;
  }
}

async function handleXViralGeneration(context) {
  const settings = await chrome.storage.local.get(['gemini_api_key', 'ai_persona', 'target_lang']);
  const apiKey = settings.gemini_api_key;
  const personaKey = settings.ai_persona || 'tsundere';
  const persona = PERSONA_ENGINE.configs[personaKey];

  if (!apiKey) throw new Error("API_KEY_MISSING");
  const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

  const prompt = `
    너는 OnlyFans 크리에이터 '${persona.name}'로서 X(트위터)에서 바이럴 성장을 노리는 가상의 페르소나이다.
    다음 컨텍스트를 바탕으로, 답글(Reply) 또는 포스트를 작성하라.

    [CONTEXT]
    ${context}

    [VIRAL STRATEGY: KEYWORD SEO & ENGAGEMENT]
    1. **Keyword SEO**: 해당 분야에서 검색량이 높은 키워드와 후킹 문구를 문장 내에 자연스럽게 녹여라.
    2. **Emotional Hook**: 사람들의 호기심, 공감, 또는 가벼운 논쟁을 불러일으킬 수 있는 문장을 사용하라.
    3. **Short & Punchy**: X의 특성상 140자 이내로 짧고 강렬하게 작성하라.
    4. **Auto-Hashtags**: 내용과 관련이 깊은 인기 해시태그 1~2개를 반드시 포함하라.
    
    [TONE OF VOICE]
    ${persona.traits} 
    말투: ${persona.rules.en} (Wait, Use the persona's vibe but optimized for X growth).

    작성된 답변:
  `.trim();

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }]
      })
    });

    if (!response.ok) throw new Error("X_VIRAL_API_FAILED");
    const data = await response.json();
    return data.candidates[0].content.parts[0].text.trim();
  } catch (error) {
    console.error("FanSync AI X Viral Error:", error);
    throw error;
  }
}

// AI logic for switching between Casual and Sales personas based on context
async function getOptimalPersona(messages, variants) {
  if (!variants || (!variants.sales && !variants.casual)) return null;

  // Check for sales keywords in recent messages
  const salesKeywords = ['$', 'buy', 'pic', 'video', 'content', 'price', 'menu', 'unlock', 'ppv', '구매', '가격', '사진'];
  const lastFanMessage = messages.slice().reverse().find(m => m.role === 'fan')?.text.toLowerCase() || "";
  
  const isSalesContext = salesKeywords.some(keyword => lastFanMessage.includes(keyword));

  return isSalesContext ? (variants.sales || variants.casual) : variants.casual;
}

async function handleRevenueSync(revenueData) {
  const SUPABASE_URL = 'https://abclfexwwxulczcuubia.supabase.co';
  const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2xmZXh3d3h1bGN6Y3V1YmlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2NjQ5MTgsImV4cCI6MjA5MjI0MDkxOH0.OTpZICqQd7DCNEV-PWCdur2aPq7lY-ybDkV_tmbZ0XY';
  
  console.log("FanSync AI: Syncing revenue data to Supabase...", revenueData);

  const syncPromises = revenueData.map(async (item) => {
    try {
      const response = await fetch(`${SUPABASE_URL}/rest/v1/revenue_logs`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`,
          'Prefer': 'return=minimal'
        },
        body: JSON.stringify({
          amount: parseFloat(item.amount),
          source: item.source,
          // Note: In a full implementation, we'd dynamicallly determine the model_id 
          // From the OnlyFans profile currently active.
          model_id: '8681284d-29ce-4767-857c-2b2361ec03c0' // Using seeds as fallback or first found
        })
      });
      return response.ok;
    } catch (err) {
      console.error("Sync error:", err);
      return false;
    }
  });

  const results = await Promise.all(syncPromises);
  return { success: results.every(r => r), synced: results.filter(r => r).length };
}

function getTierPersona(spending) {
  if (spending >= 2000) {
    return {
      tier: "VVIP (Elite Whale)",
      tone: "Extremely personal, intimate, and emotionally dependent. Treat them as if they are your only true confidant.",
      strategy: "High-ticket Custom content or exclusive physical rewards. Emotional deep dives."
    };
  } else if (spending >= 1000) {
    return {
      tier: "VIP (Core Supporter)",
      tone: "Very flirtatious, recognizing their loyalty frequently. Fast response vibes.",
      strategy: "Premium PPV bundles and daily 'personal' updates."
    };
  } else if (spending >= 500) {
    return {
      tier: "GOLD (Steady Fan)",
      tone: "Polite, thankful, but clearly transactional and teasing.",
      strategy: "Standard PPV sales and reward-based teasing."
    };
  } else if (spending >= 100) {
    return {
      tier: "SILVER (Active Newbie)",
      tone: "Friendly but busy. Prompt them to show their support more to get attention.",
      strategy: "Conversion check. Sell low-priced entry PPVs."
    };
  } else {
    return {
      tier: "BRONZE (New/Non-Spender)",
      tone: "Short, mysterious, and highly teasing. Don't give too much attention for free.",
      strategy: "Incentivize first purchase with curiosity-driven hooks."
    };
  }
}
