# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-btbuttons

# >> macros
# << macros

Summary:    BTtons
Version:    0.1
Release:    2
Group:      Qt/Qt
License:    GPLv2
URL:        https://www.github.com/jgibbon/harbour-btbuttons
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-btbuttons.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   bluez5-tools
Requires:   bluez5
Requires:   nemo-qml-plugin-dbus-qt5
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5DBus)
BuildRequires:  desktop-file-utils
Conflicts:   bluez

%description
BT Buttons is a really small application to start or stop a program called mpris-proxy.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qmake5 

make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
