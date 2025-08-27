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

    this.editor = new Editor(textarea, editorContainer, onContentChange);

    this.el.form.addEventListener("submit", (_event) => {
      textarea.value = this.editor.getContent();
    });
  },

  destroyed() {
    if (this.editor) {
      this.editor.destroy();
    }
  },
};
