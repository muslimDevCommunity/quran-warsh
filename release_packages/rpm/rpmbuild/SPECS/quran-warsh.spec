Name:           quran-warsh
Version:        %{?version}
Release:        1%{?dist}
Summary:        tajweed quran in the warsh 'ورش' reading
License:        MIT
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  zig, CSFML-devel
Requires: CSFML

%description
tajweed quran in the warsh (ورش) reading

%prep
%setup -q

%build
zig build --release=safe

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/usr/share/quran-warsh
install -m 0755 zig-out/bin/quran-warsh %{buildroot}/usr/local/bin/quran-warsh
cp zig-out/bin/res/*.jpg %{buildroot}/usr/share/quran-warsh
mkdir -p %{buildroot}/usr/share/applications/
mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable/apps
install -m 0644 src/quran-warsh.desktop %{buildroot}/usr/share/applications/quran-warsh.desktop
install -m 0644 src/quran-warsh.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/quran-warsh.svg


%files
/usr/local/bin/quran-warsh
/usr/share/quran-warsh
/usr/share/applications/quran-warsh.desktop
/usr/share/icons/hicolor/scalable/apps/quran-warsh.svg

%changelog
# * completed building alhamdo li Allah 

