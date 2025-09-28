# SPDX-FileCopyrightText: 2025 Smooth-E
# SPDX-License-Identifier: GPL-3.0-or-later

Name:       moe.smoothie.seriesfinale

# >> macros
# << macros
%define __provides_exclude_from ^%{_datadir}/.*$
%define __requires_exclude (libpython3*|libpyside2*|libcrypt.*|libffi.*|python3dist|lib.*)

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}

Summary:    SeriesFinale is a TV series browser and tracker application.
Version:    1.5.1
Release:    1
Group:      Applications/Internet
License:    GPLv3
URL:        https://github.com/corecomic/seriesfinale
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
# Requires:   libsailfishapp-launcher
BuildRequires:  pkgconfig(auroraapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
SeriesFinale is a TV series browser and tracker application
Its goal is to help you manage the TV shows you watch regularly and
keep track of the episodes you have seen so far. The shows and episodes
can be retrieved automatically by using the “TheTVDB API” to help you
get to the "series finale" with the least effort.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qmake5  \
    VERSION=%{version} \
    RELEASE=%{release}

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
%{_bindir}/%{name}
%{_libexecdir}/%{name}
%defattr(644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
