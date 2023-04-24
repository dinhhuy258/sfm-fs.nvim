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
  view = {
    -- this option allows you to specify where to render the selection icon in the file explorer.
    -- the default value is `false`, which means the selection icon will be rendered before the entry name.
    -- if you set this option to `true`, the selection icon will be rendered in the Vim sign column.
    render_selection_in_sign = false,
  },
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
  view = {
    render_selection_in_sign = true,
  },
  icons = {
    selection = "*",
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

You can customize these key bindings by defining action names in the `mappings` configuration option. For example:

```lua
sfm_explorer:load_extension("sfm-fs", {
  mappings = {
    list = {
      {
        key = "l",
        action = "create",
      },
    },
  },
}
```

Please note that if the action for a key is set to `nil` or an empty string, the default key binding for that key will be disabled. Also, ensure that the action provided is a valid function or action name, as listed in the above table.

## Highlighting

The following highlight values are used in the `sfm-fs` extension:

- `SFMSelection`: This highlight value is used to highlight the selection indicator of selected entries. The default color scheme for this highlight value is `blue`.

## Events

`sfm-fs` dispatches events whenever an action is made in the explorer. These events can be subscribed to through handler functions, allowing for even further customization of `sfm`.

**Available events:**

- `EntryCreated`: Dispatched when a new file/directory is created. The payload of the event is a table with the following keys:
  - `path`: The entry path of the deleted entry
- `EntryDeleted`: Dispatched when a new file/directory is created. The payload of the event is a table with the following keys:
  - `path`: The entry path of the newly created entry
- `EntryWillRename`: Dispatched when a file/directory will be renamed. The payload of the event is a table with the following keys:
  - `from_path`: The old path
  - `to_path`: The new path
- `EntryRenamed`: Dispatched when a file/directory is renamed. The payload of the event is a table with the following keys:
  - `from_path`: The old path
  - `to_path`: The new path

Here's an example of how you might use the API provided by the `sfm` plugin in your own extension or configuration file:

```lua
sfm_explorer:subscribe(sfm_fs_event.Event.EntryCreated, function(payload)
  -- handle the event here
  print("New entry created: " .. payload)
end)
```
