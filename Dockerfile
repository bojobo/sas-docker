FROM bojobo/heasoft:6.34 AS base

ARG version=21.0

USER 0

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y \
    && apt-get install -y rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/sas \
    && mkdir -p /var/lib/ccf \
    && chown -R heasoft:heasoft /opt/sas \
    && chown -R heasoft:heasoft /var/lib/ccf

# Install needed Python packages
# Already installed packages in bojobo/heasoft: astropy numpy scipy matplotlib setuptools
RUN pip install --upgrade pip && \
    pip install requests astroquery

FROM base AS sas_builder

WORKDIR /opt/sas

# Temporarly rename environment variables from bojobo/heasoft to match the naming scheme needed by SAS
ENV SAS_PERL=/usr/bin/perl
ADD --chown=heasoft:heasoft https://sasdev-xmm.esac.esa.int/pub/sas/${version}.0/Linux/Ubuntu22.04/sas_${version}.0-Ubuntu22.04.tgz sas.tgz
RUN tar xfz sas.tgz \
    && /bin/bash -c ./install.sh \
    && rm sas.tgz

FROM base AS final

LABEL version="${version}" \
      description="Scientific Analysis System (SAS) ${version} https://www.cosmos.esa.int/web/xmm-newton/sas" \
      maintainer="Bojan Todorkov"

COPY --from=sas_builder --chown=heasoft:heasoft /opt/sas /opt/sas

# Set environment variables needed by SAS
ENV PYTHONPATH=/opt/sas/xmmsas_20230412_1735/lib/python:${PYTHONPATH} \
    LIBRARY_PATH=/opt/conda/lib:/opt/sas/xmmsas_20230412_1735/libextra:/opt/sas/xmmsas_20230412_1735/lib \
    LD_LIBRARY_PATH=/opt/conda/lib:/opt/sas/xmmsas_20230412_1735/libextra:/opt/sas/xmmsas_20230412_1735/lib:${LD_LIBRARY_PATH} \
    SAS_PATH=/opt/sas/xmmsas_20230412_1735 \
    SAS_DIR=/opt/sas/xmmsas_20230412_1735 \
    PATH=/opt/sas/xmmsas_20230412_1735/binextra:/opt/sas/xmmsas_20230412_1735/bin:/opt/sas/xmmsas_20230412_1735/bin/devel:${PATH} \
    SAS_SUPRESS_WARNING=1 \
    SAS_CCFPATH=/var/lib/ccf

USER heasoft
WORKDIR /home/heasoft
