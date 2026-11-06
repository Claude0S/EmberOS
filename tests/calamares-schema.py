#!/usr/bin/env python3
"""Validate Ember's Calamares module configs against the official schemas
shipped in the Calamares source tree (src/modules/<m>/<m>.schema.yaml)."""
import glob, os, sys
import yaml, jsonschema

src = sys.argv[1]            # extracted calamares source dir
ours = sys.argv[2]           # profile/airootfs/etc/calamares
bad = 0
for conf in sorted(glob.glob(os.path.join(ours, "modules", "*.conf"))):
    name = os.path.basename(conf)[:-5]
    module = name.split("_")[0]          # shellprocess_ember -> shellprocess
    schema = os.path.join(src, "src", "modules", module, f"{module}.schema.yaml")
    data = yaml.safe_load(open(conf)) or {}
    if not os.path.exists(schema):
        print(f"--   {name}: no schema in Calamares (skipped)")
        continue
    sch = yaml.safe_load(open(schema))
    try:
        jsonschema.validate(data, sch)
        print(f"OK   {name}")
    except jsonschema.ValidationError as e:
        bad += 1
        path = "/".join(str(p) for p in e.absolute_path)
        print(f"BAD  {name}: {path}: {e.message}")
    # unknown top-level keys (typos / removed options)
    props = (sch.get("properties") or {}).keys()
    for k in data:
        if props and k not in props:
            print(f"WARN {name}: key '{k}' not in schema")
sys.exit(1 if bad else 0)
