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
