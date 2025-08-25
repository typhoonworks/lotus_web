import { EditorView, basicSetup } from "codemirror";
import { placeholder } from "@codemirror/view";
import { EditorState, Compartment } from "@codemirror/state";
import { sql } from "@codemirror/lang-sql";

const editorTheme = EditorView.theme({
  "&": {
    fontSize: "14px",
    height: "100%",
  },
  ".cm-content": {
    padding: "12px",
    fontFamily: "'Monaco', 'Menlo', 'Ubuntu Mono', monospace",
  },
  ".cm-focused": {
    outline: "none",
  },
  ".cm-editor": {
    height: "100%",
  },
  ".cm-editor.cm-focused": {
    outline: "2px solid #3b82f6",
    outlineOffset: "-1px",
  },
  ".cm-scroller": {
    fontFamily: "'Monaco', 'Menlo', 'Ubuntu Mono', monospace",
    lineHeight: "1.5",
  },
});

export default {
  mounted() {
    let textarea = this.el;

    let language = new Compartment();
    let state = EditorState.create({
      doc: textarea.value,
      extensions: [
        basicSetup,
        language.of(sql()),
        editorTheme,
        EditorView.lineWrapping,
        placeholder("SELECT * FROM TABLE_NAME"),
      ],
    });

    let view = new EditorView({
      state: state,
      parent: document.getElementById("editor"),
      dispatch: (transaction) => {
        view.update([transaction]);

        if (transaction.docChanged) {
          const content = view.state.doc.toString();
          textarea.value = content;

          this.pushEventTo(
            this.el.closest("[data-phx-component]"),
            "editor_content_changed",
            {
              statement: content,
            },
          );
        }
      },
    });

    this.view = view;

    this.el.form.addEventListener("submit", (_event) => {
      textarea.value = view.state.doc.toString();
    });
  },

  destroyed() {
    if (this.view) {
      this.view.destroy();
    }
  },
};
