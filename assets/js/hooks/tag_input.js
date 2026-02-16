export default {
  mounted() {
    this._pendingFocus = false;
    this._pendingScroll = false;
    this._lastTagCount = parseInt(this.el.dataset.tagCount, 10) || 0;

    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        const value = this.el.value.trim();
        if (value !== "") {
          this.addTag(value);
          this.el.value = "";
        }
      } else if (e.key === "Backspace" && this.el.value === "") {
        this.removeLastTag();
      }
    });
  },

  updated() {
    if (this._pendingFocus) {
      this._pendingFocus = false;
      this.el.focus();
    }

    const newCount = parseInt(this.el.dataset.tagCount, 10) || 0;
    if (this._pendingScroll && newCount > this._lastTagCount) {
      const chipsContainer = this.el.previousElementSibling;
      if (chipsContainer) {
        chipsContainer.scrollLeft = chipsContainer.scrollWidth;
      }
    }
    this._pendingScroll = false;
    this._lastTagCount = newCount;
  },

  getHidden() {
    return document.getElementById(this.el.dataset.hiddenId);
  },

  addTag(value) {
    const current = this.getTags();
    current.push(value);
    this._pendingFocus = true;
    this._pendingScroll = true;
    this.setTags(current);
  },

  removeLastTag() {
    const current = this.getTags();
    if (current.length > 0) {
      current.pop();
      this._pendingFocus = true;
      this.setTags(current);
    }
  },

  getTags() {
    const hidden = this.getHidden();
    if (!hidden) return [];
    const val = hidden.value;
    return val === "" ? [] : val.split(",");
  },

  setTags(tags) {
    const hidden = this.getHidden();
    if (!hidden) return;
    hidden.value = tags.join(",");
    hidden.dispatchEvent(new Event("input", { bubbles: true }));
    hidden.dispatchEvent(new Event("change", { bubbles: true }));
  },
};
