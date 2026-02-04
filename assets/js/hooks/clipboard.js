export default {
  mounted() {
    this.el.addEventListener("click", () => {
      const input = document.querySelector(this.el.dataset.copyFrom);
      if (input) {
        navigator.clipboard
          .writeText(input.value)
          .then(() => {
            // Show checkmark feedback
            const icon = this.el.querySelector("svg");
            if (icon) {
              const originalHTML = icon.outerHTML;
              icon.outerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="${icon.className.baseVal} text-green-600 dark:text-green-400">
                  <path d="M20 6L9 17l-5-5"/>
                </svg>
              `;
              setTimeout(() => {
                this.el.querySelector("svg").outerHTML = originalHTML;
              }, 1000);
            }
          });
      }
    });
  },
};
