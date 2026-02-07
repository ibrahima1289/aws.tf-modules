import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import List, Tuple

ALLOWED_EXTENSIONS = {".tf", ".md"}
IGNORE_DIR_NAMES = {"examples", "examples-client-side-encryption", ".terraform"}


def find_disallowed_files(modules_root: Path) -> List[Path]:
    disallowed: List[Path] = []
    for root, dirs, files in os.walk(modules_root):
        # prune ignored directories
        dirs[:] = [d for d in dirs if d not in IGNORE_DIR_NAMES]
        for fname in files:
            fpath = Path(root) / fname
            ext = fpath.suffix.lower()
            if ext not in ALLOWED_EXTENSIONS:
                disallowed.append(fpath)
    return disallowed


def run_cmd(cmd: List[str], cwd: Path) -> Tuple[int, str, str]:
    try:
        proc = subprocess.run(cmd, cwd=str(cwd), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return proc.returncode, proc.stdout, proc.stderr
    except FileNotFoundError as e:
        return 127, "", str(e)


def check_terraform_fmt(modules_root: Path) -> Tuple[bool, str]:
    if shutil.which("terraform") is None:
        return False, "Terraform CLI not found; skipping fmt check."
    rc, out, err = run_cmd(["terraform", "fmt", "-check", "-recursive"], modules_root)
    ok = rc == 0
    msg = out if ok else (out + "\n" + err)
    return ok, msg.strip()


def discover_module_dirs(modules_root: Path) -> List[Path]:
    module_dirs: List[Path] = []
    for root, dirs, files in os.walk(modules_root):
        # prune ignored directories
        dirs[:] = [d for d in dirs if d not in IGNORE_DIR_NAMES]
        if any(f.endswith(".tf") for f in files):
            module_dirs.append(Path(root))
    return module_dirs


def validate_module(module_dir: Path) -> Tuple[bool, str]:
    if shutil.which("terraform") is None:
        return False, f"Terraform CLI not found; skipping validate for {module_dir}."
    # Initialize without contacting backends
    rc_init, out_init, err_init = run_cmd(["terraform", "init", "-backend=false", "-input=false"], module_dir)
    # Even if init fails (e.g., missing provider blocks), attempt validate to catch syntax errors
    rc_val, out_val, err_val = run_cmd(["terraform", "validate", "-no-color"], module_dir)
    ok = rc_val == 0
    details = []
    if rc_init != 0:
        details.append(f"init non-zero ({rc_init}):\n{out_init}\n{err_init}".strip())
    details.append((out_val + "\n" + err_val).strip())
    return ok, "\n\n".join([d for d in details if d])


def main() -> int:
    parser = argparse.ArgumentParser(description="Check Terraform module folders for allowed files and formatting/validation")
    parser.add_argument("--root", type=str, default=str(Path(__file__).resolve().parent.parent), help="Repository root containing the modules/ folder (default: repo root)")
    parser.add_argument("--modules-subdir", type=str, default="modules", help="Modules subdirectory relative to root (default: modules)")
    parser.add_argument("--skip-validate", action="store_true", help="Skip terraform validate per module")
    args = parser.parse_args()

    repo_root = Path(args.root).resolve()
    modules_root = repo_root / args.modules_subdir

    if not modules_root.is_dir():
        print(f"ERROR: modules directory not found: {modules_root}")
        return 2

    print(f"Scanning modules under: {modules_root}")

    # Check disallowed files
    disallowed = find_disallowed_files(modules_root)
    if disallowed:
        print("Disallowed files found (only .tf and .md permitted; ignoring 'examples' folders):")
        for p in disallowed:
            print(f" - {p}")
    else:
        print("No disallowed files detected.")

    # Check terraform fmt
    ok_fmt, fmt_msg = check_terraform_fmt(modules_root)
    print("\nTerraform fmt -check -recursive:")
    print(fmt_msg or "(no output)")

    # Validate per module
    ok_validate_all = True
    if not args.skip_validate:
        print("\nRunning terraform validate per module directory:")
        for module_dir in discover_module_dirs(modules_root):
            ok, msg = validate_module(module_dir)
            status = "OK" if ok else "FAILED"
            print(f" - {module_dir}: {status}")
            if msg:
                print(msg)
            ok_validate_all = ok_validate_all and ok
    else:
        print("Skipping terraform validate per --skip-validate.")

    # Exit code summary
    if disallowed:
        print("\nResult: FAIL (disallowed files present)")
        return 3
    if not ok_fmt:
        print("\nResult: FAIL (terraform fmt check failed)")
        return 4
    if not args.skip_validate and not ok_validate_all:
        print("\nResult: FAIL (one or more module validations failed)")
        return 5

    print("\nResult: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
