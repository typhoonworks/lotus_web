const AIPromptInput = {
  mounted() {
    // Set initial value
    const prompt = this.el.dataset.prompt;
    if (prompt !== undefined) {
      this.el.value = prompt;
    }

    // Listen for custom clear event
    this.el.addEventListener("clear", () => {
      this.el.value = "";
      this.el.focus();
    });

    // Auto-focus when mounted and visible
    if (this.el.offsetParent !== null) {
      this.el.focus();
    }
  },
  updated() {
    // Update value when data-prompt changes
    const prompt = this.el.dataset.prompt;
    if (prompt !== undefined && this.el.value !== prompt) {
      this.el.value = prompt;
      // Re-focus after clearing
      if (prompt === "" && this.el.offsetParent !== null) {
        this.el.focus();
      }
    }
  }
};

export default AIPromptInput;
