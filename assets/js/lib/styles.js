const editorStyles = {
  "&": { fontSize: "14px", height: "100%" },
  ".cm-editor": { height: "100%" },
  ".cm-content": {
    padding: "12px",
    fontFamily: "'Monaco','Menlo','Ubuntu Mono',monospace",
  },
  ".cm-scroller": {
    fontFamily: "'Monaco','Menlo','Ubuntu Mono',monospace",
    lineHeight: "1.5",
  },
  ".cm-focused": { outline: "none" },
  ".cm-editor.cm-focused": {
    outline: "2px solid #3b82f6",
    outlineOffset: "-1px",
  },
  ".cm-gutters": {
    backgroundColor: "#F2F5F9",
    borderRight: "1px solid #E5E7EB",
  },
  ".cm-lineNumbers .cm-gutterElement": {
    color: "#6B7280",
  },
  ".dark .cm-gutters": {
    backgroundColor: "#27272A !important",
    borderRight: "1px solid #404040 !important",
  },
  ".dark .cm-lineNumbers .cm-gutterElement": {
    color: "#6B7280 !important",
  },
};

const completionStyles = {
  ".cm-tooltip": { borderRadius: "6px", border: "1px solid #e5e7eb" },
  ".cm-tooltip-autocomplete": { fontSize: "13px" },
  ".cm-tooltip-autocomplete ul": {
    fontFamily: "'Monaco','Menlo','Ubuntu Mono',monospace",
  },
  ".cm-tooltip-autocomplete ul li[aria-selected]": {
    background: "rgba(236,72,153,.12)",
    color: "#be185d",
  },
};

export { editorStyles, completionStyles };
