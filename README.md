# 🛠️ Disassembler: Source & Assembly Web Viewer

![License: BSD](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)

## 🚀 Overview

This project implements a **Ruby-based disassembler** that takes an executable file and automatically generates **side-by-side source code and assembly HTML pages**. The tool parses the output of:

- `llvm-dwarfdump --debug-line`
- `objdump -d`

to map C source lines to their corresponding assembly instructions. It supports **multi-file programs** and adds interactive web functionality to enhance user experience.

---

## 🔑 Key Features

- **One-Step Build:** Orchestrates `dwarfdump` and `objdump` behind the scenes automatically.
- **Multi-File Support:** Handles executables compiled from multiple source files, generating individual HTMLs for each.
- **Interactive HTML:**
    - Clickable line numbers: Highlight corresponding source & assembly lines.
    - Arrow key navigation: Move seamlessly up/down between related lines without needing to click.
- **Optimized Output:** Generates HTML files named as `[source_file]_disassem.html` (e.g., `ascii_disassem.html`).
- **Failsafe:** Skips generating HTML if a source file has no corresponding assembly instructions.

---

## 🗂️ Project Structure

```
disassembler/
├── disassem.rb                # Main Ruby script
├── disassem.erb               # ERB template for HTML output
├── Makefile                   # Build & test commands
├── input/                     # Sample C programs (e.g., ascii.c)
├── output/                    # Generated dump & HTML files
├── README.md
├── README.txt
└── (generated .html files)
```

---

## ▶️ How to Run

### 1️⃣ Basic Usage

Run the `disassem` program with a compiled executable:

```bash
ruby disassem.rb your_executable
```

💡 **Note:**  
- The executable must be **compiled with `-g3`** using GCC for debug symbols.
- The source file(s) are auto-detected via `llvm-dwarfdump`.

### 2️⃣ Run Provided Tests

Test with `ascii.c`:

```bash
make test
```

Run tests with optimization flags:

```bash
make test_O1
make test_O2
make test_O3
```

---

## 🧹 Clean the Project

To clean up all test executables, dump files, and generated HTMLs:

```bash
make clean
```

---

## 💡 Implementation Details

- **Language:** Ruby
- **Web Generator:** Embedded Ruby (`ERB`) templates (see `disassem.erb`).
- **Parsing:**  
    - **Regexes:** Extract mappings from `llvm-dwarfdump` and `objdump` output.
    - **Linking:** Maps source lines to assembly and vice versa to build the interactive viewer.

- **Extra Credit Features:**
    1. Support for executables compiled from **multiple source files.**
    2. Added **keyboard navigation** (arrow keys) in the HTML to improve UX.

---

## 📸 Screenshots

*(Add screenshots of your generated HTML if available)*

---

## 👥 Contributors

- **Yuesong Huang** (yhu116@u.rochester.edu)
- **Wentao Jiang** (wjiang20@u.rochester.edu)

---

## 📄 License

This project is licensed under the BSD 3-Clause License – see the [LICENSE](LICENSE) file for details.

---
