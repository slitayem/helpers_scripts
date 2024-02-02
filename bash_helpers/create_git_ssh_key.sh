#!/usr/bin/env bash 
set -e

#==================================
# Create a new ssh key for Github
#==================================

display_usage() { 
  echo -e "\nUsage: $0 email-address [ssh-key-suffix] \n" 
} 
# if less than two arguments supplied, display usage 
if [  $# -lt 1 ] 
then 
  display_usage
  exit 1
fi 

# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $@ == "--help") ||  $@ == "-h" ]] 
then 
  display_usage
  exit 0
fi 

EMAIL_ADDRESS=$1
FILE_SUFFIX=""
if [ ! -z "$2" ]
  then
    FILE_SUFFIX=$2    
fi


# Generate the ssh key
#  using Ed25519 is an EdDSA scheme and 100 rounds of key derivations
FILE_PATH=~/.ssh/id_ed25519_"${FILE_SUFFIX}"
ssh-keygen -t ed25519 -C $EMAIL_ADDRESS -a 100 -f $FILE_PATH

echo "SSH key file: "$FILE_PATH

# Add the SSH key to the ssh-agent
# 1. Start the ssh-agent in the background.
eval "$(ssh-agent -s)

# 2. automatically load keys into the ssh-agent and store passphrases in the keychain 
cat <<EOT >> ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ${FILE_PATH}
EOT"
echo "....... $FILE_PATH" 
#3. Add SSH private key to the ssh-agent and store passphrase in the keychain
ssh-add --apple-use-keychain ${FILE_PATH} 

echo '\033[0;35m' "SSH key successfully created"
echo "Run:" '\033[0;32m' "pbcopy < ${FILE_PATH}.pub" '\033[0m' 

echo "For repository local commiter config, run this inside the repo folder"
echo "git config user.email $EMAIL_ADDRESS"