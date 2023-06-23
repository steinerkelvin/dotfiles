# Command for loading encironment variables from file
alias loadenv='export $(grep -v '^#' .env | xargs)'
