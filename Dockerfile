FROM bojobo/heasoft:6.34

ARG version=21.0

LABEL version="${version}" \
      description="Scientific Analysis System (SAS) ${version} https://www.cosmos.esa.int/web/xmm-newton/sas" \
      maintainer="Bojan Todorkov"

USER 0

RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get install -y rsync \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/sas \
    && mkdir -p /var/lib/ccf \
    && chown -R heasoft:heasoft /opt/sas \
    && chown -R heasoft:heasoft /var/lib/ccf

# Use heasoft user from bojobo/heasoft
USER heasoft

# Install needed Python packages
# Already installed packages in bojobo/heasoft: astropy numpy scipy matplotlib setuptools
RUN /opt/conda/bin/conda install requests astroquery -c conda-forge

WORKDIR /opt/sas

# Temporarly rename environment variables from bojobo/heasoft to match the naming scheme needed by SAS
ENV SAS_PERL=${PERL}
ENV SAS_PYTHON=/opt/conda/bin
ADD --chown=heasoft:heasoft https://sasdev-xmm.esac.esa.int/pub/sas/${version}.0/Linux/Ubuntu22.04/sas_${version}.0-Ubuntu22.04.tgz sas.tgz
RUN tar xfz sas.tgz \
    && /bin/bash -c ./install.sh \
    && rm sas.tgz

# Set environment variables needed by SAS
ENV PYTHONPATH=/opt/sas/xmmsas_20230412_1735/lib/python:${PYTHONPATH} \
    LIBRARY_PATH=/opt/sas/xmmsas_20230412_1735/libextra:/opt/sas/xmmsas_20230412_1735/lib \
    LD_LIBRARY_PATH=/opt/sas/xmmsas_20230412_1735/libextra:/opt/sas/xmmsas_20230412_1735/lib:${LD_LIBRARY_PATH} \
    SAS_PATH=/opt/sas/xmmsas_20230412_1735 \
    SAS_DIR=/opt/sas/xmmsas_20230412_1735 \
    PATH=/opt/sas/xmmsas_20230412_1735/binextra:/opt/sas/xmmsas_20230412_1735/bin:/opt/sas/xmmsas_20230412_1735/bin/devel:${PATH} \
    SAS_SUPRESS_WARNING=1 \
    SAS_CCFPATH=/var/lib/ccf

WORKDIR /home/heasoft