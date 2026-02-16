export default {
  mounted() {
    this.el.addEventListener("click", (e) => {
      e.preventDefault();
      const idx = parseInt(this.el.dataset.tagRemove, 10);
      const hidden = document.getElementById(this.el.dataset.hiddenId);
      if (!hidden) return;

      const tags = hidden.value === "" ? [] : hidden.value.split(",");
      tags.splice(idx, 1);
      hidden.value = tags.join(",");
      hidden.dispatchEvent(new Event("input", { bubbles: true }));
      hidden.dispatchEvent(new Event("change", { bubbles: true }));
    });
  },
};
