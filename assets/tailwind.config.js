const plugin = require("tailwindcss/plugin");

module.exports = {
  content: ["./js/**/*.js", "../lib/**/*.*ex"],
  theme: {
    extend: {
      colors: require("./tailwind.colors.json"),
      fontFamily: {
        sans: ["Inter var", "sans-serif"],
        mono: [
          "Menlo",
          "Monaco",
          "Consolas",
          "Liberation Mono",
          "Courier New",
          "monospace",
        ],
      },
    },
  },
  variants: {
    display: ["group-hover"],
  },
  plugins: [require("@tailwindcss/forms")],
};
