#!/bin/bash

file_name='Ballerina.toml' 
export BALLERINA_HOME="/usr/lib/ballerina"


if [ ! -f  "${file_name}" ] ; then
  echo "BALLERINA TOML NOT EXISTS : SET BALLERINA DEFAULT VERSION (2201.7.0) " 
  ballerina_version="2201.7.0" 
  selected_ballerina_dist=22010700 
else
  ref_word="distribution"
  # use grep to find the line containing the reference word
  ref_line=$(grep -n "$ref_word" "$file_name" | cut -d ":" -f 1)

  # extract the desired version from the line
  version=$(sed "${ref_line}q;d" "$file_name" | awk '{print $3}  ')
  ballerina_version=$(echo "$version" | tr -d '"')
  echo "--> BALLERINA TOML VERSION"
  echo ${ballerina_version}
  sanatized_ballerina_version=$(echo $ballerina_version | awk -F'[.]' '{printf("%d%02d%02d\n", $1,$2,$3);}')

  # Check if the value is less than or equal to 2201.3.5
  if [ $((sanatized_ballerina_version)) -le 22010305 ]; then
      echo "SET THE BALLERINA VERSION TO 2201.3.5, ENSUREING THAT ANY DECTECTED VERSION IS LESS THAN OR EQUAL TO 2201.3.5"
      ballerina_version="2201.3.5"
      selected_ballerina_dist=22010305 
  else
    if [ $((sanatized_ballerina_version)) -gt 22010401 ] && [ $((sanatized_ballerina_version)) -le 22010500 ]; then
      echo "SET THE BALLERINA VERSION TO 2201.5.0, ENSUREING THAT ANY DECTECTED VERSION IS GREATER THAN  TO 2201.4.1 AND LESS THAN OR EQUAL TO 2201.5.0 "
      ballerina_version="2201.5.0"
      if [ $((sanatized_ballerina_version)) -eq 22010500 ]; then
        selected_ballerina_dist=22010500 
      else
        selected_ballerina_dist=22010402
      fi
    else
      # Check if the value is greater than or equal to 2201.5.0 and less than or equal to 2201.6.0
      if [ $((sanatized_ballerina_version)) -gt 22010500 ] && [ $((sanatized_ballerina_version)) -le 22010600 ]; then
        echo "SET THE BALLERINA VERSION TO 2201.6.0, ENSUREING THAT ANY DECTECTED VERSION IS GREATER THAN  TO 2201.5.0"
        ballerina_version="2201.6.0"
        selected_ballerina_dist=22010600 
      else

        if [ $((sanatized_ballerina_version)) -gt 22010600 ] ; then
          echo "SET THE BALLERINA VERSION TO 2201.7.0, ENSUREING THAT ANY DECTECTED VERSION IS GREATER THAN  TO 2201.6.0"
          ballerina_version="2201.7.0"
          selected_ballerina_dist=22010700 
        else
          # check support ballerina version exists
          if ! [ -d "${BALLERINA_HOME}/${ballerina_version}" ]  ; then
            echo "SET BALLERINA DEFAULT VERSION (2201.4.1) "
            ballerina_version="2201.4.1"
            selected_ballerina_dist=22010401
          fi
        fi
        selected_ballerina_dist=22010401
      fi
    fi
  fi

fi

export PATH=${BALLERINA_HOME}/${ballerina_version}/bin:$PATH
export BALLERINA_DISTRIBUTION=${selected_ballerina_dist}

echo "BALLERINA COMPILING VERSION"
bal -v
echo "$PATH" >> $GITHUB_PATH
echo "BALLERINA DISTRIBUTION VERSION"
echo $BALLERINA_DISTRIBUTION
echo "BALLERINA_DISTRIBUTION=$BALLERINA_DISTRIBUTION" >> $GITHUB_ENV
