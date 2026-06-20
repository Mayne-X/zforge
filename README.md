# zforge

A blazing-fast, 100% Zig-native project scaffolder designed for developer experience. 

Stop manually setting up your `build.zig` files. Initialize new Zig projects with interactive CLI commands.

---

## 🚀 Features
- **Lightning Fast:** Written in Zig, generating projects instantly.
- **Minimalist:** No heavy dependencies.
- **Templates:** Supports multiple project templates out of the box.

---

## 🛠️ Usage

### Initialize a new project
```bash
# Basic project
./zforge --name my-project --type basic

# Web server template
./zforge --name my-web-server --type web

# TUI application template
./zforge --name my-tui-app --type tui
```

### Available Templates
| Template | Description |
|:---------|:------------|
| `basic` | Standard "Hello World" entry point |
| `web` | Boilerplate for a web server |
| `tui` | Boilerplate for a Terminal User Interface |

---

## 🏗️ Contributing
Contributions are welcome! Please feel free to open a PR for new templates or interactive features.

## License
MIT License - see [LICENSE](LICENSE) file.
