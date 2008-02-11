BASENAME=$(shell basename `pwd`)_$(shell cat VERSION)_$(shell date '+%Y%m%d')

dist:
	rm -fr /tmp/${BASENAME}
	#find . -type d -name '.svn' | xargs rm -fr
	find /tmp/${BASENAME} -type d -name '.svn'
	cp -pbR . /tmp/${BASENAME}
	tar zcf /tmp/${BASENAME}.tgz -C /tmp ${BASENAME}
	(cd /tmp; zip -qr ${BASENAME}.zip ${BASENAME})
