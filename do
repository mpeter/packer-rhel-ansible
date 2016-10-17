#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -x


# navigate to project root
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALL_CFG="${ROOT_DIR}/install.cfg"

cd "${ROOT_DIR}"

function prop {
    grep "^\\s*${1}=" "${INSTALL_CFG}" | cut -d'=' -f2
}
function setup-env {
    os=${OSTYPE//[0-9.-]*/}
    case "$os" in
        darwin)
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew tap caskroom/cask
        brew cask install virtualbox vagrant
        brew install git packer ansible
        #brew update
        #brew upgrade
    ;;
    msys)
        echo "Not yet implemented. Check README.md"
    ;;
    linux)
        echo "Not yet implemented. Check README.md"
    ;;
    *)
        echo "Unknown Operating system $OSTYPE"
        exit 1
    esac
}

setup-ansible() {
    cd "${ROOT_DIR}/ansible"
    ansible-galaxy install --role-file=requirements.yml
}

build-packer() {
    only=${1}
    cd "${ROOT_DIR}/packer"
    packer_json=$(prop 'packer_json')
    iso_path=$(prop 'iso_path')
    iso_name=$(basename $iso_path)
    mirror="file:///$(dirname $iso_path)"
    template=$(basename $packer_json .json)

    packer build \
        -only=${only} \
        -force \
        -var arch=$(prop 'arch') \
        -var box_basename=$(prop 'box_basename') \
        -var iso_checksum=$(prop 'iso_checksum') \
        -var iso_checksum_type=$(prop 'iso_checksum_type') \
        -var iso_name=${iso_name} \
        -var ks_path=$(prop 'ks_path') \
        -var mirror=${mirror} \
        -var rhel_release=$(prop 'rhel_release') \
        -var rhsm_password=$(prop 'rhsm_password') \
        -var rhsm_username=$(prop 'rhsm_username') \
        -var template=${template} \
        -var version=$(prop 'version') \
        ${packer_json}

    cd "${ROOT_DIR}"
}

install-vagrant-box() {
    box_prefix=$(prop 'box_prefix')
    box_basename=$(prop 'box_basename')

    vagrant box add \
        --provider virtualbox \
        --force \
        --name "${box_prefix}/${box_basename}" \
        "packer/builds/${box_basename}.virtualbox.box"
}

case "${1:-}" in
  "")
    ;;
  "setup")
    setup-env
    setup-ansible
    ;;
  "build-ovf")
    build-packer build-packer-ovf
    ;;
  "build-box")
    build-packer build-packer-box
    ;;
  "build-null")
    build-packer build-packer-null
    ;;
  "build")
    build-packer build-packer-ovf
    build-packer build-packer-box
    ;;
  "install")
    install-vagrant-box
    ;;
esac
