import vegaEmbed from "vega-embed";

export default {
  mounted() {
    this.renderChart();

    // Handle chart updates from server
    this.handleEvent("update-chart", ({ spec }) => {
      this.renderChart(spec);
    });

    // Handle theme changes
    this.themeObserver = new MutationObserver(() => {
      this.renderChart();
    });
    this.themeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class"],
    });

    // Handle resize
    this.resizeObserver = new ResizeObserver(() => {
      if (this.resizeTimeout) clearTimeout(this.resizeTimeout);
      this.resizeTimeout = setTimeout(() => this.renderChart(), 100);
    });
    this.resizeObserver.observe(this.el);
  },

  updated() {
    // phx-update="ignore" prevents updates, but if we need to handle them:
    // this.renderChart();
  },

  renderChart(spec) {
    const specData = spec || this.getSpecFromDOM();
    if (!specData || Object.keys(specData).length === 0) {
      this.el.innerHTML =
        '<div class="flex items-center justify-center h-full text-gray-400">No visualization configured</div>';
      return;
    }

    // Get container height (now reliable with explicit CSS height)
    const containerHeight = this.el.clientHeight || 400;

    // Build full spec - use "container" for width, explicit height
    const fullSpec = {
      ...specData,
      width: "container",
      height: Math.max(containerHeight - 40, 300),
      autosize: { type: "fit", contains: "padding", resize: true },
    };

    // Detect dark mode
    const isDark = document.documentElement.classList.contains("dark");

    // Configure vega-embed options
    const embedOptions = {
      actions: false,
      renderer: "svg",
      theme: isDark ? "dark" : undefined,
      config: isDark
        ? {
            background: "transparent",
            axis: {
              labelColor: "#9ca3af",
              titleColor: "#d1d5db",
              gridColor: "#374151",
              domainColor: "#4b5563",
            },
            legend: {
              labelColor: "#9ca3af",
              titleColor: "#d1d5db",
            },
            title: {
              color: "#d1d5db",
            },
            view: {
              stroke: "transparent",
            },
          }
        : {
            background: "transparent",
            view: {
              stroke: "transparent",
            },
          },
    };

    vegaEmbed(this.el, fullSpec, embedOptions)
      .then((result) => {
        this.vegaView = result.view;
        // Dispatch resize to ensure Vega picks up container dimensions
        window.dispatchEvent(new Event("resize"));
      })
      .catch((err) => {
        console.error("Vega-Lite rendering error:", err);
        this.el.innerHTML = `<div class="flex items-center justify-center h-full text-red-500">
          <div class="text-center">
            <p class="font-medium">Chart Error</p>
            <p class="text-sm mt-1">${err.message}</p>
          </div>
        </div>`;

        // Notify server of error
        const component = this.el.closest("[data-phx-component]");
        if (component) {
          this.pushEventTo(component, "chart_render_error", {
            error: err.message,
          });
        }
      });
  },

  getSpecFromDOM() {
    const specAttr = this.el.dataset.spec;
    if (!specAttr) return null;
    try {
      return JSON.parse(specAttr);
    } catch (e) {
      console.error("Failed to parse Vega spec:", e);
      return null;
    }
  },

  destroyed() {
    if (this.vegaView) {
      this.vegaView.finalize();
    }
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
    if (this.themeObserver) {
      this.themeObserver.disconnect();
    }
    if (this.resizeTimeout) {
      clearTimeout(this.resizeTimeout);
    }
  },
};
