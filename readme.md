# hcloud devgate

Notes:
- This **is not** an **official Hetzner Cloud project**
- This is my **personal development setup** and **highly opinionated**. It does currently only contain configurations for my own use-cases (pull requests welcome though)
- This is my first terraform project so you might not find the optimal solution for all aspects of terraform here

## What is this?

The devgate is a Terraform configuration to launch a hetzner cloud instance configured to be used as a remote development machine, especially with VSCode remote tools in mind.

## Why?

### Devgate

The experience I made when _trying out_ or _working with_ different languages was that I was actively cluttering my machine with different tools which will set up environments each for their own language. This filled my home repository and added a lot of entries to my `.zshrc`. On top of that, if I want to keep going on a different machine, like at home or work I will have to install all of the tooling again.

The best solution for this problem was to just create a remote machine that I can pollute with dependencies and ssh into for development with vim or any other command line based tools.

Microsoft releasing their VSCode `Remote Development` Plugins sealed the deal for the devgate as I can use a fully featured IDE on a remote machine.

### Terraform

Terraform was mainly chosen to be able to save some money. Instead of running a powerful CX51 for an entire month, I am able to boot up my development machine when I need it and destroy it when I am done.

## How to use

### Prerequisites

- [`terraform`](https://www.terraform.io/) >= 0.12
- [Hetzner Cloud](https://console.hetzner.cloud/) project with a generated [API-Key](https://docs.hetzner.cloud/#overview-getting-started)
- A `Floating IP` in your Hetzner Cloud project
- A `Volume` in your Hetzner Cloud project
- An ssh-keypair that will be used by the user on the devgate for e.g. pushing to GitHub
- (optional) [VSCode](https://code.visualstudio.com/) with [Remote Development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

### Configuration

#### Required

1. Remove the `.example` suffix from `terraform.tfvars.example`
2. Replace the config placeholders with your preferences
3. Copy the pre-generated ssh-keypair into the `.ssh` directory of this repository

#### Quality of life
1. Edit your `~/.ssh/config` to contain
    ```
    Host devgate
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null
        HostName <your_floating_ip>
        User <your_user_name>
        IdentityFile <ssh_key_to_authenticate_with>
    ```
    Disabling `StrictHostKeyChecking` will allow you to log into the devgate without receiving a warning from `ssh` as we are expecting the server behind the IP to be changing.
2. If using VSCode, add `.vscode/extensions.json` to your project and fill it with the extension you want to use in that project. When opening the project with VSCode it will prompt you to install the extensions (on the remote machine) which will save you some time

### Usage
There are not many things to say about the usage, apart from that it is expected that projects are created in the volume, for ease of use this template creates a softlink to the volume in your home directory with the name `projects`.
