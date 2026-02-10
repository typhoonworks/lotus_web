import { tinykeys } from "tinykeys";

export function initGlobalShortcuts() {
  const unsubscribe = tinykeys(window, {
    "$mod+Slash": (event) => {
      event.preventDefault();
      toggleShortcutsModal();
    },
    "$mod+k": (event) => {
      event.preventDefault();
      toggleAIAssistant();
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

function toggleAIAssistant() {
  const aiButton = document.getElementById("ai-assistant-btn");
  if (aiButton) {
    aiButton.click();
  }
}
