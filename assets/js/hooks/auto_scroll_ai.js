/**
 * AutoScrollAI Hook
 *
 * Automatically scrolls the AI conversation history to the bottom
 * when new messages are added.
 */
export default {
  mounted() {
    this.scrollToBottom();
  },

  updated() {
    this.scrollToBottom();
  },

  scrollToBottom() {
    this.el.scrollTop = this.el.scrollHeight;
  }
};
