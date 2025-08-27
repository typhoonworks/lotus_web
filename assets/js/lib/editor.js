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

export class Editor {
  constructor(textarea, editorContainer, onContentChange) {
    this.textarea = textarea;
    this.editorContainer = editorContainer;
    this.onContentChange = onContentChange;
    this.view = null;
    this.initialize();
  }

  initialize() {
    let language = new Compartment();
    let state = EditorState.create({
      doc: this.textarea.value,
      extensions: [
        basicSetup,
        language.of(sql()),
        editorTheme,
        EditorView.lineWrapping,
        placeholder("SELECT * FROM TABLE_NAME"),
      ],
    });

    this.view = new EditorView({
      state: state,
      parent: this.editorContainer,
      dispatch: (transaction) => {
        this.view.update([transaction]);

        if (transaction.docChanged) {
          const content = this.view.state.doc.toString();
          this.textarea.value = content;

          if (this.onContentChange) {
            this.onContentChange(content);
          }
        }
      },
    });
  }

  destroy() {
    if (this.view) {
      this.view.destroy();
      this.view = null;
    }
  }

  getContent() {
    return this.view ? this.view.state.doc.toString() : "";
  }

  setContent(content) {
    if (this.view) {
      this.view.dispatch({
        changes: {
          from: 0,
          to: this.view.state.doc.length,
          insert: content,
        },
      });
    }
  }
}