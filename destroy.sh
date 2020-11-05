#!/bin/bash

read -t 30 -p "DESTROY THIS SERVER?(y/N)" input
case $input in
	[yY][eE][sS]|[yY])
	docker-compose down --rmi local
;;

	[nN][oO]|[nN])
;;

*)
exit 0
;;
esac
