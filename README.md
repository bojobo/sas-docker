# sas-docker
Docker image for Scientific Analysis System (SAS)

After building the image, you'll have to download the CCF. To do that, do the folllowing:

1. Create a temporary container, mount a volume and run bash in this container:
```
docker run -v ccf:/var/lib/ccf --rm -it YOUR-TAG bash
```

2. Download the valid CCF and runu `cifbuild`:
```
rsync -v -a --delete --delete-after --force --include='*.CCF' --exclude='*/' sasdev-xmm.esac.esa.int::XMM_VALID_CCF /var/lib/ccf/ \
&& cd /var/lib/ccf && cifbuild withobservationdate=yes
```