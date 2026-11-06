matugen --version
matugen --help 2>&1 | head -30
matugen image --help 2>&1 | head -40
echo "=== try json"; matugen image .github/x/w.png --json hex --dry-run 2>&1 | head -c 3000; echo
echo "=== try json 2"; matugen image .github/x/w.png -j hex --dry-run 2>&1 | head -c 600; echo
