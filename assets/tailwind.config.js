const plugin = require("tailwindcss/plugin");

module.exports = {
  content: ["./js/**/*.js", "../lib/**/*.*ex"],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        ...require("./tailwind.colors.json"),
        black: "#09090B",
        gray: {
          800: "#171717",
          900: "#09090B",
        },
        'editor-light': "#F2F5F9",
        'editor-dark': "#27272A",
        'input-dark': "#171717",
        'text-light': "#27272A",
        'text-dark': "#F4F4F5",
      },
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
