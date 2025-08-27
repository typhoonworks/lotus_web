import { Editor } from "../lib/editor.js";

export default {
  mounted() {
    let textarea = this.el;
    let editorContainer = document.getElementById("editor");

    const onContentChange = (content) => {
      this.pushEventTo(
        this.el.closest("[data-phx-component]"),
        "editor_content_changed",
        {
          statement: content,
        },
      );
    };

    const initialSchema = this.getSchemaFromDOM();
    this.editor = new Editor(
      textarea,
      editorContainer,
      onContentChange,
      initialSchema,
    );

    this.el.form.addEventListener("submit", (_event) => {
      textarea.value = this.editor.getContent();
    });

    this.requestSchema();
  },

  updated() {
    const newSchema = this.getSchemaFromDOM();
    if (this.editor && newSchema) {
      this.editor.updateSchema(newSchema);
    }
  },

  getSchemaFromDOM() {
    const schemaElement = document.querySelector("[data-editor-schema]");
    if (schemaElement) {
      try {
        return JSON.parse(schemaElement.dataset.editorSchema);
      } catch (e) {
        console.warn("Failed to parse editor schema data:", e);
        return null;
      }
    }
    return null;
  },

  requestSchema() {
    this.pushEventTo(
      this.el.closest("[data-phx-component]"),
      "request_editor_schema",
      {},
    );
  },

  destroyed() {
    if (this.editor) {
      this.editor.destroy();
    }
  },
};
