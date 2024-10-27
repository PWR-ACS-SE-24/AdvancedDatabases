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

/**
 * @param {number} mean
 * @param {number} sd
 * @returns {number}
 */
export function normal(mean, sd, min, max) {
  while (true) {
    const value = PD.rnorm(1, mean, sd)[0];
    if (value >= min && value <= max) {
      return value;
    }
  }
}
