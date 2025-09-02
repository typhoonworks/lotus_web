import { load, store } from "../lib/settings";

export default {
  applyTheme() {
    const wantsDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    const theme = load("theme");

    if (
      theme === "dark" ||
      (theme === "system" && wantsDark) ||
      (!theme && wantsDark)
    ) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  },

  mounted() {
    this.applyTheme();

    this.el.addEventListener("click", () => {
      const currentTheme = load("theme");
      let newTheme;

      if (currentTheme === "light" || !currentTheme) {
        newTheme = "dark";
      } else if (currentTheme === "dark") {
        newTheme = "system";
      } else {
        newTheme = "light";
      }

      store("theme", newTheme);

      this.applyTheme();
    });
  },
};
