const emoji = require("node-emoji");
const config = require("./install/config");
const command = require("./helpers/command");

const installPackages = function(type) {
  console.info(emoji.get("coffee"), " installing " + type + " packages");
  config[type].forEach(function(item) {
    console.info(type + ":", item);
    command(
      ". helpers/echos.sh && . helpers/requirers.sh && require_" +
        type +
        " " +
        item,
      __dirname,
      function(err, out) {
        if (err) console.error(emoji.get("fire"), err);
        // console.info(out)
      }
    );
  });
};

installPackages("brew");
installPackages("cask");
installPackages("npm");
installPackages("gem");
installPackages("apm");
installPackages("mas");
installPackages("code");
