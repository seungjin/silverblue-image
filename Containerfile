ARG FEDORA_MAJOR_VERSION=38

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}

RUN wget https://copr.fedorainfracloud.org/coprs/th3-s4lm0n/leftwm/repo/fedora-${FEDORA_MAJOR_VERSION}/th3-s4lm0n-leftwm-fedora-38.repo \
    -q -O /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:th3-s4lm0n:leftwm.repo

RUN wget https://copr.fedorainfracloud.org/coprs/jerrycasiano/FontManager/repo/fedora-${FEDORA_MAJOR_VERSION}/jerrycasiano-FontManager-fedora-${FEDORA_MAJOR_VERSION}.repo \
    -q -O /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:jnrrycasiano:FontManager.repo

RUN rpm-ostree install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN mkdir -p /var/lib && ln -s /usr/lib/alternatives /var/lib/alternatives

COPY pkgs /tmp/pkgs
RUN rpm-ostree install $(cat /tmp/pkgs)
RUN ansible-galaxy collection install community.general

RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer
    
# nvidia driver 
#nvidia non-free driver
#RUN rpm-ostree install kmod-nvidia xorg-x11-drv-nvidia 
#RUN  rpm-ostree kargs --append=rd.driver.blacklist=nouveau \
#    --append=modprobe.blacklist=nouveau \
#    --append=nvidia-drm.modeset=1
#RUN rm -fr /var/log/akmods/akmods.log

#RUN systemctl enable vnstat.service
#RUN systemctl enable sshd.service
#RUN semanage port -a -t ssh_port_t -p tcp 432
#RUN systemctl enable firewalld 
#RUN firewall-cmd --permanent --zone=public --add-port=432/tcp

COPY usr /usr
RUN mkdir /usr/lib/vagrant

#RUN mv /usr/share/ibus/component/hangul.xml /usr/share/ibus/component/hangul.xml.original
#COPY usr/share/ibus/component/hangul.xml /usr/share/ibus/component/hangul.xml 

RUN rm -fr /var/lib

RUN rpm-ostree cleanup -m && ostree container commit


