import topbar from "topbar";

import DispatchChangeOnUpdate from "./hooks/dispatch_change_on_update";
import EditorForm from "./hooks/editor_form";
import PlatformScout from "./hooks/platform_scout";

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
  PlatformScout,
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
