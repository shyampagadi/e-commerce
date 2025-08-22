/* eslint-disable no-restricted-globals */

export function confirmDialog(message) {
  // explicit window reference avoids ESLint no-restricted-globals
  return window.confirm(message);
}

export function alertDialog(message) {
  return window.alert(message);
}

export function promptDialog(message, defaultValue = '') {
  return window.prompt(message, defaultValue);
}
