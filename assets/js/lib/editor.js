import { EditorView, basicSetup } from "codemirror";
import { placeholder, keymap } from "@codemirror/view";
import { EditorState, Compartment } from "@codemirror/state";
import { sql } from "@codemirror/lang-sql";
import {
  lotusVariablesPlugin,
  lotusVariableStyles,
} from "./plugins/lotus_variables";

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
  constructor(
    textarea,
    editorContainer,
    onContentChange,
    schema = null,
    onVariableChange = null,
    onRunQuery = null,
  ) {
    this.textarea = textarea;
    this.editorContainer = editorContainer;
    this.onContentChange = onContentChange;
    this.onVariableChange = onVariableChange;
    this.onRunQuery = onRunQuery;
    this.schema = schema;
    this.view = null;
    this.languageCompartment = new Compartment();
    this.initialize();
  }

  initialize() {
    const extensions = [];

    if (this.onRunQuery) {
      extensions.push(
        keymap.of([
          {
            key: "Mod-Enter",
            run: (view) => {
              this.onRunQuery();
              return true;
            },
            preventDefault: true,
            stopPropagation: true,
          },
        ]),
      );
    }

    extensions.push(
      basicSetup,
      this.languageCompartment.of(this.createSqlExtension()),
      editorTheme,
      lotusVariableStyles,
      EditorView.lineWrapping,
      placeholder("SELECT * FROM TABLE_NAME"),
    );

    if (this.onVariableChange) {
      extensions.push(lotusVariablesPlugin(this.onVariableChange));
    }

    let state = EditorState.create({
      doc: this.textarea.value,
      extensions: extensions,
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

  createSqlExtension() {
    const sqlConfig = {
      upperCaseKeywords: true,
    };

    if (this.schema) {
      sqlConfig.schema = this.schema;
    }

    return sql(sqlConfig);
  }

  updateSchema(schema) {
    if (this.view && schema !== this.schema) {
      this.schema = schema;
      this.view.dispatch({
        effects: this.languageCompartment.reconfigure(
          this.createSqlExtension(),
        ),
      });
    }
  }
}
