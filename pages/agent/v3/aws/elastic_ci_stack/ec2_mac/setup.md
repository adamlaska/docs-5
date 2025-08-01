# EC2 Mac setup for the Elastic CI Stack for AWS

You can run your builds on AWS EC2 Mac using Buildkite's [CloudFormation template](https://github.com/buildkite/elastic-mac-for-aws). This template creates an Auto Scaling group, launch template, and host resource group for maintaining a pool of EC2 Mac instances that run the
Buildkite agent. Using Buildkite agents, you can run pipelines and build
Xcode-based software projects for macOS, iOS, iPadOS, tvOS, and watchOS.

> 🚧
> As you must prepare and supply your own AMI (Amazon Machine Image) for this template, macOS support has **not** been incorporated into the Elastic CI Stack for AWS.

Using an Auto Scaling group for your instances ensures booting your macOS
Buildkite Agents is repeatable, and enables automatic instance replacement when
hardware failures occur.

## Before you start

You should have familiarity with:

* AWS VPCs
* AWS EC2 AMIs
* macOS GUI

You must also choose an AWS Region with EC2 Mac instances available. See
[Amazon EC2 Mac instances](https://aws.amazon.com/ec2/instance-types/mac/) and
[Amazon EC2 Dedicated Hosts pricing](https://aws.amazon.com/ec2/dedicated-hosts/pricing/)
for details on which regions have EC2 Mac Dedicated Hosts.

> 🚧 Minimum allocation
>Dedicated macOS <strong>hosts</strong> on AWS have a <a href="https://aws.amazon.com/ec2/dedicated-hosts/pricing/#on-demand">minimum billing period</a> of 24 hours. However you can scale instances running on the host at will.

See also the [Amazon EC2 Mac instances user guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-mac-instances.html) for more details on AWS EC2 Mac instances.

## Step 1: Choose a VPC layout

Before deploying this template you must [choose a VPC subnet design](/docs/agent/v3/aws/architecture/vpc), and which VPC security groups your instances will belong to.

Depending on your threat model, you may find running instances in your default
VPC's public subnets with a public IP address suitable. Otherwise, you may wish
to explore options like separate public/private subnets with a NAT Gateway, and
a bastion instance or a VPN to access the private instances over SSH and VNC.
See the [AWS VPC Design documentation](/docs/agent/v3/aws/architecture/vpc) for more
details, and the [AWS VPC quick start](https://aws.amazon.com/quickstart/architecture/vpc/)
for a ready-made CloudFormation template.

EC2 Mac Dedicated Hosts are not available in every Availability Zone in the
supported regions. You need to provision a VPC subnet in all of your region's Availability
Zones to maximize the size of your instance pool.

You also need to configure or define the VPC security groups your instance
network interfaces will belong to. At a minimum, inbound SSH access is
required to set up your initial template EC2 AMI.

## Step 2: Build an AMI

Before deploying this template, you must create a template AMI that will be
horizontally scaled across multiple instances.

1. Reserve an [EC2 Mac](https://aws.amazon.com/ec2/instance-types/mac/)
Dedicated Host.
1. Boot a macOS instance using your desired AMI on the Dedicated Host. Ensure
the root disk is large enough for the version of Xcode you plan to download and
install.
1. Configure the instance VPC subnet, security groups, and key name so that you
can access the instance.
1. Using an SSH or AWS SSM session:
	- Set a password for the `ec2-user` using `sudo passwd ec2-user`
	- Enable screen sharing using `sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -restart -agent -privs -all`
	- Grow the AFPS container to use all the available space in your EBS root disk if needed, see the [AWS user guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-mac-instances.html#mac-instance-increase-volume)
1. Using a VNC session (run SSH port forwarding `ssh -L 5900:localhost:5900 ec2-user@<ip-address>` if direct access is not available):
	1. Sign in as the `ec2-user`.
	1. Set **Automatically log in as** to `ec2-user` in **System Settings** > **Users & Groups**.
	1. Set an empty password in **System Settings** > **Login Password**.
	1. Set **Start Screen Saver when inactive** to `Never` in **System Settings** > **Lock Screen**.
1. Install your required version of Xcode, and ensure you launch Xcode at least
once so you are presented with the EULA prompt.
1. If you plan to customize the UserData script or build automation tools, note that Homebrew paths differ by architecture:
   - Apple Silicon (ARM): `/opt/homebrew/bin`
   - Intel (x86): `/usr/local/bin`
1. Using the AWS EC2 Console, create an AMI from your instance.

You do not need to install the `buildkite-agent` in your template AMI, the
`buildkite-agent` will be installed at boot time by the launch template's
`UserData` script.

> 📘 UserData script considerations
> The default UserData script installs the Buildkite Agent using Homebrew. Since Homebrew is installed under the `ec2-user` account (not root), the UserData script must run Homebrew commands using `su - ec2-user -c`. If you're customizing the UserData script, ensure you maintain this pattern to avoid "command not found: brew" errors.

## Step 3: Associate your AMI with a self-managed license in AWS License Manager

To launch an instance using a host resource group, the instance AMI must be
associated with a **Self-managed license** in **AWS License Manager**.

Using the AWS Console, open the **AWS License Manager** and navigate to
**Self-managed licenses**. Create a new **Self-managed license**, enter a
descriptive name and select a **License type** of `Cores`.

Once your self-managed license has been saved, open the detail view for your
license. Open the **Associated AMIs** tab and choose **Associate AMI**. From the
list of **Available AMIs**, select your macOS template AMI and then click
**Associate**.

## Step 4: Deploy the CloudFormation template

Using the VPC and AMI prepared earlier, prepare values for the following
required parameters:

* `ImageId` from your AMI set up
* `RootVolumeSize` no smaller than the template AMI's root disk
* `Subnets` from your VPC set up
* `SecurityGroupIds` from your VPC set up
* `IamInstanceProfile` if accessing AWS services from your builds, provide an Instance Profile ARN with an appropriate IAM role attached
* `BuildkiteAgentToken` an Agent Token for your [Buildkite organization](http://buildkite.com/organizations/-/agents)
* `BuildkiteAgentQueue` the Buildkite Queue your pipeline steps use

There are optional parameters to configure which EC2 Mac instance types to use:

* `HostFamily` defaults to `mac1`
* `InstanceType` defaults to `mac1.metal`

There are also optional parameters to configure the size of the Auto Scaling
group:

* `MinSize` defaults to 0
* `MaxSize` defaults to 3

The default AWS Limit for `mac1.metal` is three Dedicated Hosts per account
region. If you require more than three instances, request an increased limit in
the *AWS Service Quotas Dashboard*.

### Deploy using the AWS Console

* Use the launch button below to create a CloudFormation stack from the latest
version of the Buildkite template:

<a href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=buildkite-mac&templateURL=https://s3.amazonaws.com/buildkite-serverless-apps-us-east-1/elastic-mac/template/latest.yml"><%= image "launch-stack.svg", alt: "Launch stack button" %></a>

* Ensure the selected region in the top menu bar matches the region of your VPC
and AMI resources.

* Give your stack a unique name, and fill in the required parameters.

### Deploy using the AWS CLI

To deploy using the AWS CLI, save your parameters in a `.parameters.json` file
and run the following commands:

```
$ cat .parameters.json
> [
	{
		"ParameterKey": "ImageId",
		"ParameterValue": "ami-0c3a7d0c15048b6b5"
	},
	{
		"ParameterKey": "RootVolumeSize",
		"ParameterValue": "250"
	},
	{
		"ParameterKey": "Subnets",
		"ParameterValue": "subnet-f3e72abb,subnet-f23fe294"
	},
	{
		"ParameterKey": "SecurityGroupIds",
		"ParameterValue": "sg-a09db9d7"
	},
	{
		"ParameterKey": "BuildkiteAgentQueue",
		"ParameterValue": "mac"
	},
	{
		"ParameterKey": "BuildkiteAgentToken",
		"ParameterValue": "[redacted]"
	}
]

$ make
> sed "s/%v/v0.0.1-9-g1790b0d/" <template.yml >build/template.yml

$ aws cloudformation deploy --stack-name buildkite-mac --region YOUR_REGION --template-file build/template.yml --parameters-override file:///$PWD/.parameters.json
```

See the [AWS CloudFormation Deploy CLI documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudformation/deploy/index.html)
for help using the AWS CLI.

## Step 5: Starting your Buildkite agents

Once you have successfully deployed the template, use the deployed stack's
**Resources** tab to find the `AutoScaleGroup` and open the **Physical ID** link.
**Edit** the selected Auto Scaling group, and set the **Desired capacity** to the
number of instances you require.

The Auto Scaling group will automatically provision Dedicated Hosts using the
host resource group and boot instances on them. The launch template's `UserData`
script will resize the root disk, then install, configure, and start the
Buildkite Agent.

EC2 Mac instances are slower to boot and terminate than Linux instances. If want
to match your **Desired capacity** to your workload, consider configuring
[scheduled scaling for your Auto Scaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/schedule_time.html)
