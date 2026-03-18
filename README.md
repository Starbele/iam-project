# IAM Roles and Secure Access Automation

**Author:** Sharon Ogbogu
**Platform:** Microsoft Azure
**Tools:** Azure CLI, Bash, GitHub Actions
**Date:** March 2026

---

##  Project Overview

This project automates the setup of secure Identity and Access Management
(IAM) controls on Microsoft Azure using Azure CLI and Bash scripting.

Instead of manually clicking through the Azure Portal, all resources are
created automatically by running scripts. The project demonstrates how to
control who has access to what in a cloud environment — a critical skill
in cloud security.

---

## Architecture
```
Azure Subscription
└── Resource Group: IAM-Project-RG (East US)
    ├── Virtual Network: IAM-VNet (10.0.0.0/16)
    │   ├── WebSubnet (10.0.1.0/24)
    │   └── DBSubnet  (10.0.2.0/24)
    └── Microsoft Entra ID (Azure AD)
        ├── Group: WebAdmins
        │   └── Member: webadmin.test
        └── Group: DBAdmins
            ├── Member: dbadmin.test
            └── Role: Reader (scoped to IAM-Project-RG)
```

---

## Folder Structure
```
iam-project/
├── scripts/
│   ├── iam_setup.sh        # Main setup script
│   └── iam_cleanup.sh      # Bonus cleanup script
├── .github/
│   └── workflows/
│       └── iam-deploy.yml  # CI/CD pipeline
└── README.md               # This file
```

---

## Tasks Completed

### Task 1 — Resource Group, Virtual Network and Subnets
- Created Resource Group: `IAM-Project-RG` in East US
- Created Virtual Network: `IAM-VNet` with address space `10.0.0.0/16`
- Created `WebSubnet` with address `10.0.1.0/24`
- Created `DBSubnet` with address `10.0.2.0/24`

### Task 2 — Azure AD Groups
- Created group: `WebAdmins`
- Created group: `DBAdmins`

### Task 3 — Role Assignment
- Assigned the built-in `Reader` role to `DBAdmins`
- Scoped to the `IAM-Project-RG` Resource Group
- Follows the principle of least privilege

### Task 4 — Test Users and Validation
- Created user: `webadmin.test`
- Created user: `dbadmin.test`
- Added webadmin.test to WebAdmins group
- Added dbadmin.test to DBAdmins group
- Validated role assignments using `az role assignment list`

---

## Scripts Explained

### iam_setup.sh
The main automation script that runs 8 steps in sequence:
1. Creates the Resource Group
2. Creates the Virtual Network
3. Creates WebSubnet and DBSubnet
4. Creates WebAdmins and DBAdmins AD groups
5. Assigns Reader role to DBAdmins
6. Creates test users
7. Adds users to their groups
8. Validates and prints all assignments

### iam_cleanup.sh (BONUS)
Removes everything safely:
- Revokes Reader role from DBAdmins
- Deletes both test users
- Deletes both AD groups
- Deletes the entire Resource Group

---

## How to Run

### Prerequisites
- Active Azure account
- Azure CLI installed
- Git Bash or Terminal

### Step 1 — Clone the repo
```bash
git clone https://github.com/Starbele/iam-project.git
cd iam-project
```

### Step 2 — Login to Azure
```bash
az login
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### Step 3 — Run the setup
```bash
export MSYS_NO_PATHCONV=1
chmod +x scripts/iam_setup.sh
bash scripts/iam_setup.sh
```

### Step 4 — Cleanup when done
```bash
bash scripts/iam_cleanup.sh
```


## CI/CD Pipeline

This project includes a GitHub Actions pipeline that automatically runs
the IAM setup script every time code is pushed to the main branch.

**Pipeline file:** `.github/workflows/iam-deploy.yml`

**How it works:**
1. Code is pushed to GitHub
2. GitHub Actions automatically triggers
3. Pipeline logs into Azure using stored credentials
4. Runs `iam_setup.sh` automatically
5. Confirms deployment

**Secrets required:**
- `AZURE_CREDENTIALS` — Azure service principal credentials
- `AZURE_SUBSCRIPTION_ID` — Your Azure subscription ID


## Challenges and Solutions

| Git Bash converting `/subscriptions/` paths to Windows paths | Added `export MSYS_NO_PATHCONV=1` to all scripts |
| MissingSubscription error on role assignment | Used `az account set` with explicit subscription ID |
| Scripts not found by CI/CD pipeline | Moved all scripts into correct `scripts/` folder |
| GitHub push rejected | Ran `git pull origin main` to sync before pushing |


##  Submission

- **GitHub Repository:** https://github.com/Starbele/iam-project
- **Presentation:** IAM_Presentation.pptx



