import tippy from "tippy.js";
import "tippy.js/dist/tippy.css";

const Tippy = {
  mounted() {
    this._init = () => {
      const tplId = this.el.getAttribute("data-tooltip-template");
      const template = tplId ? document.getElementById(tplId) : null;
      const title =
        this.el.getAttribute("data-title") ||
        this.el.getAttribute("data-tippy-content");
      const placement = this.el.getAttribute("data-tooltip-placement") || "top";

      if (!template && !title) return;

      this.tippy = tippy(this.el, {
        content: template ?? title ?? "",
        theme: "lotus",
        arrow: true,
        offset: [0, 10],
        delay: [250, 80],
        allowHTML: !!template || !!this.el.getAttribute("data-tippy-content"),
        animation: "fade",
        placement,
      });
    };

    this._init();

    this._onThemeChanged = () => {
      if (this.tippy) {
        this.tippy.destroy();
        this.tippy = null;
      }
      this._init();
    };

    window.addEventListener("lotus:theme-changed", this._onThemeChanged);
  },

  updated() {
    if (!this.tippy) return;
    const tplId = this.el.getAttribute("data-tooltip-template");
    const template = tplId ? document.getElementById(tplId) : null;
    const title =
      this.el.getAttribute("data-title") ||
      this.el.getAttribute("data-tippy-content");
    const placement = this.el.getAttribute("data-tooltip-placement") || "top";

    this.tippy.setProps({
      content: template ?? title ?? "",
      placement,
      allowHTML: !!template || !!this.el.getAttribute("data-tippy-content"),
    });
  },

  destroyed() {
    if (this.tippy) this.tippy.destroy();
    window.removeEventListener("lotus:theme-changed", this._onThemeChanged);
  },
};

export default Tippy;
