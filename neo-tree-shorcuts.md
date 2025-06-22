# Neo-Tree File Explorer Shortcuts

## 🚀 How to Open the Explorer

- **`<leader>e`** - Toggle file explorer
- **`<leader>o`** - Open file explorer on left side
- **`<leader>p`** - Open file explorer on right side

> **Note:** The `<leader>` key is **Space** in your Neovim

## 📁 Basic Navigation

### Inside the Explorer:
- **`Enter`** or **Double click** - Open file/folder
- **`<bs>`** (Backspace) - Go back to previous folder
- **`j`** - Move down
- **`k`** - Move up
- **`gg`** - Go to top
- **`G`** - Go to bottom

### Quick Navigation:
- **`.`** - Set current folder as root
- **`/`** - Fuzzy search (type file name)
- **`H`** - Show/hide hidden files

## 📝 File Operations

### Open Files:
- **`Enter`** - Open file normally
- **`S`** - Open in horizontal split
- **`s`** - Open in vertical split
- **`t`** - Open in new tab

### Manage Files:
- **`a`** - Create new file
- **`A`** - Create new folder
- **`d`** - Delete file/folder
- **`r`** - Rename file/folder
- **`c`** - Copy file/folder
- **`m`** - Move file/folder
- **`y`** - Copy to clipboard
- **`x`** - Cut to clipboard
- **`p`** - Paste from clipboard

### View:
- **`P`** - Toggle file preview
- **`C`** - Close current node
- **`z`** - Close all nodes

## 🔍 Search and Filters

- **`/`** - Fuzzy search (type part of name)
- **`D`** - Fuzzy search only in folders
- **`f`** - Filter by pattern
- **`<C-x>`** - Clear filters

## 🎯 Important Tips

1. **For beginners:** Use `<leader>e` to open the explorer
2. **Quick navigation:** Type `/` and start typing the file name
3. **Open files:** Use `Enter` to open normally
4. **Go back:** Use `<bs>` (Backspace) to go back one level
5. **Hidden files:** Use `H` to show/hide files that start with a dot

## 🆘 Help

- **`?`** - Show all available shortcuts
- **`q`** - Close the explorer

## 💡 Basic Usage Example

1. Press **Space + e** to open the explorer
2. Use **j/k** to navigate through files
3. Press **Enter** to open a file
4. Use **`<bs>`** to go back one folder
5. Type **`/`** and start typing to quickly search for a file

## 🔄 How to Apply Changes

### **Restart Neovim:**
```bash
nvim
```

### **Install Plugins:**
Inside Neovim, execute:
```vim
:Lazy sync
```

### **Test the Plugin:**
1. Press **Space + e** to toggle the explorer
2. Press **Space + o** to open on the left
3. Press **Space + p** to open on the right

---

**Remember:** Neo-Tree is very intuitive! Most operations can be done with the keys you already know from Vim. 