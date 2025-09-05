const Flash = {
  mounted() {
    const el = this.el;
    if (["client-error", "server-error"].includes(el.id)) return;

    const timeout = parseInt(el.dataset.timeout || "5000", 10);
    const fadeDelay = 500;

    // Store timeout IDs so we can clear them if user dismisses manually
    this.timeoutId = setTimeout(() => {
      if (el.parentNode) { // Only fade if still in DOM
        el.style.opacity = "0";
      }
    }, timeout);

    this.removeTimeoutId = setTimeout(() => {
      if (el.parentNode) { // Only remove if still in DOM
        this.clearFlash();
      }
    }, timeout + fadeDelay);

    // Add click listener for manual dismiss button
    const dismissButton = el.querySelector('[aria-label="Dismiss"]');
    if (dismissButton) {
      dismissButton.addEventListener('click', () => {
        this.dismissFlash();
      });
    }
  },

  dismissFlash() {
    const el = this.el;
    
    // Clear existing timeouts
    if (this.timeoutId) clearTimeout(this.timeoutId);
    if (this.removeTimeoutId) clearTimeout(this.removeTimeoutId);
    
    // Fade out immediately
    el.style.opacity = "0";
    
    // Remove after fade delay
    setTimeout(() => {
      if (el.parentNode) {
        this.clearFlash();
      }
    }, 200);
  },

  clearFlash() {
    const el = this.el;
    let key = el.dataset.key;
    if (!key && el.id && el.id.startsWith("flash-")) {
      key = el.id.replace("flash-", "");
    }
    this.pushEvent("lv:clear-flash", { key });
    el.remove();
  },

  destroyed() {
    // Clear timeouts if component is destroyed
    if (this.timeoutId) clearTimeout(this.timeoutId);
    if (this.removeTimeoutId) clearTimeout(this.removeTimeoutId);
  }
};

export default Flash;