#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    IDENTIFIER="atomic_number = $1"
  else
    IDENTIFIER="symbol = '$1' OR name = '$1'"
  fi

  DATA=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type FROM elements e JOIN properties p USING(atomic_number) JOIN types t USING(type_id) WHERE $IDENTIFIER")

  if [[ -z $DATA ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$DATA" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL MASS MELTING_POINT BOILING_POINT TYPE
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi