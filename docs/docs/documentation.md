# IAM Roles and Secure Access Automation
# Project Documentation

**Author:** Sharon Ogbogu
**Platform:** Microsoft Azure
**Tools Used:** Azure CLI, Bash Scripting, GitHub Actions
**Date:** March 2026

# 1. Project Overview

This project automates the setup of Identity and Access Management
(IAM) controls on Microsoft Azure using Azure CLI and Bash scripting.

The goal is to control WHO can access WHAT inside a cloud environment
without manually clicking through the Azure Portal every time.
Everything is done through automation scripts that can be run
repeatedly and consistently.

# 2. Architecture
```
Azure Subscription
└── Resource Group: IAM-Project-RG (East US)
    ├── Virtual Network: IAM-VNet (10.0.0.0/16)
    │   ├── WebSubnet (10.0.1.0/24)
    │   └── DBSubnet  (10.0.2.0/24)
    └── Microsoft Entra ID (Azure Active Directory)
        ├── Group: WebAdmins
        │   └── Member: webadmin.test
        └── Group: DBAdmins
            ├── Member: dbadmin.test
            └── Role: Reader (scoped to IAM-Project-RG)
```

# Design Decisions

**Why two subnets?**
Separating Web and DB into different subnets follows the principle
of network isolation. The web team and database team operate in
different zones, reducing the risk of one compromising the other.

**Why Reader role for DBAdmins?**
This follows the Principle of Least Privilege — one of the most
important rules in security. DBAdmins are given only the minimum
access they need: they can view database resources but cannot
create, edit or delete anything.

**Why Azure AD Groups instead of individual users?**
Assigning roles to groups rather than individuals makes management
scalable. If you add a new person to the DBAdmins group, they
automatically inherit the Reader role without any extra steps.

# 3. Prerequisites

Before running the scripts you need:

- An active Microsoft Azure account
- Azure CLI installed on your machine
- Git Bash (Windows) or Terminal (Mac/Linux)
- VS Code (recommended)
- Git installed

# 4. Folder Structure

| Folder/File | Purpose |

| `scripts/iam_setup.sh` | Main automation script |
| `scripts/iam_cleanup.sh` | Cleanup and revoke access script |
| `docs/documentation.md` | This documentation file |
| `screenshots/` | All deployment screenshots |
| `.github/workflows/iam-deploy.yml` | CI/CD pipeline |
| `README.md` | Project overview |

# 5. Deployment Steps

# Step 1 — Clone the Repository
```bash
git clone https://github.com/Starbele/iam-project.git
cd iam-project
```
# Step 2 — Login to Azure
```bash
az login
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

# Step 3 — Run the Setup Script
```bash
export MSYS_NO_PATHCONV=1
chmod +x scripts/iam_setup.sh
bash scripts/iam_setup.sh
```

# Step 4 — Verify in Azure Portal
After the script completes:
- Go to portal.azure.com
- Search for Resource Groups
- Click IAM-Project-RG
- Confirm all resources were created

# 6. Script Details

# iam_setup.sh — What It Does Step by Step

| Step | Command Used | What It Creates |

| 1 | az group create | Resource Group: IAM-Project-RG |
| 2 | az network vnet create | Virtual Network: IAM-VNet |
| 3 | az network vnet subnet create | WebSubnet and DBSubnet |
| 4 | az ad group create | WebAdmins and DBAdmins groups |
| 5 | az role assignment create | Reader role → DBAdmins |
| 6 | az ad user create | webadmin.test and dbadmin.test |
| 7 | az ad group member add | Users added to their groups |
| 8 | az role assignment list | Validates everything worked |

# iam_cleanup.sh — What It Does Step by Step

| Step | Command Used | What It Removes |

| 1 | az role assignment delete | Revokes Reader role from DBAdmins |
| 2 | az ad user delete | Deletes both test users |
| 3 | az ad group delete | Deletes WebAdmins and DBAdmins |
| 4 | az group delete | Deletes entire Resource Group |

# 7. CI/CD Pipeline

# What is CI/CD?
CI/CD stands for Continuous Integration and Continuous Deployment.
Every time code is pushed to the main branch on GitHub, the pipeline
automatically logs into Azure and runs the IAM setup script.
No manual work needed.

# Pipeline Steps

| Step | What Happens |

| Checkout Code | Downloads the repo onto GitHub's server |
| Login to Azure | Authenticates using stored credentials |
| Set Subscription | Points Azure CLI to correct subscription |
| Make Script Executable | Grants run permission on Linux |
| Run IAM Setup Script | Executes iam_setup.sh automatically |
| Confirm Deployment | Verifies Resource Group exists |

# GitHub Secrets Required

| Secret Name | What It Contains |

| AZURE_CREDENTIALS | Full JSON credentials from service principal |
| AZURE_SUBSCRIPTION_ID | Your Azure subscription ID |

# 8. Challenges Faced and Solutions

# Challenge 1 — Git Bash Path Conversion
**Problem:** Git Bash on Windows automatically converted
`/subscriptions/abc123` to `C:/Program Files/Git/subscriptions/abc123`
which caused every Azure CLI command involving a path to fail with
a MissingSubscription error.

**Solution:** Added `export MSYS_NO_PATHCONV=1` to the top of all
scripts. This environment variable tells Git Bash to stop converting
Unix paths to Windows paths.

# Challenge 2 — MissingSubscription Error
**Problem:** Even after fixing the path issue, Azure CLI was not
recognising the subscription in some commands causing role assignment
to fail repeatedly.

**Solution:** Ran `az account set --subscription "ID"` explicitly
with the hardcoded subscription ID before running role assignment
commands. Also hardcoded the subscription ID directly in the scope
path instead of relying on variables.

# Challenge 3 — Text Editor Confusion
**Problem:** When using Azure Cloud Shell, the nano text editor
conflicted with browser keyboard shortcuts. Pressing Ctrl+S triggered
the browser Save dialog instead of saving the file.

**Solution:** Switched entirely to VS Code on local machine with
Git Bash terminal. This gave a much better development experience
with full file management and no browser conflicts.

# Challenge 4 — GitHub Push Rejected
**Problem:** GitHub rejected the push because the remote repository
had changes (a README created online) that the local repo did not
have, causing histories to diverge.

**Solution:** Ran `git pull origin main --allow-unrelated-histories`
to force merge the two different histories before pushing.

# Challenge 5 — Scripts Not Found by CI/CD Pipeline
**Problem:** The CI/CD pipeline failed with
"cannot access scripts/iam_setup.sh: No such file or directory"
because the scripts were in the root folder instead of inside
a dedicated scripts/ folder.

**Solution:** Created the scripts/ folder, moved all .sh files
into it, updated the pipeline file to reference the correct path,
and pushed the corrected structure to GitHub.

# 9. Key Learnings

 **Azure RBAC** — Role-Based Access Control lets you assign
  permissions at different scopes using built-in roles like
  Reader, Contributor and Owner

**Principle of Least Privilege** — Always give users and groups
  only the minimum access they need to do their job

**Infrastructure as Code** — Writing scripts to create cloud
  resources is faster, more reliable and repeatable than
  clicking through a portal manually

 **CI/CD Automation** — GitHub Actions can automatically deploy
  infrastructure every time code is pushed, removing manual steps
  entirely

 **Troubleshooting** — Real cloud engineering involves debugging
  environment-specific issues like Windows path conversion, Git
  history conflicts and permission errors


# 10. Resources

- Azure CLI Documentation: https://docs.microsoft.com/cli/azure
- Azure RBAC Documentation: https://docs.microsoft.com/azure/role-based-access-control
- GitHub Actions Documentation: https://docs.github.com/actions
- GitHub Repository: https://github.com/Starbele/iam-project