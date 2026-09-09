# Autonomous Engineering & Repository Tracking Protocol

## 1. Operational Pipeline
Every authorized modification or fix must strictly execute through the following operational pipeline:
**Scope Lock → State Inspection → Risk Gate → Minimal Change → Validation → Atomic Commit → Push Verification → Documentation Sync**

---

## 2. Scope Lock
Before modifying any file across the codebase:
- Identify the explicit user-requested objective.
- Identify target repositories, affected components, and files.
- Formulate the expected behavioral change.
- **Do not expand scope opportunistically**: If an adjacent defect or cleanup opportunity is discovered:
  - Record the defect.
  - Do not fix it in the current atomic unit.
  - Continue only if the user explicitly authorizes expanding scope.

---

## 3. Working Tree & State Inspection
- **Inspect Before Modifying**: Run `git status` in target repositories to identify pre-existing working tree state before touching any file.
- **Protect Pre-existing Changes**: Never modify, reset, revert, stash, amend, or commit changes that were not created by the current task unless explicitly authorized.
- **Verified Changes Discipline**: No verified change may remain uncommitted. Never discard, reset, stash, or overwrite unrelated user changes. Unverified experimental modifications must remain isolated.

---

## 4. Risk Gate & Prohibited Operations
Require explicit user authorization before:
- Deleting source files.
- Adding, changing, or deleting Git repository remotes.
- Switching branches or altering tracking branches.
- Force-pushing (`git push -f`) or rewriting Git history.
- Altering partition layouts, block sizes, or storage mount points (`recovery.fstab`, `twrp.flags`).
- Modifying release signing configurations or cryptographic keys.
- Changing recovery HAL interfaces or keymaster crypto configurations.
- Modifying prebuilt kernel binaries (`prebuilt/kernel`, `prebuilt/dtb.img`, `prebuilt/dtbo.img`).
- Performing destructive repository cleanup.
- Initiating any local compilation process when not explicitly authorized.

### Strict Prohibition on Destructive Git Commands
Never run any of the following commands without explicit user authorization:
- `git reset --hard`
- `git clean -fdx`
- `git checkout -- <files>`
- `git restore <files>`
- `git rebase`
- `git commit --amend`

---

## 5. Source Tree vs Generated Artifacts (`out/` & `artifacts/`)
- **`out/` and `artifacts/` are Not Source-of-Truth**: Generated build outputs, flashable ZIPs (`OrangeFox*.zip`), recovery images (`OrangeFox*.img`), and intermediate build objects are ephemeral artifacts and must never be committed or treated as the source of truth.
- **Never Patch Generated Files**: Do not modify generated files (e.g., generated build manifests, unpackaged ramdisks, or intermediate configuration headers) to fix source-level issues. Trace every defect back to its original device tree source or workflow definition.

---

## 6. Recovery Device Tree Architecture
- **Device Tree Isolation**: Makefiles (`BoardConfig.mk`, `device.mk`, `twrp_whyred.mk`, `omni_whyred.mk`, `AndroidProducts.mk`), recovery configs (`vendorsetup.sh`), and recovery ramdisk files (`recovery/root/`) belong exclusively to this repository.
- **Prebuilt Kernel & DTB**: Prebuilt kernel and dtb images are placed under `prebuilt/`. Ensure kernel command lines and boot arguments in `BoardConfig.mk` match the prebuilt 4.19 kernel requirements.
- **OrangeFox Build Flags**: Core OrangeFox variables (`FOX_BUILD_DEVICE`, `OF_DEFAULT_KEYMASTER_VERSION`, `OF_FBE_METADATA_MOUNT_IGNORE`, etc.) must be consistently declared in `vendorsetup.sh` and guarded against undefined shell variable crashes during `build/envsetup.sh`.

---

## 7. Compilation & CI Build Protocol
- **CI / GitHub Actions Workflow**: Recovery builds are primarily executed through GitHub Actions (`.github/workflows/build.yml`) via `gh workflow run`.
- **Environment Setup Guard**: When sourcing Android build scripts (`build/envsetup.sh`), environment variables must be exported before sourcing, and bash strict error handling (`set -e`) must be managed appropriately so that non-zero test commands inside AOSP `envsetup.sh` do not abort the build prematurely.
- **Build Failure Handling**: When compilation is explicitly authorized:
  1. Autonomously diagnose build failures from workflow logs (`gh run view --log-failed <run_id>`).
  2. Apply minimal reproducible fixes in the proper device tree or workflow file.
  3. Continue through recoverable, deterministic failures.
  4. **Avoid Infinite Loops**: Immediately stop and report if a failure is external (runner disk exhaustion, upstream network/sync downtime, missing upstream repository), non-deterministic, introduces destructive risk, or requires user input.

