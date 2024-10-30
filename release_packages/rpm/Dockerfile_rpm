# بسم الله الرحمن الرحيم
# la ilaha illa Allah Mohammed rassoul Allah

FROM fedora

RUN echo 'Y' | dnf install rpm-build
RUN echo 'Y' | dnf install CSFML-devel
RUN echo 'Y' | dnf install zig

COPY ./rpmbuild /root/rpmbuild
# COPY quran-warsh-1.0.0.tar.gz rpmbuild/SOURCES

ARG VERSION

RUN rpmbuild -ba --define "version ${VERSION}" /root/rpmbuild/SPECS/quran-warsh.spec

# RUN rm /root/rpmbuild/RPMS/x86_64/quran-warsh-debug*

CMD ["echo", "thanks to Allah"]

