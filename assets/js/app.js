import topbar from "topbar";

import DispatchChangeOnUpdate from "./hooks/dispatch_change_on_update";
import EditorForm from "./hooks/editor_form";
import MultiSelectSearch from "./hooks/multi_select_search";
import PlatformScout from "./hooks/platform_scout";
import ThemeSelector from "./hooks/theme_selector";
import { load } from "./lib/settings";

function initializeTheme() {
  const wantsDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  const theme = load("theme") || "system";

  if (
    theme === "dark" ||
    (theme === "system" && wantsDark)
  ) {
    document.documentElement.classList.add("dark");
  } else {
    document.documentElement.classList.remove("dark");
  }
}

initializeTheme();

let topBarScheduled = undefined;

window.addEventListener("phx:page-loading-start", (info) => {
  if (!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 500);
  }
});

window.addEventListener("phx:page-loading-stop", (info) => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});

topbar.config({
  barColors: { 0: "#FF8086" },
  shadowColor: "rgba(0, 0, 0, .3)",
});

const hooks = {
  DispatchChangeOnUpdate,
  EditorForm,
  MultiSelectSearch,
  PlatformScout,
  ThemeSelector,
};

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
const liveTran = document
  .querySelector("meta[name='live-transport']")
  .getAttribute("content");
const livePath = document
  .querySelector("meta[name='live-path']")
  .getAttribute("content");

const liveSocket = new LiveView.LiveSocket(livePath, Phoenix.Socket, {
  transport: liveTran === "longpoll" ? Phoenix.LongPoll : WebSocket,
  params: { _csrf_token: csrfToken },
  hooks: hooks,
});

liveSocket.connect();
