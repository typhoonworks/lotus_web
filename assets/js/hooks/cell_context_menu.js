// Shared stats rendering helpers (extracted from column_stats.js)
function formatNumber(n) {
  if (n == null) return "—";
  return Number(n).toLocaleString(undefined, { maximumFractionDigits: 4 });
}

function formatPercentage(n) {
  if (n == null) return "—";
  return Number(n).toFixed(1) + "%";
}

function buildHistogramHTML(histogram) {
  if (!histogram || histogram.length === 0) return "";
  const maxCount = Math.max(...histogram.map((b) => b.count));
  if (maxCount === 0) return "";

  const bars = histogram
    .map((bin) => {
      const pct = maxCount > 0 ? (bin.count / maxCount) * 100 : 0;
      const label =
        bin.bin_start === bin.bin_end
          ? formatNumber(bin.bin_start)
          : `${formatNumber(bin.bin_start)}–${formatNumber(bin.bin_end)}`;
      return `
      <div class="lotus-stats-hist-row">
        <span class="lotus-stats-hist-label" title="${label}">${label}</span>
        <div class="lotus-stats-hist-bar-bg">
          <div class="lotus-stats-hist-bar" style="width:${pct}%"></div>
        </div>
        <span class="lotus-stats-hist-count">${bin.count}</span>
      </div>`;
    })
    .join("");

  return `
    <div class="lotus-stats-section-title">Distribution</div>
    <div class="lotus-stats-histogram">${bars}</div>`;
}

function buildTopValuesHTML(topValues) {
  if (!topValues || topValues.length === 0) return "";

  const maxCount = Math.max(...topValues.map((v) => v.count));
  const rows = topValues
    .slice(0, 8)
    .map((v) => {
      const pct = maxCount > 0 ? (v.count / maxCount) * 100 : 0;
      const val =
        v.value.length > 24 ? v.value.substring(0, 24) + "…" : v.value;
      return `
      <div class="lotus-stats-hist-row">
        <span class="lotus-stats-hist-label" title="${v.value}">${val}</span>
        <div class="lotus-stats-hist-bar-bg">
          <div class="lotus-stats-hist-bar lotus-stats-hist-bar--string" style="width:${pct}%"></div>
        </div>
        <span class="lotus-stats-hist-count">${v.count}</span>
      </div>`;
    })
    .join("");

  return `
    <div class="lotus-stats-section-title">Top values</div>
    <div class="lotus-stats-histogram">${rows}</div>`;
}

function buildDistributionHTML(distribution) {
  if (!distribution || distribution.length === 0) return "";

  const maxCount = Math.max(...distribution.map((d) => d.count));
  const rows = distribution
    .slice(0, 10)
    .map((d) => {
      const pct = maxCount > 0 ? (d.count / maxCount) * 100 : 0;
      return `
      <div class="lotus-stats-hist-row">
        <span class="lotus-stats-hist-label">${d.bucket}</span>
        <div class="lotus-stats-hist-bar-bg">
          <div class="lotus-stats-hist-bar lotus-stats-hist-bar--temporal" style="width:${pct}%"></div>
        </div>
        <span class="lotus-stats-hist-count">${d.count}</span>
      </div>`;
    })
    .join("");

  return `
    <div class="lotus-stats-section-title">Distribution</div>
    <div class="lotus-stats-histogram">${rows}</div>`;
}

function statRow(label, value) {
  return `<div class="lotus-stats-row"><span class="lotus-stats-label">${label}</span><span class="lotus-stats-value">${value}</span></div>`;
}

function buildStatsContent(stats) {
  const type = stats.type;
  const typeBadge = `<span class="lotus-stats-type-badge lotus-stats-type-badge--${type}">${type}</span>`;

  let html = `<div class="lotus-stats-popover">`;
  html += `<div class="lotus-stats-header">${typeBadge}</div>`;

  html += statRow("Count", formatNumber(stats.count));
  html += statRow(
    "Null",
    `${stats.null_count} (${formatPercentage(stats.null_percentage)})`,
  );
  html += statRow("Distinct", formatNumber(stats.distinct_count));

  if (type === "numeric") {
    html += `<div class="lotus-stats-divider"></div>`;
    html += statRow("Min", formatNumber(stats.min));
    html += statRow("Max", formatNumber(stats.max));
    html += statRow("Avg", formatNumber(stats.avg));
    html += statRow("Median", formatNumber(stats.median));
    html += statRow("Sum", formatNumber(stats.sum));
    html += buildHistogramHTML(stats.histogram);
  } else if (type === "string") {
    html += `<div class="lotus-stats-divider"></div>`;
    html += statRow("Min length", formatNumber(stats.min_length));
    html += statRow("Max length", formatNumber(stats.max_length));
    html += buildTopValuesHTML(stats.top_values);
  } else if (type === "temporal") {
    html += `<div class="lotus-stats-divider"></div>`;
    html += statRow("Earliest", stats.earliest || "—");
    html += statRow("Latest", stats.latest || "—");
    html += buildDistributionHTML(stats.distribution);
  }

  html += `</div>`;
  return html;
}

