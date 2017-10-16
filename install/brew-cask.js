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
  'ubersicht',
  'sourcetree',
  'intellij-idea',
  'postman',
  'sketch',
  'razer-synapse',
  'myo-connect',
  'steam',
  'sequel-pro',
  'postgres',
  'virtualbox',
  'hyper',
  'cargo',
  'keybase',
  'mongodb-compass',
  'visual-studio-code',
  'now',
  'duet',
  'exodus',
  'rescuetime',
  'mactex',
  'astropad',
  'cheatsheet'
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
  'font-awesome-terminal-fonts',
  'font-hack',
  'font-inconsolata-dz-for-powerline',
  'font-inconsolata-g-for-powerline',
  'font-inconsolata-for-powerline',
  'font-roboto-mono',
  'font-roboto-mono-for-powerline',
  'font-source-code-pro',
  'font-meslo-lg-for-powerline',
  'font-firacode-nerd-font-mono'
]

const all = [...brewCask, ...quickLookPlugin, ...fonts]

module.exports = all
