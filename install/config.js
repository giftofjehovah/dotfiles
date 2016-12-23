const brew = require('./brew')
const cask = require('./brew-cask')
const gem = require('./gem')
const npm = require('./npm')
const apm = require('./apm')

module.exports = {
  brew,
  cask,
  gem,
  npm,
  apm
}
