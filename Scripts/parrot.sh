PARROT=$PROJECT_DIR/Tools/Parrot
SOURCE=$PROJECT_DIR/Sources
TESTS=$PROJECT_DIR/Tests

if [ -f "$PARROT" ]; then
echo "💚 Running Parrot - SQUAAWWWKKKK 💚"
$PARROT $SOURCE $TESTS || exit 0
else
echo "warning: ⚠️ ./Scripts/install-tools.sh to enable Parrot"
fi
