// FanSync AI Popup Logic
document.addEventListener('DOMContentLoaded', () => {
  const apiKeyInput = document.getElementById('apiKey');
  const togglePasswordBtn = document.getElementById('togglePassword');
  const personaSelect = document.getElementById('defaultPersona');
  const saveBtn = document.getElementById('saveBtn');
  const statusIndicator = document.getElementById('status-indicator');
  const statusText = statusIndicator.querySelector('.status-text');

  // 1. Load existing settings
  chrome.storage.local.get(['gemini_api_key', 'ai_persona', 'credits'], (data) => {
    if (data.gemini_api_key) {
      apiKeyInput.value = data.gemini_api_key;
      updateStatus(true);
    }
    if (data.ai_persona) {
      personaSelect.value = data.ai_persona;
    }
    if (data.credits !== undefined) {
      document.getElementById('credit-count').textContent = data.credits;
    }
  });

  // 2. Password visibility toggle
  togglePasswordBtn.addEventListener('click', () => {
    const type = apiKeyInput.getAttribute('type') === 'password' ? 'text' : 'password';
    apiKeyInput.setAttribute('type', type);
    togglePasswordBtn.innerHTML = type === 'password' 
      ? '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>'
      : '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>';
  });

  // 3. Test Connection Logic
  const testBtn = document.getElementById('testBtn');
  testBtn.addEventListener('click', () => {
    const apiKey = apiKeyInput.value.trim();
    if (!apiKey) {
      showError('Please enter an API Key to test.');
      return;
    }

    testBtn.disabled = true;
    testBtn.textContent = 'Testing...';

    // Temporary set to storage for background.js to use
    chrome.storage.local.set({ 'gemini_api_key': apiKey }, () => {
      chrome.runtime.sendMessage({ type: "TEST_CONNECTION" }, (response) => {
        testBtn.disabled = false;
        testBtn.textContent = 'Test Connection';

        if (response && response.success) {
          alert('✅ Connection Successful! Gemini API is active.');
          updateStatus(true);
        } else {
          showError('❌ Connection Failed: ' + (response ? response.error : 'Unknown error'));
          updateStatus(false);
        }
      });
    });
  });

  // 4. Save Logic
  saveBtn.addEventListener('click', () => {
    const apiKey = apiKeyInput.value.trim();
    const persona = personaSelect.value;

    if (!apiKey) {
      showError('Please enter an API Key');
      return;
    }

    saveBtn.disabled = true;
    saveBtn.textContent = 'Saving...';

    chrome.storage.local.set({
      'gemini_api_key': apiKey,
      'ai_persona': persona
    }, () => {
      setTimeout(() => {
        saveBtn.disabled = false;
        saveBtn.textContent = 'Settings Saved!';
        saveBtn.style.background = '#10B981';
        updateStatus(true);

        setTimeout(() => {
          saveBtn.textContent = 'Save Settings';
          saveBtn.style.background = '#008FDB';
        }, 2000);
      }, 500);
    });
  });

  function updateStatus(connected) {
    if (connected) {
      statusIndicator.classList.add('connected');
      statusText.textContent = 'Connected';
    } else {
      statusIndicator.classList.remove('connected');
      statusText.textContent = 'Disconnected';
    }
  }

  function showError(msg) {
    alert(msg); // Simple for now, can be improved to a toast
  }
});