---

## 8. Commit & Push Standards
- **Conventional Commits**: Every commit must strictly follow Conventional Commits specification in English (e.g., `fix(device): ...`, `ci(workflow): ...`, `feat(recovery): ...`, `docs: ...`).
- **No AI Attribution**: Never include `Co-Authored-By`, assistant identifiers, or any AI generation disclosures in commit messages, pull requests, or repository metadata.
- **Atomic Commits**: Separate commits strictly by concern. Never combine workflow changes with device tree configurations or documentation updates unless logically unified.
- **Pre-Commit Inspection (No Blind Commits)**:
  Before committing:
  1. Run `git status`.
  2. Inspect the complete staged diff (`git diff --staged`).
  3. Verify that only intended files are staged.
  4. Run non-compilation validation (syntax checks, lints) when available.
  5. Commit only when the staged diff matches the intended task unit.
- **Push Verification**:
  Before pushing:
  - Verify current branch (`git branch --show-current`).
  - Verify remote URL (`git remote -v`).
  - Verify tracking upstream branch (`main`).
  - Check latest commit (`git log -1 --oneline`).
  - Push only to the verified tracking branch (`main`).
- **Missing Remote Protocol**:
  If a modified repository lacks the required personal remote fork:
  - Stop before pushing.
  - Report the missing remote to the user.
  - Request authorization before creating or changing repository remotes.

---

## 8.1 Remote Branch Hygiene

Personal fork repositories (`kveld9/*`) must keep only branches that represent an active development line or intentionally preserved work.

Obsolete or abandoned remote branches may be removed only after a verification pass confirms that they contain no pending or uniquely preserved work.

Before deleting any remote branch:

1. Fetch and prune remote references.
2. Verify the current branch topology and tracking relationships.
3. Compare the candidate branch against its corresponding active maintenance branch.
4. Identify commits present only on the candidate branch.
5. Confirm that no unique commit contains pending fixes, experiments, recovery points, or other work that must be preserved.
6. Confirm that relevant work is already merged, cherry-picked, superseded, tagged, or otherwise safely preserved.
7. Obtain explicit user authorization before performing the destructive deletion.
8. Delete only the specifically approved obsolete branch.
9. Verify that the remote branch was actually removed and that no unintended refs were affected.

Branches must **not** be deleted merely because they are old, inactive, or no longer checked out locally. Age or inactivity alone is insufficient justification.

The active maintenance branch for each repository must always be preserved unless the user explicitly authorizes a maintenance-branch migration.

Never perform bulk remote branch deletion without first generating and reviewing a branch/commit inventory.

Branch cleanup must not modify, reset, rewrite, or otherwise alter commit history. Deleting a remote branch is a reference cleanup operation and must not be used as a substitute for normal commit, merge, tag, or archival procedures.

When branch cleanup is performed, document:

* branches inspected;
* branches retained and the reason for retention;
* branches approved for deletion;
* branches actually deleted;
* unique commits found on deleted branches;
* any branches requiring manual review.

If a branch contains work whose preservation status cannot be established with confidence, **do not delete it**. Report it for manual review instead.

---

## 9. Repository Topology & Remote Mapping
- **Recovery Device Tree** (`.`):
  - Remote: `origin` (`main`)
  - Scope: OrangeFox / TWRP recovery device tree, makefiles, root ramdisk, vendorsetup, prebuilts, and GitHub Actions build workflow.
- **ROM Workspace Reference** (`../lineageos-whyred`):
  - Scope: Reference LineageOS 21 (Android 14) kernel source (4.19), device configurations, and proprietary blobs for HAL alignment.

---

## 10. Documentation & README Maintenance Policy
- **Synchronize Only Meaningful Changes**: Update `README.md` when repository topology, supported branches, build procedures, patch levels, partition layouts, prerequisites, or release artifacts change.
- **Prevent Documentation Churn**: Do not modify `README.md` for internal bugfixes, code refactorings, or implementation details that do not alter user-facing or documented behavior.
- **Commit Standards**: Documentation updates must be committed with Conventional Commits (e.g., `docs: update README with ...`) in English and pushed to the remote repository.
