# run_edb360.sh
echo "Start edb360."
ps -ef | grep pmo[n] | grep -v \+ASM | sed 's/.*mon_\(.*\)$/\1/' | while read INST; do
  echo "instance: $INST"

  export ORACLE_SID=$INST
  export ORAENV_ASK=NO
  . oraenv

  sqlplus -s /nolog <<EOF 
  connect / as sysdba

@sql/edb360_0a_main.sql T 31

EOF
done
echo "End edb360."