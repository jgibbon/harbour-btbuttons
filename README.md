# BTtons (BT Buttons) for Sailfish OS
BTtons is a really small application to easily start or stop mpris-proxy.
This enables control (AVRCP) from bluetooth-connected devices like head phones or car stereos for many existing media players that are already using the MPRIS2 Specification (mostly used for lock screen controls). 
It is meant for devices using Bluez version 5, which for example __excludes the original Jolla Phone and Jolla Tablet__. Please don't try to install it on there.

BTtons depends on the package bluez5-tools (containing mpris-proxy), which will be automatically installed from the official repositories (or any other enabled repository that provides it).

It is meant as a quick and dirty band-aid-solution for inexperienced or lazy users until Jolla finds the time to fix this part of the bluez integration in Sailfish. This means:
 - There is no daemon or autostart. You'll have to manually start it after a reboot (or possibly, after errors).
 - There is no debugging or logging. If you want to debug when mpris-proxy isn't working, you'll have to run that independently from BTtons.
 - Mpris-proxy may misbehave, for example when using flight mode or disabling bluetooth. You _may_ have to restart it if it stops working.

## License

    BTtons (harbour-btbuttons)
    Copyright (C) 2019 John Gibbon

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.