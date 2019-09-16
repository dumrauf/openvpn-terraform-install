# A Comprehensive OpenVPN Server Solution in AWS with Terraform

This repository contains a one-stop Terraform module that creates a single node [OpenVPN Server](https://en.wikipedia.org/wiki/OpenVPN) cluster in a dedicated AWS VPC and subnet. The OpenVPN server is configured to be readily accessible by the users supplied in the Terraform input file. The same Terraform input file can be used to subsequently update the list of authorised users.

> For further information, see the corresponding article on [Ready to Use OpenVPN Servers in AWS For Everyone](https://www.how-hard-can-it.be/openvpn-server-install-terraform-aws/) on [How Hard Can It Be?!](https://www.how-hard-can-it.be/).


## You Have

Before you can use the Terraform module in this repository out of the box, you need

 - an [AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html)
 - a [Terraform](https://www.terraform.io/intro/getting-started/install.html) CLI
 - a list of users to provision with OpenVPN access

Moreover, you probably had enough of people snooping on you and want some privacy back or just prefer to have a long lived static IP.


## You Want

After running the Terraform module in this repository you get
 - an EC2 node running in a dedicated VPC and subnet
 - an OpenVPN server bootstrapped on the EC2 node by the excellent [openvpn-install.sh](https://github.com/angristan/openvpn-install/blob/master/openvpn-install.sh) Bash script from [https://github.com/angristan/openvpn-install](https://github.com/angristan/openvpn-install)
 - SSH access to the OpenVPN sever locked down to the IP address of the machine executing the Terraform module (see the FAQs for how to handle drift over time)
 - the list of users supplied as input to the Terraform module readily provisioned on the OpenVPN server
 - the configuration of each user supplied in the Terraform configuration downloaded onto the local machine and ready for use
 - the option to provision and revoke users from the OpenVPN server by simply re-running the Terraform module 


## Setup

The minimal setup leverages as much of the default settings in [variables.tf](variables.tf) as possible. However some input is required.

### Providing SSH Keys

In order to bootstrap as well as manage the OpenVPN server, the Terraform module needs to SSH into the EC2 node. By default, it uses the public key in `settings/openvpn.pub` and the private key in `settings/openvpn`. Both can be created by executing the following command from the root directory of this repository
```
cd settings
ssh-keygen -f openvpn -t rsa
```
Here, hit return when prompted for a password in order to make the SSH keys passwordless.

### Configuring Your Settings

The minimum input variables for the module are defined in [settings/example.tfvars](settings/example.tfvars) to be
```hcl
aws_region = "<your-region>"

shared_credentials_file = "/path/to/.aws/credentials"

profile = "<your-profile>"

ovpn_users = ["userOne", "userTwo", "userThree"]
```
Here, you need to replace the example values with your settings.

Moreover, note that users `userOne`, `userTwo`, and `userThree` will be provisioned with access to the OpenVPN sever and their configurations downloaded to the default location `generated/ovpn-config`.

> Each user provisioned via input `ovpn_users` should preferably be defined as a single word (i.e., no whitespace), _consisting only of ASCII letters and numbers with underscores as delimiters_; in technical terms, each user should adhere to `^[a-zA-Z0-9_]+$`.

## Execution

All Terraform interactions are wrapped in helper Bash scripts for convenience.

### Initialising Terraform

Initialise Terraform by running
```
./terraform-bootstrap.sh
```

### Applying the Terraform Configuration

The OpenVPN server can be created and updated by running
```
./terraform-apply.sh <input-file-name>
```
where `<input-file-name>` references input file `settings/<input-file-name>.tfvars`.
When using input file [settings/example.tfvars](settings/example.tfvars) configured above, the command becomes
```
./terraform-apply.sh example
```
Under the bonnet, the `terraform-apply.sh` Bash script with input `example`
 - selects or creates a new workspace called `example`
 - executes `terraform apply` where the inputs are taken from input file `settings/example.tfvars`
 - does not ask for permission to proceed as it uses `-auto-approve` when running the underlying `terraform apply` command


## Terraform Outputs

By default, all `.ovpn` configurations for the users provisioned with access to the OpenVPN server in input `ovpn_users` are automatically downloaded to `generated/ovpn-config`.

Additionally, the Terraform module also outputs
 - the `ec2_instance_dns`
 - the `ec2_instance_ip` and
 - a `connection_string` that can be used to SSH into the EC2 node 

## Deletion

The OpenVPN server can be deleted by running
```
./terraform-destroy.sh <input-file-name>
```
where `<input-file-name>` again references input file `settings/<input-file-name>.tfvars`.
When using input file [settings/example.tfvars](settings/example.tfvars) configured above, the command becomes
```
./terraform-destroy.sh example
```

Under the bonnet, the `terraform-destroy.sh` Bash script with input `example`
 - selects the `example` workspace
 - executes `terraform destroy` where the inputs are taken from file `settings/example.tfvars`
 - _does ask for permission_ to proceed when running the `terraform apply` command


## Testing VPN Connectivity

Once the Terraform module execution has successfully completed, the connection to the OpenVPN can be tested as follows. 

> While below instructions are specific to a recent Mac using [Homebrew](https://brew.sh/) as a package manager, the actual underlying `openvpn` command should be fairly transferable to other platforms as well.

If not already present, install `openvpn` via `brew` by executing
```
brew install openvpn
```
Follow the instructions on screen and if the installation may need a little final nudge, try running
```
sudo brew services start openvpn
```
In case `openvpn` isn't readily available from the terminal after the installation above, a [StackOverflow answer](https://apple.stackexchange.com/a/233221) suggests to add the `openvpn` executable to the `$PATH` environment variable by executing
```
export PATH=$(brew --prefix openvpn)/sbin:$PATH
```
Assuming a valid OpenVPN configuration has been downloaded to `generated/ovpn-config/userOne.ovpn `, the connection can be tested by initiating the actual `openvpn` connection by running
```
sudo openvpn --config generated/ovpn-config/userOne.ovpn 
```
> Note that the above command will actually change your network settings and hence public IP.


## Credits

This repository relies on the great [openvpn-install.sh](https://github.com/angristan/openvpn-install/blob/master/openvpn-install.sh) Bash script from [https://github.com/angristan/openvpn-install](https://github.com/angristan/openvpn-install) to do the OpenVPN plumbing under the bonnet. Keep up the good work, Stanislas Lange, aka [angristan](https://angristan.xyz/)!


## FAQs

Below is a list of frequently asked questions.

### I Cannot SSH Into the OpenVPN Server Any Longer!

Most likely, the IP address of your machine executing the Terraform module has changed since the original installation. The security groups for the OpenVPN server are designed to only permit SSH access from a single predefined IP address. As this has drifted from the original value, you are being refused SSH access. But this scenario has been incorporated into the design of the Terraform module.

Just re-run the `./terraform-apply.sh` Bash script again with your `<input-file-name>`. Terraform should pick up your new IP address and update the ingress rules for the security groups accordingly.

### Why Is There no Route 53/DNS Support for Custom Domains?

Custom domains are great for running an OpenVPN server at [vpn.how-hard-can-it.be](vpn.how-hard-can-it.be). However, depending on the domain, its age, and many other factors, a provider may choose to _not resolve_ the domain which leaves the OpenVPN server unreachable when it may be needed the most.

Standard AWS URLs such as [ec2-1-2-3-4.eu-west-2.compute.amazonaws.com](ec2-1-2-3-4.eu-west-2.compute.amazonaws.com) tend to be resolved by most providers. It's probably not the most memorable URL but it tends to work in the places I personally care about.

### How Do I Configure OpenVPN Access on My Mac?

Please refer to the excellent guide on [Downloading and Installing Tunnelblick](https://tunnelblick.net/cInstall.html).

### How Do I Configure OpenVPN Access On My iPhone?

Please refer to the excellent guide on how to [Install OpenVPN on iOS](https://www.ovpn.com/en/guides/ios).
For transferring `.ovpn` configurations onto your iPhone, please refer to [Transfer Files to Your Mobile By Scanning a QR Code](https://www.how-hard-can-it.be/transfer-files-to-your-mobile-by-scanning-a-qr-code/).

### How Do I Configure OpenVPN Access On My Android phone?

Please refer to the excellent [Guide to install OpenVPN Connect for Android](https://www.ovpn.com/en/guides/android).
For transferring `.ovpn` configurations onto your Android phone, please refer to [Transfer Files to Your Mobile By Scanning a QR Code](https://www.how-hard-can-it.be/transfer-files-to-your-mobile-by-scanning-a-qr-code/).
 
### How do I Add or Remove Users from a Provisioned OpenVPN Server?

Simply add or remove the users from the list of `ovpn_users` in your `settings/<input-file-name>.tfvars` input file and re-run `./terraform-apply.sh <input-file-name>` as described above.

### Why is There no Load Balancing?

This Terraform module has been deliberately kept simple. It's intended for personal use and to reclaim some lost privacy, security, and freedom. If you require professional or enterprise level VPN services, then there is a sheer abundance of [commercial VPN providers](https://en.wikipedia.org/wiki/Comparison_of_virtual_private_network_services) to choose from.

This isn't to say that it wouldn't be a fun project to put the OpenVPN servers behind ASGs and ALBs and spin up bastion hosts on demand. However, this makes the key handling a bit more complicated. If you're interested, reach out and we can discuss over a pint.

On a side note: From personal experience, a single node OpenVPN cluster has served my digital family with a handful of more of less permanently connected devices well on a daily base over the course of the past six months. And running.

### Why Is Terraform Also Being Used for User Provisioning and Maintenance?

In one word: simplicity.

Terraform is great for provisioning (fairly static) infrastructure but there are more sophisticated tools out there for provisioning and maintaining elastic infrastructure at scale, let alone user provisioning and maintenance. For sake of simplicity, Terraform is being used as the single tool of choice in this case.

### Wait — There's a Pint Bounty in the Code?!

Yes. Find it. Solve it. Bag your reward. I'm looking forward to your solutions! Teach me something new!
