# sfm-fs.nvim

The `sfm-fm` extension is a plugin for the [sfm](https://github.com/dinhhuy258/sfm.nvim) plugin that adds file management functionality to the sfm file explorer. With sfm-fm, you can easily create, delete, move, and rename files and directories within the sfm explorer.

## Demonstration

Here is a short demonstration of the `sfm-fs` extension in action:

https://user-images.githubusercontent.com/17776979/213240383-77a32c60-cf7c-433f-8171-5203773a4a92.mp4

## Installation

To install the `sfm-fs` extension, you will need to have the [sfm](https://github.com/dinhhuy258/sfm.nvim) plugin installed. You can then install the extension using your preferred plugin manager. For example, using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
{
  "dinhhuy258/sfm.nvim",
  requires = {
    { "dinhhuy258/sfm-fs.nvim" },
  },
  config = function()
    local sfm_explorer = require("sfm").setup {}
    sfm_explorer:load_extension "sfm-fs"
  end
}
```

## Configuration

The `sfm-fs` plugin provides the following configuration options:

```lua
local default_config = {
  icons = {
    selection = "",
  },
  mappings = {
    custom_only = false,
    list = {
      -- user mappings go here
    }
  }
}
```

You can override the default configuration in `load_extension` method

```lua
sfm_explorer:load_extension("sfm-fs", {
  icons = {
    selection = "",
  }
})
```

## Mappings

To use the functionalities provided by the `sfm-fs` extension, you can use the following key bindings:

| Key     | Action            | Description                                                                    |
| ------- | ----------------- | ------------------------------------------------------------------------------ |
| n       | create            | Create a new file/directory in the current folder                              |
| c       | copy              | Copy the current file or directory to a destination path specified by the user |
| p       | copy_selections   | Copy all selected files or directories to the current folder                   |
| r       | move              | Move/rename the current file or directory                                      |
| x       | move_selections   | Move all selected files or directories to the current folder                   |
| dd      | delete            | Delete the current file or directory                                           |
| ds      | delete_selections | Delete all selected files or directories                                       |
| space   | toggle_selection  | Toggle the selection of the current file or directory                          |
| c-space | clear_selections  | Clear all selections                                                           |

You can customize these key bindings by setting them via the `mappings` configuration. It's similar to the way [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) handles mapping overrides.

## Highlighting

The following highlight values are used in the `sfm-fs` extension:

- `SFMSelection`: This highlight value is used to highlight the selection indicator of selected entries. The default color scheme for this highlight value is `blue`.
