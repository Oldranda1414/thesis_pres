set quiet

# List available recipies
default:
  just --list --list-heading $'Available commands:\n'

# Build and open the slides
[no-exit-message]
slides:
  open slides.pdf &
  marp slides.md --pdf --output slides.pdf -w --allow-local-files
