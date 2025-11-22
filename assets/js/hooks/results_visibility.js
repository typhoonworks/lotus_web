const ResultsVisibility = {
  mounted() {
    const resultsEl = document.querySelector('[id^="query-results-"]');
    if (!resultsEl) return;

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          this.pushEventTo(
            this.el.closest("[data-phx-component]"),
            "results-visibility-changed",
            {
              visible: entry.isIntersecting,
            }
          );
        });
      },
      {
        threshold: 0.1, // Trigger when 10% of results are visible
      }
    );

    this.observer.observe(resultsEl);
  },

  destroyed() {
    if (this.observer) {
      this.observer.disconnect();
    }
  },
};

export default ResultsVisibility;
