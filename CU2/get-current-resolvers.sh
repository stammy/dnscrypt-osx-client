#! /bin/sh

get_interface() {
  route get default | while read line; do    
    case "$line" in
      interface:*) echo $line | sed 's/ *interface: *//' ; exit 0 ;;
      *) ;;
    esac
  done
  exit 1
}

get_hardware_port() {
  wanted_interface="$1"
  networksetup -listallhardwareports | while read line; do
    case "$line" in
      Hardware\ Port:\ *)
        hardware_port=$(echo "$line" | sed 's/ *Hardware Port: *//')  
      ;;
      Device:\ *)
        interface=$(echo "$line" | sed 's/ *Device: *//')
        if [ x"$interface" = x"$wanted_interface" ]; then
          echo $hardware_port
          exit 0
        fi
      ;;
    esac
  done
  exit 1
}

interface=$(get_interface)
hardware_port=$(get_hardware_port "$interface")
name_servers=$(networksetup -getdnsservers "$hardware_port" 2> /dev/null)
case "$name_servers" in
  *any\ DNS\ Servers*)
    name_servers=$(ipconfig getpacket "$interface" 2> /dev/null | fgrep 'domain_name_server' | \
                   sed -e 's/^.*{//' -e 's/,/ /g' -e 's/}//' )
  ;;
esac
echo $name_servers

