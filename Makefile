DIST=dist/bitmask
NEXT_VERSION = $(shell cat pkg/next-version)
DIST_VERSION = dist/bitmask-$(NEXT_VERSION)/
include pkg/pyinst/build.mk
include pkg/thirdparty/openvpn/build.mk

dev-mail:
	pip install -e '.[mail]'

dev-gui: install_pixelated
	pip install -e '.[gui]'

dev-backend:
	pip install -e '.[backend]'

dev-latest-backend: dev-backend
	pip install -e 'git+https://0xacab.org/leap/leap_pycommon@master#egg=leap.common'
	pip install -e 'git+https://0xacab.org/leap/soledad@master#egg=leap.soledad'

dev-all: install_pixelated
	pip install -e '.[all]'

dev-latest-all: dev-all
	pip install -e 'git+https://0xacab.org/leap/leap_pycommon@master#egg=leap.common'
	pip install -e 'git+https://0xacab.org/leap/soledad@master#egg=leap.soledad'

uninstall:
	pip uninstall leap.bitmask

test:
	tox

test_e2e:
	tests/e2e/e2e-test-mail.sh
	tests/e2e/e2e-test-vpn.sh

install_helpers:
	cp src/leap/bitmask/vpn/helpers/linux/bitmask-root /usr/local/sbin/
	cp src/leap/bitmask/vpn/helpers/linux/se.leap.bitmask.policy /usr/share/polkit-1/actions/

install_pixelated:
	# install pixelated from our repo until assets get packaged.
	pip install requests==2.11.1 whoosh chardet
	pip install pixelated-www pixelated-user-agent --find-links https://downloads.leap.se/libs/pixelated/  

qt-resources:
	pyrcc5 pkg/branding/icons.qrc -o src/leap/bitmask/gui/app_rc.py

doc:
	cd docs && make html

bundle_in_virtualenv:
	pkg/build_bundle_with_venv.sh

bundle_in_docker:
	# needs a docker container called 'mybundle', created with 'make docker_container'
	cat pkg/docker_build | docker run -i -v ~/leap/bitmask-dev:/dist -w /dist -u `id -u` mybundle bash

docker_container:
	cd pkg/docker_bundle && docker build -t mybundle .

clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
