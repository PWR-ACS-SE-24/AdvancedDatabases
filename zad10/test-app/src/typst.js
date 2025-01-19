/** @typedef {{ columns: number; align?: string; fill?: string; header?: string; }} TypstTableOptions */
/** @typedef {{ rowspan?: number; colspan?: number; bold?: boolean; mono?: boolean; }} TypstCellOptions */

export class TypstTable {
  #columns;
  #align;
  #fill;
  #header;
  #cells;

  /** @param {TypstTableOptions} options */
  constructor(options) {
    this.#columns = options.columns;
    this.#align = options.align ?? "auto";
    this.#fill = options.fill ?? "none";
    this.#header = options.header ?? "";
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
    let code = "";
    for (let i = 0; i < this.#cells.length; i++) {
      code += this.#cells[i];
      code += (i + 1) % this.#columns === 0 ? ",\n  " : ", ";
    }
    return `
${this.#header}
#table(
  columns: ${this.#columns},
  align: ${this.#align},
  fill: ${this.#fill},
  ${code}
)\n`.trimStart();
  }
}

export function initializeDiffTable() {
  const table = new TypstTable({
    columns: 7,
    align: "right + horizon",
    fill: `(x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") }`,
    header: `#let r(n) = text(fill: rgb("#880000"), n)\n#let g(n) = text(fill: rgb("#008800"), n)`,
  });
  table.addCell("Nazwa", { rowspan: 2, bold: true });
  table.addCell("Średni czas [ms]", { colspan: 3, bold: true });
  table.addCell("Koszt", { colspan: 3, bold: true });
  table.addCell("Stary", { bold: true });
  table.addCell("Nowy", { bold: true });
  table.addCell("Zmiana", { bold: true });
  table.addCell("Stary", { bold: true });
  table.addCell("Nowy", { bold: true });
  table.addCell("Zmiana", { bold: true });
  return table;
}

/**
 * @param {number} n
 * @param {boolean} int
 */
export function f(n, int = false) {
  return n
    .toLocaleString("en", {
      minimumFractionDigits: int ? 0 : 2,
      maximumFractionDigits: int ? 0 : 2,
    })
    .replaceAll(",", " ");
}

/**
 * @param {number} n
 * @param {boolean} int
 */
export function diff(n, int = false) {
  return n === 0
    ? f(n, int)
    : n > 0
    ? `#r("+${f(n, int)}")`
    : `#g("-${f(Math.abs(n), int)}")`;
}
