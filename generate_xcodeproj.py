#!/usr/bin/env python3
"""
Generate a valid FirstStep.xcodeproj/project.pbxproj from scratch.

This script creates a minimal but complete Xcode project file that:
- Defines a single iOS app target (FirstStepApp)
- Wires all Swift source files from FirstStep/
- References Info.plist and entitlements
- Configures HealthKit capability
- Sets deployment target to iOS 17.0

Run: python3 generate_xcodeproj.py
"""

import os
import hashlib
import pathlib
import re

# ─── Helpers ───────────────────────────────────────────────────────────────────

_used_ids = set()

def make_id(seed: str) -> str:
    """Generate a unique 24-char uppercase hex ID deterministically from a seed."""
    h = hashlib.md5(seed.encode()).hexdigest().upper()[:24]
    while h in _used_ids:
        seed += "_"
        h = hashlib.md5(seed.encode()).hexdigest().upper()[:24]
    _used_ids.add(h)
    return h

def isa_quote(s: str) -> str:
    """Quote a string for pbxproj if it contains special chars."""
    if re.match(r'^[A-Za-z0-9_./$]+$', s):
        return s
    return f'"{s}"'

# ─── Project root ─────────────────────────────────────────────────────────────

ROOT = pathlib.Path(__file__).parent.resolve()
PROJ_DIR = ROOT / "FirstStep.xcodeproj"
PROJ_DIR.mkdir(exist_ok=True)

# ─── Collect source files ─────────────────────────────────────────────────────

def collect_swift_files(directory: str) -> list:
    """Collect all .swift files under a directory, relative to ROOT."""
    result = []
    base = ROOT / directory
    if not base.exists():
        return result
    for f in sorted(base.rglob("*.swift")):
        result.append(str(f.relative_to(ROOT)))
    return result

ios_sources = collect_swift_files("FirstStep")

print(f"iOS sources: {len(ios_sources)} files")

# ─── Generate IDs for every object ────────────────────────────────────────────

# Project-level
PROJECT_ID = make_id("project")
MAIN_GROUP_ID = make_id("mainGroup")
PRODUCTS_GROUP_ID = make_id("productsGroup")
FRAMEWORKS_GROUP_ID = make_id("frameworksGroup")

# iOS target
IOS_TARGET_ID = make_id("target_ios")
IOS_PRODUCT_ID = make_id("product_ios")
IOS_SOURCES_PHASE_ID = make_id("sources_phase_ios")
IOS_FRAMEWORKS_PHASE_ID = make_id("frameworks_phase_ios")
IOS_DEBUG_ID = make_id("buildconfig_ios_debug")
IOS_RELEASE_ID = make_id("buildconfig_ios_release")
IOS_CONFIGLIST_ID = make_id("configlist_ios")
IOS_HEALTHKIT_REF_ID = make_id("healthkit_framework_ios")
IOS_HEALTHKIT_BUILD_ID = make_id("healthkit_build_ios")

# Project-level build configs
PROJ_DEBUG_ID = make_id("buildconfig_proj_debug")
PROJ_RELEASE_ID = make_id("buildconfig_proj_release")
PROJ_CONFIGLIST_ID = make_id("configlist_proj")

# File references and build files for sources
file_refs = {}  # path -> ref_id
build_files_ios = {}  # path -> build_file_id

for path in ios_sources:
    file_refs[path] = make_id(f"fileref_{path}")

for path in ios_sources:
    build_files_ios[path] = make_id(f"buildfile_ios_{path}")

# Group IDs for directory structure
group_ids = {}
all_dirs = set()
for path in ios_sources:
    parts = pathlib.Path(path).parts
    for i in range(1, len(parts)):
        all_dirs.add("/".join(parts[:i]))

for d in sorted(all_dirs):
    group_ids[d] = make_id(f"group_{d}")

# Ensure top-level source directory is a group
if "FirstStep" not in group_ids:
    group_ids["FirstStep"] = make_id("group_FirstStep")

# Info.plist and entitlements file references
INFO_PLIST_REF = make_id("fileref_info_ios")
ENTITLEMENTS_REF = make_id("fileref_entitlements_ios")

