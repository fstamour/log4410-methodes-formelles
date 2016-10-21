!/bin/sh -e

SPIN='./spin.exe'
if [ ! -f "$SPIN" ]; then
    SPIN=spin
fi

# -T : Do not indent printf's output
$SPIN -T q1.pml 


