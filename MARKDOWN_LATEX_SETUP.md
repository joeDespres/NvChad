# World-Class Markdown + LaTeX Editing

## Features Enabled

### 1. **Markdown Editing** (`<leader>m*` mappings)
- `<leader>mt` — Toggle markdown tasks/checkboxes
- `<leader>mo` — Show outline/TOC
- `<leader>mn` — Insert table of contents
- `<leader>mp` — Live preview in browser
- `<leader>mi` — Paste images (auto-save to `assets/`)
- `<leader>mT` — Table mode toggle
- `<leader>mz` — Zen mode (distraction-free)
- `<leader>mr` — Toggle markdown rendering

### 2. **Compile & Preview** (`<leader>p`)
**Single keystroke to compile and open PDF:**

#### Markdown Files
- `<leader>p` compiles to PDF using **pandoc + xelatex**
- Opens PDF in default viewer (Preview.app)
- No line-length warnings (MD013 disabled in `.markdownlint.json`)

#### LaTeX Files
- `<leader>p` compiles using **latexmk** (vimtex)
- Auto-view in configured PDF viewer
- Continuous compilation on save (latexmk mode)

### 3. **Plugins Configured**

| Plugin | Purpose |
|--------|---------|
| `vimtex` | LaTeX editing, compilation, preview |
| `render-markdown.nvim` | Beautiful markdown rendering in-buffer |
| `markdown-preview.nvim` | Live browser preview (`<leader>mp`) |
| `markdown.nvim` | Task toggling, TOC, etc. |
| `img-clip.nvim` | Paste images directly |
| `vim-table-mode` | Markdown table editing |
| `zen-mode.nvim` | Distraction-free writing |

### 4. **No Markdown Warnings**
- Line-length (MD013) disabled
- Raw HTML allowed (MD033 disabled)
- Trailing spaces (MD009) set to 2 spaces for `<br>`

### 5. **Editor Settings**
- **Word wrap** enabled for markdown/LaTeX
- **Line break** respects words (doesn't split mid-word)
- **Spell check** enabled
- **Concealing** enabled for markdown (renders links prettily)
- **Folding** uses TreeSitter expressions

## Keyboard Shortcuts

### PDF Compilation
```
<leader>p  → Compile markdown/LaTeX to PDF and open
```

### Markdown-Specific
```
<leader>mt  → Toggle task checkbox
<leader>mo  → Show outline
<leader>mn  → Insert TOC
<leader>mp  → Browser preview
<leader>mi  → Paste image
<leader>mT  → Table mode
<leader>mz  → Zen mode
<leader>mr  → Render toggle
```

### Writing Comfort
```
Ctrl+Up/Down/Left/Right  → Resize splits
<A-j> / <A-k>           → Move lines up/down
<leader>z               → Zen mode
```

## Requirements

All required tools are installed ✓

- **pandoc** — Markdown to PDF conversion
- **xelatex** — PDF rendering engine (via MacTeX)
- **latexmk** — LaTeX build automation
- **Preview.app** — Default macOS PDF viewer

## Writing Workflow

1. **Start a markdown file:**
   ```
   nvim my-document.md
   ```

2. **Write with live rendering:**
   - `<leader>mp` → Opens browser preview (hot-reloads)
   - `<leader>mz` → Zen mode for distraction-free editing

3. **Insert images:**
   - `<leader>mi` → Paste from clipboard (auto-saves to `assets/`)

4. **Compile to PDF:**
   - `<leader>p` → Creates `my-document.pdf` and opens it

5. **No line-length headaches:**
   - Write freely—no warnings about 80/100 char limits
   - Markdown renders beautifully in-buffer

## For LaTeX Files

**Auto-compile on save:**
```tex
% File: paper.tex
% Every time you save, it compiles + opens PDF automatically
```

**Manual compilation:**
- `<leader>p` → Compile and view
- `:VimtexCompile` → Start/stop continuous compilation
- `:VimtexView` → Open PDF viewer

## Tips

- **Cell-based editing** — Use `<!-- -->` comments to break up long documents
- **Image workflow** — `<leader>mi` to paste, then `<leader>p` to see in PDF
- **Collaborative writing** — Browser preview (`<leader>mp`) lets you share live-view URL
- **Focus time** — `<leader>mz` + `<leader>mp` for zen + preview side-by-side

---

**Status:** ✨ All systems configured and ready to go!