# ─── Build the pbxproj content ────────────────────────────────────────────────

lines = []

def w(line=""):
    lines.append(line)

w("// !$*UTF8*$!")
w("{")
w("\tarchiveVersion = 1;")
w("\tclasses = {")
w("\t};")
w("\tobjectVersion = 56;")
w("\tobjects = {")
w("")

# ─── PBXBuildFile ──────────────────────────────────────────────────────────────
w("/* Begin PBXBuildFile section */")
for path, bid in sorted(build_files_ios.items()):
    fname = pathlib.Path(path).name
    w(f"\t\t{bid} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[path]} /* {fname} */; }};")
# HealthKit framework build file
w(f"\t\t{IOS_HEALTHKIT_BUILD_ID} /* HealthKit.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {IOS_HEALTHKIT_REF_ID} /* HealthKit.framework */; }};")
w("/* End PBXBuildFile section */")
w("")

# ─── PBXFileReference ─────────────────────────────────────────────────────────
w("/* Begin PBXFileReference section */")
# Product reference
w(f'\t\t{IOS_PRODUCT_ID} /* First Step.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "First Step.app"; sourceTree = BUILT_PRODUCTS_DIR; }};')

# Source file references
for path, ref_id in sorted(file_refs.items()):
    fname = pathlib.Path(path).name
    w(f"\t\t{ref_id} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {isa_quote(fname)}; sourceTree = \"<group>\"; }};")

# Info.plist reference
w(f'\t\t{INFO_PLIST_REF} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')

# Entitlements reference
w(f'\t\t{ENTITLEMENTS_REF} /* FirstStep.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = FirstStep.entitlements; sourceTree = "<group>"; }};')

# HealthKit framework reference
w(f'\t\t{IOS_HEALTHKIT_REF_ID} /* HealthKit.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = HealthKit.framework; path = System/Library/Frameworks/HealthKit.framework; sourceTree = SDKROOT; }};')
w("/* End PBXFileReference section */")
w("")

