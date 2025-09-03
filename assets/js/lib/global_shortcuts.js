import { tinykeys } from "tinykeys";

export function initGlobalShortcuts() {
  const unsubscribe = tinykeys(window, {
    "$mod+Slash": (event) => {
      event.preventDefault();
      toggleShortcutsModal();
    },
  });

  return unsubscribe;
}

function toggleShortcutsModal() {
  const commandButton = document.querySelector(
    'button[title="Keyboard shortcuts"]',
  );
  if (commandButton) {
    commandButton.click();
  }
}
