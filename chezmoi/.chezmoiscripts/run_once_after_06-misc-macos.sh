sudo xcodebuild -license accept

mackup restore

mkdir ~/dev

pub=$HOME/.ssh/id_rsa.pub
echo 'Checking for SSH key, generating one if it does not exist...'
[[ -f $pub ]] || ssh-keygen -t rsa

brew cleanup