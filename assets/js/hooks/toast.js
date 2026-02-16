import { showToast } from "../lib/toast";

const Toast = {
  mounted() {
    this.handleEvent("toast", ({ kind, message }) => {
      showToast(kind, message);
    });
  },
};

export default Toast;
