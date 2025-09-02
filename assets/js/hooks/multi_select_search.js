export default {
  mounted() {
    this.searchInput = this.el.querySelector('input[type="text"]');
    this.optionsList = this.el.querySelector(
      '[role="listbox"] > div:last-child',
    );
    this.noResultsDiv = this.el.querySelector(".no-results");

    this.allOptions = Array.from(this.el.querySelectorAll('[role="option"]'));

    if (this.searchInput) {
      this.searchInput.addEventListener("input", (e) => {
        this.filterOptions(e.target.value.toLowerCase());
      });
    }
  },

  updated() {
    this.allOptions = Array.from(this.el.querySelectorAll('[role="option"]'));
    this.noResultsDiv = this.el.querySelector(".no-results");
  },

  filterOptions(searchTerm) {
    if (!this.allOptions) return;

    let visibleCount = 0;

    this.allOptions.forEach((option) => {
      const label = option.textContent.toLowerCase().trim();
      const shouldShow = searchTerm === "" || label.startsWith(searchTerm);

      if (shouldShow) {
        option.style.display = "";
        visibleCount++;
      } else {
        option.style.display = "none";
      }
    });

    // Show/hide "No results" message
    if (this.noResultsDiv) {
      this.noResultsDiv.style.display = visibleCount === 0 ? "block" : "none";
    }
  },
};
