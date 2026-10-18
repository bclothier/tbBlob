# tools\

Scripts and files for building and shipping tbBlob, as opposed to testing it (`tests\`).

| Path | Purpose |
|---|---|
| `package.ps1` | Builds the distributable folder `dist\tbBlob\`: `tbBlob.exe`, the bundled CastXML with its resource headers, licences, README and docs. It then verifies the package (`tbBlob --check` must pass using the bundled CastXML, a generation from the package must work, and the docs must cover every option and exit code). `-Out <folder>` packages elsewhere; `-SelfTest` packages to a temp folder, verifies, and deletes it (`tests\run-all.ps1` does this). See [docs\SETUP.md](../docs/SETUP.md#deploying) |
| `impexp\` | The twinBASIC import/export tool. `impexp.twinproj` is its source; `Build\tBImportExport_win64.exe` is the built tool, kept in git because building it needs the IDE. It turns a folder (`Settings` + `Sources\`) into a `.twinproj` and back. `tests\import.ps1` uses it to rebuild `tbBlob.twinproj` from `Source\`, the harness and spike build scripts use it to assemble their projects, and tbBlob's integration tests use it to check that generated code imports (`Tools.ImportToolPath`). tbBlob itself never needs it (D-047). If you rebuild it, compile `impexp.twinproj` as win64; the output lands in `impexp\Build\`, apart from tbBlob's `Build\` |
| `licenses\LLVM-LICENSE.txt` | LLVM's licence, verbatim from tag `llvmorg-18.1.3`, the Clang version built into the bundled `castxml.exe`. `package.ps1` copies it into the package's `licenses\` (Apache-2.0 requires the text, not a link, when the binary is redistributed; D-047). CastXML's own licence comes from the vcpkg install |

`package.ps1` needs a current `Build\tbBlob_win64.exe` and CastXML installed in `CastXML\` (see
[CastXML\README.md](../CastXML/README.md)). It exits 2 and says what to do if either is missing or
stale.
