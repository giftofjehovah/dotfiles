const brew = require("./brew");
const cask = require("./brew-cask");
const gem = require("./gem");
const npm = require("./npm");
const apm = require("./apm");
const mas = require("./mas");
const code = require("./code");

module.exports = {
  brew,
  cask,
  gem,
  npm,
  apm,
  mas,
  code
};
