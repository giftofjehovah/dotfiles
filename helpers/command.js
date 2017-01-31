var exec = require('child_process').execSync
module.exports = function _command (cmd, dir, cb) {
  exec(cmd, {
    cwd: dir || __dirname,
    stdio: [0, 1, 2]
  }, function (err, stdout, stderr) {
    if (err) {
      console.error(err, stdout, stderr)
    }
    cb(err, stdout.split('\n').join(''))
  })
}
