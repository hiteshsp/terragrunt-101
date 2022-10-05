# terragrunt-101



## Use Cases

### Keep your Terraform code DRY

#### Before

```
└── live
    ├── prod
    │   ├── app
    │   │   └── main.tf
    │   ├── mysql
    │   │   └── main.tf
    │   └── vpc
    │       └── main.tf
    ├── qa
    │   ├── app
    │   │   └── main.tf
    │   ├── mysql
    │   │   └── main.tf
    │   └── vpc
    │       └── main.tf
    └── stage
        ├── app
        │   └── main.tf
        ├── mysql
        │   └── main.tf
        └── vpc
            └── main.tf

```

#### Problem

The contents of each environment will be more or less identical, except for a few settings (e.g. the prod environment may run bigger or more servers). 
As the size of the infrastructure grows, having to maintain all of this duplicated code between environments becomes more error prone. 
You can reduce the amount of copy paste using Terraform modules, but even the code to instantiate a module and set up input variables, output variables, providers, and remote state can still create a lot of maintenance overhead.

#### After

`modules` repo would look like this.
```
└── modules
    ├── app
    │   └── main.tf
    ├── mysql
    │   └── main.tf
    └── vpc
        └── main.tf
```

`input` variables will differentiate the environments (Dev, QA etc.)

```
variable "instance_count" {
  description = "How many servers to run"
}

variable "instance_type" {
  description = "What kind of servers to run (e.g. t2.large)"
}
```

```
└── live
    ├── prod
    │   ├── app
    │   │   └── terragrunt.hcl
    │   ├── mysql
    │   │   └── terragrunt.hcl
    │   └── vpc
    │       └── terragrunt.hcl
    ├── qa
    │   ├── app
    │   │   └── terragrunt.hcl
    │   ├── mysql
    │   │   └── terragrunt.hcl
    │   └── vpc
    │       └── terragrunt.hcl
    └── stage
        ├── app
        │   └── terragrunt.hcl
        ├── mysql
        │   └── terragrunt.hcl
        └── vpc
            └── terragrunt.hcl

```

`stage/app/terragrunt.hcl` may look like this:

```
terraform {
  # Deploy version v0.0.3 in stage
  source = "git::git@github.com:foo/modules.git//app?ref=v0.0.3"
}

inputs = {
  instance_count = 3
  instance_type  = "t2.micro"
}
```

And `prod/app/terragrunt.hcl` may look like this:

```
terraform {
  # Deploy version v0.0.1 in prod
  source = "git::git@github.com:foo/modules.git//app?ref=v0.0.1"
}

inputs = {
  instance_count = 10
  instance_type  = "m2.large"
}
```

##### How it works behind the scenes ?
* Download the configurations specified via the source parameter into the --terragrunt-download-dir folder (by default .terragrunt-cache in the working directory, which we recommend adding to .gitignore). Terragrunt will download all the code in the repo (i.e. the part before the double-slash //) so that relative paths work correctly between modules in that repo.
* Copy all files from the current working directory into the temporary folder.
* Execute whatever Terraform command you specified in that temporary folder.
* Pass any variables defined in the `inputs = { …​ }` block as environment variables (prefixed with TF_VAR_ to your Terraform code. Notice how the inputs block in `stage/app/terragrunt.hcl` deploys fewer and smaller instances than prod.

>**Note**: Use `tee live/{dev,test}/{app,mysql}/terragrunt.hcl < terragrunt.hcl` to quickly copy initial terragrunt.hcl