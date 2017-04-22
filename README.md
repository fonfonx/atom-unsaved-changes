# Atom Unsaved Changes

[![Plugin installs](https://img.shields.io/apm/dm/atom-unsaved-changes.svg?style=flat)](https://atom.io/packages/atom-unsaved-changes)
[![Package version](https://img.shields.io/apm/v/atom-unsaved-changes.svg?style=flat)](https://atom.io/packages/atom-unsaved-changes)
[![CircleCI](https://circleci.com/gh/fonfonx/atom-unsaved-changes/tree/master.svg?style=shield)](https://circleci.com/gh/fonfonx/atom-unsaved-changes/tree/master)

Shows changes in your active buffer via a panel at the bottom of the editor.
Similar to "Show Unsaved Changes" in Sublime Text.

![preview](https://cloud.githubusercontent.com/assets/12617169/7885149/496b1540-05f0-11e5-9a91-b85a4e6ad2f4.png)

## Installation

The package is available on the Atom website: [atom-unsaved-changes](https://atom.io/packages/atom-unsaved-changes).

Run the following command:
```sh
apm install atom-unsaved-changes
```
Or find the package in **Settings** &rarr; **Install** and search for "**atom-unsaved-changes**"

## Usage

In Menu, `Packages => Atom Unsaved Changes => Show`

In context-menu, `Atom Unsaved Changes`

In Command Palette, type `Atom Unsaved Changes`

Keybinding, `ctrl + alt + u` (Mac: `cmd + alt + u`)

In order to close the panel showing the changes, just press again `ctrl + alt + u`.

Adds will be shown with a green background, removes with a red background.
A few lines of surrounding unchanged text are also shown for context.
A yellow line separates hunks.

**Note: Compares whitespace.** If a line ends with a whitespace a symbol &#8709; is appended at the end of the line.

## License

This repository has been forked from [unsaved-changes](https://github.com/Ge-Bra/unsaved-changes) because it was not maintained any more, and in order to correct bugs.
