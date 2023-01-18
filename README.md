# sfm-fs.nvim

The `sfm-fm` extension is a plugin for the [sfm](https://github.com/dinhhuy258/sfm.nvim) plugin that adds file management functionality to the sfm file explorer. With sfm-fm, you can easily create, delete, move, and rename files and directories within the sfm explorer.

## Demonstration

Here is a short demonstration of the `sfm-fs` extension in action:

TODO: Update video

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

The default mapping is configurated [here](https://github.com/dinhhuy258/sfm-fs.nvim/blob/master/lua/sfm/extensions/sfm-fs/config.lua). You can override the default mapping by setting it via the `mappings` configuration. It's similar to the way [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) handles mapping overrides.
