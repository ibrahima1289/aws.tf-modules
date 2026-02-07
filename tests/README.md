# Terraform Modules Test

This test script scans the `modules/` folder to ensure only `.tf` and `.md` files are present (excluding `examples` folders) and checks Terraform formatting and validation.

## Prerequisites
- Python 3.8+
- Terraform CLI installed and on `PATH`

## Install (optional)
No external Python packages are required.

## Run
Windows PowerShell:

```powershell
cd z:\home\abe\github\aws.tf-modules
python .\tests\terraform_module_check.py
```

Options:
- `--root <path>`: repository root (default: parent of `tests/`)
- `--modules-subdir <name>`: modules folder name (default: `modules`)
- `--skip-validate`: skip `terraform validate` per module

Examples:

```powershell
# Full checks
python .\tests\terraform_module_check.py

# Skip validation (formatting only)
python .\tests\terraform_module_check.py --skip-validate
```

## How It Works
- Allowed file types: Enforces that files under `modules/` only use `.tf` and `.md` extensions.
	- Ignores folders named `examples` and `.terraform` anywhere in the tree.
	- Reports any disallowed files with full paths.
- Formatting: Runs `terraform fmt -check -recursive` at the modules root to confirm canonical formatting.
	- Requires Terraform CLI; if missing, the check fails with a clear message.
- Module discovery: Treats any directory containing one or more `.tf` files as a module directory.
- Validation: For each discovered module directory, runs:
	- `terraform init -backend=false -input=false` (no remote backends)
	- `terraform validate -no-color`
	- Collects and prints outputs; a non-zero validate status marks the module as failed.
- Exit codes:
	- `0`: PASS — allowed files only, fmt OK, and all validations OK (unless `--skip-validate`)
	- `2`: modules directory not found
	- `3`: disallowed files present
	- `4`: `terraform fmt -check` failed (or Terraform not found)
	- `5`: one or more module validations failed

## Script Layout
- Main script: [tests/terraform_module_check.py](tests/terraform_module_check.py)
- Requirements: [tests/requirements.txt](tests/requirements.txt) (none required)

## Tips
- To focus only on formatting, use `--skip-validate`.
- For CI, run the script from the repo root after installing Terraform. A simple check step can assert a zero exit code.
