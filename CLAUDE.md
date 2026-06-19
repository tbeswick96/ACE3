# CLAUDE.md — ACE3 (UKSF fork)

Advanced Combat Environment 3 — Arma 3 realism overhaul (medical, ballistics, interaction, missile guidance). **UKSF fork of acemod/ACE3, upstream-tracking.** Part of the UKSF modpack stack. Prefix `ace`, mainprefix `z` → `\z\ace\addons\<component>\`. Currently ACE3 3.19.0.

Working branch: **`uksfcustom`**. Remotes: `origin` = `tbeswick96/ACE3`, `upstream` = `acemod/ACE3` (plus contributor remotes `pterolatypus`, `tcvm`).

## Fork status — upstream-tracking, UKSF owns the build

UKSF controls this fork's build and ships it. **Patching ACE source and calling ACE internals is safe — no drift concern** for the UKSF build. BUT this fork **tracks upstream acemod/ACE3**: it gets rebased/merged onto new ACE releases, so keep UKSF edits **rebase-survivable** — minimal, localized diffs against upstream classes (e.g. medical serialization overrides, `missileguidance` multi-seeker / AAM telemetry work), not sweeping rewrites. Always rebase `uksfcustom` onto `upstream`, never reset upstream onto our changes.

## Build

```bash
hemtt build    # release (build.bat)
hemtt dev      # dev PBOs (dev.bat)
hemtt check    # lint
```
~191 addons. Rust extension built via `cargo` (`Cargo.toml`); `ace_x64.dll` committed and bundled via `.hemtt/project.toml [files]`. Translated READMEs are relocated by a HEMTT pre_build hook.

## Key dirs

```
addons/              ~191 components (medical*, ballistics, missileguidance, interaction, arsenal, …)
  compat_*/          per-mod compat patches (RHS, CUP, CFP, GM, CSLA, …)
.hemtt/hooks/        pre_build / post_build / post_release (README VFS moves, etc.)
extension/           Rust extension source
```

## Gotchas

- **Rebase discipline** (above) is the defining constraint — this is the one fork that re-syncs with upstream.
- `ace_x64.dll` is a committed binary bundled by `[files]`, not produced by `hemtt build`; the Rust extension is a separate `cargo` build.
- UKSF aircraft (uksf_air) depend on ACE missile/ammo classes here — air-weapon ammo edits land in this repo (`addons/missile_aim9/`, `missileguidance`). Coordinate with `uksf_air` PROTECTED-class list before touching guidance/ammo.
- Mainprefix `z`, prefix `ace` — config paths `\z\ace\addons\…`.

## Brain & skills

Brain vault (`E:/Workspace/workshop/Brain`, via `mcp__brain__*`):
- `concepts/ace-missileguidance-seeker-params-under-subclass.md`, `concepts/ace-missileguidance-prox-fuze-pattern.md`
- `decisions/ace-missileguidance-route2-in-place-patch.md` — patch base class in place, never duplicate ammo classes
- `work/arma-uksf_air/index.md` (cross-cuts ACE multi-seeker work), `entities/uksf-workspace-layout.md` (fork = "ACE3 fork with UKSF medical serialization overrides"), `entities/arma3-modpack-stack.md`

Skills: `arma-config-syntax`, `arma-config-cache`, `sqf-deep-review`, `sqf-command-lookup`, `arma-dev-test-server`, `uksf-server`.
