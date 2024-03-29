const brewCask = [
  'slack',
  'google-chrome',
  'firefox',
  'alfred',
  'spectacle',
  'bartender',
  'airserver',
  'franz',
  'zeplin',
  'sourcetree',
  'intellij-idea',
  'pycharm',
  'datagrip',
  // 'postman',
  'sketch',
  // 'razer-synapse',
  'steam',
  'sequel-pro',
  'postgres',
  'hyper',
  // 'cargo',
  'keybase',
  'mongodb-compass',
  'visual-studio-code',
  'now',
  'duet',
  'exodus',
  'rescuetime',
  'mactex',
  'astropad',
  'cheatsheet',
  'docker',
  'java',
  // 'oni',
  'numi',
  'notion',
  'insomnia',
  'lunar'
]

// Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
const quickLookPlugin = [
  'qlcolorcode',
  'qlstephen',
  'qlmarkdown',
  'quicklook-json',
  'qlprettypatch',
  'quicklook-csv',
  // 'betterzipql',
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
  // 'font-meslo-lg-for-powerline',
  'font-firacode-nerd-font-mono'
]

const all = [...brewCask, ...quickLookPlugin, ...fonts]

module.exports = all
