/** @typedef {{ sql: string; params: Record<string, any> }} Query */

/** @typedef {{ count: number; min: number; max: number; avg: number; std: number }} Stats */

/** @typedef {Record<string, Query>} EditQuery */

/** @typedef {{ create: string[]; drop: string[]; editQuery: EditQuery }} IndexEntry */

/** @typedef {IndexEntry[]} IndexSet */

export {};
