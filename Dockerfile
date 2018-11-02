FROM ruby:2.5-slim

USER root

ENV PACKER_VERSION=1.3.1
ENV TERRAFORM_VERSION=0.11.10
ENV ANSIBLE_VERSION=2.7.0

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./


RUN echo "===> Installing dependencies and tools..." &&\
    apt-get update && \
    apt-get install -y \
        apt-utils \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        openssl \
        ca-certificates \
        git \
        bash \
        wget \
        curl \
        openssh-client \
        openssh-server \
        python3-dev \
        libffi-dev \
        unzip \
        zip \
        openjdk-8-jdk \
        openjdk-8-jre &&\
    \
    pip3 install --upgrade \
      cffi \
      pywinrm \
      virtualenv \
      awscli &&\
    \
    \
    echo "===> Installing Terraform..." &&\
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip &&\
    \
    \
    echo "===> Installing Packer..." &&\
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin &&\
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip &&\
    \
    \
    echo "===> Installing Ansible..."  && \
    pip3 install ansible==${ANSIBLE_VERSION} && \
    \
    \
    echo "===> Creating Jenkins user..."  && \
    ssh-keygen -A &&\
    adduser jenkins &&\
    echo "jenkins:jenkins" | chpasswd &&\
    mkdir -p /var/run/sshd &&\
    \
    \
    echo "===> Package cleanup..." && \
    apt-get clean && \
    apt-get autoremove --purge

RUN echo "===> Installing Test-Kitchen..." && \
    gem install \
    test-kitchen:1.16.0 \
    kitchen-ansible:0.48.8\
    bundler

ADD Gemfile .

RUN bundle install

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
