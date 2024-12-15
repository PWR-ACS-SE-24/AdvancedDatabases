/** @typedef {{ columns: number; align?: string; }} TypstTableOptions */
/** @typedef {{ rowspan?: number; colspan?: number; bold?: boolean; mono?: boolean; }} TypstCellOptions */

export class TypstTable {
  #columns;
  #align;
  #cells;

  /** @param {TypstTableOptions} options */
  constructor(options) {
    this.#columns = options.columns;
    this.#align = options.align ?? "auto";
    this.#cells = [];
  }

  /**
   * @param {string} content
   * @param {TypstCellOptions} options
   */
  addCell(content, options = {}) {
    const { rowspan = 1, colspan = 1, bold = false, mono = false } = options;
    if (mono) {
      content = `\`${content}\``;
    }
    if (bold) {
      content = `*${content}*`;
    }
    let code = "";
    if (rowspan !== 1 || colspan !== 1) {
      code += `table.cell(rowspan: ${rowspan}, colspan: ${colspan})`;
    }
    code += `[${content}]`;
    this.#cells.push(code);
  }

  render() {
    return `
#table(
  columns: ${this.#columns},
  align: ${this.#align},
  ${this.#cells.join(", ")}
)`.trimStart();
  }
}

export function initializeDiffTable() {
  const table = new TypstTable({ columns: 7, align: "right + horizon" });
  table.addCell("Name", { rowspan: 2, bold: true });
  table.addCell("Czas [ms]", { colspan: 3, bold: true });
  table.addCell("Koszt", { colspan: 3, bold: true });
  table.addCell("Stary", { bold: true });
  table.addCell("Nowy", { bold: true });
  table.addCell("Zmiana", { bold: true });
  table.addCell("Stary", { bold: true });
  table.addCell("Nowy", { bold: true });
  table.addCell("Zmiana", { bold: true });
  return table;
}
