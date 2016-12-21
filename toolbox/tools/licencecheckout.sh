#!/bin/bash

LMUTIL=/usr/local/bin/lmutil
MATLAB=/opt/matlab/bin/matlab

if [ ! -f $LMUTIL -o ! -f $MATLAB ]; then
  echo "Required binaries for licence checkout not available. Exiting..."
  exit 1
fi

LANG='en_US.UTF-8'
DATUM=$( date '+%d-%b-%Y' -d '14 days' )
LANG='de_DE.UTF-8'

cd /tmp
cat >lizenzen.m <<EOF
license checkout MATLAB;
license checkout Communication_Toolbox;
license checkout Image_Toolbox;
license checkout Optimization_Toolbox;
license checkout Signal_Toolbox;
license checkout Signal_Blocks;
quit;
EOF

$LMUTIL lmborrow MLM $DATUM
$MATLAB -nosplash -nojvm -nodesktop -nodisplay -r lizenzen
$LMUTIL lmborrow -clear
$LMUTIL lmborrow -status

# remove empty license file
FLEXLM=/home/mindstorms/.flexlmborrow
if [ ! -s $FLEXLM ]; then
  rm -f $FLEXLM
fi