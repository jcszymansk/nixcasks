unpackCmdHooks+=(_tryUnpackDmg)
_tryUnpackDmg() {
    if ! [[ "$curSrc" =~ \.[Dd][Mm][Gg]$ ]]; then return 1; fi
    7zz -snld x "$curSrc"
}
