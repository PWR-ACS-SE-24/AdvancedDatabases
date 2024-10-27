import PD from "probability-distributions";

/**
 * @param {number} min
 * @param {number} max
 * @returns {number}
 */
export function rand(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * @param {number} lambda
 * @param {number} min
 * @param {number} max
 * @returns {number}
 */
export function poisson(lambda, min, max) {
  while (true) {
    const value = PD.rpois(1, lambda)[0];
    if (value >= min && value <= max) {
      return value;
    }
  }
}
