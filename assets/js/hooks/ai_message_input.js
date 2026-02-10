/**
 * AIMessageInput Hook
 *
 * Handles the AI message input textarea behavior:
 * - Auto-expand height as user types
 * - Submit on Enter (Shift+Enter for new line)
 * - Clear and reset on form submission
 */
export default {
  mounted() {
    // Submit on Enter (Shift+Enter for new line)
    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        const form = this.el.closest("form");
        if (form && this.el.value.trim()) {
          form.requestSubmit();
        }
      }
    });

    // Auto-expand textarea as content grows
    this.el.addEventListener("input", () => {
      this.el.style.height = "auto";
      this.el.style.height = this.el.scrollHeight + "px";
    });

    // Reset height after form submission
    const form = this.el.closest("form");
    if (form) {
      form.addEventListener("submit", () => {
        setTimeout(() => {
          this.el.value = "";
          this.el.style.height = "auto";
        }, 100);
      });
    }
  }
};
