#!/bin/bash

name="Outside Function"

local_example() {
  local name="Inside Function"
  echo "Inside local_example: $name"
}

global_example() {
  name="Changed Outside"
  echo "Inside global_example: $name"
}

echo "Before local_example: $name"
local_example
echo "After local_example: $name"

echo "Before global_example: $name"
global_example
echo "After global_example: $name"
