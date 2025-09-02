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

const lightCompletionStyles = {
  ".cm-tooltip.cm-tooltip-autocomplete": {
    fontSize: "13px",
    borderRadius: "6px",
    border: "1px solid #e5e7eb",
    backgroundColor: "#ffffff",
  },
  ".cm-tooltip.cm-tooltip-autocomplete ul": {
    fontFamily: "'Monaco','Menlo','Ubuntu Mono',monospace",
    backgroundColor: "#ffffff",
  },
  ".cm-tooltip.cm-tooltip-autocomplete ul li": {
    color: "#374151",
  },
  ".cm-tooltip.cm-tooltip-autocomplete ul li[aria-selected]": {
    background: "rgba(236,72,153,.12)",
    color: "#be185d",
  },
};

const darkCompletionStyles = {
  ".cm-tooltip.cm-tooltip-autocomplete": {
    fontSize: "13px",
    borderRadius: "6px",
    border: "1px solid #404040",
    backgroundColor: "#171717",
  },
  ".cm-tooltip.cm-tooltip-autocomplete ul": {
    fontFamily: "'Monaco','Menlo','Ubuntu Mono',monospace",
    backgroundColor: "#171717",
  },
  ".cm-tooltip.cm-tooltip-autocomplete ul li": {
    color: "#d1d5db",
  },
  ".cm-tooltip.cm-tooltip-autocomplete ul li[aria-selected]": {
    background: "rgba(236,72,153,.2)",
    color: "#f9a8d4",
  },
  ".cm-completionDetail": {
    color: "#9ca3af",
  },
};

function getCompletionStyles(isDark = false) {
  return isDark ? darkCompletionStyles : lightCompletionStyles;
}

export {
  editorStyles,
  lightCompletionStyles as completionStyles,
  getCompletionStyles,
};
