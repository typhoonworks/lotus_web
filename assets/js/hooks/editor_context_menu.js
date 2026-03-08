const BRAIN_ICON = `<svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 18V5"/>
  <path d="M15 13a4.17 4.17 0 0 1-3-4 4.17 4.17 0 0 1-3 4"/>
  <path d="M17.598 6.5A3 3 0 1 0 12 5a3 3 0 1 0-5.598 1.5"/>
  <path d="M17.997 5.125a4 4 0 0 1 2.526 5.77"/>
  <path d="M18 18a4 4 0 0 0 2-7.464"/>
  <path d="M19.967 17.483A4 4 0 1 1 12 18a4 4 0 1 1-7.967-.517"/>
  <path d="M6 18a4 4 0 0 1-2-7.464"/>
  <path d="M6.003 5.125a4 4 0 0 0-2.526 5.77"/>
</svg>`;

const EditorContextMenu = {
  mounted() {
    this.button = null;
    this.debounceTimer = null;

    if (this.el.dataset.aiEnabled !== "true") return;

    this.handleMouseUp = (e) => {
      this.scheduleCheck();
    };

    this.handleKeyUp = (e) => {
      if (e.shiftKey || e.key === "Shift") {
        this.scheduleCheck();
      }
    };

    this.handleMouseDown = (e) => {
      if (this.button && !this.button.contains(e.target)) {
        this.hideButton();
      }
    };

    this.handleKeyDown = (e) => {
      if (e.key === "Escape") {
        this.hideButton();
      }
    };

    this.el.addEventListener("mouseup", this.handleMouseUp);
    this.el.addEventListener("keyup", this.handleKeyUp);
    this.el.addEventListener("mousedown", this.handleMouseDown);
    document.addEventListener("keydown", this.handleKeyDown);
  },

  destroyed() {
    this.hideButton();
    if (this.debounceTimer) clearTimeout(this.debounceTimer);
    this.el.removeEventListener("mouseup", this.handleMouseUp);
    this.el.removeEventListener("keyup", this.handleKeyUp);
    this.el.removeEventListener("mousedown", this.handleMouseDown);
    document.removeEventListener("keydown", this.handleKeyDown);
  },

  scheduleCheck() {
    if (this.debounceTimer) clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => this.checkSelection(), 150);
  },

  checkSelection() {
    const editorContainer = document.getElementById("editor");
    if (!editorContainer?.lotusEditor?.view) return;

    const view = editorContainer.lotusEditor.view;
    const sel = view.state.selection.main;
    const selectedText = view.state.sliceDoc(sel.from, sel.to).trim();

    if (!selectedText || !/\w{2,}/.test(selectedText)) {
      this.hideButton();
      return;
    }

    this.showButton(view, sel, selectedText);
  },

  showButton(view, sel, selectedText) {
    this.hideButton();

    const coords = view.coordsAtPos(sel.to);
    if (!coords) return;

    const btn = document.createElement("button");
    btn.className =
      "fixed z-50 inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium rounded-lg border " +
      "text-cyan-700 dark:text-cyan-300 border-cyan-300 dark:border-cyan-600 " +
      "hover:bg-cyan-50 dark:hover:bg-cyan-900/20 bg-white dark:bg-gray-800 shadow-md";
    btn.innerHTML = `${BRAIN_ICON}<span>Explain fragment</span>`;
    btn.type = "button";

    btn.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      this.pushEventTo(
        this.el.closest("[data-phx-component]"),
        "explain_fragment",
        { fragment: selectedText },
      );
      this.hideButton();
    });

    document.body.appendChild(btn);
    this.button = btn;

    // Position near selection end, offset below
    const btnRect = btn.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    let left = coords.left;
    let top = coords.bottom + 6;

    if (left + btnRect.width > vw) {
      left = Math.max(4, vw - btnRect.width - 4);
    }
    if (top + btnRect.height > vh) {
      top = Math.max(4, coords.top - btnRect.height - 6);
    }

    btn.style.left = left + "px";
    btn.style.top = top + "px";
  },

  hideButton() {
    if (this.button) {
      this.button.remove();
      this.button = null;
    }
  },
};

export default EditorContextMenu;
