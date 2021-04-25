docker build -q -t ei .
docker run --rm --name ei -d -p 8080:8080 ei

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":0,"state":{"a":242,"b":0,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":true,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":0,"interruptsEnabled":false}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":0,"state":{"a":242,"b":0,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":true,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":4,"interruptsEnabled":true}}'

docker kill ei

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mEI Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mEI Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi