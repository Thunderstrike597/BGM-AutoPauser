# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_all

# pycaw/comtypes and pystray both do some dynamic importing under the hood
# (comtypes builds COM interface glue at runtime; pystray picks its Windows
# backend via importlib) that PyInstaller's static analysis can miss, so
# these are collected explicitly rather than relying on autodetection.
hiddenimports = ['pystray._win32', 'comtypes.stream']
# The 'icon=' arg below only stamps the .exe's own file icon (Explorer,
# taskbar) - it does NOT copy the file anywhere the running app can read it.
# The tray icon is loaded at runtime via resource_path("assets", "icon.ico")
# in auto_pauser.py, so the same file needs to also ship as a data file -
# ends up at dist/BGM-AutoPauser/_internal/assets/icon.ico.
datas = [('assets/icon.ico', 'assets')]
binaries = []

for pkg in ('comtypes', 'pycaw'):
    d, b, h = collect_all(pkg)
    datas += d
    binaries += b
    hiddenimports += h

a = Analysis(
    ['auto_pauser.py'],
    pathex=[],
    binaries=binaries,
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='BGM-AutoPauser',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    # UPX compresses every bundled DLL, which trades a smaller dist folder
    # for CPU time spent decompressing each one at every startup - with this
    # many bundled DLLs (comtypes, pycaw, tkinter/Tcl-Tk, Pillow all pulled
    # in above), that adds up. Set to True if the smaller folder matters
    # more than shaving startup time.
    upx=False,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['assets/icon.ico'],
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=False,
    upx_exclude=[],
    name='BGM-AutoPauser',
)
