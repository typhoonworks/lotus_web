const CellContextMenu = {
  mounted() {
    this.menu = null;
    this.cellData = null;

    this.handleContextMenu = (e) => {
      const td = e.target.closest("td[data-column]");
      if (!td) return;

      e.preventDefault();

      this.cellData = {
        column: td.dataset.column,
        value: td.dataset.value,
        isNull: td.dataset.isNull === "true",
      };

      this.showMenu(e.clientX, e.clientY);
    };

    this.handleClick = (e) => {
      if (this.menu && !this.menu.contains(e.target)) {
        this.hideMenu();
      }
    };

    this.handleScroll = () => {
      this.hideMenu();
    };

    this.handleKeydown = (e) => {
      if (e.key === "Escape") {
        this.hideMenu();
      }
    };

    this.el.addEventListener("contextmenu", this.handleContextMenu);
    document.addEventListener("click", this.handleClick);
    document.addEventListener("scroll", this.handleScroll, true);
    document.addEventListener("keydown", this.handleKeydown);
  },

  destroyed() {
    this.hideMenu();
    this.el.removeEventListener("contextmenu", this.handleContextMenu);
    document.removeEventListener("click", this.handleClick);
    document.removeEventListener("scroll", this.handleScroll, true);
    document.removeEventListener("keydown", this.handleKeydown);
  },

  showMenu(x, y) {
    this.hideMenu();

    const menu = document.createElement("div");
    menu.className =
      "fixed z-50 min-w-[180px] py-1 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 text-sm";

    const items = this.buildMenuItems();
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

  hideMenu() {
    if (this.menu) {
      this.menu.remove();
      this.menu = null;
    }
  },

  buildMenuItems() {
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
};

export default CellContextMenu;
