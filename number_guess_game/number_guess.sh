#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Check database for user
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME';")

if [[ -z $USER_DATA ]]
then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME');")
else
  # Existing user
  echo "$USER_DATA" | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Secret number logic
SECRET=$(( $RANDOM % 1000 + 1))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS
  (( GUESS_COUNT++ ))

  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -eq $SECRET ]]
  then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET. Nice job!"
    break
  elif [[ $GUESS -gt $SECRET ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# Update Database
UPDATE_GAME=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME';")
CURRENT_BEST=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")

if [[ -z $CURRENT_BEST || $GUESS_COUNT -lt $CURRENT_BEST ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username='$USERNAME';")
fi