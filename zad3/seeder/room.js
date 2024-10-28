export class Room {
  constructor(capacity) {
    this.capacity = capacity;
    this.changes = new Map();
  }

  goIn(s, e) {
    this.changes.set(s, (this.changes.get(s) ?? 0) + 1);
    this.changes.set(e, (this.changes.get(e) ?? 0) - 1);
  }

  canFit(s, e) {
    const temp = new Map(this.changes);
    temp.set(s, (temp.get(s) ?? 0) + 1);
    temp.set(e, (temp.get(e) ?? 0) - 1);

    const events = Array.from(temp.entries()).sort((a, b) => a[0] - b[0]);

    let current = 0;
    for (const [_, change] of events) {
      current += change;
      if (current > this.capacity) return false;
    }
    return true;
  }
}
