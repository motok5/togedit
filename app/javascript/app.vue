<template>
  <div id="app">
    <div id="editor" style="height: 600px" @compositionstart="composing=true" @compositionend="composing=false"></div>
  </div>
</template>

<script>

require('ace-min-noconflict/ace')
require('ace-min-noconflict/theme-monokai')

export default {
  data: function () {
    return {
      editor: null,
      editorChannel: null,
      websocketSent: null,
      websocketReceived: null,
      receiveLines: 0,
      composing: false
    }
  },
  mounted: function () {
    this.editor = ace.edit("editor")
    this.editor.setTheme('ace/theme/monokai')
    this.editor.getSession().on("change", this.write)
    this.editor.$blockScrolling = Infinity
    this.websocketSent = false
    this.websocketReceived = false
    this.editorChannel = this.$cable.subscriptions.create("EditorChannel", {
      received: this.receiveWrite
    })
  },
  methods: {
    write: function (e) {
      if (this.composing) {
        return
      }
      if (!this.websocketReceived) {
        this.websocketSent = true
        this.editorChannel.perform('write', { text: this.editor.getSession().getValue() })
      } else {
        if (e.data.action == "insertText") {
          if (this.receiveLines == 0) {
            this.websocketReceived = false
          } else if (this.receiveLines > 0) {
            this.receiveLines--
          }
        } else if (e.data.action == "insertLines") {
          this.receiveLines = this.receiveLines - e.data.lines.length
        }
      }
    },
    receiveWrite: function (data) {
      if (this.editor != '' && !this.websocketSent) {
        this.websocketReceived = true
        this.receiveLines = (data.text.match(/\r?\n/g) || '').length + 1
        const position = this.editor.getCursorPosition()
        this.editor.getSession().setValue(data.text)
        this.editor.selection.moveTo(position.row, position.column)
      }
      this.websocketSent = false
    }
  }
}
</script>

<style scoped>
</style>
