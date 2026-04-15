#!/bin/bash

# --- Argument validation ---
PART=$1
ACTION=${2:-up}
MACHINE=$3

case "$PART" in
	p1|p2|p3|bonus) ;;
	*)
		echo "First argument must be p1, p2, p3 or bonus"
		echo "Usage: $0 <p1|p2|p3|bonus> [up|down|halt|destroy|ssh|status] [machine]"
		exit 1
		;;
esac

# --- Vagrant command ---
case "$ACTION" in
	up)      VAGRANT_CMD="up" ;;
	down)    VAGRANT_CMD="halt" ;;
	halt)    VAGRANT_CMD="halt" ;;
	destroy) VAGRANT_CMD="destroy -f" ;;
	ssh)     VAGRANT_CMD="ssh" ;;
	status)  VAGRANT_CMD="status" ;;
	*)
		echo "Unknown action '$ACTION'"
		echo "Valid actions: up, down, halt, destroy, ssh, status"
		exit 1
		;;
esac

# --- Change directory ---
cd "src/$PART" || { echo "Directory src/$PART not found"; exit 1; }

# --- Run vagrant ---
if [ -n "$MACHINE" ]; then
	vagrant $VAGRANT_CMD $MACHINE
else
	vagrant $VAGRANT_CMD
fi
VAGRANT_EXIT=$?

# --- Message ---
if [ "$ACTION" = "up" ] && [ $VAGRANT_EXIT -eq 0 ]; then
	case "$PART" in
		p1)		echo -e "\nConnect to the machines:\n"
				echo -e "  ${0} p1 ssh vzurera-S"
				echo -e "  ${0} p1 ssh vzurera-SW\n";;
		p2)		echo -e "\nOpen Chrome with host rules:"
				echo -e 'google-chrome --host-resolver-rules="MAP app1.com 127.0.0.1, MAP app2.com 127.0.0.1, MAP app3.com 127.0.0.1"\n';;
		p3)		echo -e "\nOpen Chrome with host rules:"
				echo -e 'google-chrome --host-resolver-rules="MAP argocd.local 127.0.0.1, MAP web-app.local 127.0.0.1"\n';;
		bonus)	echo -e "\nOpen Chrome with host rules:"
				echo -e 'google-chrome --host-resolver-rules="MAP gitlab.local 127.0.0.1, MAP argocd.local 127.0.0.1, MAP web-app.local 127.0.0.1"\n';;
	esac
fi
