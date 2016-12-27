const brewCask = [
  'atom',
  'evernote',
  'iterm2',
  'slack',
  'google-chrome',
  'firefox',
  'alfred',
  'spectacle',
  'bartender',
  'airserver',
  'franz',
  'logic',
  'emacs',
  'zeplin',
  'flux',
  'psequel',
  'ubersicht',
  'sourcetree',
  'intellij-idea',
  'postman',
  'sketch',
  'razer-synapse',
  'myo-connect',
  'steam',
  'enpass'
]

// Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
const quickLookPlugin = [
  'qlcolorcode',
  'qlstephen',
  'qlmarkdown',
  'quicklook-json',
  'qlprettypatch',
  'quicklook-csv',
  'betterzipql',
  'qlimagesize',
  'webpquicklook',
  'suspicious-package'
]

const fonts = [
  'font-awesome',
  'font-awesome-terminal-fonts',
  'font-hack',
  'font-inconsolata-dz-for-powerline',
  'font-inconsolata-g-for-powerline',
  'font-inconsolata-for-powerline',
  'font-roboto-mono',
  'font-roboto-mono-for-powerline',
  'font-source-code-pro'
]

const all = [...brewCask, ...quickLookPlugin, ...fonts]

module.exports = all
