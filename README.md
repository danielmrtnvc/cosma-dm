
# Cosma Mind Map

This project is a dynamic, evolving mind map that connects and visualizes the diverse knowledge I’ve explored across philosophy, technology, and the startup world. It’s designed to grow over time, linking concepts and insights to deepen understanding and fuel new ideas.


## Overview

Cosma is a CLI tool for managing and visualizing knowledge graphs using structured plain text data (Markdown and CSV). It provides bibliographic support and powerful graphing capabilities for researchers, note-takers, and thinkers.

---

## Features

- **Knowledge Graphs**: Create and visualize data relationships via interactive graphs.
- **Plain Text Format**: Uses Markdown for content and YAML for metadata.
- **Citation Support**: Handles bibliographic data with Pandoc-compatible citation syntax.
- **Customizable Output**: Tweak graph colors, layouts, and display filters.

---

## Installation

### Requirements:
- [Node.js](https://nodejs.org/) v12+
- Terminal, text editor, and web browser.

Install Cosma globally:
```bash
npm install @graphlab-fr/cosma -g
```
Verify:
```bash
cosma --version
```

---

## Quick Start

### Setting Up a Local Project
1. Create a directory structure:
   ```bash
   mkdir cosma-test && cd cosma-test
   mkdir data export
   ```
2. Initialize with a configuration file:
   ```bash
   cosma config
   ```
   Edit `config.yml`:
   - Set data path:
     ```yaml
     files_origin: ./data
     ```
   - Set export path:
     ```yaml
     export_target: ./export/
     ```
3. Enable custom record types:
   ```yaml
   record_types:
     concept:
       fill: "#984ea3"
       stroke: "#984ea3"
     insight:
       fill: "#ff7f00"
       stroke: "#ff7f00"
   ```

---

### Adding Records
Use Cosma’s command to generate Markdown files with YAML headers:
```bash
cosma record
```
- Example:
  ```plaintext
  title: Evergreen notes
  type: concept
  ```
Add content below the YAML section and link records using `[[id|Title]]`.

---

### Citations
Cosma supports bibliographic citations using [Pandoc syntax](https://pandoc.org/MANUAL.html#citations).

1. Prepare bibliographic data (e.g., with Zotero + Better BibTeX).
2. Reference in text:
   ```markdown
   "Classifying is the highest of intellectual operations" [@otlet1934, 379].
   ```
3. Output:
   ```plaintext
   "Classifying is the highest of intellectual operations" (Otlet 1934/2015, p. 379).
   ```

---

### Creating a Cosmoscope
1. Build the visualization:
   ```bash
   cosma modelize
   ```
2. View the graph:
   - Output is generated in the `export` directory as `cosmoscope.html`.
   - Open in a browser to interact with the graph.

---

## Advanced Features
- **History Tracking**: Enable `history: true` in `config.yml` to save previous cosmoscopes.
- **Graph Customization**: Edit layout settings in `config.yml` or adjust interactively in the browser.
- **Warnings Log**: Debug unrecognized types via Cosma’s log file.

---

## Learn More
- [Cosma Documentation](https://cosma.arthurperret.fr/user-manual.html)
- [Markdown Guide](https://commonmark.org/help/)
- [YAML Basics](https://yaml.org/)
