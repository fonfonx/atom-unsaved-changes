AtomUnsavedChanges = require '../lib/atom-unsaved-changes'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.
describe "AtomUnsavedChanges", ->
  # The CS way to declare variables without assigning values
  [workspaceElement, activationPromise, editor] = []

  show = (callback) ->
    # This will resolve activationPromise
    atom.commands.dispatch workspaceElement, 'atom-unsaved-changes:show'

    waitsForPromise ->
      activationPromise

    runs callback

  beforeEach ->
    workspaceElement = atom.views.getView atom.workspace
    activationPromise = atom.packages.activatePackage 'atom-unsaved-changes'

  describe "when the atom-unsaved-changes:show event is triggered", ->
    it "should always show our panel", ->
      show ->
        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage).toExist()

    it "should show appropriate message in the panel if active text editor is untitled", ->
      waitsForPromise ->
        atom.workspace.open()
          .then (o) ->
            editor = o

      runs ->
        show ->
          panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-context'
          expect(panelMessage.textContent).toEqual 'Unsaved file!'

    it "should show appropriate message in the panel if active text editor is unchanged", ->
      waitsForPromise ->
        atom.workspace.open('test.txt')
          .then (o) ->
            editor = o

      runs ->
        show ->
          expect(editor.getTitle()).toEqual 'test.txt'
          expect(editor.getURI()).toBe atom.project.getDirectories()[0]?.resolve('test.txt')
          panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-context'
          expect(panelMessage.textContent).toEqual 'No changes!'

  describe "parseDiff", ->
    [editor, oldText, newText] = []

    beforeEach ->
      waitsForPromise ->
        testPath = atom.packages.resolvePackagePath('atom-unsaved-changes') + '/spec/test.txt'
        atom.workspace.open(testPath)
          .then (o) ->
            editor = o
            oldText = editor.buffer.getText()
            # oldText = 'Two\npeanuts\nwere\nwalking\ndown\nthe\nroad.\nOne\nwas\nassaulted.\n'

    it "should show buffer changes in the panel when appending text", ->
      expect(editor.isModified()).toBeFalsy()
      editor.buffer.append 'Ha Ha\n'
      expect(editor.isModified()).toBeTruthy()
      newText = editor.buffer.getText()

      # Invoking show() directly resulted in a fail,
      # due to that method containing a promise.
      # Bypass that File.read and invoke parseDiff directly
      atom.commands.dispatch workspaceElement, 'atom-unsaved-changes:show'

      waitsForPromise ->
        activationPromise

      runs ->
        AtomUnsavedChanges.parseDiff oldText, newText

        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage.textContent).toEqual '0008: One\n0009: was\n0010: assaulted.'

        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-add'
        expect(panelMessage.textContent).toEqual '0011: Ha Ha'

    it "should show buffer changes in the panel when prepending text", ->
      editor.buffer.insert [0, 0], 'Heard this one?\n'
      newText = editor.buffer.getText()

      atom.commands.dispatch workspaceElement, 'atom-unsaved-changes:show'

      waitsForPromise ->
        activationPromise

      runs ->
        AtomUnsavedChanges.parseDiff oldText, newText

        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage.textContent).toEqual '0002: Two\n0003: peanuts\n0004: were'

        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-add'
        expect(panelMessage.textContent).toEqual '0001: Heard this one?'

    it "should show buffer changes in the panel when inserting text", ->
      editor.buffer.insert [4, 0], 'slowly,\nmethodically\n'
      newText = editor.buffer.getText()

      atom.commands.dispatch workspaceElement, 'atom-unsaved-changes:show'

      waitsForPromise ->
        activationPromise

      runs ->
        AtomUnsavedChanges.parseDiff oldText, newText

        panelMessage = workspaceElement.querySelectorAll '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage[0].textContent).toEqual '0002: peanuts\n0003: were\n0004: walking'

        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-add'
        expect(panelMessage.textContent).toEqual '0005: slowly,\n0006: methodically'

        panelMessage = workspaceElement.querySelectorAll '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage[1].textContent).toEqual '0007: down\n0008: the\n0009: road.'

    it "should show buffer changes in the panel when deleting text", ->
      editor.buffer.deleteRow 2
      newText = editor.buffer.getText()

      atom.commands.dispatch workspaceElement, 'atom-unsaved-changes:show'

      waitsForPromise ->
        activationPromise

      runs ->
        AtomUnsavedChanges.parseDiff oldText, newText

        panelMessage = workspaceElement.querySelectorAll '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage[0].textContent).toEqual '0001: Two\n0002: peanuts'

        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-remove'
        expect(panelMessage.textContent).toEqual '....  were'

        panelMessage = workspaceElement.querySelectorAll '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage[1].textContent).toEqual '0003: walking\n0004: down\n0005: the'

    it "should show buffer changes in the panel when modifying text", ->
      editor.buffer.insert [3, 7], ' slowly, methodically'
      newText = editor.buffer.getText()

      atom.commands.dispatch workspaceElement, 'atom-unsaved-changes:show'

      waitsForPromise ->
        activationPromise

      runs ->
        AtomUnsavedChanges.parseDiff oldText, newText

        panelMessage = workspaceElement.querySelectorAll '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage[0].textContent).toEqual '0001: Two\n0002: peanuts\n0003: were'

        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-remove'
        expect(panelMessage.textContent).toEqual '....  walking'

        panelMessage = workspaceElement.querySelector '.panel-body .atom-unsaved-changes-add'
        expect(panelMessage.textContent).toEqual '0004: walking slowly, methodically'

        panelMessage = workspaceElement.querySelectorAll '.panel-body .atom-unsaved-changes-context'
        expect(panelMessage[1].textContent).toEqual '0005: down\n0006: the\n0007: road.'
