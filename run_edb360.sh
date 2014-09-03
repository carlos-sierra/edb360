# run_edb360.sh
echo "Start edb360."
ps -ef | grep pmo[n] | grep -v \+ASM | sed 's/.*mon_\(.*\)$/\1/' | while read INST; do
  echo "instance: $INST"

  export ORACLE_SID=$INST
  export ORAENV_ASK=NO
  . oraenv

  sqlplus -s /nolog <<EOF 
  connect / as sysdba

@sql/esp_collect_requirements.sql
@sql/edb360_0a_main.sql T 31

EOF
done
zip -qmT esp_requirements.zip esp_requirements.csv esp_requirements.log
zip -qmT edb360_output.zip esp_requirements.zip edb360_*.zip
echo "End edb360. Output: edb360_output.zip"
