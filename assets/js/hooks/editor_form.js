import { createEditor } from "../lib/editor.js";
import { tinykeys } from "tinykeys";

export default {
  mounted() {
    const textarea = this.el;
    const editorContainer = document.getElementById("editor");

    const onContentChange = (content) => {
      this.pushEventTo(
        this.el.closest("[data-phx-component]"),
        "editor_content_changed",
        { statement: content },
      );
    };

    // debounce vars -> server
    let t = null;
    const onVariableChange = (vars) => {
      if (t) clearTimeout(t);
      t = setTimeout(() => {
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "variables_detected",
          { variables: vars },
        );
      }, 500);
    };

    const onRunQuery = () => {
      const form = this.el.form;
      if (!form) return;
      textarea.value = this.editor.getContent();
      const submit = form.querySelector('button[type="submit"]');
      if (submit && !submit.disabled) submit.click();
    };

    const initialSchema = this.getSchemaFromDOM();

    this.editor = createEditor({
      textarea,
      parent: editorContainer,
      schema: initialSchema,
      onChange: onContentChange,
      onRun: onRunQuery,
      onVars: onVariableChange,
    });

    editorContainer.lotusEditor = this.editor;

    this.unbindKeys = tinykeys(window, {
      "Meta+Enter": (event) => {
        event.preventDefault();
        onRunQuery();
      },
      "Control+Enter": (event) => {
        event.preventDefault();
        onRunQuery();
      },
      "Meta+Shift+c": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "copy_query",
          {},
        );
      },
      "Control+Shift+c": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "copy_query",
          {},
        );
      },
      "Meta+x": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "toggle_variable_settings",
          {},
        );
      },
      "Control+x": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "toggle_variable_settings",
          {},
        );
      },
      "Meta+e": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "toggle_schema_explorer",
          {},
        );
      },
      "Control+e": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "toggle_schema_explorer",
          {},
        );
      },
      "Meta+ArrowDown": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "expand_editor",
          {},
        );
      },
      "Control+ArrowDown": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "expand_editor",
          {},
        );
      },
      "Meta+ArrowUp": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "minimize_editor",
          {},
        );
      },
      "Control+ArrowUp": (event) => {
        event.preventDefault();
        this.pushEventTo(
          this.el.closest("[data-phx-component]"),
          "minimize_editor",
          {},
        );
      },
    });

    this.el.form?.addEventListener("submit", () => {
      textarea.value = this.editor.getContent();
    });

    this.handleEvent("copy-editor-content", () => {
      const content = this.editor.getContent();
      navigator.clipboard
        .writeText(content)
        .then(() => {
          this.pushEventTo(
            this.el.closest("[data-phx-component]"),
            "copy-to-clipboard-success",
            {},
          );
        })
        .catch((err) => {
          this.pushEventTo(
            this.el.closest("[data-phx-component]"),
            "copy-to-clipboard-error",
            { error: err.message },
          );
        });
    });

    this.requestSchema();
  },

  updated() {
    const newSchema = this.getSchemaFromDOM();
    if (newSchema) this.editor?.updateSchema(newSchema);

    if (this.editor && this.el.value !== this.editor.getContent()) {
      this.editor.setContent(this.el.value);
    }
  },

  getSchemaFromDOM() {
    const el = document.querySelector("[data-editor-schema]");
    if (!el) return null;
    try {
      return JSON.parse(el.dataset.editorSchema);
    } catch {
      return null;
    }
  },

  requestSchema() {
    this.pushEventTo(
      this.el.closest("[data-phx-component]"),
      "request_editor_schema",
      {},
    );
  },

  destroyed() {
    this.editor?.destroy();
    this.unbindKeys?.();
  },
};
