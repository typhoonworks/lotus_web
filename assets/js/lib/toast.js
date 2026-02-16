const STYLES = {
  info: {
    border: "border-blue-400 dark:border-blue-500",
    bg: "bg-blue-50 dark:bg-blue-500/10",
    text: "text-blue-700 dark:text-blue-300",
    icon: "text-blue-400 dark:text-blue-500",
  },
  error: {
    border: "border-yellow-400 dark:border-yellow-500",
    bg: "bg-yellow-50 dark:bg-yellow-500/10",
    text: "text-yellow-700 dark:text-yellow-300",
    icon: "text-yellow-400 dark:text-yellow-500",
  },
};

const ICONS = {
  info: `<svg class="size-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
    <path fill-rule="evenodd" d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Zm-7-4a1 1 0 1 1-2 0 1 1 0 0 1 2 0ZM9 9a.75.75 0 0 0 0 1.5h.253a.25.25 0 0 1 .244.304l-.459 2.066A1.75 1.75 0 0 0 10.747 15H11a.75.75 0 0 0 0-1.5h-.253a.25.25 0 0 1-.244-.304l.459-2.066A1.75 1.75 0 0 0 9.253 9H9Z" clip-rule="evenodd" />
  </svg>`,
  error: `<svg class="size-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
    <path fill-rule="evenodd" d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495ZM10 5a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 10 5Zm0 9a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z" clip-rule="evenodd" />
  </svg>`,
};

const DISMISS_ICON = `<svg class="h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
  <path d="M6.28 5.22a.75.75 0 0 0-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 1 0 1.06 1.06L10 11.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L11.06 10l3.72-3.72a.75.75 0 0 0-1.06-1.06L10 8.94 6.28 5.22Z" />
</svg>`;

let activeToast = null;

export function showToast(kind, message, timeout = 5000) {
  // Remove any existing toast
  if (activeToast && activeToast.parentNode) {
    activeToast.remove();
  }

  const style = STYLES[kind] || STYLES.info;
  const icon = ICONS[kind] || ICONS.info;

  const el = document.createElement("div");
  el.className = [
    "fixed bottom-4 right-4 p-4 z-50 shadow-lg max-w-md border-l-4 transition-opacity duration-200",
    style.border,
    style.bg,
  ].join(" ");

  el.innerHTML = `
    <div class="flex items-center">
      <div class="shrink-0 ${style.icon}">${icon}</div>
      <div class="ml-3 flex-1">
        <p class="text-sm ${style.text}">${escapeHtml(message)}</p>
      </div>
      <div class="ml-auto pl-3">
        <button type="button" class="inline-flex p-1.5 text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-400 transition-colors" aria-label="Dismiss">
          ${DISMISS_ICON}
        </button>
      </div>
    </div>
  `;

  document.body.appendChild(el);
  activeToast = el;

  const dismiss = () => {
    el.style.opacity = "0";
    setTimeout(() => el.remove(), 200);
    if (activeToast === el) activeToast = null;
  };

  el.querySelector('[aria-label="Dismiss"]').addEventListener("click", dismiss);

  setTimeout(() => {
    if (el.parentNode) dismiss();
  }, timeout);
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}
