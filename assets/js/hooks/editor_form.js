import { createEditor } from "../lib/editor.js";

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

    this.el.form?.addEventListener("submit", () => {
      textarea.value = this.editor.getContent();
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
  },
};
