// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { hooks as colocatedHooks } from "phoenix-colocated/publii_ex"
import topbar from "../vendor/topbar"

import "../vendor/easymde.min.js"
import EditorJS from "@editorjs/editorjs"
import Header from "@editorjs/header"
import List from "@editorjs/list"
import ImageTool from "@editorjs/image"
import Quote from "@editorjs/quote"
import InlineCode from "@editorjs/inline-code"
import Marker from "@editorjs/marker"
import Table from "@editorjs/table"
import CodeTool from "@editorjs/code"
import Delimiter from "@editorjs/delimiter"
import Checklist from "@editorjs/checklist"
import Embed from "@editorjs/embed"

const EditorJSHook = {
  mounted() {
    const initialData = this.el.dataset.content ? JSON.parse(this.el.dataset.content) : {};

    const editor = new EditorJS({
      holder: this.el,
      data: initialData,
      placeholder: 'Let`s write an awesome story!',
      tools: {
        header: {
          class: Header,
          inlineToolbar: ['link']
        },
        list: {
          class: List,
          inlineToolbar: true
        },
        image: {
          class: ImageTool,
          config: {
            endpoints: {
              byFile: '/api/uploads', // Your backend file uploader endpoint
              byUrl: '/api/fetchUrl', // Your endpoint that provides uploading by Url
            }
          }
        },
        quote: Quote,
        inlineCode: InlineCode,
        marker: Marker,
        table: Table,
        code: CodeTool,
        delimiter: Delimiter,
        checklist: Checklist,
        embed: Embed
      },
      onChange: (api, event) => {
        editor.save().then((outputData) => {
          this.pushEvent("editor-changed", { content: outputData });
        }).catch((error) => {
          console.log('Saving failed: ', error)
        });
      }
    });

    this.handleEvent("insert-editor-image", ({ path, name }) => {
      // Logic to insert image block
      const index = editor.blocks.getBlocksCount();
      editor.blocks.insert('image', {
        file: {
          url: path
        },
        caption: name
      });
    });

    this.editor = editor;
  },
  destroyed() {
    if (this.editor && typeof this.editor.destroy === 'function') {
      this.editor.destroy();
    }
  }
}

const EasyMDEHook = {
  mounted() {
    // If EasyMDE isn't a module, it might be on window.
    // Ensure we can reference it.
    const editor = new EasyMDE({
      element: this.el,
      forceSync: true,
      spellChecker: false,
      status: false,
      minHeight: "300px"
    });

    // Sync changes back to the textarea for LiveView
    editor.codemirror.on("change", () => {
      this.el.value = editor.value();
      this.el.dispatchEvent(new Event("input", { bubbles: true }));
    });

    this.handleEvent("insert-image", ({ path, name }) => {
      const pos = editor.codemirror.getCursor();
      const text = `![${name}](${path})`;
      editor.codemirror.replaceRange(text, pos);
      editor.codemirror.focus();
    });

    this.editor = editor;
  },
  destroyed() {
    if (this.editor) {
      this.editor.toTextArea();
      this.editor = null;
    }
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...colocatedHooks, EasyMDE: EasyMDEHook, EditorJS: EditorJSHook },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({ detail: reloader }) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if (keyDown === "c") {
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if (keyDown === "d") {
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}


// Allows to execute JS commands from the server
window.addEventListener("phx:js-exec", ({ detail }) => {
  document.querySelectorAll(detail.to).forEach(el => {
    liveSocket.execJS(el, el.getAttribute(detail.attr))
  })
})

window.addEventListener("phx:refresh-preview", (e) => {
  const frame = document.getElementById("preview-frame");
  if (frame) {
    frame.contentWindow.location.reload();
  }
});