# ─── PBXFrameworksBuildPhase ──────────────────────────────────────────────────
w("/* Begin PBXFrameworksBuildPhase section */")
w(f"\t\t{IOS_FRAMEWORKS_PHASE_ID} /* Frameworks */ = {{")
w("\t\t\tisa = PBXFrameworksBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
w(f"\t\t\t\t{IOS_HEALTHKIT_BUILD_ID} /* HealthKit.framework in Frameworks */,")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")
w("/* End PBXFrameworksBuildPhase section */")
w("")

# ─── PBXGroup ─────────────────────────────────────────────────────────────────
w("/* Begin PBXGroup section */")

# Main group (project root)
w(f"\t\t{MAIN_GROUP_ID} = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{group_ids['FirstStep']} /* FirstStep */,")
w(f"\t\t\t\t{FRAMEWORKS_GROUP_ID} /* Frameworks */,")
w(f"\t\t\t\t{PRODUCTS_GROUP_ID} /* Products */,")
w("\t\t\t);")
w("\t\t\tsourceTree = \"<group>\";")
w("\t\t};")

# Products group
w(f"\t\t{PRODUCTS_GROUP_ID} /* Products */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f'\t\t\t\t{IOS_PRODUCT_ID} /* First Step.app */,')
w("\t\t\t);")
w("\t\t\tname = Products;")
w("\t\t\tsourceTree = \"<group>\";")
w("\t\t};")

# Frameworks group
w(f"\t\t{FRAMEWORKS_GROUP_ID} /* Frameworks */ = {{")
w("\t\t\tisa = PBXGroup;")
w("\t\t\tchildren = (")
w(f"\t\t\t\t{IOS_HEALTHKIT_REF_ID} /* HealthKit.framework */,")
w("\t\t\t);")
w("\t\t\tname = Frameworks;")
w("\t\t\tsourceTree = \"<group>\";")
w("\t\t};")

# Build directory groups
def get_children_for_dir(dir_path: str):
    """Return (subdirs, files) that are direct children of dir_path."""
    subdirs = []
    files = []
    prefix = dir_path + "/"

    # Find direct child subdirectories
    for d in sorted(all_dirs):
        if d.startswith(prefix):
            remaining = d[len(prefix):]
            if "/" not in remaining:
                subdirs.append(d)

    # Find direct child files
    for path in sorted(ios_sources):
        parent = str(pathlib.Path(path).parent)
        if parent == dir_path:
            files.append(path)

    return subdirs, files

def emit_group(dir_path: str, extra_children=None):
    name = pathlib.Path(dir_path).name
    subdirs, files = get_children_for_dir(dir_path)
    w(f"\t\t{group_ids[dir_path]} /* {name} */ = {{")
    w("\t\t\tisa = PBXGroup;")
    w("\t\t\tchildren = (")
    for sd in subdirs:
        sname = pathlib.Path(sd).name
        w(f"\t\t\t\t{group_ids[sd]} /* {sname} */,")
    for f in files:
        fname = pathlib.Path(f).name
        w(f"\t\t\t\t{file_refs[f]} /* {fname} */,")
    if extra_children:
        for child in extra_children:
            w(f"\t\t\t\t{child},")
    w("\t\t\t);")
    w(f"\t\t\tpath = {isa_quote(name)};")
    w("\t\t\tsourceTree = \"<group>\";")
    w("\t\t};")

# Emit all groups - FirstStep and its subdirectories
# The App group needs Info.plist and entitlements added
all_group_dirs = ["FirstStep"] + sorted(d for d in all_dirs if d.startswith("FirstStep/"))
for d in all_group_dirs:
    if d == "FirstStep/App":
        # Add Info.plist and entitlements as extra children in App group
        emit_group(d, extra_children=[
            f'{INFO_PLIST_REF} /* Info.plist */',
            f'{ENTITLEMENTS_REF} /* FirstStep.entitlements */',
        ])
    else:
        emit_group(d)

w("/* End PBXGroup section */")
w("")

# ─── PBXNativeTarget ──────────────────────────────────────────────────────────
w("/* Begin PBXNativeTarget section */")
w(f"\t\t{IOS_TARGET_ID} /* FirstStepApp */ = {{")
w("\t\t\tisa = PBXNativeTarget;")
w(f"\t\t\tbuildConfigurationList = {IOS_CONFIGLIST_ID} /* Build configuration list for PBXNativeTarget \"FirstStepApp\" */;")
w("\t\t\tbuildPhases = (")
w(f"\t\t\t\t{IOS_SOURCES_PHASE_ID} /* Sources */,")
w(f"\t\t\t\t{IOS_FRAMEWORKS_PHASE_ID} /* Frameworks */,")
w("\t\t\t);")
w("\t\t\tbuildRules = (")
w("\t\t\t);")
w("\t\t\tdependencies = (")
w("\t\t\t);")
w("\t\t\tname = FirstStepApp;")
w(f'\t\t\tproductName = "First Step";')
w(f"\t\t\tproductReference = {IOS_PRODUCT_ID} /* First Step.app */;")
w("\t\t\tproductType = \"com.apple.product-type.application\";")
w("\t\t};")
w("/* End PBXNativeTarget section */")
w("")

# ─── PBXProject ───────────────────────────────────────────────────────────────
w("/* Begin PBXProject section */")
w(f"\t\t{PROJECT_ID} /* Project object */ = {{")
w("\t\t\tisa = PBXProject;")
w(f"\t\t\tbuildConfigurationList = {PROJ_CONFIGLIST_ID} /* Build configuration list for PBXProject \"FirstStep\" */;")
w("\t\t\tcompatibilityVersion = \"Xcode 14.0\";")
w("\t\t\tdevelopmentRegion = en;")
w("\t\t\thasScannedForEncodings = 0;")
w("\t\t\tknownRegions = (")
w("\t\t\t\ten,")
w("\t\t\t\tBase,")
w("\t\t\t);")
w(f"\t\t\tmainGroup = {MAIN_GROUP_ID};")
w(f"\t\t\tproductRefGroup = {PRODUCTS_GROUP_ID} /* Products */;")
w("\t\t\tprojectDirPath = \"\";")
w("\t\t\tprojectRoot = \"\";")
w("\t\t\ttargets = (")
w(f"\t\t\t\t{IOS_TARGET_ID} /* FirstStepApp */,")
w("\t\t\t);")
w("\t\t};")
w("/* End PBXProject section */")
w("")

# ─── PBXSourcesBuildPhase ─────────────────────────────────────────────────────
w("/* Begin PBXSourcesBuildPhase section */")
w(f"\t\t{IOS_SOURCES_PHASE_ID} /* Sources */ = {{")
w("\t\t\tisa = PBXSourcesBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
for path, bid in sorted(build_files_ios.items()):
    fname = pathlib.Path(path).name
    w(f"\t\t\t\t{bid} /* {fname} in Sources */,")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")
w("/* End PBXSourcesBuildPhase section */")
w("")

# ─── XCBuildConfiguration ────────────────────────────────────────────────────
w("/* Begin XCBuildConfiguration section */")

# Project-level Debug
w(f"\t\t{PROJ_DEBUG_ID} /* Debug */ = {{")
w("\t\t\tisa = XCBuildConfiguration;")
w("\t\t\tbuildSettings = {")
w("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
w("\t\t\t\tCLANG_ANALYZER_NONNULL = YES;")
w("\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;")
w("\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";")
w("\t\t\t\tCLANG_ENABLE_MODULES = YES;")
w("\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;")
w("\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;")
w('\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;')
w('\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_COMMA = YES;')
w('\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;')
w('\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;')
w('\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;')
w('\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;')
w('\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;')
w('\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;')
w('\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;')
w('\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;')
w('\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;')
w('\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;')
w('\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;')
w('\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;')
w('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;')
w('\t\t\t\tCOPY_PHASE_STRIP = NO;')
w('\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
w('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
w('\t\t\t\tENABLE_TESTABILITY = YES;')
w('\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;')
w('\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
w('\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;')
w('\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
w('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (')
w('\t\t\t\t\t"DEBUG=1",')
w('\t\t\t\t\t"$(inherited)",')
w('\t\t\t\t);')
w('\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;')
w('\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;')
w('\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;')
w('\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;')
w('\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;')
w('\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;')
w('\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
w('\t\t\t\tMTL_FAST_MATH = YES;')
w('\t\t\t\tONLY_ACTIVE_ARCH = YES;')
w('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "$(inherited) DEBUG";')
w('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
w('\t\t\t\tSWIFT_VERSION = 5.0;')
w("\t\t\t};")
w("\t\t\tname = Debug;")
w("\t\t};")

# Project-level Release
w(f"\t\t{PROJ_RELEASE_ID} /* Release */ = {{")
w("\t\t\tisa = XCBuildConfiguration;")
w("\t\t\tbuildSettings = {")
w("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
w("\t\t\t\tCLANG_ANALYZER_NONNULL = YES;")
w("\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;")
w("\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";")
w("\t\t\t\tCLANG_ENABLE_MODULES = YES;")
w("\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;")
w("\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;")
w('\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;')
w('\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_COMMA = YES;')
w('\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;')
w('\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;')
w('\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;')
w('\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;')
w('\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;')
w('\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;')
w('\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;')
w('\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;')
w('\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;')
w('\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;')
w('\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;')
w('\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;')
w('\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;')
w('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;')
w('\t\t\t\tCOPY_PHASE_STRIP = NO;')
w('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
w('\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
w('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
w('\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;')
w('\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;')
w('\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;')
w('\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;')
w('\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;')
w('\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;')
w('\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;')
w('\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;')
w('\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;')
w('\t\t\t\tMTL_FAST_MATH = YES;')
w('\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;')
w('\t\t\t\tSWIFT_VERSION = 5.0;')
w("\t\t\t};")
w("\t\t\tname = Release;")
w("\t\t};")

# iOS target Debug
w(f"\t\t{IOS_DEBUG_ID} /* Debug */ = {{")
w("\t\t\tisa = XCBuildConfiguration;")
w("\t\t\tbuildSettings = {")
w('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
w('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
w('\t\t\t\tCODE_SIGN_ENTITLEMENTS = FirstStep/App/FirstStep.entitlements;')
w('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
w('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
w('\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
w('\t\t\t\tINFOPLIST_FILE = FirstStep/App/Info.plist;')
w('\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
w('\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
w('\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
w('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
w('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (')
w('\t\t\t\t\t"$(inherited)",')
w('\t\t\t\t\t"@executable_path/Frameworks",')
w('\t\t\t\t);')
w('\t\t\t\tMARKETING_VERSION = 1.0;')
w('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.firststep.app;')
w('\t\t\t\tPRODUCT_NAME = "First Step";')
w('\t\t\t\tSDKROOT = iphoneos;')
w('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
w('\t\t\t\tSWIFT_VERSION = 5.0;')
w('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
w("\t\t\t};")
w("\t\t\tname = Debug;")
w("\t\t};")

# iOS target Release
w(f"\t\t{IOS_RELEASE_ID} /* Release */ = {{")
w("\t\t\tisa = XCBuildConfiguration;")
w("\t\t\tbuildSettings = {")
w('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
w('\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;')
w('\t\t\t\tCODE_SIGN_ENTITLEMENTS = FirstStep/App/FirstStep.entitlements;')
w('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
w('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
w('\t\t\t\tGENERATE_INFOPLIST_FILE = YES;')
w('\t\t\t\tINFOPLIST_FILE = FirstStep/App/Info.plist;')
w('\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
w('\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
w('\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
w('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";')
w('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
w('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (')
w('\t\t\t\t\t"$(inherited)",')
w('\t\t\t\t\t"@executable_path/Frameworks",')
w('\t\t\t\t);')
w('\t\t\t\tMARKETING_VERSION = 1.0;')
w('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.firststep.app;')
w('\t\t\t\tPRODUCT_NAME = "First Step";')
w('\t\t\t\tSDKROOT = iphoneos;')
w('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
w('\t\t\t\tSWIFT_VERSION = 5.0;')
w('\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";')
w("\t\t\t};")
w("\t\t\tname = Release;")
w("\t\t};")

w("/* End XCBuildConfiguration section */")
w("")

# ─── XCConfigurationList ──────────────────────────────────────────────────────
w("/* Begin XCConfigurationList section */")
w(f'\t\t{PROJ_CONFIGLIST_ID} /* Build configuration list for PBXProject "FirstStep" */ = {{')
w("\t\t\tisa = XCConfigurationList;")
w("\t\t\tbuildConfigurations = (")
w(f"\t\t\t\t{PROJ_DEBUG_ID} /* Debug */,")
w(f"\t\t\t\t{PROJ_RELEASE_ID} /* Release */,")
w("\t\t\t);")
w("\t\t\tdefaultConfigurationIsVisible = 0;")
w("\t\t\tdefaultConfigurationName = Release;")
w("\t\t};")

w(f'\t\t{IOS_CONFIGLIST_ID} /* Build configuration list for PBXNativeTarget "FirstStepApp" */ = {{')
w("\t\t\tisa = XCConfigurationList;")
w("\t\t\tbuildConfigurations = (")
w(f"\t\t\t\t{IOS_DEBUG_ID} /* Debug */,")
w(f"\t\t\t\t{IOS_RELEASE_ID} /* Release */,")
w("\t\t\t);")
w("\t\t\tdefaultConfigurationIsVisible = 0;")
w("\t\t\tdefaultConfigurationName = Release;")
w("\t\t};")

w("/* End XCConfigurationList section */")
w("")

# Close objects and root
w("\t};")
w(f"\trootObject = {PROJECT_ID} /* Project object */;")
w("}")

# ─── Write the file ──────────────────────────────────────────────────────────

pbxproj_path = PROJ_DIR / "project.pbxproj"
with open(pbxproj_path, "w") as f:
    f.write("\n".join(lines) + "\n")

print(f"\nGenerated: {pbxproj_path}")
print(f"Total objects: {len(_used_ids)}")
print(f"iOS target sources: {len(build_files_ios)} files")
print("Done! Open FirstStep.xcodeproj in Xcode.")
