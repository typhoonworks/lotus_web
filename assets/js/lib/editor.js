import { EditorView, basicSetup } from "codemirror";
import { placeholder, keymap } from "@codemirror/view";
import { EditorState, Compartment, Prec } from "@codemirror/state";
import { sql, PostgreSQL, MySQL, SQLite } from "@codemirror/lang-sql";
import { editorStyles, completionStyles } from "./styles";
import { lotusVariablesPlugin } from "./plugins/lotus_variables";
import { ContextAwareCompletion } from "./context_aware_completion";

const editorTheme = EditorView.theme(editorStyles);
const completionTheme = EditorView.theme(completionStyles);
const languageCompartment = new Compartment();

function dialectFromName(name = "postgres") {
  switch (name.toLowerCase()) {
    case "postgres":
    case "postgresql":
      return PostgreSQL;
    case "mysql":
      return MySQL;
    case "sqlite":
      return SQLite;
    default:
      return PostgreSQL;
  }
}

function sqlExt(schema, dialectName, contextCompletion) {
  const cfg = {
    upperCaseKeywords: true,
    dialect: dialectFromName(dialectName),
  };
  if (schema) cfg.schema = schema;

  const sqlLang = sql(cfg);

  if (contextCompletion) {
    return [
      sqlLang,
      sqlLang.language.data.of({
        autocomplete: contextCompletion.createCompletionSource(),
      }),
    ];
  }

  return sqlLang;
}

export function createEditor({
  textarea,
  parent,
  schema = null,
  dialectName = "postgres",
  onChange,
  onRun,
  onVars,
}) {
  let currentSchema = schema;
  let currentDialect = dialectName;

  const contextCompletion = new ContextAwareCompletion(currentSchema);

  const extensions = [
    basicSetup,
    languageCompartment.of(
      sqlExt(currentSchema, currentDialect, contextCompletion),
    ),
    editorTheme,
    completionTheme,
    EditorView.lineWrapping,
    placeholder("SELECT * FROM table_name"),
  ];

  if (onRun) {
    extensions.push(
      Prec.highest(
        keymap.of([
          {
            key: "Mod-Enter",
            run: () => {
              onRun();
              return true;
            },
          },
          {
            key: "Ctrl-Enter",
            run: () => {
              onRun();
              return true;
            },
          },
        ]),
      ),
    );
  }

  if (onVars) {
    extensions.push(lotusVariablesPlugin(onVars));
  }

  const view = new EditorView({
    state: EditorState.create({ doc: textarea.value, extensions }),
    parent,
    dispatch: (tr) => {
      view.update([tr]);
      if (tr.docChanged && onChange) onChange(view.state.doc.toString());
    },
  });

  return {
    view,
    getContent() {
      return view.state.doc.toString();
    },
    setContent(content) {
      view.dispatch({
        changes: { from: 0, to: view.state.doc.length, insert: content ?? "" },
      });
    },
    updateSchema(newSchema) {
      currentSchema = newSchema;
      contextCompletion.updateSchema(currentSchema);
      view.dispatch({
        effects: languageCompartment.reconfigure(
          sqlExt(currentSchema, currentDialect, contextCompletion),
        ),
      });
    },
    updateDialect(newDialect) {
      currentDialect = newDialect || "postgres";
      view.dispatch({
        effects: languageCompartment.reconfigure(
          sqlExt(currentSchema, currentDialect, contextCompletion),
        ),
      });
    },
    destroy() {
      view.destroy();
    },
  };
}
