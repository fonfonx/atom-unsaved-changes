{CompositeDisposable, File} = require 'atom'
{MessagePanelView, PlainMessageView} = require 'atom-message-panel'
{diffLines} = require 'diff'

module.exports = AtomUnsavedChanges =
  subscriptions: null
  messagePanelView: null

  activate: (state) ->
    # Multiple resources can be aggregated in this instance
    # so they can all be disposed as a group
    @subscriptions = new CompositeDisposable

    # Register our command.
    # Note the `atom` global is always available
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-unsaved-changes:show': => @toggle()

    # Diff results shown in this panel
    @messagePanelView = new MessagePanelView
      rawTitle: true
      title: '<span class="atom-unsaved-changes-context">Atom Unsaved Changes</span>'
    @messagePanelView.attach()
    # initialize panel as invisible
    @messagePanelView.panel.visible = false

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    undefined

  toggle: ->
    if @messagePanelView.panel.visible
      @close()
    else
      @show()

  close: ->
    @messagePanelView.close()

  show: ->
    @resetPanel()
    if editor = atom.workspace.getActiveTextEditor()
      if editor.getTitle() is 'untitled'
        @displayMessage 'Unsaved file!', 'context'
      else if not editor.isModified()
        @displayMessage 'No changes!', 'context'
      else
        buffer = editor.getBuffer()
        newText = buffer.getText()

        # Could use `oldText = buffer.cachedDiskContents`
        # however `cachedDiskContents` is non-public
        file = new File buffer.getPath()

        # Grabs cached copy.
        # Note that fat arrow is required
        file.read false
          .then (oldText) =>
            if oldText
              @parseDiff oldText, newText
            else
              # Promise resolves to null if read error code is 'ENOENT'
              throw new Error 'File not found'
          .catch (error) =>
            @displayMessage error, 'context'
    else
      # Should be unreachable, but can be tested
      @displayMessage 'Are you testing me?', 'context'

  parseDiff: (oldText, newText) ->
    diff = diffLines oldText, newText

    first = 0
    last = diff.length - 1
    lineCount = 0

    for part, index in diff
      if part.added
        message = @insertLineNumbers part.value, lineCount
        if part.value.charAt(part.value.length - 2) is ' '
          @displayMessage message, 'add-empty'
        else
          @displayMessage message, 'add'
        lineCount += part.count
      else if part.removed
        message = @insertLineNumbers part.value
        if part.value.charAt(part.value.length - 2) is ' '
          @displayMessage message, 'remove-empty'
        else
          @displayMessage message, 'remove'
      else
        message = @insertLineNumbers part.value, lineCount

        # Reduce unchanged parts to just show some context.
        lines = message.split /\n/

        if index is first
          # Show last 3 lines
          context = lines[-3..].join '\n'
          @displayMessage context, 'context'
        else if index is last
          # Show first 3 lines
          context = lines[0..2].join '\n'
          @displayMessage context, 'context'
        else
          if lines.length < 7
            context = lines.join '\n'
            @displayMessage context, 'context'
          else
            # Show first 3, last 3, and seperator line
            context = lines[0..2].join '\n'
            @displayMessage context, 'context'

            @displayMessage ' ', 'separator'

            # context = context.concat lines[-3..]
            context = lines[-3..].join '\n'
            @displayMessage context, 'context'

        lineCount += part.count

  insertLineNumbers: (msg, startingLineNumber) ->
    lines = msg.split /\r?\n/

    # Remove last element due to trailing newline.
    # If new last element is empty string, pad it to display blank line
    lines.pop()
    lines[-1..] = [' '] if lines[..].pop() is ''

    lineNumber = startingLineNumber if startingLineNumber?
    newMessage = []

    for line in lines
      if lineNumber?
        lineNumber += 1
        line = ('0000' + lineNumber).slice(-4) + ': ' + line
      else
        line = '....  ' + line

      newMessage.push line

    return newMessage.join '\n'

  displayMessage: (msg, className) ->
    @messagePanelView.add new PlainMessageView
      message: msg
      className: 'atom-unsaved-changes-' + className

  resetPanel: ->
    @messagePanelView.clear()
    @messagePanelView.close()
    @messagePanelView.attach()