const CellContextMenu = {
  mounted() {
    this.menu = null;
    this.statsPanel = null;
    this.statsHoverTimer = null;
    this.cellData = null;
    this.headerData = null;
    this.activeCell = null;

    this.handleContextMenu = (e) => {
      const td = e.target.closest("td[data-column]");
      if (td) {
        e.preventDefault();

        this.cellData = {
          column: td.dataset.column,
          value: td.dataset.value,
          isNull: td.dataset.isNull === "true",
        };

        this.highlightCell(td);
        this.showFilterMenu(e.clientX, e.clientY);
        return;
      }

      const th = e.target.closest("th[data-column]");
      if (th) {
        e.preventDefault();

        this.headerData = {
          column: th.dataset.column,
          stats: th.dataset.stats,
        };

        this.highlightCell(th);
        this.showHeaderMenu(e.clientX, e.clientY);
        return;
      }
    };

    this.handleClick = (e) => {
      if (this.menu && !this.menu.contains(e.target)) {
        this.hideMenu();
      }
    };

    this.handleScroll = () => {
      this.hideMenu();
      this.hideStatsPanel();
    };

    this.handleKeydown = (e) => {
      if (e.key === "Escape") {
        this.hideMenu();
        this.hideStatsPanel();
      }
    };

    // Delayed hover for column stats popover
    this.handleMouseOver = (e) => {
      const th = e.target.closest("th[data-column]");
      if (!th) return;
      // Don't show stats popover if a context menu is open
      if (this.menu) return;

      this.clearStatsTimer();
      this.statsHoverTimer = setTimeout(() => {
        this.showStatsPopover(th);
      }, 600);
    };

    this.handleMouseOut = (e) => {
      const th = e.target.closest("th[data-column]");
      if (!th) return;

      this.clearStatsTimer();

      // Hide panel after a short delay to allow moving mouse to it
      this.statsLeaveTimer = setTimeout(() => {
        if (
          this.statsPanel &&
          !this.statsPanel.matches(":hover") &&
          !th.matches(":hover")
        ) {
          this.hideStatsPanel();
        }
      }, 200);
    };

    this.el.addEventListener("contextmenu", this.handleContextMenu);
    this.el.addEventListener("mouseover", this.handleMouseOver);
    this.el.addEventListener("mouseout", this.handleMouseOut);
    document.addEventListener("click", this.handleClick);
    document.addEventListener("scroll", this.handleScroll, true);
    document.addEventListener("keydown", this.handleKeydown);
  },

  destroyed() {
    this.hideMenu();
    this.hideStatsPanel();
    this.clearStatsTimer();
    this.el.removeEventListener("contextmenu", this.handleContextMenu);
    this.el.removeEventListener("mouseover", this.handleMouseOver);
    this.el.removeEventListener("mouseout", this.handleMouseOut);
    document.removeEventListener("click", this.handleClick);
    document.removeEventListener("scroll", this.handleScroll, true);
    document.removeEventListener("keydown", this.handleKeydown);
  },

  showFilterMenu(x, y) {
    if (this.menu) {
      this.menu.remove();
      this.menu = null;
    }

    const menu = document.createElement("div");
    menu.className =
      "fixed z-50 min-w-[180px] py-1 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 text-sm";

    const items = this.buildFilterMenuItems();
    items.forEach((item) => {
      if (item.separator) {
        const sep = document.createElement("div");
        sep.className = "border-t border-gray-200 dark:border-gray-700 my-1";
        menu.appendChild(sep);
        return;
      }

      const btn = document.createElement("button");
      btn.className =
        "w-full text-left px-3 py-1.5 hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-700 dark:text-gray-300 flex items-center gap-2";
      btn.innerHTML = `<span class="text-gray-400 dark:text-gray-500 w-12 text-right font-mono text-xs">${item.opLabel}</span><span>${item.label}</span>`;
      btn.addEventListener("click", () => {
        this.applyFilter(item.op);
        this.hideMenu();
      });
      menu.appendChild(btn);
    });

    document.body.appendChild(menu);
    this.menu = menu;

    // Position: ensure it stays within viewport
    const rect = menu.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    menu.style.left =
      (x + rect.width > vw ? Math.max(0, x - rect.width) : x) + "px";
    menu.style.top =
      (y + rect.height > vh ? Math.max(0, y - rect.height) : y) + "px";
  },

  showHeaderMenu(x, y) {
    if (this.menu) {
      this.menu.remove();
      this.menu = null;
    }
    this.hideStatsPanel();

    const menu = document.createElement("div");
    menu.className =
      "fixed z-50 min-w-[180px] py-1 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 text-sm";

    const { column } = this.headerData;

    const mkBtn = (iconSvg, label, onClick) => {
      const btn = document.createElement("button");
      btn.className =
        "w-full text-left px-3 py-1.5 hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-700 dark:text-gray-300 flex items-center gap-2";
      btn.innerHTML = `<span class="text-gray-400 dark:text-gray-500 flex-shrink-0">${iconSvg}</span><span>${label}</span>`;
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        onClick();
      });
      return btn;
    };

    menu.appendChild(
      mkBtn(
        `<svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m18 15-6-6-6 6"/></svg>`,
        "Sort ascending",
        () => {
          this.pushSortEvent(column, "asc");
          this.hideMenu();
        },
      ),
    );

    menu.appendChild(
      mkBtn(
        `<svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m6 9 6 6 6-6"/></svg>`,
        "Sort descending",
        () => {
          this.pushSortEvent(column, "desc");
          this.hideMenu();
        },
      ),
    );

    document.body.appendChild(menu);
    this.menu = menu;

    // Position: ensure it stays within viewport
    const rect = menu.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    menu.style.left =
      (x + rect.width > vw ? Math.max(0, x - rect.width) : x) + "px";
    menu.style.top =
      (y + rect.height > vh ? Math.max(0, y - rect.height) : y) + "px";
  },

  // Stats popover shown on delayed hover over <th>
  showStatsPopover(th) {
    this.hideStatsPanel();

    let stats;
    try {
      stats = JSON.parse(th.dataset.stats);
    } catch {
      return;
    }

    if (!stats || !stats.type) return;

    const panel = document.createElement("div");
    panel.className =
      "fixed z-50 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 text-sm";
    panel.innerHTML = buildStatsContent(stats);

    // Dismiss when mouse leaves the panel
    panel.addEventListener("mouseleave", () => {
      this.hideStatsPanel();
    });

    document.body.appendChild(panel);
    this.statsPanel = panel;

    // Position below the header cell
    const thRect = th.getBoundingClientRect();
    const panelRect = panel.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    let left = thRect.left;
    if (left + panelRect.width > vw) {
      left = Math.max(0, vw - panelRect.width - 8);
    }
    let top = thRect.bottom + 4;
    if (top + panelRect.height > vh) {
      top = Math.max(0, thRect.top - panelRect.height - 4);
    }

    panel.style.left = left + "px";
    panel.style.top = top + "px";
  },

  clearStatsTimer() {
    if (this.statsHoverTimer) {
      clearTimeout(this.statsHoverTimer);
      this.statsHoverTimer = null;
    }
    if (this.statsLeaveTimer) {
      clearTimeout(this.statsLeaveTimer);
      this.statsLeaveTimer = null;
    }
  },

  hideStatsPanel() {
    this.clearStatsTimer();
    if (this.statsPanel) {
      this.statsPanel.remove();
      this.statsPanel = null;
    }
  },

  highlightCell(td) {
    this.clearHighlight();
    const isDark = document.documentElement.classList.contains("dark");
    td.style.backgroundColor = isDark
      ? "rgb(30 58 138 / 0.3)"
      : "rgb(191 219 254)";
    this.activeCell = td;
  },

  clearHighlight() {
    if (this.activeCell) {
      this.activeCell.style.backgroundColor = "";
      this.activeCell = null;
    }
  },

  hideMenu() {
    if (this.menu) {
      this.menu.remove();
      this.menu = null;
    }
    this.clearHighlight();
  },

  buildFilterMenuItems() {
    const { column, value, isNull } = this.cellData;
    const display =
      value && value.length > 20 ? value.substring(0, 20) + "…" : value;
    const items = [];

    if (isNull) {
      items.push({
        op: "is_null",
        opLabel: "IS NULL",
        label: `${column} is null`,
      });
      items.push({
        op: "is_not_null",
        opLabel: "NOT NULL",
        label: `${column} is not null`,
      });
    } else {
      items.push({
        op: "eq",
        opLabel: "=",
        label: `${column} = ${display}`,
      });
      items.push({
        op: "neq",
        opLabel: "≠",
        label: `${column} ≠ ${display}`,
      });
      items.push({ separator: true });
      items.push({
        op: "gt",
        opLabel: ">",
        label: `${column} > ${display}`,
      });
      items.push({
        op: "lt",
        opLabel: "<",
        label: `${column} < ${display}`,
      });
      items.push({
        op: "gte",
        opLabel: "≥",
        label: `${column} ≥ ${display}`,
      });
      items.push({
        op: "lte",
        opLabel: "≤",
        label: `${column} ≤ ${display}`,
      });
      items.push({ separator: true });
      items.push({
        op: "like",
        opLabel: "LIKE",
        label: `${column} LIKE %${display}%`,
      });
      items.push({ separator: true });
      items.push({
        op: "is_null",
        opLabel: "IS NULL",
        label: `${column} is null`,
      });
      items.push({
        op: "is_not_null",
        opLabel: "NOT NULL",
        label: `${column} is not null`,
      });
    }

    return items;
  },

  applyFilter(op) {
    const { column, value, isNull } = this.cellData;
    const target = this.el.closest("[data-phx-component]");
    const params = { column, op };

    if (op !== "is_null" && op !== "is_not_null" && !isNull) {
      params.value = op === "like" ? `%${value}%` : value;
    }

    this.pushEventTo(target, "add_filter", params);
  },

  pushSortEvent(column, direction) {
    const target = this.el.closest("[data-phx-component]");
    this.pushEventTo(target, "set_sort", { column, direction });
  },
};

export default CellContextMenu;
