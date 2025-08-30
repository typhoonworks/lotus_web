export default {
  mounted() {
    this.prev = this.el.value || "";
  },
  updated() {
    const v = this.el.value || "";
    if (v !== this.prev) {
      this.prev = v;
      this.el.dispatchEvent(new Event("input", { bubbles: true }));
      this.el.dispatchEvent(new Event("change", { bubbles: true }));
    }
  },
};
