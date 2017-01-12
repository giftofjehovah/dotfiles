#!/usr/bin/env bash

# Create a new directory and enter it
  function mkd() {
          mkdir -p "$@" && cd "$_";
}

  # Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
          local tmpFile="${@%/}.tar";
          tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

          size=$(
                  stat -f"%z" "${tmpFile}" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null;  # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";

	zippedSize=$(
		stat -f"%z" "${tmpFile}.gz" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}.gz" 2> /dev/null; # GNU `stat`
	);

	echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* ./*;
	fi;
}

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}";
	sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

function github() {
  # Are we in a git repo? Don't show any output to user
  git rev-parse --git-dir &> /dev/null
  if [ $? -eq 0 ]; then
      # if so then check for the existance of remote url called origin
      git remote get-url origin &> /dev/null
      if [ $? -eq 0 ]; then
        URL="$(git remote get-url origin | sed 's/\.git//g' )"
        URL=${URL/git\@github\.com\:/https://github.com/}
        URL=${URL/#ssh\:\/\/git\@github\.com\//https://github.com/}
        echo "Remote Origin Found. Opening: $URL"
      else
        URL="https://github.com/new"
        echo "No Remote Origin Found. Opening: $URL"
      fi
      open $URL
  else
      echo "No Local Repo Found. Do you want to create one? [y/N] "
      read response
      response="$(echo "$response" | tr '[:upper:]' '[:lower:]')"
      if [[ $response =~ ^(yes|y)$ ]]; then
          git init
	  URL="https://github.com/new"
          echo "No Remote Origin Found. Opening: $URL"
	  open $URL
      fi
  fi
}

# `a` with no arguments opens the current directory in Atom Editor, otherwise
# opens the given location
function a() {
	if [ $# -eq 0 ]; then
		atom .;
	else
		atom "$@";
	fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
	if [ $# -eq 0 ]; then
		vim .;
	else
		vim "$@";
	fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

# Create a new git repo with one README commit and CD into it
function gitdir() { mkdir $1; cd $1; git init; touch README; git add README; git commit -m "inital commit";}
